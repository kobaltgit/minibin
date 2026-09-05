pub mod commands;
pub mod file_dialog;
pub mod recycle_bin;
pub mod settings;
pub mod single_instance;
pub mod tray;
pub mod updater;

use std::time::Duration;
use tauri::WindowEvent;

pub fn run() {
    if single_instance::handle_potential_secondary_instance() {
        return;
    }

    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .setup(|app| {
            single_instance::start_primary_ipc_listener(app.handle().clone());

            tray::create_tray(&app.handle())?;

            let app_h = app.handle().clone();
            std::thread::spawn(move || {
                let mut last_empty = true;
                let mut last_count = 0;
                loop {
                    std::thread::sleep(Duration::from_millis(2500));
                    if let Ok(stats) = recycle_bin::get_recycle_bin_stats() {
                        if stats.is_empty != last_empty || stats.item_count != last_count {
                            last_empty = stats.is_empty;
                            last_count = stats.item_count;
                            tray::update_tray_icon(&app_h);
                        }
                    }
                }
            });

            // Initial icon update
            tray::update_tray_icon(&app.handle());

            // Start background update checker (startup + weekly)
            updater::start_background_updater(app.handle().clone());

            Ok(())
        })
        .on_window_event(|window, event| {
            if let WindowEvent::Focused(false) = event {
                // Auto-close flyout when user clicks outside, like Windows 11 flyouts
                let _ = window.hide();
            }
        })
        .invoke_handler(tauri::generate_handler![
            commands::get_bin_stats,
            commands::get_bin_items,
            commands::empty_bin,
            commands::restore_item,
            commands::delete_item,
            commands::open_bin,
            commands::open_desktop_settings,
            commands::get_settings,
            commands::save_settings,
            commands::close_flyout,
            commands::select_custom_icon,
            commands::reset_custom_icons,
            commands::check_for_updates,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
