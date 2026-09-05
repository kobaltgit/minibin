use tauri::{AppHandle, Manager};

use crate::recycle_bin::{
    empty_recycle_bin as empty_bin_impl, get_recycle_bin_stats, list_recycle_bin_items,
    open_desktop_icon_settings as open_desktop_settings_impl, open_recycle_bin as open_bin_impl,
    restore_recycle_bin_item, delete_recycle_bin_item, RecycleBinItem, RecycleBinStats,
};
use crate::settings::{load_settings, save_settings as save_settings_impl, AppSettings};
use crate::tray::update_tray_icon;

#[tauri::command]
pub fn get_bin_stats() -> Result<RecycleBinStats, String> {
    get_recycle_bin_stats()
}

#[tauri::command]
pub async fn get_bin_items() -> Result<Vec<RecycleBinItem>, String> {
    tauri::async_runtime::spawn_blocking(list_recycle_bin_items)
        .await
        .map_err(|e| e.to_string())?
}

#[tauri::command]
pub async fn empty_bin(app: AppHandle) -> Result<(), String> {
    let settings = load_settings();
    tauri::async_runtime::spawn_blocking(move || {
        empty_bin_impl(settings.play_sound)?;
        Ok::<(), String>(())
    })
    .await
    .map_err(|e| e.to_string())??;

    update_tray_icon(&app);
    Ok(())
}

#[tauri::command]
pub async fn restore_item(item_id: String, app: AppHandle) -> Result<(), String> {
    let id_clone = item_id.clone();
    tauri::async_runtime::spawn_blocking(move || {
        restore_recycle_bin_item(&id_clone)
    })
    .await
    .map_err(|e| e.to_string())??;

    update_tray_icon(&app);
    Ok(())
}

#[tauri::command]
pub async fn delete_item(item_id: String, app: AppHandle) -> Result<(), String> {
    let id_clone = item_id.clone();
    tauri::async_runtime::spawn_blocking(move || {
        delete_recycle_bin_item(&id_clone)
    })
    .await
    .map_err(|e| e.to_string())??;

    update_tray_icon(&app);
    Ok(())
}

#[tauri::command]
pub fn open_bin() -> Result<(), String> {
    open_bin_impl()
}

#[tauri::command]
pub fn open_desktop_settings() -> Result<(), String> {
    open_desktop_settings_impl()
}

#[tauri::command]
pub fn get_settings() -> Result<AppSettings, String> {
    Ok(load_settings())
}

#[tauri::command]
pub fn save_settings(settings: AppSettings, app: AppHandle) -> Result<(), String> {
    save_settings_impl(&settings)?;
    update_tray_icon(&app);
    Ok(())
}

#[tauri::command]
pub fn close_flyout(app: AppHandle) -> Result<(), String> {
    if let Some(window) = app.get_webview_window("main") {
        let _ = window.hide();
    }
    Ok(())
}

fn get_custom_icons_dir() -> std::path::PathBuf {
    let dir = crate::settings::get_app_dir().join("custom_icons");
    let _ = std::fs::create_dir_all(&dir);
    dir
}

#[tauri::command]
pub fn select_custom_icon(target: String, app: AppHandle) -> Result<Option<String>, String> {
    let selected = crate::file_dialog::pick_image_file();
    if let Some(src_path) = selected {
        let bytes = std::fs::read(&src_path).map_err(|e| format!("Не удалось прочитать файл: {}", e))?;

        let img = match image::load_from_memory(&bytes) {
            Ok(im) => im,
            Err(e) => return Err(format!("Не удалось декодировать изображение: {}", e)),
        };

        let rgba = if img.width() > 128 || img.height() > 128 {
            image::imageops::resize(&img.to_rgba8(), 64, 64, image::imageops::FilterType::Lanczos3)
        } else {
            img.to_rgba8()
        };

        let custom_dir = get_custom_icons_dir();
        let file_name = if target == "empty" { "custom_empty.png" } else { "custom_full.png" };
        let dest_path = custom_dir.join(file_name);

        rgba.save_with_format(&dest_path, image::ImageFormat::Png)
            .map_err(|e| format!("Не удалось сохранить иконку: {}", e))?;

        let mut settings = load_settings();
        let path_str = dest_path.to_string_lossy().to_string();
        if target == "empty" {
            settings.custom_empty_icon = Some(path_str.clone());
        } else {
            settings.custom_full_icon = Some(path_str.clone());
        }
        settings.icon_theme = "custom".to_string();
        save_settings_impl(&settings)?;
        update_tray_icon(&app);

        Ok(Some(path_str))
    } else {
        Ok(None)
    }
}

#[tauri::command]
pub fn reset_custom_icons(app: AppHandle) -> Result<(), String> {
    let mut settings = load_settings();
    settings.custom_empty_icon = None;
    settings.custom_full_icon = None;
    settings.icon_theme = "fluent".to_string();
    save_settings_impl(&settings)?;
    update_tray_icon(&app);
    Ok(())
}

