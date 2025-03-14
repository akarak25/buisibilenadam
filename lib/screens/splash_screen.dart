import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/utils/constants.dart';
import 'package:palm_analysis/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    try {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800),
      );

      _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
        ),
      );

      _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOutBack),
        ),
      );

      _controller.forward();

      // Daha güvenli geçiş için try-catch içine alalım
      Future.delayed(const Duration(seconds: 3), () {
        try {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const OnboardingScreen()),
            );
          }
        } catch (e) {
          print("OnboardingScreen'e geçiş hatası: $e");
          if (mounted) {
            setState(() {
              _hasError = true;
              _errorMessage = "Uygulama başlatılamadı: $e";
            });
          }
        }
      });
    } catch (e) {
      print("SplashScreen initState hatası: $e");
      setState(() {
        _hasError = true;
        _errorMessage = "Uygulama başlatılamadı: $e";
      });
    }
  }

  @override
  void dispose() {
    try {
      _controller.dispose();
    } catch (e) {
      print("Controller dispose hatası: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Bir Hata Oluştu',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    try {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 15,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.back_hand_outlined,
                          size: 80,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                        const Text(
                          'Claude Yapay Zeka ile El Çizgisi Analizi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        Constants.appDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textColorLight,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      // Widget build sırasında hata oluşursa basit bir hata ekranı göster
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text("UI oluşturulurken hata: $e"),
        ),
      );
    }
  }
}
