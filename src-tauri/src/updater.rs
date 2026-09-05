use serde::{Deserialize, Serialize};
use std::os::windows::process::CommandExt;
use std::process::Command;
use std::time::{SystemTime, UNIX_EPOCH};
use tauri::{AppHandle, Emitter};

use crate::settings::{load_settings, save_settings};

const GITHUB_API_URL: &str = "https://api.github.com/repos/kobaltgit/minibin/releases/latest";
const CURRENT_VERSION: &str = env!("CARGO_PKG_VERSION");
const COOLDOWN_SECONDS: u64 = 3600; // 1 hour cooldown between automatic checks
const WEEKLY_CHECK_SECONDS: u64 = 7 * 24 * 3600; // 7 days

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct UpdateCheckResult {
    pub has_update: bool,
    pub current_version: String,
    pub latest_version: String,
    pub release_url: String,
    pub setup_url: Option<String>,
    pub portable_url: Option<String>,
    pub release_notes: String,
    pub published_at: String,
}

#[derive(Deserialize)]
struct GitHubAsset {
    name: Option<String>,
    browser_download_url: Option<String>,
}

#[derive(Deserialize)]
struct GitHubReleaseResponse {
    tag_name: Option<String>,
    html_url: Option<String>,
    body: Option<String>,
    published_at: Option<String>,
    assets: Option<Vec<GitHubAsset>>,
}

/// Parses semver numbers and compares whether `latest` is strictly newer than `current`.
pub fn is_version_newer(latest: &str, current: &str) -> bool {
    fn parse_version(v: &str) -> Vec<u32> {
        let clean = v.trim().trim_start_matches(|c| c == 'v' || c == 'V');
        let parts: Vec<&str> = clean.split('-').next().unwrap_or(clean).split('.').collect();
        parts.into_iter().filter_map(|p| p.parse::<u32>().ok()).collect()
    }

    let lat_parts = parse_version(latest);
    let cur_parts = parse_version(current);

    let max_len = lat_parts.len().max(cur_parts.len());
    for i in 0..max_len {
        let lat = lat_parts.get(i).copied().unwrap_or(0);
        let cur = cur_parts.get(i).copied().unwrap_or(0);
        if lat > cur {
            return true;
        } else if lat < cur {
            return false;
        }
    }

    false
}

fn get_current_timestamp() -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .map(|d| d.as_secs())
        .unwrap_or(0)
}

/// Queries GitHub Releases API using Windows native PowerShell Invoke-RestMethod.
pub fn query_github_latest_release() -> Result<UpdateCheckResult, String> {
    let script = format!(
        r#"
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
        $OutputEncoding = [System.Text.Encoding]::UTF8;
        $headers = @{{ 'User-Agent' = 'MiniBin-App' }};
        $resp = Invoke-RestMethod -Uri '{}' -Headers $headers -TimeoutSec 10;
        $resp | ConvertTo-Json -Depth 4 -Compress
        "#,
        GITHUB_API_URL
    );

    let output = Command::new("powershell.exe")
        .creation_flags(0x08000000) // CREATE_NO_WINDOW
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", &script])
        .output()
        .map_err(|e| format!("Не удалось выполнить запрос: {}", e))?;

    if !output.status.success() {
        return Err("Ошибка при подключении к GitHub API".into());
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let trimmed = stdout.trim().trim_start_matches('\u{feff}');

    let release: GitHubReleaseResponse = serde_json::from_str(trimmed)
        .map_err(|e| format!("Ошибка разбора ответа GitHub: {}", e))?;

    let latest_tag = release.tag_name.unwrap_or_default();
    let release_url = release.html_url.unwrap_or_else(|| "https://github.com/kobaltgit/minibin/releases".into());
    let release_notes = release.body.unwrap_or_default();
    let published_at = release.published_at.unwrap_or_default();

    let mut setup_url = None;
    let mut portable_url = None;

    if let Some(assets) = release.assets {
        for asset in assets {
            if let (Some(name), Some(url)) = (asset.name, asset.browser_download_url) {
                let name_lower = name.to_lowercase();
                if name_lower.contains("setup") && name_lower.ends_with(".exe") {
                    setup_url = Some(url.clone());
                } else if name_lower.contains("portable") && name_lower.ends_with(".zip") {
                    portable_url = Some(url.clone());
                }
            }
        }
    }

    let has_update = is_version_newer(&latest_tag, CURRENT_VERSION);

    Ok(UpdateCheckResult {
        has_update,
        current_version: CURRENT_VERSION.to_string(),
        latest_version: latest_tag,
        release_url,
        setup_url,
        portable_url,
        release_notes,
        published_at,
    })
}

/// Displays a native Windows Toast notification about an available update.
pub fn show_update_toast(version: &str) {
    let title = "MiniBin — Доступно обновление";
    let body = format!("Вышла новая версия {}. Нажмите, чтобы открыть окно загрузки.", version);

    let script = format!(
        r#"
        [Windows.UI.Notifications.ToastNotificationManager, Windows.UI.Notifications, ContentType = WindowsRuntime] > $null;
        $template = [Windows.UI.Notifications.ToastTemplateType]::ToastText02;
        $xml = [Windows.UI.Notifications.ToastNotificationManager]::GetTemplateContent($template);
        $t = $xml.GetElementsByTagName('text');
        $t.Item(0).AppendChild($xml.CreateTextNode('{}')) > $null;
        $t.Item(1).AppendChild($xml.CreateTextNode('{}')) > $null;
        $toast = [Windows.UI.Notifications.ToastNotification]::new($xml);
        [Windows.UI.Notifications.ToastNotificationManager]::CreateToastNotifier('MiniBin').Show($toast);
        "#,
        title.replace('\'', "''"),
        body.replace('\'', "''")
    );

    let _ = Command::new("powershell.exe")
        .creation_flags(0x08000000)
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", &script])
        .spawn();
}

/// Checks updates respecting cooldown (1 hour) unless `force` is true.
pub fn check_updates_with_cooldown(app: &AppHandle, force: bool) -> Result<UpdateCheckResult, String> {
    let mut settings = load_settings();
    let now = get_current_timestamp();

    if !force {
        if !settings.auto_check_updates {
            return Ok(UpdateCheckResult {
                has_update: false,
                current_version: CURRENT_VERSION.to_string(),
                latest_version: CURRENT_VERSION.to_string(),
                release_url: "https://github.com/kobaltgit/minibin/releases".to_string(),
                setup_url: None,
                portable_url: None,
                release_notes: String::new(),
                published_at: String::new(),
            });
        }

        // Check 1-hour cooldown to protect GitHub API rate limit on frequent restarts
        if settings.last_update_check_time > 0 && now >= settings.last_update_check_time && (now - settings.last_update_check_time) < COOLDOWN_SECONDS {
            return Ok(UpdateCheckResult {
                has_update: false,
                current_version: CURRENT_VERSION.to_string(),
                latest_version: CURRENT_VERSION.to_string(),
                release_url: "https://github.com/kobaltgit/minibin/releases".to_string(),
                setup_url: None,
                portable_url: None,
                release_notes: String::new(),
                published_at: String::new(),
            });
        }
    }

    let result = query_github_latest_release()?;

    // Update settings timestamp
    settings.last_update_check_time = now;

    if result.has_update {
        // Only show Windows toast notification once per release version
        if settings.last_notified_version != result.latest_version {
            show_update_toast(&result.latest_version);
            settings.last_notified_version = result.latest_version.clone();
        }
    }

    let _ = save_settings(&settings);
    let _ = app.emit("update-status", &result);

    Ok(result)
}

/// Spawns background worker thread: checks once 3 seconds after startup, then every 7 days.
pub fn start_background_updater(app: AppHandle) {
    std::thread::spawn(move || {
        // Initial delay after launch
        std::thread::sleep(std::time::Duration::from_secs(3));

        let _ = check_updates_with_cooldown(&app, false);

        loop {
            // Sleep for 1 hour between checks
            std::thread::sleep(std::time::Duration::from_secs(3600));

            let settings = load_settings();
            let now = get_current_timestamp();

            if settings.auto_check_updates && (now >= settings.last_update_check_time) && (now - settings.last_update_check_time >= WEEKLY_CHECK_SECONDS) {
                let _ = check_updates_with_cooldown(&app, false);
            }
        }
    });
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_version_comparison() {
        assert!(is_version_newer("v2.1.0", "2.0.1"));
        assert!(is_version_newer("2.0.2", "2.0.1"));
        assert!(is_version_newer("3.0.0", "2.9.9"));
        assert!(!is_version_newer("2.0.1", "2.0.1"));
        assert!(!is_version_newer("v2.0.0", "2.0.1"));
        assert!(!is_version_newer("1.9.9", "2.0.1"));
    }
}
