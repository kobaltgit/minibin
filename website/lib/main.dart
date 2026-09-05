import 'package:flutter/material.dart';

void main() {
  runApp(const MiniBinWebsiteApp());
}

class MiniBinWebsiteApp extends StatefulWidget {
  const MiniBinWebsiteApp({super.key});

  @override
  State<MiniBinWebsiteApp> createState() => _MiniBinWebsiteAppState();
}

class _MiniBinWebsiteAppState extends State<MiniBinWebsiteApp> {
  bool isRu = true;
  bool isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: isRu ? 'MiniBin v2 — Корзина Windows в системном трее' : 'MiniBin v2 — Windows Recycle Bin in System Tray',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: isDark ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF38BDF8),
          brightness: isDark ? Brightness.dark : Brightness.light,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildNavbar(),
              _buildHeroSection(),
              _buildFeaturesSection(),
              _buildComparisonSection(),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white10 : Colors.black12,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFF38BDF8), size: 24),
          ),
          const SizedBox(width: 12),
          Text(
            'MiniBin v2',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
          const Spacer(),
          // Language Switcher
          OutlinedButton(
            onPressed: () => setState(() => isRu = !isRu),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(isRu ? '🇷🇺 RU' : '🇬🇧 EN'),
          ),
          const SizedBox(width: 12),
          // Theme Toggle
          IconButton(
            onPressed: () => setState(() => isDark = !isDark),
            icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 64),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.4)),
                ),
                child: Text(
                  isRu ? '⚡ Полный рефакторинг на Tauri v2 + Rust + Svelte 5' : '⚡ Complete redesign with Tauri v2 + Rust + Svelte 5',
                  style: const TextStyle(
                    color: Color(0xFF38BDF8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                isRu ? 'Корзина Windows в трее.\nБыстрее. Легче. Элегантнее.' : 'Windows Recycle Bin in Tray.\nFaster. Lighter. Sleeker.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  height: 1.15,
                  letterSpacing: -1,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                isRu
                    ? 'Освободите рабочий стол от стандартного значка. Управляйте удалёнными файлами, восстанавливайте в один клик и очищайте корзину прямо из панели задач.'
                    : 'Declutter your desktop from the standard icon. Browse deleted files, restore them in one click, and empty trash right from your taskbar.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download_rounded, color: Colors.white),
                    label: Text(
                      isRu ? 'Скачать для Windows 10/11' : 'Download for Windows 10/11',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.code_rounded),
                    label: const Text('GitHub Repository'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {
        'icon': Icons.memory_rounded,
        'title': isRu ? '10-18 МБ ОЗУ в фоне' : '10-18 MB RAM Idle',
        'desc': isRu
            ? 'Сверхнизкое потребление ресурсов благодаря компиляции в нативный машинный код Rust.'
            : 'Ultra-lightweight background memory footprint powered by native Rust machine code.',
      },
      {
        'icon': Icons.auto_awesome_rounded,
        'title': isRu ? 'Fluent Flyout' : 'Fluent Flyout',
        'desc': isRu
            ? 'Элегантное окно в стиле Windows 11 с эффектом Acrylic, списком удалённых файлов и поиском.'
            : 'Elegant Windows 11 flyout popup with Mica/Acrylic glass, live deleted items preview and search.',
      },
      {
        'icon': Icons.mouse_rounded,
        'title': isRu ? 'Кастомизация мыши' : 'Mouse Shortcuts',
        'desc': isRu
            ? 'Настраивайте действия на левый, средний и двойной клик по значку в трее.'
            : 'Bind left click, middle click, and double click to instant purge, open, or flyout toggle.',
      },
      {
        'icon': Icons.palette_outlined,
        'title': isRu ? 'Темы и значки' : 'Themes & Icons',
        'desc': isRu
            ? 'Наборы иконок Fluent, Win98 Retro, Minimalist и Classic с динамической индикацией наполнения.'
            : 'Icon packs: Fluent, Win98 Retro, Minimalist, and Classic with live fill state indication.',
      },
      {
        'icon': Icons.bolt_rounded,
        'title': isRu ? 'Автостарт без UAC' : 'No-UAC Autostart',
        'desc': isRu
            ? 'Безопасная автозагрузка через пользовательский куст реестра HKCU без раздражающих запросов прав.'
            : 'Safe autorun registered via HKCU without admin elevation prompts.',
      },
      {
        'icon': Icons.settings_backup_restore_rounded,
        'title': isRu ? 'Точечное восстановление' : 'Item Restore',
        'desc': isRu
            ? 'Восстанавливайте случайно удалённые файлы на их исходные места без открытия громоздкого Проводника.'
            : 'Restore accidentally deleted files directly to their original locations.',
      },
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              Text(
                isRu ? 'Возможности нового поколения' : 'Next Generation Features',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 36),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: features.map((f) {
                  return SizedBox(
                    width: 300,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(f['icon'] as IconData, color: const Color(0xFF38BDF8), size: 28),
                          const SizedBox(height: 12),
                          Text(
                            f['title'] as String,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            f['desc'] as String,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonSection() {
    final rows = [
      {'metric': isRu ? 'Память в фоне' : 'Idle RAM', 'v1': '60-90 MB (Python)', 'v2': '10-18 MB (Rust)'},
      {'metric': isRu ? 'Размер установщика' : 'Installer Size', 'v1': '~60 MB', 'v2': '~10 MB'},
      {'metric': isRu ? 'Интерфейс' : 'User Interface', 'v1': isRu ? 'Только контекстное меню' : 'Context menu only', 'v2': isRu ? 'Flyout окно + список файлов' : 'Interactive Flyout + File list'},
      {'metric': isRu ? 'Кастомизация значков' : 'Icon Themes', 'v1': '2 иконки', 'v2': '4 набора + динамика'},
      {'metric': isRu ? 'Автозагрузка' : 'Autorun', 'v1': 'ProgramData (UAC)', 'v2': 'HKCU (Без прав Admin)'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
              Text(
                isRu ? 'Сравнение: MiniBin v1 vs MiniBin v2' : 'Comparison: MiniBin v1 vs MiniBin v2',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                ),
                child: Table(
                  border: TableBorder(
                    horizontalInside: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                  ),
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.02),
                      ),
                      children: [
                        _tableCell(isRu ? 'Характеристика' : 'Metric', isHeader: true),
                        _tableCell('MiniBin v1 (Python)', isHeader: true),
                        _tableCell('MiniBin v2 (Rust + Tauri)', isHeader: true, isAccent: true),
                      ],
                    ),
                    ...rows.map((r) => TableRow(
                          children: [
                            _tableCell(r['metric']!),
                            _tableCell(r['v1']!),
                            _tableCell(r['v2']!, isAccent: true),
                          ],
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tableCell(String text, {bool isHeader = false, bool isAccent = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 13 : 12.5,
          fontWeight: isHeader || isAccent ? FontWeight.bold : FontWeight.normal,
          color: isAccent
              ? const Color(0xFF38BDF8)
              : (isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Center(
        child: Text(
          'MiniBin v2 • Open Source under MIT License',
          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
        ),
      ),
    );
  }
}
