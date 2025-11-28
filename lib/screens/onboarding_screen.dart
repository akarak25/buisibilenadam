import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/home_screen.dart';
import 'package:palm_analysis/screens/auth/login_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/widgets/common/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.back_hand_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
      ),
    ),
    OnboardingData(
      icon: Icons.camera_alt_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
      ),
    ),
    OnboardingData(
      icon: Icons.psychology_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
      ),
    ),
    OnboardingData(
      icon: Icons.auto_awesome_rounded,
      iconGradient: const LinearGradient(
        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
      ),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final content = AppLocalizations.of(context).currentLanguage.onboardingContent;
    if (_currentPage < content.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    // Save onboarding completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    // Navigate to login/register or home
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _skipOnboarding() {
    _finishOnboarding();
  }

  @override
  Widget build(BuildContext context) {
    final content = AppLocalizations.of(context).currentLanguage.onboardingContent;
    final lang = AppLocalizations.of(context).currentLanguage;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Soft overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withOpacity(0.95),
                    Colors.white.withOpacity(0.90),
                  ],
                ),
              ),
            ),

            // Decorative elements
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigo.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -80,
              child: Container(
                width: 250,
                height: 250,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Skip button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            lang.skip,
                            style: GoogleFonts.inter(
                              color: AppTheme.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (page) {
                        setState(() => _currentPage = page);
                      },
                      itemCount: content.length,
                      itemBuilder: (context, index) {
                        return _OnboardingPage(
                          data: _pages[index % _pages.length],
                          title: content[index]['title']!,
                          description: content[index]['description']!,
                        );
                      },
                    ),
                  ),

                  // Bottom section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Page indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            content.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 28 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: _currentPage == index
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: _currentPage == index
                                    ? null
                                    : AppTheme.borderLight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Next/Start button
                        GradientButton(
                          text: _currentPage == content.length - 1
                              ? lang.takePicture
                              : lang.analyzeHand,
                          onPressed: _nextPage,
                          icon: _currentPage == content.length - 1
                              ? Icons.arrow_forward_rounded
                              : null,
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final LinearGradient iconGradient;

  OnboardingData({
    required this.icon,
    required this.iconGradient,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final String title;
  final String description;

  const _OnboardingPage({
    required this.data,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon with glassmorphism card
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppTheme.primaryIndigo.withOpacity(0.1),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => data.iconGradient.createShader(
                      Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                    ),
                    child: Icon(
                      data.icon,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 48),

          // Title with gradient
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => AppTheme.primaryGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            ),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
