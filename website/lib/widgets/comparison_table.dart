import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class ComparisonTable extends StatelessWidget {
  const ComparisonTable({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 860;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 70 : 40,
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
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Text(
                  S.compBadge,
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
                S.compTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppColors.textPrimary,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 40),

              // Glass Comparison Container
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: [
                      // Header Row
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        color: Colors.black.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                S.compColMetric,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                S.compColV1,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textSecondary,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                S.compColV2,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  fontFamily: 'Segoe UI',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(color: AppColors.surfaceBorder, height: 1),

                      // Rows
                      _buildRow(S.compRam, S.compRamV1, S.compRamV2, isPositive: true),
                      _buildRow(S.compSize, S.compSizeV1, S.compSizeV2, isPositive: true),
                      _buildRow(S.compUi, S.compUiV1, S.compUiV2, isPositive: true),
                      _buildRow(S.compFileMgmt, S.compFileMgmtV1, S.compFileMgmtV2, isPositive: true),
                      _buildRow(S.compIcons, S.compIconsV1, S.compIconsV2, isPositive: true),
                      _buildRow(S.compAutostart, S.compAutostartV1, S.compAutostartV2, isPositive: true, isLast: true),
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

  Widget _buildRow(String metric, String v1, String v2, {bool isPositive = false, bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.8)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              metric,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              v1,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontFamily: 'Segoe UI',
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Row(
              children: [
                if (isPositive)
                  const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    v2,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
