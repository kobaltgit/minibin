import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class InteractiveFlyoutDemo extends StatefulWidget {
  const InteractiveFlyoutDemo({super.key});

  @override
  State<InteractiveFlyoutDemo> createState() => _InteractiveFlyoutDemoState();
}

class DemoItem {
  final String id;
  final String name;
  final String path;
  final String size;
  final IconData icon;

  DemoItem(this.id, this.name, this.path, this.size, this.icon);
}

class _InteractiveFlyoutDemoState extends State<InteractiveFlyoutDemo> {
  String selectedTheme = 'Fluent';
  int activeTab = 0; // 0 = Items, 1 = Settings

  List<DemoItem> items = [
    DemoItem('1', 'Годовой_отчет_2026.docx', 'C:\\Users\\Kobalt\\Documents', '1.4 МБ', Icons.description_outlined),
    DemoItem('2', 'Презентация_проекта_v2.pptx', 'D:\\Projects\\Presentations', '18.2 МБ', Icons.slideshow_outlined),
    DemoItem('3', 'backup_database_prod.sql', 'D:\\Backups\\Database', '840.5 МБ', Icons.storage_rounded),
    DemoItem('4', 'retro-tray-icon.png', 'D:\\Design\\Icons', '14.2 КБ', Icons.image_outlined),
  ];

  void _restoreItem(String id) {
    setState(() {
      items.removeWhere((item) => item.id == id);
    });
  }

  void _emptyBin() {
    setState(() {
      items.clear();
    });
  }

  void _resetDemo() {
    setState(() {
      items = [
        DemoItem('1', 'Годовой_отчет_2026.docx', 'C:\\Users\\Kobalt\\Documents', '1.4 МБ', Icons.description_outlined),
        DemoItem('2', 'Презентация_проекта_v2.pptx', 'D:\\Projects\\Presentations', '18.2 МБ', Icons.slideshow_outlined),
        DemoItem('3', 'backup_database_prod.sql', 'D:\\Backups\\Database', '840.5 МБ', Icons.storage_rounded),
        DemoItem('4', 'retro-tray-icon.png', 'D:\\Design\\Icons', '14.2 КБ', Icons.image_outlined),
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 860;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 60 : 40,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Column(
            children: [
              // Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  S.demoBadge,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.primary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                S.demoTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppColors.textPrimary,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 12),

              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Text(
                  S.demoSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 16 : 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Interactive Flyout Mockup Card
              Container(
                width: 440,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2433).withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.surfaceBorderHover.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      blurRadius: 36,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Flyout Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Colors.white10)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                items.isEmpty ? Icons.delete_outline_rounded : Icons.delete_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'MiniBin',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                                Text(
                                  items.isEmpty
                                      ? S.demoBinEmptied
                                      : '${items.length} ${S.isRu ? "объекта" : "items"} (~860 МБ)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: items.isEmpty ? AppColors.accentGreen : AppColors.textMuted,
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Reset Demo Button if empty
                            if (items.isEmpty)
                              TextButton.icon(
                                onPressed: _resetDemo,
                                icon: const Icon(Icons.refresh_rounded, size: 14),
                                label: Text(S.isRu ? 'Сброс' : 'Reset'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  textStyle: const TextStyle(fontSize: 12, fontFamily: 'Segoe UI'),
                                ),
                              )
                            else
                              ElevatedButton.icon(
                                onPressed: _emptyBin,
                                icon: const Icon(Icons.delete_sweep_rounded, size: 14),
                                label: Text(S.demoEmptyBtn),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.accentRose.withValues(alpha: 0.2),
                                  foregroundColor: AppColors.accentRose,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, fontFamily: 'Segoe UI'),
                                ),
                              ),
                          ],
                        ),
                      ),

                      // Volume Progress Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        color: Colors.black.withValues(alpha: 0.2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  items.isEmpty ? '0 Б / 50 ГБ' : '860.1 МБ / 50 ГБ (1.7%)',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: items.isEmpty ? AppColors.accentGreen.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    items.isEmpty ? (S.isRu ? 'В норме' : 'OK') : (S.isRu ? 'Норма' : 'Normal'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: items.isEmpty ? AppColors.accentGreen : AppColors.primary,
                                      fontFamily: 'Segoe UI',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: items.isEmpty ? 0.0 : 0.08,
                                minHeight: 6,
                                backgroundColor: Colors.white10,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  items.isEmpty ? AppColors.accentGreen : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tabs
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        child: Row(
                          children: [
                            _buildTabBtn(S.demoTabItems, 0),
                            const SizedBox(width: 8),
                            _buildTabBtn(S.demoTabSettings, 1),
                          ],
                        ),
                      ),

                      // Tab Content
                      if (activeTab == 0) ...[
                        if (items.isEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 40),
                            child: Column(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded, size: 42, color: AppColors.accentGreen),
                                const SizedBox(height: 10),
                                Text(
                                  S.demoBinEmptied,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textPrimary,
                                    fontFamily: 'Segoe UI',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  S.isRu ? 'Рабочий стол чист и свободен!' : 'Your workspace is clear!',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontFamily: 'Segoe UI'),
                                ),
                              ],
                            ),
                          )
                        else
                          SizedBox(
                            height: 220,
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                              itemCount: items.length,
                              separatorBuilder: (_, _) => const Divider(color: Colors.white10, height: 1),
                              itemBuilder: (context, index) {
                                final item = items[index];
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(item.icon, size: 20, color: AppColors.primary),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.name,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: AppColors.textPrimary,
                                                fontFamily: 'Segoe UI',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              '${item.size} • ${item.path}',
                                              style: const TextStyle(
                                                fontSize: 10,
                                                color: AppColors.textMuted,
                                                fontFamily: 'Segoe UI',
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      IconButton(
                                        icon: const Icon(Icons.undo_rounded, size: 16),
                                        tooltip: S.demoRestore,
                                        onPressed: () => _restoreItem(item.id),
                                        padding: const EdgeInsets.all(4),
                                        constraints: const BoxConstraints(),
                                        style: IconButton.styleFrom(
                                          foregroundColor: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                      ] else ...[
                        // Settings Tab Simulation
                        Container(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                S.demoThemeLabel,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamily: 'Segoe UI'),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: ['Fluent', 'Minimal', 'Retro', 'Classic'].map((theme) {
                                  final isSel = selectedTheme == theme;
                                  return GestureDetector(
                                    onTap: () => setState(() => selectedTheme = theme),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: isSel ? AppColors.primary.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSel ? AppColors.primary : Colors.white12,
                                        ),
                                      ),
                                      child: Text(
                                        theme,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                          color: isSel ? AppColors.primary : AppColors.textSecondary,
                                          fontFamily: 'Segoe UI',
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(Icons.volume_up_outlined, size: 16, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    S.isRu ? 'Звук сминания бумаги при очистке' : 'Play paper crush sound',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontFamily: 'Segoe UI'),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.toggle_on_rounded, size: 30, color: AppColors.primary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabBtn(String title, int index) {
    final isSelected = activeTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => activeTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? AppColors.surfaceBorderHover.withValues(alpha: 0.4) : Colors.transparent,
            ),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
        ),
      ),
    );
  }
}
