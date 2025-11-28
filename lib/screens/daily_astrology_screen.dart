import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/services/astrology_service.dart';

/// Daily astrology screen with detailed moon phase and zodiac information
class DailyAstrologyScreen extends StatefulWidget {
  final bool hasAnalysis;

  const DailyAstrologyScreen({
    super.key,
    this.hasAnalysis = false,
  });

  @override
  State<DailyAstrologyScreen> createState() => _DailyAstrologyScreenState();
}

class _DailyAstrologyScreenState extends State<DailyAstrologyScreen>
    with SingleTickerProviderStateMixin {
  final AstrologyService _astrologyService = AstrologyService();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context).currentLanguage;
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    final moonPhase = _astrologyService.getCurrentMoonPhase();
    final moonSign = _astrologyService.getMoonSign();
    final daysUntilFull = _astrologyService.getDaysUntilFullMoon();
    final daysUntilNew = _astrologyService.getDaysUntilNewMoon();

    final moonPhaseName = isTurkish
        ? _astrologyService.getMoonPhaseTr(moonPhase)
        : _astrologyService.getMoonPhaseEn(moonPhase);
    final moonSignName = isTurkish
        ? _astrologyService.getZodiacSignTr(moonSign)
        : _astrologyService.getZodiacSignEn(moonSign);
    // Use general insights if no analysis, palm-specific if they have analysis
    final dailyInsight = widget.hasAnalysis
        ? (isTurkish
            ? _astrologyService.getDailyInsightTr(moonSign)
            : _astrologyService.getDailyInsightEn(moonSign))
        : (isTurkish
            ? _astrologyService.getGeneralDailyInsightTr(moonSign)
            : _astrologyService.getGeneralDailyInsightEn(moonSign));
    final moonPhaseInsight = widget.hasAnalysis
        ? (isTurkish
            ? _astrologyService.getMoonPhaseInsightTr(moonPhase)
            : _astrologyService.getMoonPhaseInsightEn(moonPhase))
        : (isTurkish
            ? _astrologyService.getGeneralMoonPhaseInsightTr(moonPhase)
            : _astrologyService.getGeneralMoonPhaseInsightEn(moonPhase));
    final moonPhaseIcon = _astrologyService.getMoonPhaseIcon(moonPhase);
    final zodiacIcon = _astrologyService.getZodiacSignIcon(moonSign);

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
                    AppTheme.primaryIndigo.withOpacity(0.1),
                    Colors.white.withOpacity(0.95),
                  ],
                ),
              ),
            ),

            // Decorative circles
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple.withOpacity(0.15),
                      AppTheme.primaryIndigo.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryIndigo.withOpacity(0.08),
                      AppTheme.primaryPurple.withOpacity(0.05),
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
                  _buildAppBar(lang),

                  // Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          // Moon phase hero card
                          _buildMoonPhaseHeroCard(
                            moonPhaseIcon,
                            moonPhaseName,
                            moonPhaseInsight,
                          ),

                          const SizedBox(height: 20),

                          // Moon sign and countdown row
                          Row(
                            children: [
                              Expanded(
                                child: _buildMoonSignCard(
                                  zodiacIcon,
                                  moonSignName,
                                  lang,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildCountdownCard(
                                  daysUntilFull,
                                  daysUntilNew,
                                  lang,
                                  isTurkish,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Daily insight card
                          _buildDailyInsightCard(
                            lang,
                            dailyInsight,
                            zodiacIcon,
                            moonSignName,
                            widget.hasAnalysis,
                          ),

                          const SizedBox(height: 20),

                          // Palm tips card (only show if user has analysis)
                          // Otherwise show CTA to do first analysis
                          widget.hasAnalysis
                              ? _buildPalmTipsCard(lang, moonSign, isTurkish)
                              : _buildAnalyzeCTA(lang, isTurkish),

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

  Widget _buildAppBar(dynamic lang) {
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
              lang.todaysEnergy,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          // Date display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _formatDate(),
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate() {
    final now = DateTime.now();
    final months = [
      'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
      'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara'
    ];
    return '${now.day} ${months[now.month - 1]}';
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

  Widget _buildMoonPhaseHeroCard(
    String moonIcon,
    String phaseName,
    String insight,
  ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
            AppTheme.primaryIndigo.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Animated moon icon
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Text(
                  moonIcon,
                  style: const TextStyle(fontSize: 80),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Phase name
          Text(
            phaseName,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Insight
          Text(
            insight,
            style: GoogleFonts.inter(
              fontSize: 15,
              color: Colors.white.withOpacity(0.85),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildMoonSignCard(String zodiacIcon, String signName, dynamic lang) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                zodiacIcon,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            lang.moonIn,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            signName,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownCard(
    int daysUntilFull,
    int daysUntilNew,
    dynamic lang,
    bool isTurkish,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Full moon countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌕', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$daysUntilFull ${isTurkish ? "gün" : "days"}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                  Text(
                    isTurkish ? "Dolunay'a" : "to Full Moon",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(height: 1),
          ),
          // New moon countdown
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🌑', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$daysUntilNew ${isTurkish ? "gün" : "days"}',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryPurple,
                    ),
                  ),
                  Text(
                    isTurkish ? "Yeni Ay'a" : "to New Moon",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDailyInsightCard(
    dynamic lang,
    String insight,
    String zodiacIcon,
    String signName,
    bool hasAnalysis,
  ) {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    hasAnalysis ? Icons.back_hand_rounded : Icons.auto_awesome,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasAnalysis
                          ? lang.dailyInsight
                          : (isTurkish ? 'Günün Enerjisi' : 'Daily Energy'),
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                    Text(
                      '$zodiacIcon $signName',
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
            insight,
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

  Widget _buildPalmTipsCard(dynamic lang, ZodiacSign moonSign, bool isTurkish) {
    final tips = _getPalmTips(moonSign, isTurkish);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.warningAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  color: AppTheme.warningAmber,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isTurkish ? 'Günün İpucu' : "Today's Tip",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    tip,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAnalyzeCTA(dynamic lang, bool isTurkish) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryIndigo.withOpacity(0.15),
            AppTheme.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryIndigo.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.back_hand_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isTurkish
                ? 'Kişisel El Çizgisi Yorumunuz'
                : 'Your Personal Palm Reading',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            isTurkish
                ? 'Avuç içinizi analiz ettirin ve günlük burç enerjisinin el çizgilerinizi nasıl etkilediğini keşfedin.'
                : 'Analyze your palm and discover how daily zodiac energy affects your palm lines.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop(); // Go back to home
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTurkish ? 'İlk Analizimi Yap' : 'Do My First Analysis',
                    style: GoogleFonts.inter(
                      fontSize: 14,
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

  List<String> _getPalmTips(ZodiacSign moonSign, bool isTurkish) {
    if (isTurkish) {
      switch (moonSign) {
        case ZodiacSign.aries:
        case ZodiacSign.leo:
        case ZodiacSign.sagittarius:
          return [
            'Bugün Güneş Çizginizi inceleyin - yaratıcı enerjiniz yüksek.',
            'Cesur kararlar almak için ideal bir gün.',
            'El çizgilerinizde liderlik potansiyelinizi keşfedin.',
          ];
        case ZodiacSign.taurus:
        case ZodiacSign.virgo:
        case ZodiacSign.capricorn:
          return [
            'Kader Çizginize odaklanın - kariyer fırsatları belirgin.',
            'Pratik adımlar atmak için enerjiniz güçlü.',
            'Sabır ve kararlılık size yol gösterecek.',
          ];
        case ZodiacSign.gemini:
        case ZodiacSign.libra:
        case ZodiacSign.aquarius:
          return [
            'Akıl Çizginiz bugün çok aktif - yeni fikirler kapınızda.',
            'İletişim ve sosyal bağlantılar ön planda.',
            'Yaratıcı projeler için harika bir gün.',
          ];
        case ZodiacSign.cancer:
        case ZodiacSign.scorpio:
        case ZodiacSign.pisces:
          return [
            'Kalp Çizginizi dinleyin - duygusal sezgileriniz güçlü.',
            'Yakın ilişkilerinize zaman ayırın.',
            'İç sesinize kulak verin, yanıltmayacak.',
          ];
      }
    } else {
      switch (moonSign) {
        case ZodiacSign.aries:
        case ZodiacSign.leo:
        case ZodiacSign.sagittarius:
          return [
            'Examine your Sun Line today - your creative energy is high.',
            'Ideal day for making bold decisions.',
            'Discover your leadership potential in your palm lines.',
          ];
        case ZodiacSign.taurus:
        case ZodiacSign.virgo:
        case ZodiacSign.capricorn:
          return [
            'Focus on your Fate Line - career opportunities are prominent.',
            'Your energy for practical steps is strong.',
            'Patience and determination will guide you.',
          ];
        case ZodiacSign.gemini:
        case ZodiacSign.libra:
        case ZodiacSign.aquarius:
          return [
            'Your Head Line is very active - new ideas at your door.',
            'Communication and social connections are highlighted.',
            'Great day for creative projects.',
          ];
        case ZodiacSign.cancer:
        case ZodiacSign.scorpio:
        case ZodiacSign.pisces:
          return [
            'Listen to your Heart Line - emotional intuition is strong.',
            'Dedicate time to close relationships.',
            'Trust your inner voice, it won\'t mislead you.',
          ];
      }
    }
  }
}
