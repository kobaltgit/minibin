# MiniBin v2 — Корзина Windows в системном трее

<div align="center">
  <h3>🗑️ Легковесная, нативная и стильная утилита для управления Корзиной в Windows 10 & 11</h3>

  [![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
  [![Platform: Windows](https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6.svg?logo=windows)](https://microsoft.com)
  [![Rust](https://img.shields.io/badge/Rust-2021%20Edition-DEA584.svg?logo=rust)](https://www.rust-lang.org)
  [![Tauri](https://img.shields.io/badge/Tauri-v2.0-FFC131.svg?logo=tauri)](https://v2.tauri.app)
  [![Svelte](https://img.shields.io/badge/Svelte-v5%20(Runes)-FF3E00.svg?logo=svelte)](https://svelte.dev)
  [![Flutter](https://img.shields.io/badge/Website-Flutter%20Web-02569B.svg?logo=flutter)](https://flutter.dev)
</div>

---

## ⚡ О проекте

**MiniBin v2** — это глубокий архитектурный рефакторинг оригинальной утилиты MiniBin. Приложение переведено с Python/PyQt6 на **нативный машинный код Rust и Tauri v2** с современным всплывающим окном **Flyout на Svelte 5**.

Освободите рабочий стол от стандартного значка корзины, контролируйте удалённые файлы и восстанавливайте их в один клик прямо из системного трея.

### Сравнение поколений

| Показатель | MiniBin v1 (Python / PyQt6) | MiniBin v2 (Tauri v2 + Rust) |
| :--- | :--- | :--- |
| **ОЗУ в фоне** | 60–90 МБ | **10–18 МБ** (сверхлегковесный процесс) |
| **Размер установщика** | ~60 МБ | **~10 МБ** |
| **Интерфейс** | Только контекстное меню трея | **Интерактивный Flyout у трея (Fluent Acrylic)** |
| **Управление файлами** | Очистка "вслепую" | **Превью удаленных файлов, поиск, точечное восстановление** |
| **Темы значков** | 2 фиксированные иконки | **4 набора (Fluent, Win98 Retro, Minimal, Classic) + динамика** |
| **Автозапуск** | Запись в `ProgramData` (требует Admin / UAC) | **Запись в `HKCU\...\Run` (без прав администратора)** |
| **Языки** | Русский | **Русский (RU) и Английский (EN)** |

---

## ✨ Ключевые возможности

* 🪟 **Fluent Glassmorphism Flyout**: Красивое всплывающее окно около трея с акриловым размытием (`backdrop-filter`), адаптирующееся под системную светлую и тёмную тему Windows.
* 📊 **Живой мониторинг объема**: Динамическая шкала заполнения с предупреждающей подсветкой при превышении настраиваемого лимита (5, 10, 20, 50 ГБ).
* 🔍 **Обозреватель удалённых объектов**: Полноценный список файлов в корзине с мгновенным поиском по имени или пути.
* ↩️ **Точечные действия над файлами**: Восстановление любого файла на его исходное место или безвозвратное удаление прямо из списка.
* 🖱️ **Настраиваемые действия мыши**: Гибкая привязка ЛКМ, СКМ (колёсико) и двойного клика (вызов Flyout, моментальная очистка, открытие в Проводнике).
* 🎨 **Наборы иконок трея**: Переключение между современным стилем Fluent, ретро-значками Windows 98, минимализмом и классическим видом.
* 🚀 **Безопасная автозагрузка**: Автостарт через реестр текущего пользователя (`HKCU`) без навязчивых запросов UAC.
* 🔊 **Звук и подтверждения**: Опциональный звук сминания бумаги и защита от случайной очистки.
* 🖥️ **Скрытие корзины с Рабочего стола**: Быстрый вызов системного апплета `desk.cpl,,0` для скрытия десктопного значка.

---

## 🛠️ Стек технологий

* **Backend**: Rust 2021, Tauri v2, Windows API (`SHQueryRecycleBinW`, `SHEmptyRecycleBinW`, `IShellFolder`), `winreg`.
* **Frontend**: Svelte 5 (Runes `$state`, `$derived`, `$effect`), TypeScript, Vite, Vanilla CSS.
* **Landing Page**: Flutter 3.44 Web (`website/`), адаптивный промо-лендинг для публикации на GitHub Pages.

---

## 🚀 Сборка и запуск для разработчиков

### Требования
- **Node.js** v18+ и **npm**
- **Rust toolchain** (компилятор `rustc`, `cargo`): `https://rustup.rs/`
- **C++ Build Tools** (Visual Studio Installer / MSVC)
- *(Опционально для лендинга)*: **Flutter SDK** 3.20+

### Инструкция

1. **Клонируйте репозиторий и перейдите в папку проекта:**
   ```bash
   git clone https://github.com/kobaltgit/minibin.git
   cd minibin
   ```

2. **Установите зависимости фронтенда:**
   ```bash
   npm install
   ```

3. **Запуск в режиме разработки:**
   ```bash
   npm run tauri dev
   ```

4. **Сборка релизного дистрибутива (.exe и установщик):**
   ```bash
   npm run tauri build
   ```
   Готовый бинарник будет доступен в `src-tauri/target/release/minibin.exe` или `src-tauri/target/release/bundle/nsis/`.

5. **Сборка промо-сайта на Flutter Web:**
   ```bash
   cd website
   flutter build web --release
   ```
   Файлы лендинга генерируются в `website/build/web/`.

---

## 📄 Лицензия

Этот проект распространяется по лицензии [MIT](LICENSE).

*Оригинальная идея утилиты: [King Triton](https://github.com/king-tri-ton). В версии v2 проект полностью переписан на Rust, Tauri и Svelte.*