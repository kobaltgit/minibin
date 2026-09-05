use std::path::PathBuf;

#[cfg(target_os = "windows")]
#[repr(C)]
#[allow(non_snake_case)]
struct OPENFILENAMEW {
    lStructSize: u32,
    hwndOwner: *mut std::ffi::c_void,
    hInstance: *mut std::ffi::c_void,
    lpstrFilter: *const u16,
    lpstrCustomFilter: *mut u16,
    nMaxCustFilter: u32,
    nFilterIndex: u32,
    lpstrFile: *mut u16,
    nMaxFile: u32,
    lpstrFileTitle: *mut u16,
    nMaxFileTitle: u32,
    lpstrInitialDir: *const u16,
    lpstrTitle: *const u16,
    Flags: u32,
    nFileOffset: u16,
    nFileExtension: u16,
    lpstrDefExt: *const u16,
    lCustData: usize,
    lpfnHook: *mut std::ffi::c_void,
    lpTemplateName: *const u16,
    pvReserved: *mut std::ffi::c_void,
    dwReserved: u32,
    FlagsEx: u32,
}

#[cfg(target_os = "windows")]
pub fn pick_image_file() -> Option<PathBuf> {
    #[link(name = "comdlg32")]
    extern "system" {
        fn GetOpenFileNameW(lpofn: *mut OPENFILENAMEW) -> i32;
    }

    let filter: Vec<u16> = "Иконки и изображения (*.ico, *.png, *.bmp, *.jpg)\0*.ico;*.png;*.bmp;*.jpg;*.jpeg\0Все файлы (*.*)\0*.*\0\0"
        .encode_utf16()
        .collect();
    let title: Vec<u16> = "Выберите значок для корзины\0".encode_utf16().collect();

    let mut file_buf = [0u16; 1024];

    let mut ofn = OPENFILENAMEW {
        lStructSize: std::mem::size_of::<OPENFILENAMEW>() as u32,
        hwndOwner: std::ptr::null_mut(),
        hInstance: std::ptr::null_mut(),
        lpstrFilter: filter.as_ptr(),
        lpstrCustomFilter: std::ptr::null_mut(),
        nMaxCustFilter: 0,
        nFilterIndex: 1,
        lpstrFile: file_buf.as_mut_ptr(),
        nMaxFile: file_buf.len() as u32,
        lpstrFileTitle: std::ptr::null_mut(),
        nMaxFileTitle: 0,
        lpstrInitialDir: std::ptr::null_mut(),
        lpstrTitle: title.as_ptr(),
        Flags: 0x00000800 | 0x00001000 | 0x00080000, // OFN_PATHMUSTEXIST | OFN_FILEMUSTEXIST | OFN_EXPLORER
        nFileOffset: 0,
        nFileExtension: 0,
        lpstrDefExt: std::ptr::null(),
        lCustData: 0,
        lpfnHook: std::ptr::null_mut(),
        lpTemplateName: std::ptr::null(),
        pvReserved: std::ptr::null_mut(),
        dwReserved: 0,
        FlagsEx: 0,
    };

    unsafe {
        if GetOpenFileNameW(&mut ofn) != 0 {
            let len = file_buf.iter().position(|&c| c == 0).unwrap_or(file_buf.len());
            let path_str = String::from_utf16_lossy(&file_buf[..len]);
            Some(PathBuf::from(path_str))
        } else {
            None
        }
    }
}

#[cfg(not(target_os = "windows"))]
pub fn pick_image_file() -> Option<PathBuf> {
    None
}
