import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/utils/constants.dart';
import 'package:palm_analysis/screens/home_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Widget> _buildDots() {
    final onboardingContent = AppLocalizations.of(context).currentLanguage.onboardingContent;
    List<Widget> dots = [];
    for (int i = 0; i < onboardingContent.length; i++) {
      dots.add(
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: _currentPage == i ? 24 : 8,
          decoration: BoxDecoration(
            color: _currentPage == i
                ? AppTheme.primaryColor
                : AppTheme.dividerColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );
    }
    return dots;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                itemCount: AppLocalizations.of(context).currentLanguage.onboardingContent.length,
                itemBuilder: (context, index) {
                  final onboardingContent = AppLocalizations.of(context).currentLanguage.onboardingContent;
                  return OnboardingPage(
                    title: onboardingContent[index]['title']!,
                    description: onboardingContent[index]['description']!,
                    index: index,
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _buildDots(),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage == AppLocalizations.of(context).currentLanguage.onboardingContent.length - 1) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                    ),
                    child: Text(
                      _currentPage == AppLocalizations.of(context).currentLanguage.onboardingContent.length - 1
                          ? AppLocalizations.of(context).currentLanguage.takePicture
                          : AppLocalizations.of(context).currentLanguage.analyzeHand,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (_currentPage != AppLocalizations.of(context).currentLanguage.onboardingContent.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                      child: Text(AppLocalizations.of(context).currentLanguage.settings, style: const TextStyle(fontSize: 16)),
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

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final int index;

  const OnboardingPage({
    super.key,
    required this.title,
    required this.description,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildIllustration(),
          const SizedBox(height: 32),
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textColorLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    IconData iconData;

    switch (index) {
      case 0:
        iconData = Icons.back_hand_outlined;
        break;
      case 1:
        iconData = Icons.camera_alt_outlined;
        break;
      case 2:
        iconData = Icons.psychology_outlined;
        break;
      case 3:
        iconData = Icons.lightbulb_outline;
        break;
      default:
        iconData = Icons.back_hand_outlined;
    }

    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        iconData,
        size: 100,
        color: AppTheme.primaryColor,
      ),
    );
  }
}
