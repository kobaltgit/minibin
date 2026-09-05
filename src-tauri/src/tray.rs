use std::sync::atomic::{AtomicBool, Ordering};
use tauri::{
    image::Image,
    menu::{Menu, MenuItem, PredefinedMenuItem},
    tray::{MouseButton, MouseButtonState, TrayIcon, TrayIconBuilder, TrayIconEvent},
    AppHandle, Emitter, Manager, WebviewWindow,
};

use crate::recycle_bin::{empty_recycle_bin, get_recycle_bin_stats, open_desktop_icon_settings, open_recycle_bin};
use crate::settings::load_settings;

static IS_UPDATING: AtomicBool = AtomicBool::new(false);

#[cfg(target_os = "windows")]
pub fn position_flyout(window: &WebviewWindow) {
    use windows_sys::Win32::Foundation::{POINT, RECT};
    use windows_sys::Win32::UI::WindowsAndMessaging::{
        GetCursorPos, SystemParametersInfoW, SPI_GETWORKAREA,
    };

    let mut cursor = POINT { x: 0, y: 0 };
    unsafe {
        GetCursorPos(&mut cursor);
    }

    let mut work_area = RECT {
        left: 0,
        top: 0,
        right: 1920,
        bottom: 1040,
    };
    unsafe {
        SystemParametersInfoW(
            SPI_GETWORKAREA,
            0,
            &mut work_area as *mut _ as *mut std::ffi::c_void,
            0,
        );
    }

    let win_w = 380;
    let win_h = 520;

    // Position window around cursor / tray area, clamped inside work_area
    let mut x = cursor.x - (win_w / 2);
    let mut y = work_area.bottom - win_h - 12;

    if x + win_w > work_area.right - 10 {
        x = work_area.right - win_w - 10;
    }
    if x < work_area.left + 10 {
        x = work_area.left + 10;
    }

    if cursor.y < work_area.bottom / 2 {
        // Taskbar is at top
        y = work_area.top + 12;
    }

    let _ = window.set_position(tauri::Position::Physical(tauri::PhysicalPosition { x, y }));
}

pub fn update_tray_icon(app: &AppHandle) {
    if IS_UPDATING.swap(true, Ordering::SeqCst) {
        return;
    }

    let app_handle = app.clone();
    std::thread::spawn(move || {
        let stats = get_recycle_bin_stats().unwrap_or(crate::recycle_bin::RecycleBinStats {
            total_size_bytes: 0,
            item_count: 0,
            is_empty: true,
            formatted_size: "0 B".into(),
        });

        let settings = load_settings();

        if let Some(tray) = app_handle.tray_by_id("main_tray") {
            let limit_bytes = (settings.alert_threshold_gb as i64) * 1024 * 1024 * 1024;
            let is_alert = settings.alert_threshold_gb > 0 && stats.total_size_bytes >= limit_bytes;

            let tooltip = if settings.language == "en" {
                if stats.is_empty {
                    "Recycle Bin: Empty".to_string()
                } else if is_alert {
                    format!("Recycle Bin: {} files ({}) [OVERFLOW]", stats.item_count, stats.formatted_size)
                } else {
                    format!("Recycle Bin: {} files ({})", stats.item_count, stats.formatted_size)
                }
            } else {
                if stats.is_empty {
                    "Корзина: Пусто".to_string()
                } else if is_alert {
                    format!("Корзина: {} эл. ({}) [ПЕРЕПОЛНЕНА]", stats.item_count, stats.formatted_size)
                } else {
                    format!("Корзина: {} эл. ({})", stats.item_count, stats.formatted_size)
                }
            };
            let _ = tray.set_tooltip(Some(&tooltip));

            // Select icon based on theme (supports custom icons)
            let img = load_tray_icon(&settings, stats.is_empty);
            let _ = tray.set_icon(Some(img));
        }

        IS_UPDATING.store(false, Ordering::SeqCst);
    });
}

fn load_tray_icon(settings: &crate::settings::AppSettings, is_empty: bool) -> Image<'static> {
    if settings.icon_theme == "custom" {
        let custom_path = if is_empty {
            settings.custom_empty_icon.as_deref()
        } else {
            settings.custom_full_icon.as_deref()
        };
        if let Some(path) = custom_path {
            if let Ok(bytes) = std::fs::read(path) {
                if let Ok(img) = Image::from_bytes(&bytes) {
                    return img;
                }
            }
        }
    }

    let default_bytes = get_icon_bytes(&settings.icon_theme, is_empty);
    Image::from_bytes(default_bytes).expect("Failed to load default tray icon")
}

fn get_icon_bytes(theme: &str, is_empty: bool) -> &'static [u8] {
    match (theme, is_empty) {
        ("fluent", true) => include_bytes!("../icons/fluent-empty.png"),
        ("fluent", false) => include_bytes!("../icons/fluent-full.png"),
        ("minimal", true) => include_bytes!("../icons/minimal-empty.png"),
        ("minimal", false) => include_bytes!("../icons/minimal-full.png"),
        ("retro", true) => include_bytes!("../icons/retro-empty.png"),
        ("retro", false) => include_bytes!("../icons/retro-full.png"),
        (_, true) => include_bytes!("../icons/minibin-empty.png"),
        (_, false) => include_bytes!("../icons/minibin-full.png"),
    }
}

pub fn create_tray(app: &AppHandle) -> Result<TrayIcon, tauri::Error> {
    let settings = load_settings();
    let is_en = settings.language == "en";

    let title_item = MenuItem::with_id(
        app,
        "title",
        if is_en { "🗑 MiniBin" } else { "🗑 MiniBin" },
        false,
        None::<&str>,
    )?;

    let open_item = MenuItem::with_id(
        app,
        "open_bin",
        if is_en { "Open Recycle Bin" } else { "Открыть корзину" },
        true,
        None::<&str>,
    )?;

    let empty_item = MenuItem::with_id(
        app,
        "empty_bin",
        if is_en { "Empty Recycle Bin" } else { "Очистить корзину" },
        true,
        None::<&str>,
    )?;

    let flyout_item = MenuItem::with_id(
        app,
        "toggle_flyout",
        if is_en { "Preview & Quick Actions" } else { "Превью и управление" },
        true,
        None::<&str>,
    )?;

    let desktop_settings_item = MenuItem::with_id(
        app,
        "desktop_settings",
        if is_en { "Desktop Icon Settings" } else { "Значки рабочего стола" },
        true,
        None::<&str>,
    )?;

    let settings_item = MenuItem::with_id(
        app,
        "settings",
        if is_en { "Settings..." } else { "Настройки..." },
        true,
        None::<&str>,
    )?;

    let about_item = MenuItem::with_id(
        app,
        "about",
        if is_en { "About MiniBin..." } else { "О программе..." },
        true,
        None::<&str>,
    )?;

    let exit_item = MenuItem::with_id(
        app,
        "exit",
        if is_en { "Exit" } else { "Выход" },
        true,
        None::<&str>,
    )?;

    let sep1 = PredefinedMenuItem::separator(app)?;
    let sep2 = PredefinedMenuItem::separator(app)?;
    let sep3 = PredefinedMenuItem::separator(app)?;

    let menu = Menu::with_items(
        app,
        &[
            &title_item,
            &sep1,
            &flyout_item,
            &open_item,
            &empty_item,
            &sep2,
            &desktop_settings_item,
            &settings_item,
            &about_item,
            &sep3,
            &exit_item,
        ],
    )?;

    let default_icon = load_tray_icon(&settings, true);

    let tray = TrayIconBuilder::with_id("main_tray")
        .icon(default_icon)
        .menu(&menu)
        .show_menu_on_left_click(false)
        .on_menu_event(|app, event| match event.id.as_ref() {
            "open_bin" => {
                let _ = open_recycle_bin();
            }
            "empty_bin" => {
                let s = load_settings();
                let _ = empty_recycle_bin(s.play_sound);
                update_tray_icon(app);
            }
            "toggle_flyout" => {
                if let Some(window) = app.get_webview_window("main") {
                    let _ = window.emit("switch-tab", "overview");
                    position_flyout(&window);
                    let _ = window.show();
                    let _ = window.set_focus();
                }
            }
            "settings" => {
                if let Some(window) = app.get_webview_window("main") {
                    let _ = window.emit("switch-tab", "settings");
                    position_flyout(&window);
                    let _ = window.show();
                    let _ = window.set_focus();
                }
            }
            "about" => {
                if let Some(window) = app.get_webview_window("main") {
                    let _ = window.emit("switch-tab", "about");
                    position_flyout(&window);
                    let _ = window.show();
                    let _ = window.set_focus();
                }
            }
            "desktop_settings" => {
                let _ = open_desktop_icon_settings();
            }
            "exit" => {
                app.exit(0);
            }
            _ => {}
        })
        .on_tray_icon_event(|tray, event| {
            let app = tray.app_handle();
            match event {
                TrayIconEvent::Click {
                    button: MouseButton::Left,
                    button_state: MouseButtonState::Up,
                    ..
                } => {
                    let s = load_settings();
                    if s.click_action_lmb == "open_bin" {
                        let _ = open_recycle_bin();
                    } else if let Some(window) = app.get_webview_window("main") {
                        if let Ok(visible) = window.is_visible() {
                            if visible {
                                let _ = window.hide();
                            } else {
                                position_flyout(&window);
                                let _ = window.show();
                                let _ = window.set_focus();
                            }
                        }
                    }
                }
                TrayIconEvent::Click {
                    button: MouseButton::Middle,
                    button_state: MouseButtonState::Up,
                    ..
                } => {
                    let s = load_settings();
                    if s.click_action_mmb == "empty_bin" {
                        let _ = empty_recycle_bin(s.play_sound);
                        update_tray_icon(app);
                    }
                }
                TrayIconEvent::DoubleClick {
                    button: MouseButton::Left,
                    ..
                } => {
                    let s = load_settings();
                    if s.click_action_double == "empty_bin" {
                        let _ = empty_recycle_bin(s.play_sound);
                        update_tray_icon(app);
                    } else {
                        let _ = open_recycle_bin();
                    }
                }
                _ => {}
            }
        })
        .build(app)?;

    Ok(tray)
}
