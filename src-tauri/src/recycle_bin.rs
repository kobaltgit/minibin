use serde::{Deserialize, Serialize};
use std::os::windows::process::CommandExt;
use std::process::Command;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecycleBinStats {
    pub total_size_bytes: i64,
    pub item_count: i64,
    pub is_empty: bool,
    pub formatted_size: String,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct RecycleBinItem {
    pub id: String,
    pub name: String,
    pub original_path: String,
    pub date_deleted: String,
    pub size: i64,
    pub formatted_size: String,
}

#[repr(C)]
struct SHQUERYRBINFO {
    cb_size: u32,
    i64_size: i64,
    i64_num_items: i64,
}

extern "system" {
    fn SHQueryRecycleBinW(pszRootPath: *const u16, pSHQueryRBInfo: *mut SHQUERYRBINFO) -> i32;
    fn SHEmptyRecycleBinW(hwnd: *mut std::ffi::c_void, pszRootPath: *const u16, dwFlags: u32) -> i32;
    fn SHChangeNotify(wEventId: i32, uFlags: u32, dwItem1: *const std::ffi::c_void, dwItem2: *const std::ffi::c_void);
}

pub fn format_bytes(bytes: i64) -> String {
    if bytes <= 0 {
        return "0 B".to_string();
    }
    const UNITS: &[&str] = &["B", "KB", "MB", "GB", "TB"];
    let mut size = bytes as f64;
    let mut unit_idx = 0;
    while size >= 1024.0 && unit_idx < UNITS.len() - 1 {
        size /= 1024.0;
        unit_idx += 1;
    }
    if unit_idx == 0 {
        format!("{} {}", bytes, UNITS[unit_idx])
    } else {
        format!("{:.1} {}", size, UNITS[unit_idx])
    }
}

pub fn get_recycle_bin_stats() -> Result<RecycleBinStats, String> {
    let mut info = SHQUERYRBINFO {
        cb_size: std::mem::size_of::<SHQUERYRBINFO>() as u32,
        i64_size: 0,
        i64_num_items: 0,
    };

    let result = unsafe { SHQueryRecycleBinW(std::ptr::null(), &mut info) };
    if result != 0 {
        return Err(format!("SHQueryRecycleBinW failed with code {}", result));
    }

    Ok(RecycleBinStats {
        total_size_bytes: info.i64_size,
        item_count: info.i64_num_items,
        is_empty: info.i64_num_items == 0,
        formatted_size: format_bytes(info.i64_size),
    })
}

pub fn empty_recycle_bin(play_sound: bool) -> Result<(), String> {
    let mut flags: u32 = 0x00000001 | 0x00000002; // SHERB_NOCONFIRMATION | SHERB_NOPROGRESSUI
    if !play_sound {
        flags |= 0x00000004; // SHERB_NOSOUND
    }

    let result = unsafe { SHEmptyRecycleBinW(std::ptr::null_mut(), std::ptr::null(), flags) };
    if result != 0 && result != 1 {
        return Err(format!("SHEmptyRecycleBinW failed with code {}", result));
    }

    // Notify shell of change
    const SHCNE_ASSOCCHANGED: i32 = 0x08000000;
    unsafe {
        SHChangeNotify(SHCNE_ASSOCCHANGED, 0, std::ptr::null(), std::ptr::null());
    }

    Ok(())
}

pub fn open_recycle_bin() -> Result<(), String> {
    Command::new("explorer.exe")
        .arg("shell:RecycleBinFolder")
        .spawn()
        .map_err(|e| e.to_string())?;
    Ok(())
}

pub fn open_desktop_icon_settings() -> Result<(), String> {
    Command::new("rundll32.exe")
        .arg("shell32.dll,Control_RunDLL")
        .arg("desk.cpl,,0")
        .spawn()
        .map_err(|e| e.to_string())?;
    Ok(())
}

pub fn list_recycle_bin_items() -> Result<Vec<RecycleBinItem>, String> {
    let script = r#"
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
        $OutputEncoding = [System.Text.Encoding]::UTF8;
        $b = (New-Object -ComObject Shell.Application).Namespace(10);
        $items = @();
        if ($b) {
            foreach ($i in $b.Items()) {
                $p = $b.GetDetailsOf($i, 1);
                $d = $b.GetDetailsOf($i, 2);
                $items += [PSCustomObject]@{
                    id = $i.Path;
                    name = $i.Name;
                    size = [int64]$i.Size;
                    original_path = if ($p) { $p } else { "" };
                    date_deleted = if ($d) { $d } else { "" };
                };
            }
        }
        if ($items.Count -gt 0) {
            $items | ConvertTo-Json -Compress
        } else {
            '[]'
        }
    "#;

    let output = Command::new("powershell.exe")
        .creation_flags(0x08000000) // CREATE_NO_WINDOW
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script])
        .output()
        .map_err(|e| e.to_string())?;

    if !output.status.success() {
        return Err("Failed to query recycle bin items via Shell API".into());
    }

    let stdout = String::from_utf8_lossy(&output.stdout);
    let trimmed = stdout.trim().trim_start_matches('\u{feff}');
    if trimmed.is_empty() || trimmed == "[]" {
        return Ok(Vec::new());
    }

    #[derive(Deserialize)]
    struct RawItem {
        id: Option<String>,
        name: Option<String>,
        size: Option<i64>,
        original_path: Option<String>,
        date_deleted: Option<String>,
    }

    let mut result = Vec::new();
    if trimmed.starts_with('[') {
        if let Ok(raw_items) = serde_json::from_str::<Vec<RawItem>>(trimmed) {
            for item in raw_items {
                let size = item.size.unwrap_or(0);
                result.push(RecycleBinItem {
                    id: item.id.clone().unwrap_or_default(),
                    name: item.name.unwrap_or_else(|| "Без имени".into()),
                    original_path: item.original_path.unwrap_or_default(),
                    date_deleted: item.date_deleted.unwrap_or_default(),
                    size,
                    formatted_size: format_bytes(size),
                });
            }
        }
    } else if trimmed.starts_with('{') {
        if let Ok(item) = serde_json::from_str::<RawItem>(trimmed) {
            let size = item.size.unwrap_or(0);
            result.push(RecycleBinItem {
                id: item.id.clone().unwrap_or_default(),
                name: item.name.unwrap_or_else(|| "Без имени".into()),
                original_path: item.original_path.unwrap_or_default(),
                date_deleted: item.date_deleted.unwrap_or_default(),
                size,
                formatted_size: format_bytes(size),
            });
        }
    }

    Ok(result)
}

pub fn restore_recycle_bin_item(item_id: &str) -> Result<(), String> {
    let script = format!(
        r#"
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
        $OutputEncoding = [System.Text.Encoding]::UTF8;
        $target = '{}';
        $b = (New-Object -ComObject Shell.Application).Namespace(10);
        foreach ($i in $b.Items()) {{
            if ($i.Path -eq $target -or $i.Name -eq $target) {{
                foreach ($v in $i.Verbs()) {{
                    $clean = $v.Name -replace '&', '';
                    if ($clean -match 'Restore|Восстанов') {{
                        $v.DoIt();
                        exit 0;
                    }}
                }}
            }}
        }}
        exit 1;
        "#,
        item_id.replace('\'', "''")
    );

    let status = Command::new("powershell.exe")
        .creation_flags(0x08000000)
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", &script])
        .status()
        .map_err(|e| e.to_string())?;

    if status.success() {
        Ok(())
    } else {
        Err("Не удалось восстановить файл (глагол Restore не найден)".into())
    }
}

pub fn delete_recycle_bin_item(item_id: &str) -> Result<(), String> {
    let script = format!(
        r#"
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
        $OutputEncoding = [System.Text.Encoding]::UTF8;
        $target = '{}';
        $b = (New-Object -ComObject Shell.Application).Namespace(10);
        foreach ($i in $b.Items()) {{
            if ($i.Path -eq $target -or $i.Name -eq $target) {{
                foreach ($v in $i.Verbs()) {{
                    $clean = $v.Name -replace '&', '';
                    if ($clean -match 'Delete|Удалить') {{
                        $v.DoIt();
                        exit 0;
                    }}
                }}
            }}
        }}
        exit 1;
        "#,
        item_id.replace('\'', "''")
    );

    let status = Command::new("powershell.exe")
        .creation_flags(0x08000000)
        .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", &script])
        .status()
        .map_err(|e| e.to_string())?;

    if status.success() {
        Ok(())
    } else {
        Err("Не удалось окончательно удалить файл".into())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_recycle_bin_items_utf8() {
        let items = list_recycle_bin_items();
        assert!(items.is_ok(), "list_recycle_bin_items failed: {:?}", items.err());
        let list = items.unwrap();
        for item in list {
            println!("Item: id='{}', name='{}', path='{}'", item.id, item.name, item.original_path);
            assert!(!item.name.contains('\u{FFFD}'), "Item name contains replacement char: {}", item.name);
        }
    }

    #[test]
    fn test_powershell_cyrillic_json() {
        let script = r#"
            [Console]::OutputEncoding = [System.Text.Encoding]::UTF8;
            $OutputEncoding = [System.Text.Encoding]::UTF8;
            $items = @(
                [PSCustomObject]@{
                    id = 'C:\$Recycle.Bin\test1.txt';
                    name = 'Тестовый документ с кириллицей.docx';
                    size = 12345;
                    original_path = 'C:\Users\Тест\Документы';
                    date_deleted = '05.09.2026 09:15';
                }
            );
            $items | ConvertTo-Json -Compress
        "#;

        let output = Command::new("powershell.exe")
            .creation_flags(0x08000000)
            .args(["-NoProfile", "-ExecutionPolicy", "Bypass", "-Command", script])
            .output()
            .expect("Failed to run powershell");

        assert!(output.status.success());
        let stdout = String::from_utf8_lossy(&output.stdout);
        let trimmed = stdout.trim().trim_start_matches('\u{feff}');
        assert!(trimmed.contains("Тестовый документ с кириллицей.docx"));
        assert!(!trimmed.contains('\u{FFFD}'));
    }
}
