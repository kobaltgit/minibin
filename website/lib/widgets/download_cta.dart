import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class DownloadCta extends StatelessWidget {
  const DownloadCta({super.key});

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
        vertical: isDesktop ? 80 : 50,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isDesktop ? 48 : 24,
              vertical: isDesktop ? 56 : 36,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.surfaceBorderHover.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  blurRadius: 40,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    S.ctaBadge,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: AppColors.primary,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                Text(
                  S.ctaTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isDesktop ? 38 : 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.0,
                    color: AppColors.textPrimary,
                    fontFamily: 'Segoe UI',
                  ),
                ),
                const SizedBox(height: 14),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 620),
                  child: Text(
                    S.ctaSubtitle,
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

                // Active Download Buttons
                Wrap(
                  spacing: 16,
                  runSpacing: 14,
                  alignment: WrapAlignment.center,
                  children: [
                    // Installer
                    ElevatedButton.icon(
                      onPressed: () => _launchUrl(AppConstants.setupDownloadUrl),
                      icon: const Icon(Icons.download_rounded, size: 20),
                      label: Text(S.ctaSetupBtn),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Segoe UI',
                        ),
                        elevation: 4,
                      ),
                    ),

                    // Portable Zip
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(AppConstants.portableDownloadUrl),
                      icon: const Icon(Icons.folder_zip_outlined, size: 20),
                      label: Text(S.ctaPortableBtn),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.surfaceBorderHover, width: 1.5),
                        backgroundColor: AppColors.card.withValues(alpha: 0.6),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ),

                    // Standalone Exe
                    OutlinedButton.icon(
                      onPressed: () => _launchUrl(AppConstants.standaloneExeUrl),
                      icon: const Icon(Icons.bolt_rounded, size: 20),
                      label: Text(S.ctaStandaloneBtn),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.surfaceBorder),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Link to all releases
                TextButton.icon(
                  onPressed: () => _launchUrl(AppConstants.releaseUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: Text(S.ctaViewReleases),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Segoe UI',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
