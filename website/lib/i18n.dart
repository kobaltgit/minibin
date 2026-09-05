import 'package:flutter/foundation.dart';

enum AppLang { ru, en }

final ValueNotifier<AppLang> currentLang = ValueNotifier<AppLang>(AppLang.ru);

void setAppLanguage(AppLang lang) {
  currentLang.value = lang;
}

class S {
  static AppLang get lang => currentLang.value;
  static bool get isRu => lang == AppLang.ru;

  // Navbar
  static String get navFeatures => isRu ? 'Возможности' : 'Features';
  static String get navFlyoutDemo => isRu ? 'Интерактивный Flyout' : 'Live Flyout Demo';
  static String get navComparison => isRu ? 'Сравнение v1 и v2' : 'v1 vs v2';
  static String get navFaq => isRu ? 'FAQ' : 'FAQ';
  static String get navDownload => isRu ? 'Скачать' : 'Download';

  // Hero Section
  static String get heroBadge => isRu
      ? 'MiniBin v2.0.1 Релиз доступен — Нативный Rust, Tauri v2 & Svelte 5'
      : 'MiniBin v2.0.1 Release Available — Native Rust, Tauri v2 & Svelte 5';
  static String get heroTitlePrefix => isRu ? 'Корзина Windows прямо в ' : 'Windows Recycle Bin in ';
  static String get heroTitleGradient => isRu ? 'системном трее' : 'Your System Tray';
  static String get heroSubtitle => isRu
      ? 'Освободите рабочий стол от стандартного значка корзины. Мгновенный мониторинг объема, предпросмотр удалённых файлов, поиск и восстановление в один клик без открытия Проводника.'
      : 'Free your desktop from the clunky recycle bin icon. Live size monitoring, deleted file previews, search, and one-click restore without opening Windows Explorer.';

  static String get heroDownloadSetup => isRu ? 'Скачать установщик (.exe)' : 'Download Installer (.exe)';
  static String get heroDownloadPortable => isRu ? 'Портабельная версия (.zip)' : 'Portable Version (.zip)';
  static String get heroGithub => isRu ? 'GitHub Репозиторий' : 'GitHub Repository';

  static String get heroStatRam => isRu ? '< 15 МБ' : '< 15 MB';
  static String get heroStatRamLabel => isRu ? 'ОЗУ в фоне (Rust)' : 'Background RAM usage';
  static String get heroStatSpeed => isRu ? '< 1 сек' : '< 1 sec';
  static String get heroStatSpeedLabel => isRu ? 'Мгновенный старт' : 'Instant startup';
  static String get heroStatUac => isRu ? '0% UAC' : 'No UAC';
  static String get heroStatUacLabel => isRu ? 'Без прав администратора' : 'Standard user rights';
  static String get heroStatLicense => isRu ? '100% Free' : '100% Free';
  static String get heroStatLicenseLabel => isRu ? 'Открытый исходный код' : 'Open Source (MIT)';

  // Flyout Demo
  static String get demoBadge => isRu ? 'ИНТЕРАКТИВНЫЙ FLYOUT' : 'INTERACTIVE FLYOUT';
  static String get demoTitle => isRu ? 'Попробуйте интерфейс прямо в браузере' : 'Experience the Flyout in Browser';
  static String get demoSubtitle => isRu
      ? 'Всплывающее окно в стиле Windows 11 Fluent Acrylic. Нажмите кнопки очистки, восстановления или смените тему значков.'
      : 'Windows 11 Fluent Acrylic flyout interface. Try emptying, restoring items, or switching themes.';
  static String get demoTabItems => isRu ? 'Обзор файлов' : 'File Explorer';
  static String get demoTabSettings => isRu ? 'Настройки' : 'Settings';
  static String get demoEmptyBtn => isRu ? 'Очистить корзину' : 'Empty Bin';
  static String get demoSearchHint => isRu ? 'Поиск в корзине...' : 'Search items...';
  static String get demoTotalSize => isRu ? 'Занято: 3.42 ГБ / 4 объекта' : 'Size: 3.42 GB / 4 items';
  static String get demoRestore => isRu ? 'Восстановить' : 'Restore';
  static String get demoDelete => isRu ? 'Удалить навсегда' : 'Permanent Delete';
  static String get demoBinEmptied => isRu ? 'Корзина пуста' : 'Recycle Bin is empty';
  static String get demoThemeLabel => isRu ? 'Тема значков трея:' : 'Tray Icon Theme:';

  // Features Grid
  static String get featuresBadge => isRu ? 'ВОЗМОЖНОСТИ' : 'FEATURES';
  static String get featuresTitle => isRu ? 'Всё, что нужно для чистой и быстрой системы' : 'Engineered for Pure Performance & Beauty';

  static String get featAcrylicTitle => isRu ? 'Fluent Acrylic Glassmorphism' : 'Fluent Acrylic Glassmorphism';
  static String get featAcrylicDesc => isRu
      ? 'Элегантное окно у трея с системным акриловым размытием, адаптирующееся под светлую и тёмную тему Windows 10/11.'
      : 'Sleek flyout window anchored to your tray with real acrylic blur, seamlessly syncing with Windows 10 & 11 light/dark mode.';

  static String get featPreviewTitle => isRu ? 'Обозреватель удалённых объектов' : 'Live Deleted File Explorer';
  static String get featPreviewDesc => isRu
      ? 'Видно имя, исходный путь, дату удаления и размер каждого файла с мгновенной фильтрацией и поиском.'
      : 'View file names, original paths, deletion dates, and sizes with instant real-time filtering and search.';

  static String get featRestoreTitle => isRu ? 'Восстановление в 1 клик' : 'One-Click Restore & Delete';
  static String get featRestoreDesc => isRu
      ? 'Возвращайте случайно удалённые файлы на их исходные места или удаляйте их безвозвратно прямо из меню.'
      : 'Restore misplaced files back to their exact original folder or permanently delete them with zero friction.';

  static String get featThemesTitle => isRu ? '4 набора иконок + свои значки' : '4 Icon Sets & Custom Picker';
  static String get featThemesDesc => isRu
      ? 'Наборы Fluent, Win98 Retro, Minimal, Classic, а также возможность загрузить любую собственную пару иконок (.ico, .png).'
      : 'Switch between modern Fluent, vintage Windows 98, Minimal, Classic, or set your own custom icon pairs (.ico, .png).';

  static String get featNoUacTitle => isRu ? 'Безопасный автозапуск без UAC' : 'Safe Autostart (No UAC)';
  static String get featNoUacDesc => isRu
      ? 'Программа прописывается в HKCU текущего пользователя и запускается тихо, не раздражая всплывающими окнами контроля учетных записей.'
      : 'Integrates into HKCU user registry run keys. Launches silently on startup without triggering annoying admin UAC prompts.';

  static String get featRustTitle => isRu ? 'Нативная скорость Rust + Tauri' : 'Native Rust + Tauri Engine';
  static String get featRustDesc => isRu
      ? 'Никакого тяжелого Python-рантайма или Electron. Потребление памяти всего 10–15 МБ, мгновенный отклик и чистый код.'
      : 'Zero heavy Python runtime or Electron bloat. Consumes a tiny 10–15 MB RAM with instant startup and flawless responsiveness.';

  // Comparison
  static String get compBadge => isRu ? 'ЭВОЛЮЦИЯ' : 'EVOLUTION';
  static String get compTitle => isRu ? 'MiniBin v1 vs MiniBin v2' : 'MiniBin v1 vs MiniBin v2';
  static String get compColMetric => isRu ? 'Критерий' : 'Metric';
  static String get compColV1 => isRu ? 'MiniBin v1 (Python)' : 'MiniBin v1 (Python)';
  static String get compColV2 => isRu ? 'MiniBin v2 (Rust / Tauri)' : 'MiniBin v2 (Rust / Tauri)';

  static String get compRam => isRu ? 'ОЗУ в фоне' : 'RAM usage';
  static String get compRamV1 => '60–90 МБ (Python / Qt)';
  static String get compRamV2 => '10–18 МБ (Машинный код Rust)';

  static String get compSize => isRu ? 'Размер установщика' : 'Installer size';
  static String get compSizeV1 => '~60 МБ';
  static String get compSizeV2 => '~2.2 МБ (Легковесный NSIS)';

  static String get compUi => isRu ? 'Пользовательский интерфейс' : 'User Interface';
  static String get compUiV1 => isRu ? 'Только плоское контекстное меню' : 'Basic context menu only';
  static String get compUiV2 => isRu ? 'Акриловый Flyout у трея + поиск + превью' : 'Acrylic Glass Flyout + search + preview';

  static String get compFileMgmt => isRu ? 'Управление файлами' : 'File Management';
  static String get compFileMgmtV1 => isRu ? 'Очистка только вслепую' : 'Blind empty only';
  static String get compFileMgmtV2 => isRu ? 'Выборочное восстановление и удаление' : 'Selective restore & permanent delete';

  static String get compIcons => isRu ? 'Темы значков' : 'Icon Themes';
  static String get compIconsV1 => isRu ? '2 фиксированные иконки' : '2 hardcoded icons';
  static String get compIconsV2 => isRu ? '4 набора + свои иконки из файлов' : '4 sets + custom user files';

  static String get compAutostart => isRu ? 'Автозапуск' : 'Autostart';
  static String get compAutostartV1 => isRu ? 'Требовал прав Admin (ProgramData)' : 'Required Admin rights';
  static String get compAutostartV2 => isRu ? 'HKCU Run (чисто, без UAC)' : 'HKCU Run (clean, zero UAC)';

  // FAQ
  static String get faqBadge => isRu ? 'ВОПРОСЫ И ОТВЕТЫ' : 'FAQ';
  static String get faqTitle => isRu ? 'Часто задаваемые вопросы' : 'Frequently Asked Questions';

  static String get faqQ1 => isRu ? 'Нужны ли права администратора для установки?' : 'Does MiniBin require administrator privileges?';
  static String get faqA1 => isRu
      ? 'Нет! MiniBin v2 работает полностью в пространстве текущего пользователя (HKCU), не требует прав администратора и не вызывает запросов контроля учётных записей (UAC).'
      : 'No! MiniBin v2 operates completely within the standard user space (HKCU) and never requests admin UAC elevation.';

  static String get faqQ2 => isRu ? 'Как работает портабельная версия?' : 'How does the portable version work?';
  static String get faqA2 => isRu
      ? 'Скачайте MiniBin_2.0.1_Portable.zip, распакуйте в любую папку или на флешку. Наличие файла portable.txt указывает программе хранить все настройки и кастомные иконки в этой же папке.'
      : 'Download MiniBin_2.0.1_Portable.zip, unpack anywhere or onto a flash drive. The presence of portable.txt tells MiniBin to keep all settings and icons locally in that folder.';

  static String get faqQ3 => isRu ? 'Как скрыть значок корзины с Рабочего стола?' : 'How do I hide the Recycle Bin from my desktop?';
  static String get faqA3 => isRu
      ? 'В настройках MiniBin есть кнопка «Скрыть значок с Рабочего стола», открывающая стандартный системный апплет Windows (desk.cpl), где достаточно снять одну галочку.'
      : 'MiniBin includes a shortcut button to open the native Windows desktop icon settings dialog (desk.cpl) where you simply uncheck the Recycle Bin icon.';

  static String get faqQ4 => isRu ? 'Поддерживается ли Windows 10 и 11?' : 'Is Windows 10 and 11 supported?';
  static String get faqA4 => isRu
      ? 'Да! Поддерживаются как 64-битная Windows 10, так и Windows 11 с автоматической адаптацией темы оформления.'
      : 'Yes! Fully tested and supported on both 64-bit Windows 10 and Windows 11 with automatic dark/light theme detection.';

  // Download CTA
  static String get ctaBadge => isRu ? 'СКАЧАТЬ' : 'DOWNLOAD';
  static String get ctaTitle => isRu ? 'Сделайте свой рабочий стол чище уже сегодня' : 'Declutter Your Desktop Today';
  static String get ctaSubtitle => isRu
      ? 'Выберите удобный формат: стандартный установщик Windows или портабельный архив без установки.'
      : 'Choose your format: standard Windows installer or standalone zero-install portable zip.';
  static String get ctaSetupBtn => isRu ? 'Установщик Windows (.exe)' : 'Windows Installer (.exe)';
  static String get ctaPortableBtn => isRu ? 'Портабельный архив (.zip)' : 'Portable Archive (.zip)';
  static String get ctaStandaloneBtn => isRu ? 'Прямой .exe (9.9 МБ)' : 'Direct .exe (9.9 MB)';
  static String get ctaViewReleases => isRu ? 'Все релизы на GitHub' : 'All GitHub Releases';

  // Footer
  static String get footerDesc => isRu
      ? 'Современная, нативная и легковесная замена стандартной корзины Windows в системном трее.'
      : 'Modern, native, and lightweight Windows recycle bin tray companion.';
  static String get footerCredit => isRu
      ? 'Разработка: kobaltgit • Оригинальная идея: King Triton • Лицензия MIT'
      : 'Crafted by kobaltgit • Original idea by King Triton • MIT Licensed';
}
