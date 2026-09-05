import 'package:flutter/material.dart';
import '../i18n.dart';
import '../theme.dart';

class FeaturesGrid extends StatelessWidget {
  const FeaturesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth > 860;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isDesktop ? 80 : 50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
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
                  S.featuresBadge,
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
                S.featuresTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 36 : 26,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.8,
                  color: AppColors.textPrimary,
                  fontFamily: 'Segoe UI',
                ),
              ),
              const SizedBox(height: 48),

              // 6 Features in responsive layout
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: [
                  _buildFeatureCard(
                    title: S.featAcrylicTitle,
                    desc: S.featAcrylicDesc,
                    icon: Icons.auto_awesome_rounded,
                    accentColor: AppColors.primary,
                    cardWidth: isDesktop ? 340 : double.infinity,
                  ),
                  _buildFeatureCard(
                    title: S.featPreviewTitle,
                    desc: S.featPreviewDesc,
                    icon: Icons.manage_search_rounded,
                    accentColor: AppColors.secondary,
                    cardWidth: isDesktop ? 340 : double.infinity,
                  ),
                  _buildFeatureCard(
                    title: S.featRestoreTitle,
                    desc: S.featRestoreDesc,
                    icon: Icons.restore_page_rounded,
                    accentColor: AppColors.accentGreen,
                    cardWidth: isDesktop ? 340 : double.infinity,
                  ),
                  _buildFeatureCard(
                    title: S.featThemesTitle,
                    desc: S.featThemesDesc,
                    icon: Icons.palette_outlined,
                    accentColor: AppColors.accentAmber,
                    cardWidth: isDesktop ? 340 : double.infinity,
                  ),
                  _buildFeatureCard(
                    title: S.featNoUacTitle,
                    desc: S.featNoUacDesc,
                    icon: Icons.shield_outlined,
                    accentColor: AppColors.accentRose,
                    cardWidth: isDesktop ? 340 : double.infinity,
                  ),
                  _buildFeatureCard(
                    title: S.featRustTitle,
                    desc: S.featRustDesc,
                    icon: Icons.speed_rounded,
                    accentColor: AppColors.primary,
                    cardWidth: isDesktop ? 340 : double.infinity,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color accentColor,
    required double cardWidth,
  }) {
    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, color: accentColor, size: 24),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: 'Segoe UI',
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            desc,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
              fontFamily: 'Segoe UI',
            ),
          ),
        ],
      ),
    );
  }
}
