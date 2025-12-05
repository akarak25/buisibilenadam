import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/models/daily_reading.dart';
import 'package:palm_analysis/services/daily_reading_service.dart';
import 'package:palm_analysis/services/auth_service.dart';
import 'package:palm_analysis/screens/camera_screen.dart';

/// Personalized daily reading screen with palm + astrology combination
class PersonalizedDailyScreen extends StatefulWidget {
  final DailyReading? initialReading;

  const PersonalizedDailyScreen({
    super.key,
    this.initialReading,
  });

  @override
  State<PersonalizedDailyScreen> createState() => _PersonalizedDailyScreenState();
}

class _PersonalizedDailyScreenState extends State<PersonalizedDailyScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  final DailyReadingService _readingService = DailyReadingService();
  final AuthService _authService = AuthService();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  DailyReading? _reading;
  bool _isLoading = true;
  String? _errorMessage;
  String? _userName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);

    _loadUserName();

    if (widget.initialReading != null) {
      _reading = widget.initialReading;
      _isLoading = false;
    } else {
      _loadReading();
    }
  }

  Future<void> _loadUserName() async {
    final user = await _authService.loadStoredUser();
    if (mounted && user != null) {
      setState(() {
        _userName = user.name;
      });
    }
  }

  String _getDynamicGreeting(dynamic lang) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = lang.goodMorning;
    } else if (hour < 18) {
      greeting = lang.goodAfternoon;
    } else {
      greeting = lang.goodEvening;
    }

    if (_userName != null && _userName!.isNotEmpty) {
      return '$greeting $_userName!';
    }
    return '$greeting!';
  }

  Future<void> _loadReading() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final locale = Localizations.localeOf(context);
      final reading = await _readingService.getDailyReading(
        lang: locale.languageCode,
      );

      if (mounted) {
        final locale = Localizations.localeOf(context);
        final isTurkish = locale.languageCode == 'tr';
        setState(() {
          _reading = reading;
          _isLoading = false;
          if (reading == null) {
            _errorMessage = isTurkish
                ? 'Kişiselleştirilmiş okuma için önce el analizi yapın.'
                : 'Please complete a palm analysis first for personalized readings.';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
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
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Background overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.primaryIndigo.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withValues(alpha: 0.12),
                      AppTheme.primaryIndigo.withValues(alpha: 0.08),
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
                  _buildAppBar(lang, isTurkish),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingState()
                        : _reading == null || _errorMessage != null
                            ? _buildNoProfileState(isTurkish)
                            : _buildContent(isTurkish, lang),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(dynamic lang, bool isTurkish) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isTurkish ? 'Günlük El Çizgisi Analiziniz' : 'Your Daily Palm Analysis',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
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

  Widget _buildLoadingState() {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
          ),
          const SizedBox(height: 16),
          Text(
            isTurkish ? 'Günlük yorumunuz hazırlanıyor...' : 'Preparing your daily reading...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProfileState(bool isTurkish) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.back_hand_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            isTurkish
                ? 'Kişisel Günlük Yorumunuz'
                : 'Your Personal Daily Reading',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            isTurkish
                ? 'El çizgilerinize özel günlük yorumlar almak için önce bir el analizi yapmanız gerekiyor.'
                : 'You need to complete a palm analysis first to receive personalized daily readings.',
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildFeatureList(isTurkish),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.camera_alt_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    isTurkish ? 'El Analizi Yap' : 'Analyze Palm',
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
        ],
      ),
    );
  }

  Widget _buildFeatureList(bool isTurkish) {
    final features = isTurkish
        ? [
            'El çizgilerinize özel günlük yorumlar',
            'Ay fazı ve burç etkileşimi analizi',
            'Günlük şanslı renk ve sayılar',
            'Kişiselleştirilmiş tavsiyeler',
          ]
        : [
            'Daily readings tailored to your palm',
            'Moon phase and zodiac interaction',
            'Daily lucky colors and numbers',
            'Personalized advice',
          ];

    return Column(
      children: features.map((feature) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.successGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 16,
                color: AppTheme.successGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                feature,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildContent(bool isTurkish, dynamic lang) {
    final reading = _reading!;

    return RefreshIndicator(
      onRefresh: () async {
        final locale = Localizations.localeOf(context);
        final newReading = await _readingService.refreshDailyReading(
          lang: locale.languageCode,
        );
        if (mounted && newReading != null) {
          setState(() => _reading = newReading);
        }
      },
      color: AppTheme.primaryIndigo,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Greeting card with moon
            _buildGreetingCard(reading, isTurkish, lang),

            const SizedBox(height: 20),

            // Active line card
            _buildActiveLineCard(reading, isTurkish),

            const SizedBox(height: 20),

            // Moon influence card
            _buildMoonInfluenceCard(reading, isTurkish),

            const SizedBox(height: 20),

            // Advice card
            _buildAdviceCard(reading, isTurkish),

            const SizedBox(height: 20),

            // Lucky elements row
            _buildLuckyElementsRow(reading, isTurkish),

            // Warning card (if any)
            if (reading.reading.warning != null) ...[
              const SizedBox(height: 20),
              _buildWarningCard(reading, isTurkish),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildGreetingCard(DailyReading reading, bool isTurkish, dynamic lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            AppTheme.primaryIndigo.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Moon icon animated
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Text(
                  reading.astronomy.moonPhase.icon,
                  style: const TextStyle(fontSize: 64),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Dynamic greeting based on device time
          Text(
            _getDynamicGreeting(lang),
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Moon phase and sign
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${reading.astronomy.moonPhase.getName(isTurkish)} • ${reading.astronomy.moonSign.icon} ${reading.astronomy.moonSign.getName(isTurkish)}',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Daily energy
          Text(
            reading.reading.dailyEnergy,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.85),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveLineCard(DailyReading reading, bool isTurkish) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.back_hand_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTurkish ? 'Günün Aktif Çizgisi' : "Today's Active Line",
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                    Text(
                      '${reading.astronomy.activeLine.getName(isTurkish)} (${reading.astronomy.activeLine.getPlanet(isTurkish)})',
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
          const SizedBox(height: 16),
          Text(
            reading.reading.activeLineReading,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoonInfluenceCard(DailyReading reading, bool isTurkish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    reading.astronomy.moonSign.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isTurkish ? 'Ay Etkisi' : 'Moon Influence',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${reading.astronomy.moonSign.getName(isTurkish)} - ${reading.astronomy.moonSign.getElement(isTurkish)}',
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
          const SizedBox(height: 16),
          Text(
            reading.reading.moonInfluence,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: AppTheme.textPrimary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(DailyReading reading, bool isTurkish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.successGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.successGreen.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isTurkish ? 'Günün Tavsiyesi' : "Today's Advice",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            reading.reading.advice,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withValues(alpha: 0.95),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLuckyElementsRow(DailyReading reading, bool isTurkish) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryIndigo.withValues(alpha: 0.2),
                      AppTheme.primaryPurple.withValues(alpha: 0.15),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: AppTheme.primaryIndigo,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isTurkish ? 'Bugünün Şanslı Elementleri' : "Today's Lucky Elements",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // Lucky Color Card
        _buildExpandableLuckyCard(
          icon: '🎨',
          iconBgColor: const Color(0xFFE8D5F2),
          label: isTurkish ? 'Şanslı Renk' : 'Lucky Color',
          value: reading.reading.luckyElements.color,
          description: reading.reading.luckyElements.colorDescription,
          tipText: isTurkish
              ? 'Bu rengi bugün kıyafetlerinizde veya aksesuarlarınızda tercih edin'
              : 'Wear this color in your clothes or accessories today',
          gradientColors: [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
          isTurkish: isTurkish,
        ),

        const SizedBox(height: 12),

        // Lucky Number Card
        _buildExpandableLuckyCard(
          icon: '✨',
          iconBgColor: const Color(0xFFD5E8F2),
          label: isTurkish ? 'Şanslı Sayı' : 'Lucky Number',
          value: reading.reading.luckyElements.number,
          description: reading.reading.luckyElements.numberDescription,
          tipText: isTurkish
              ? 'Bu sayıyı önemli kararlarınızda ve planlarınızda aklınızda tutun'
              : 'Keep this number in mind for important decisions and plans',
          gradientColors: [const Color(0xFF3498DB), const Color(0xFF2980B9)],
          isTurkish: isTurkish,
        ),

        const SizedBox(height: 12),

        // Lucky Time Card
        _buildExpandableLuckyCard(
          icon: '⏰',
          iconBgColor: const Color(0xFFD5F2E8),
          label: isTurkish ? 'Enerjik Saat Dilimi' : 'Energetic Time',
          value: reading.reading.luckyElements.time,
          description: reading.reading.luckyElements.timeDescription,
          tipText: isTurkish
              ? 'Önemli işlerinizi bu saat dilimine planlayın'
              : 'Plan your important tasks for this time period',
          gradientColors: [const Color(0xFF27AE60), const Color(0xFF1E8449)],
          isTurkish: isTurkish,
        ),
      ],
    );
  }

  Widget _buildExpandableLuckyCard({
    required String icon,
    required Color iconBgColor,
    required String label,
    required String value,
    required String description,
    required String tipText,
    required List<Color> gradientColors,
    required bool isTurkish,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),
          ),
          title: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: gradientColors[0],
            ),
          ),
          trailing: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: gradientColors[0].withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: gradientColors[0],
            ),
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradientColors[0].withValues(alpha: 0.08),
                    gradientColors[1].withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: gradientColors[0].withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (description.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.star_rounded,
                            size: 18,
                            color: gradientColors[0],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            description,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.textPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  // Tip
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 18,
                          color: gradientColors[0],
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tipText,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
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

  Widget _buildWarningCard(DailyReading reading, bool isTurkish) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningAmber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.warningAmber.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppTheme.warningAmber,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              reading.reading.warning!,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
