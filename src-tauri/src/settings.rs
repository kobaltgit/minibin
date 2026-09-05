use serde::{Deserialize, Serialize};
use std::fs;
use std::path::PathBuf;

fn default_true() -> bool {
    true
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct AppSettings {
    pub language: String,            // "ru" | "en"
    pub theme: String,               // "dark" | "light" | "system"
    pub icon_theme: String,          // "fluent" | "retro" | "minimal" | "original" | "custom"
    pub click_action_lmb: String,    // "toggle_flyout" | "open_bin"
    pub click_action_mmb: String,    // "empty_bin" | "none"
    pub click_action_double: String, // "open_bin" | "empty_bin"
    pub confirm_empty: bool,
    pub play_sound: bool,
    pub autorun: bool,
    pub alert_threshold_gb: u32,     // 0 = disabled, e.g. 5, 10, 20
    pub custom_empty_icon: Option<String>,
    pub custom_full_icon: Option<String>,
    #[serde(default = "default_true")]
    pub auto_check_updates: bool,
    #[serde(default)]
    pub last_update_check_time: u64,
    #[serde(default)]
    pub last_notified_version: String,
}

impl Default for AppSettings {
    fn default() -> Self {
        Self {
            language: "ru".to_string(),
            theme: "dark".to_string(),
            icon_theme: "fluent".to_string(),
            click_action_lmb: "toggle_flyout".to_string(),
            click_action_mmb: "empty_bin".to_string(),
            click_action_double: "open_bin".to_string(),
            confirm_empty: false,
            play_sound: true,
            autorun: true,
            alert_threshold_gb: 10,
            custom_empty_icon: None,
            custom_full_icon: None,
            auto_check_updates: true,
            last_update_check_time: 0,
            last_notified_version: String::new(),
        }
    }
}

pub fn get_app_dir() -> PathBuf {
    if let Ok(mut exe_dir) = std::env::current_exe() {
        exe_dir.pop();
        if exe_dir.join("portable.txt").exists()
            || exe_dir.join("portable").exists()
            || exe_dir.join("settings.json").exists()
        {
            return exe_dir;
        }
    }

    let base = std::env::var("APPDATA")
        .map(PathBuf::from)
        .unwrap_or_else(|_| PathBuf::from("."));
    let dir = base.join("MiniBin");
    let _ = fs::create_dir_all(&dir);
    dir
}

pub fn get_settings_path() -> PathBuf {
    get_app_dir().join("settings.json")
}

pub fn load_settings() -> AppSettings {
    let path = get_settings_path();
    if let Ok(content) = fs::read_to_string(&path) {
        if let Ok(settings) = serde_json::from_str::<AppSettings>(&content) {
            return settings;
        }
    }
    let default_settings = AppSettings::default();
    let _ = save_settings(&default_settings);
    default_settings
}

pub fn save_settings(settings: &AppSettings) -> Result<(), String> {
    let path = get_settings_path();
    let json = serde_json::to_string_pretty(settings).map_err(|e| e.to_string())?;
    fs::write(&path, json).map_err(|e| e.to_string())?;

    // Update Windows autorun registry
    #[cfg(target_os = "windows")]
    {
        use winreg::enums::{HKEY_CURRENT_USER, KEY_READ, KEY_WRITE};
        use winreg::RegKey;

        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        if let Ok(run_key) = hkcu.open_subkey_with_flags(
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            KEY_READ | KEY_WRITE,
        ) {
            if settings.autorun {
                if let Ok(current_exe) = std::env::current_exe() {
                    let exe_str = format!("\"{}\"", current_exe.to_string_lossy());
                    let _ = run_key.set_value("MiniBin", &exe_str);
                }
            } else {
                let _ = run_key.delete_value("MiniBin");
            }
        }
    }

    Ok(())
}
