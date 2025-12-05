import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/auth/login_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/widgets/common/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _scanLineController;
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late Animation<double> _scanLineAnimation;
  late Animation<double> _pulseAnimation;

  final List<OnboardingData> _pages = [
    OnboardingData(
      icon: Icons.fingerprint,
      accentColor: AppTheme.primaryIndigo,
    ),
    OnboardingData(
      icon: Icons.document_scanner_outlined,
      accentColor: const Color(0xFF0EA5E9),
    ),
    OnboardingData(
      icon: Icons.psychology_outlined,
      accentColor: AppTheme.primaryPurple,
    ),
    OnboardingData(
      icon: Icons.insights_outlined,
      accentColor: const Color(0xFF10B981),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );
    _scanLineController.repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );
    _rotateController.repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final content =
        AppLocalizations.of(context).currentLanguage.onboardingContent;
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

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
    final content =
        AppLocalizations.of(context).currentLanguage.onboardingContent;
    final lang = AppLocalizations.of(context).currentLanguage;
    final isTurkish =
        AppLocalizations.of(context).locale.languageCode == 'tr';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E1A),
              Color(0xFF1A1F35),
              Color(0xFF0A0E1A),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated grid background
            Positioned.fill(
              child: CustomPaint(
                painter: _GridBackgroundPainter(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.1),
                ),
              ),
            ),

            // Rotating outer ring
            Positioned(
              top: MediaQuery.of(context).size.height * 0.15,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _rotateController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotateController.value * 2 * math.pi,
                      child: Container(
                        width: 280,
                        height: 280,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _DashedCirclePainter(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                            dashLength: 10,
                            gapLength: 10,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Logo/Brand
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.fingerprint,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'PALMIFY',
                              style: GoogleFonts.orbitron(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                        // Skip button
                        TextButton(
                          onPressed: _skipOnboarding,
                          child: Text(
                            lang.skip,
                            style: GoogleFonts.inter(
                              color: Colors.white60,
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
                          stepNumber: index + 1,
                          totalSteps: content.length,
                          scanLineAnimation: _scanLineAnimation,
                          pulseAnimation: _pulseAnimation,
                        );
                      },
                    ),
                  ),

                  // Bottom section
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        // Progress indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            content.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _currentPage == index ? 32 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: _currentPage == index
                                    ? AppTheme.primaryGradient
                                    : null,
                                color: _currentPage == index
                                    ? null
                                    : Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                boxShadow: _currentPage == index
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryIndigo
                                              .withValues(alpha: 0.5),
                                          blurRadius: 10,
                                        ),
                                      ]
                                    : null,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Next/Start button
                        _buildActionButton(content, isTurkish),

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

  Widget _buildActionButton(List<Map<String, String>> content, bool isTurkish) {
    final isLast = _currentPage == content.length - 1;

    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLast
                  ? (isTurkish ? 'Başlat' : 'Get Started')
                  : (isTurkish ? 'Devam' : 'Continue'),
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isLast ? Icons.rocket_launch_outlined : Icons.arrow_forward,
              color: Colors.white,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingData {
  final IconData icon;
  final Color accentColor;

  OnboardingData({
    required this.icon,
    required this.accentColor,
  });
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingData data;
  final String title;
  final String description;
  final int stepNumber;
  final int totalSteps;
  final Animation<double> scanLineAnimation;
  final Animation<double> pulseAnimation;

  const _OnboardingPage({
    required this.data,
    required this.title,
    required this.description,
    required this.stepNumber,
    required this.totalSteps,
    required this.scanLineAnimation,
    required this.pulseAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Futuristic icon container
          _buildIconContainer(),

          const SizedBox(height: 48),

          // Step indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: data.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: data.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              'STEP $stepNumber OF $totalSteps',
              style: GoogleFonts.orbitron(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: data.accentColor,
                letterSpacing: 2,
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Title
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (bounds) => LinearGradient(
              colors: [Colors.white, data.accentColor],
            ).createShader(bounds),
            child: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 26,
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
              fontSize: 15,
              color: Colors.white60,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer glow ring
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 180 * pulseAnimation.value,
                height: 180 * pulseAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: data.accentColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              );
            },
          ),

          // Middle ring
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: data.accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),

          // Inner container with icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  data.accentColor.withValues(alpha: 0.2),
                  data.accentColor.withValues(alpha: 0.05),
                ],
              ),
              border: Border.all(
                color: data.accentColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.accentColor.withValues(alpha: 0.3),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Center(
                  child: ShaderMask(
                    blendMode: BlendMode.srcIn,
                    shaderCallback: (bounds) => LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        data.accentColor,
                      ],
                    ).createShader(bounds),
                    child: Icon(
                      data.icon,
                      size: 56,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Scan line effect
          AnimatedBuilder(
            animation: scanLineAnimation,
            builder: (context, child) {
              return Positioned(
                top: 40 + (scanLineAnimation.value * 120),
                child: Container(
                  width: 100,
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        data.accentColor,
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: data.accentColor.withValues(alpha: 0.8),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Corner accents
          ..._buildCornerAccents(),
        ],
      ),
    );
  }

  List<Widget> _buildCornerAccents() {
    const size = 16.0;
    const offset = 85.0;

    return [
      Positioned(
        top: 100 - offset,
        left: 100 - offset,
        child: _CornerAccent(size: size, color: data.accentColor),
      ),
      Positioned(
        top: 100 - offset,
        right: 100 - offset,
        child: Transform.rotate(
          angle: math.pi / 2,
          child: _CornerAccent(size: size, color: data.accentColor),
        ),
      ),
      Positioned(
        bottom: 100 - offset,
        left: 100 - offset,
        child: Transform.rotate(
          angle: -math.pi / 2,
          child: _CornerAccent(size: size, color: data.accentColor),
        ),
      ),
      Positioned(
        bottom: 100 - offset,
        right: 100 - offset,
        child: Transform.rotate(
          angle: math.pi,
          child: _CornerAccent(size: size, color: data.accentColor),
        ),
      ),
    ];
  }
}

class _CornerAccent extends StatelessWidget {
  final double size;
  final Color color;

  const _CornerAccent({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(color: color),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;

  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, 0)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GridBackgroundPainter extends CustomPainter {
  final Color color;

  _GridBackgroundPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    const spacing = 30.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var y = 0.0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double dashLength;
  final double gapLength;

  _DashedCirclePainter({
    required this.color,
    required this.dashLength,
    required this.gapLength,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circumference = 2 * math.pi * radius;
    final dashCount = (circumference / (dashLength + gapLength)).floor();
    final anglePerDash = 2 * math.pi / dashCount;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = i * anglePerDash;
      final sweepAngle = anglePerDash * (dashLength / (dashLength + gapLength));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
