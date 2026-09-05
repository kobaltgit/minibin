import 'package:flutter/material.dart';
import 'i18n.dart';
import 'theme.dart';
import 'widgets/navbar.dart';
import 'widgets/hero_section.dart';
import 'widgets/interactive_flyout_demo.dart';
import 'widgets/features_grid.dart';
import 'widgets/comparison_table.dart';
import 'widgets/faq_section.dart';
import 'widgets/download_cta.dart';
import 'widgets/footer.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MiniBinWebsiteApp());
}

class MiniBinWebsiteApp extends StatelessWidget {
  const MiniBinWebsiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppLang>(
      valueListenable: currentLang,
      builder: (context, lang, _) {
        return MaterialApp(
          key: ValueKey('app_$lang'),
          title: lang == AppLang.ru
              ? 'MiniBin v2 — Корзина Windows в системном трее'
              : 'MiniBin v2 — Windows Recycle Bin in System Tray',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          home: LandingPage(key: ValueKey('landing_$lang')),
        );
      },
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _featuresKey = GlobalKey();
  final GlobalKey _demoKey = GlobalKey();
  final GlobalKey _comparisonKey = GlobalKey();
  final GlobalKey _faqKey = GlobalKey();
  final GlobalKey _downloadKey = GlobalKey();

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient background glow (Undoit style)
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            height: 650,
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.heroGlowGradient,
              ),
            ),
          ),

          // Main scrollable content
          Column(
            children: [
              // Sticky Navigation Bar
              NavBar(
                onFeaturesTap: () => _scrollToKey(_featuresKey),
                onDemoTap: () => _scrollToKey(_demoKey),
                onComparisonTap: () => _scrollToKey(_comparisonKey),
                onFaqTap: () => _scrollToKey(_faqKey),
                onDownloadTap: () => _scrollToKey(_downloadKey),
              ),

              // Scrollable Body
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      HeroSection(
                        onDemoTap: () => _scrollToKey(_demoKey),
                      ),
                      Container(
                        key: _demoKey,
                        child: const InteractiveFlyoutDemo(),
                      ),
                      Container(
                        key: _featuresKey,
                        child: const FeaturesGrid(),
                      ),
                      Container(
                        key: _comparisonKey,
                        child: const ComparisonTable(),
                      ),
                      Container(
                        key: _faqKey,
                        child: const FaqSection(),
                      ),
                      Container(
                        key: _downloadKey,
                        child: const DownloadCta(),
                      ),
                      const Footer(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
