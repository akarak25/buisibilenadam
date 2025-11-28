import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/camera_screen.dart';
import 'package:palm_analysis/screens/history_screen.dart';
import 'package:palm_analysis/screens/settings_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/services/auth_service.dart';
import 'package:palm_analysis/services/astrology_service.dart';
import 'package:palm_analysis/services/streak_service.dart';
import 'package:palm_analysis/screens/daily_astrology_screen.dart';
import 'package:palm_analysis/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _totalAnalyses = 0;
  User? _currentUser;
  int _currentStreak = 0;
  final AuthService _authService = AuthService();
  final AstrologyService _astrologyService = AstrologyService();
  final StreakService _streakService = StreakService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      final user = await _authService.loadStoredUser();

      // Record app open and get streak
      final streakData = await _streakService.recordAppOpen();

      if (mounted) {
        setState(() {
          _totalAnalyses = totalAnalyses;
          _currentUser = user;
          _currentStreak = streakData.currentStreak;
        });
      }
    } catch (e) {
      print('Data loading error: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryIndigo.withOpacity(0.12),
                      AppTheme.primaryPurple.withOpacity(0.08),
                    ],
                  ),
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
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.1),
                      AppTheme.primaryIndigo.withOpacity(0.06),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // App name with gradient
                        ShaderMask(
                          blendMode: BlendMode.srcIn,
                          shaderCallback: (bounds) =>
                              AppTheme.primaryGradient.createShader(
                            Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                          ),
                          child: Text(
                            lang.appName,
                            style: GoogleFonts.inter(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Action buttons
                        _buildIconButton(
                          icon: Icons.settings_rounded,
                          onTap: () {
                            Navigator.of(context)
                                .push(
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            )
                                .then((_) => _loadData());
                          },
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Greeting card
                          _buildGreetingCard(lang),

                          const SizedBox(height: 16),

                          // Daily Astrology Card
                          _buildDailyAstrologyCard(lang),

                          const SizedBox(height: 24),

                          // Main action - Analyze Hand
                          Center(
                            child: AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _pulseAnimation.value,
                                  child: child,
                                );
                              },
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(
                                    MaterialPageRoute(
                                      builder: (_) => const CameraScreen(),
                                    ),
                                  )
                                      .then((_) => _loadData());
                                },
                                child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.primaryGradient,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.primaryIndigo
                                            .withOpacity(0.4),
                                        blurRadius: 30,
                                        spreadRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.back_hand_rounded,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        lang.analyzeHand,
                                        style: GoogleFonts.inter(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          Center(
                            child: Text(
                              lang.takePicture,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Feature cards
                          _buildFeatureCard(
                            icon: Icons.history_rounded,
                            title: lang.analysisHistory,
                            subtitle:
                                '$_totalAnalyses ${lang.analysisHistory.toLowerCase()}',
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '$_totalAnalyses',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onTap: () {
                              Navigator.of(context)
                                  .push(
                                MaterialPageRoute(
                                  builder: (_) => const HistoryScreen(),
                                ),
                              )
                                  .then((_) => _loadData());
                            },
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
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

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          shape: BoxShape.circle,
          boxShadow: AppTheme.cardShadow,
        ),
        child: Icon(
          icon,
          color: AppTheme.textPrimary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildGreetingCard(dynamic lang) {
    final greeting = _getGreeting(lang);
    final userName = _currentUser?.name ?? lang.settings;
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';
    final streakEmoji = _streakService.getStreakEmoji(_currentStreak);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.5),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    _currentUser?.name.isNotEmpty == true
                        ? _currentUser!.name[0].toUpperCase()
                        : '👋',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser != null ? userName : lang.appDescription,
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              // Streak indicator
              if (_currentStreak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.warningAmber.withOpacity(0.2),
                        AppTheme.warningAmber.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningAmber.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        streakEmoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$_currentStreak ${isTurkish ? "gün" : "days"}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.warningAmber,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getGreeting(dynamic lang) {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return lang.goodMorning;
    } else if (hour < 18) {
      return lang.goodAfternoon;
    } else {
      return lang.goodEvening;
    }
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
    bool isPremium = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? AppTheme.warningAmber.withOpacity(0.2)
                : Colors.white.withOpacity(0.5),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isPremium
                        ? AppTheme.premiumGradient
                        : AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyAstrologyCard(dynamic lang) {
    final moonPhase = _astrologyService.getCurrentMoonPhase();
    final moonSign = _astrologyService.getMoonSign();
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';
    final hasAnalysis = _totalAnalyses > 0;

    final moonPhaseName = isTurkish
        ? _astrologyService.getMoonPhaseTr(moonPhase)
        : _astrologyService.getMoonPhaseEn(moonPhase);
    final moonSignName = isTurkish
        ? _astrologyService.getZodiacSignTr(moonSign)
        : _astrologyService.getZodiacSignEn(moonSign);
    // Use general insights if no analysis, palm-specific if they have analysis
    final dailyInsight = hasAnalysis
        ? (isTurkish
            ? _astrologyService.getDailyInsightTr(moonSign)
            : _astrologyService.getDailyInsightEn(moonSign))
        : (isTurkish
            ? _astrologyService.getGeneralDailyInsightTr(moonSign)
            : _astrologyService.getGeneralDailyInsightEn(moonSign));
    final moonPhaseIcon = _astrologyService.getMoonPhaseIcon(moonPhase);
    final zodiacIcon = _astrologyService.getZodiacSignIcon(moonSign);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DailyAstrologyScreen(hasAnalysis: hasAnalysis),
          ),
        );
      },
      child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryIndigo.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryIndigo.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    moonPhaseIcon,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lang.todaysEnergy,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                    Text(
                      '$moonPhaseName • ${lang.moonIn} $zodiacIcon $moonSignName',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Daily insight
          Text(
            dailyInsight,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textPrimary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          // Tap hint
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                Localizations.localeOf(context).languageCode == 'tr'
                    ? 'Detaylar için dokun'
                    : 'Tap for details',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.primaryIndigo.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: AppTheme.primaryIndigo.withOpacity(0.7),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }
}
