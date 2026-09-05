import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class HeroSection extends StatelessWidget {
  final VoidCallback? onDemoTap;

  const HeroSection({super.key, this.onDemoTap});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

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
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Release Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.surfaceBorderHover.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        S.heroBadge,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Title with Gradient
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: isDesktop ? 54 : 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    color: AppColors.textPrimary,
                    height: 1.15,
                    fontFamily: 'Segoe UI',
                  ),
                  children: [
                    TextSpan(text: S.heroTitlePrefix),
                    WidgetSpan(
                      child: ShaderMask(
                        shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                        child: Text(
                          S.heroTitleGradient,
                          style: TextStyle(
                            fontSize: isDesktop ? 54 : 34,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -1.5,
                            color: Colors.white,
                            height: 1.15,
                            fontFamily: 'Segoe UI',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  S.heroSubtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 18 : 15,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textSecondary,
                    height: 1.6,
                    fontFamily: 'Segoe UI',
                  ),
                ),
              ),

              const SizedBox(height: 36),

              // Action Buttons with ACTIVE links
              Wrap(
                spacing: 16,
                runSpacing: 14,
                alignment: WrapAlignment.center,
                children: [
                  // Primary Installer Download
                  ElevatedButton.icon(
                    onPressed: () => _launchUrl(AppConstants.setupDownloadUrl),
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: Text(S.heroDownloadSetup),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.background,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Segoe UI',
                      ),
                      elevation: 4,
                      shadowColor: AppColors.primary.withValues(alpha: 0.4),
                    ),
                  ),

                  // Portable Download
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl(AppConstants.portableDownloadUrl),
                    icon: const Icon(Icons.archive_outlined, size: 20),
                    label: Text(S.heroDownloadPortable),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: const BorderSide(color: AppColors.surfaceBorderHover, width: 1.5),
                      backgroundColor: AppColors.surface.withValues(alpha: 0.6),
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),

                  // GitHub Button
                  OutlinedButton.icon(
                    onPressed: () => _launchUrl(AppConstants.repoUrl),
                    icon: const Icon(Icons.code_rounded, size: 20),
                    label: Text(S.heroGithub),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textSecondary,
                      side: const BorderSide(color: AppColors.surfaceBorder),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Segoe UI',
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Metrics Chips
              Wrap(
                spacing: 24,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildMetricChip(S.heroStatRam, S.heroStatRamLabel, Icons.memory_rounded),
                  _buildMetricChip(S.heroStatSpeed, S.heroStatSpeedLabel, Icons.bolt_rounded),
                  _buildMetricChip(S.heroStatUac, S.heroStatUacLabel, Icons.verified_user_outlined),
                  _buildMetricChip(S.heroStatLicense, S.heroStatLicenseLabel, Icons.lock_open_rounded),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricChip(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  fontFamily: 'Segoe UI',
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
