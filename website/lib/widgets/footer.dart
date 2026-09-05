import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants.dart';
import '../i18n.dart';
import '../theme.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
      decoration: const BoxDecoration(
        color: Color(0xFF05070B),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo + short bio
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                gradient: AppColors.primaryGradient,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.delete_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'MiniBin v2',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                fontFamily: 'Segoe UI',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 360),
                          child: Text(
                            S.footerDesc,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                              height: 1.5,
                              fontFamily: 'Segoe UI',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quick Links
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ресурсы',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: 'Segoe UI',
                        ),
                      ),
                      const SizedBox(height: 10),
                      _buildFooterLink('GitHub Repository', AppConstants.repoUrl),
                      const SizedBox(height: 6),
                      _buildFooterLink('Releases (${AppConstants.releaseTag})', AppConstants.releaseUrl),
                      const SizedBox(height: 6),
                      _buildFooterLink('Report Issue', AppConstants.issuesUrl),
                      const SizedBox(height: 6),
                      _buildFooterLink('MIT License', AppConstants.licenseUrl),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 36),
              const Divider(color: Colors.white10),
              const SizedBox(height: 20),

              // Bottom credits
              Text(
                S.footerCredit,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFamily: 'Segoe UI',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooterLink(String label, String url) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => _launchUrl(url),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
            fontFamily: 'Segoe UI',
          ),
        ),
      ),
    );
  }
}
