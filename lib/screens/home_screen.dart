import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/screens/camera_screen.dart';
import 'package:palm_analysis/screens/history_screen.dart';
import 'package:palm_analysis/screens/settings_screen.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/services/auth_service.dart';
import 'package:palm_analysis/services/api_service.dart';
import 'package:palm_analysis/services/token_service.dart';
import 'package:palm_analysis/services/astrology_service.dart';
import 'package:palm_analysis/services/streak_service.dart';
import 'package:palm_analysis/services/daily_reading_service.dart';
import 'package:palm_analysis/screens/daily_astrology_screen.dart';
import 'package:palm_analysis/screens/personalized_daily_screen.dart';
import 'package:palm_analysis/models/user.dart';
import 'package:palm_analysis/models/daily_reading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  int _totalAnalyses = 0;
  User? _currentUser;
  int _currentStreak = 0;
  DailyReading? _dailyReading;
  bool _isLoadingReading = false;
  final AuthService _authService = AuthService();
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  final AstrologyService _astrologyService = AstrologyService();
  final StreakService _streakService = StreakService();
  final DailyReadingService _dailyReadingService = DailyReadingService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
      int totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      final user = await _authService.loadStoredUser();

      // If user is logged in, try to get count from backend
      final token = await _tokenService.getToken();
      if (token != null) {
        try {
          final queries = await _apiService.getQueries();
          totalAnalyses = queries.length;
          // Update local storage with backend count
          await prefs.setInt('total_analyses', totalAnalyses);
          debugPrint('Synced analysis count from backend: $totalAnalyses');
        } catch (e) {
          debugPrint('Backend sync error (using local): $e');
        }
      }

      // Record app open and get streak
      final streakData = await _streakService.recordAppOpen();

      if (mounted) {
        setState(() {
          _totalAnalyses = totalAnalyses;
          _currentUser = user;
          _currentStreak = streakData.currentStreak;
        });
      }

      // Load personalized daily reading (async, don't block UI)
      _loadDailyReading();
    } catch (e) {
      debugPrint('Data loading error: $e');
    }
  }

  Future<void> _loadDailyReading() async {
    if (_isLoadingReading || !mounted) return;

    setState(() => _isLoadingReading = true);

    try {
      final locale = Localizations.localeOf(context);
      final reading = await _dailyReadingService.getDailyReading(
        lang: locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _dailyReading = reading;
          _isLoadingReading = false;
        });
      }
    } catch (e) {
      debugPrint('Daily reading load error: $e');
      if (mounted) {
        setState(() => _isLoadingReading = false);
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _animationController.stop();
    } else if (state == AppLifecycleState.resumed) {
      _animationController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
                    Colors.white.withValues(alpha: 0.95),
                    Colors.white.withValues(alpha: 0.90),
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
                      AppTheme.primaryIndigo.withValues(alpha: 0.12),
                      AppTheme.primaryPurple.withValues(alpha: 0.08),
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
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                      AppTheme.primaryIndigo.withValues(alpha: 0.06),
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
                                            .withValues(alpha: 0.4),
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
          color: Colors.white.withValues(alpha: 0.8),
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
            ),
            boxShadow: AppTheme.cardShadow,
          ),
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
                        AppTheme.warningAmber.withValues(alpha: 0.2),
                        AppTheme.warningAmber.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warningAmber.withValues(alpha: 0.3),
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
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPremium
                ? AppTheme.warningAmber.withValues(alpha: 0.2)
                : Colors.white.withValues(alpha: 0.5),
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
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';
    final hasAnalysis = _totalAnalyses > 0;

    // Show loading state while fetching personalized reading
    if (_isLoadingReading && hasAnalysis && _dailyReading == null) {
      return _buildLoadingDailyCard(isTurkish);
    }

    // If we have personalized reading, show that
    if (_dailyReading != null && _dailyReading!.hasPalmProfile) {
      return _buildPersonalizedDailyCard(lang, isTurkish);
    }

    // Otherwise show generic astrology card
    final moonPhase = _astrologyService.getCurrentMoonPhase();
    final moonSign = _astrologyService.getMoonSign();

    final moonPhaseName = isTurkish
        ? _astrologyService.getMoonPhaseTr(moonPhase)
        : _astrologyService.getMoonPhaseEn(moonPhase);
    final moonSignName = isTurkish
        ? _astrologyService.getZodiacSignTr(moonSign)
        : _astrologyService.getZodiacSignEn(moonSign);
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
            AppTheme.primaryIndigo.withValues(alpha: 0.1),
            AppTheme.primaryPurple.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryIndigo.withValues(alpha: 0.2),
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
                isTurkish ? 'Detaylar için dokun' : 'Tap for details',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 10,
                color: AppTheme.primaryIndigo.withValues(alpha: 0.7),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// Personalized daily reading card (when palm profile exists)
  Widget _buildPersonalizedDailyCard(dynamic lang, bool isTurkish) {
    final reading = _dailyReading!;

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PersonalizedDailyScreen(initialReading: reading),
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
              const Color(0xFF1a1a2e).withValues(alpha: 0.95),
              AppTheme.primaryIndigo.withValues(alpha: 0.85),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryIndigo.withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with personalized badge
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      reading.astronomy.moonPhase.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isTurkish ? 'Günlük El Çizgisi Yorumunuz' : 'Your Daily Palm Reading',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.successGreen.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isTurkish ? 'Kişisel' : 'Personal',
                              style: GoogleFonts.inter(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.successGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${reading.astronomy.moonPhase.getName(isTurkish)} • ${reading.astronomy.moonSign.icon} ${reading.astronomy.moonSign.getName(isTurkish)}',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Personalized greeting/energy
            Text(
              reading.reading.dailyEnergy,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            // Lucky elements row
            Row(
              children: [
                _buildMiniLuckyElement(
                  '🎨',
                  reading.reading.luckyElements.color,
                ),
                const SizedBox(width: 8),
                _buildMiniLuckyElement(
                  '🔢',
                  reading.reading.luckyElements.number,
                ),
                const SizedBox(width: 8),
                _buildMiniLuckyElement(
                  '⏰',
                  reading.reading.luckyElements.time,
                ),
                const Spacer(),
                // Tap hint
                Row(
                  children: [
                    Text(
                      isTurkish ? 'Detaylar' : 'Details',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 10,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLuckyElement(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Loading state card for daily reading
  Widget _buildLoadingDailyCard(bool isTurkish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e).withValues(alpha: 0.95),
            AppTheme.primaryIndigo.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: _ShimmerIcon(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isTurkish ? 'Günlük Yorumunuz Yükleniyor' : 'Loading Your Daily Reading',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _ShimmerBar(width: 120, height: 10),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Shimmer content lines
          _ShimmerBar(width: double.infinity, height: 14),
          const SizedBox(height: 8),
          _ShimmerBar(width: 200, height: 14),
          const SizedBox(height: 14),
          // Shimmer lucky elements
          Row(
            children: [
              _ShimmerBar(width: 60, height: 24),
              const SizedBox(width: 8),
              _ShimmerBar(width: 50, height: 24),
              const SizedBox(width: 8),
              _ShimmerBar(width: 70, height: 24),
            ],
          ),
        ],
      ),
    );
  }
}

/// Animated shimmer bar for loading state
class _ShimmerBar extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBar({required this.width, required this.height});

  @override
  State<_ShimmerBar> createState() => _ShimmerBarState();
}

class _ShimmerBarState extends State<_ShimmerBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.height / 2),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + _animation.value, 0),
              end: Alignment(_animation.value, 0),
              colors: [
                Colors.white.withValues(alpha: 0.1),
                Colors.white.withValues(alpha: 0.25),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Animated shimmer icon for loading state
class _ShimmerIcon extends StatefulWidget {
  const _ShimmerIcon();

  @override
  State<_ShimmerIcon> createState() => _ShimmerIconState();
}

class _ShimmerIconState extends State<_ShimmerIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: 0.3 + (_controller.value * 0.7),
          child: const Text(
            '✨',
            style: TextStyle(fontSize: 22),
          ),
        );
      },
    );
  }
}
