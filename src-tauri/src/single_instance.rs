use std::fs;
use std::io::{Read, Write};
use std::net::{TcpListener, TcpStream};
use std::path::PathBuf;
use std::time::Duration;
use tauri::{AppHandle, Manager};

#[cfg(target_os = "windows")]
pub struct NamedMutex {
    handle: *mut std::ffi::c_void,
}

#[cfg(target_os = "windows")]
unsafe impl Send for NamedMutex {}
#[cfg(target_os = "windows")]
unsafe impl Sync for NamedMutex {}

#[cfg(target_os = "windows")]
impl NamedMutex {
    pub fn try_acquire(name: &str) -> Option<Self> {
        let wide: Vec<u16> = name.encode_utf16().chain(std::iter::once(0)).collect();
        unsafe {
            #[link(name = "kernel32")]
            extern "system" {
                fn SetLastError(dw_err_code: u32);
                fn CreateMutexW(
                    lp_attrs: *mut std::ffi::c_void,
                    b_initial: i32,
                    lp_name: *const u16,
                ) -> *mut std::ffi::c_void;
                fn GetLastError() -> u32;
                fn CloseHandle(h: *mut std::ffi::c_void) -> i32;
            }
            const ERROR_ALREADY_EXISTS: u32 = 183;

            SetLastError(0);
            let handle = CreateMutexW(std::ptr::null_mut(), 1, wide.as_ptr());
            if handle.is_null() || GetLastError() == ERROR_ALREADY_EXISTS {
                if !handle.is_null() {
                    CloseHandle(handle);
                }
                None
            } else {
                Some(Self { handle })
            }
        }
    }
}

#[cfg(target_os = "windows")]
impl Drop for NamedMutex {
    fn drop(&mut self) {
        if !self.handle.is_null() {
            unsafe {
                #[link(name = "kernel32")]
                extern "system" {
                    fn CloseHandle(h: *mut std::ffi::c_void) -> i32;
                }
                CloseHandle(self.handle);
            }
        }
    }
}

fn get_ipc_port_file() -> PathBuf {
    crate::settings::get_app_dir().join("ipc.port")
}

static MUTEX_HOLDER: std::sync::Mutex<Option<NamedMutex>> = std::sync::Mutex::new(None);

pub fn handle_potential_secondary_instance() -> bool {
    let port_file = get_ipc_port_file();
    if let Ok(content) = fs::read_to_string(&port_file) {
        if let Ok(port) = content.trim().parse::<u16>() {
            let addr_str = format!("127.0.0.1:{}", port);
            if let Ok(addr) = addr_str.parse() {
                if let Ok(mut stream) = TcpStream::connect_timeout(&addr, Duration::from_millis(400)) {
                    let _ = stream.write_all(b"TOGGLE_FLYOUT\n");
                    let _ = stream.flush();
                    let mut buf = [0u8; 16];
                    let _ = stream.read(&mut buf);
                    return true;
                }
            }
        }
    }

    #[cfg(target_os = "windows")]
    {
        match NamedMutex::try_acquire("Local\\MiniBin_SingleInstance_Mutex_Kobalt") {
            Some(mutex) => {
                if let Ok(mut guard) = MUTEX_HOLDER.lock() {
                    *guard = Some(mutex);
                }
            }
            None => {
                return true;
            }
        }
    }

    false
}

pub fn start_primary_ipc_listener(app_handle: AppHandle) {
    std::thread::spawn(move || {
        let listener = match TcpListener::bind("127.0.0.1:0") {
            Ok(l) => l,
            Err(e) => {
                eprintln!("Failed to bind single-instance IPC listener: {}", e);
                return;
            }
        };

        if let Ok(addr) = listener.local_addr() {
            let port_file = get_ipc_port_file();
            let _ = fs::write(&port_file, addr.port().to_string());
        }

        for stream in listener.incoming() {
            if let Ok(mut socket) = stream {
                use std::io::BufRead;
                let mut reader = std::io::BufReader::new(&mut socket);
                let mut line = String::new();
                if reader.read_line(&mut line).is_ok() {
                    let cmd = line.trim();
                    if cmd == "TOGGLE_FLYOUT" {
                        if let Some(window) = app_handle.get_webview_window("main") {
                            if let Ok(visible) = window.is_visible() {
                                if visible {
                                    let _ = window.hide();
                                } else {
                                    crate::tray::position_flyout(&window);
                                    let _ = window.show();
                                    let _ = window.set_focus();
                                }
                            }
                        }
                    }
                }
                let _ = socket.write_all(b"OK\n");
                let _ = socket.flush();
            }
        }
    });
}
