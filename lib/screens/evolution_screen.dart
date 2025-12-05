import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/models/palm_analysis.dart';
import 'package:palm_analysis/services/api_service.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// EvolutionException is imported from api_service.dart

/// Evolution Analysis Screen
/// Track how palm lines change over time by comparing analyses from different dates
class EvolutionScreen extends StatefulWidget {
  const EvolutionScreen({super.key});

  @override
  State<EvolutionScreen> createState() => _EvolutionScreenState();
}

class _EvolutionScreenState extends State<EvolutionScreen>
    with TickerProviderStateMixin {
  List<PalmAnalysis> _analyses = [];
  PalmAnalysis? _selectedOlder;
  PalmAnalysis? _selectedNewer;
  bool _isLoading = true;
  bool _isAnalyzing = false;
  String? _evolutionResult;
  String? _errorMessage;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanController;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _loadAnalyses();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analysisListJson = prefs.getStringList('analyses') ?? [];
      final analysisList = analysisListJson
          .map((json) => PalmAnalysis.fromJson(jsonDecode(json)))
          .toList();

      // Sort by date (oldest first for evolution)
      analysisList.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (mounted) {
        setState(() {
          _analyses = analysisList;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to load analyses: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  bool _isDifferentPersonError = false;
  bool _isDateError = false;

  Future<void> _analyzeEvolution() async {
    if (_selectedOlder == null || _selectedNewer == null) return;

    // Check if both analyses have valid image paths
    if (_selectedOlder!.imagePath == null || _selectedNewer!.imagePath == null) {
      setState(() {
        _errorMessage = Localizations.localeOf(context).languageCode == 'tr'
            ? 'Seçilen analizlerden birinin resmi bulunamadı. Lütfen başka analizler seçin.'
            : 'Image not found for one of the selected analyses. Please select different analyses.';
      });
      return;
    }

    // Resolve relative paths to absolute paths (iOS UUID fix)
    final olderResolvedPath = await PalmAnalysis.resolveImagePath(_selectedOlder!.imagePath);
    final newerResolvedPath = await PalmAnalysis.resolveImagePath(_selectedNewer!.imagePath);

    if (olderResolvedPath == null || newerResolvedPath == null) {
      setState(() {
        _errorMessage = Localizations.localeOf(context).languageCode == 'tr'
            ? 'Resim dosyaları bulunamadı. Lütfen yeni analizler yapın.'
            : 'Image files not found. Please create new analyses.';
      });
      return;
    }

    final olderImageFile = File(olderResolvedPath);
    final newerImageFile = File(newerResolvedPath);

    // Verify files exist (double check)
    if (!await olderImageFile.exists() || !await newerImageFile.exists()) {
      setState(() {
        _errorMessage = Localizations.localeOf(context).languageCode == 'tr'
            ? 'Resim dosyaları bulunamadı. Lütfen yeni analizler yapın.'
            : 'Image files not found. Please create new analyses.';
      });
      return;
    }

    // Check minimum date difference (at least 30 days)
    final daysDifference = _selectedNewer!.createdAt.difference(_selectedOlder!.createdAt).inDays;
    if (daysDifference < 30) {
      setState(() {
        _isDateError = true;
        _isDifferentPersonError = false;
        _errorMessage = Localizations.localeOf(context).languageCode == 'tr'
            ? 'Değişim analizi için iki fotoğraf arasında en az 30 gün fark olmalıdır. Mevcut fark: $daysDifference gün.'
            : 'For evolution analysis, there must be at least 30 days between two photos. Current difference: $daysDifference days.';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _evolutionResult = null;
      _isDifferentPersonError = false;
      _isDateError = false;
    });

    try {
      final locale = Localizations.localeOf(context);
      final result = await _apiService.analyzeEvolution(
        olderImageFile: olderImageFile,
        newerImageFile: newerImageFile,
        olderDate: _formatDate(_selectedOlder!.createdAt),
        newerDate: _formatDate(_selectedNewer!.createdAt),
        language: locale.languageCode,
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _evolutionResult = result;
        });
        // Save the evolution analysis to history
        await _saveEvolutionAnalysis(result);
      }
    } on EvolutionException catch (e) {
      debugPrint('Evolution analysis error: ${e.errorCode} - ${e.message}');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _isDifferentPersonError = e.isDifferentPerson;
          _errorMessage = e.message;
        });
      }
    } catch (e) {
      debugPrint('Evolution analysis error: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  /// Save evolution analysis to SharedPreferences
  Future<void> _saveEvolutionAnalysis(String result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analysisListJson = prefs.getStringList('analyses') ?? [];

      final newAnalysis = PalmAnalysis(
        analysis: result,
        analysisType: AnalysisType.evolution,
        imagePath: _selectedOlder?.imagePath,
        secondaryImagePath: _selectedNewer?.imagePath,
        firstAnalysisDate: _selectedOlder?.createdAt,
        secondAnalysisDate: _selectedNewer?.createdAt,
      );

      analysisListJson.add(jsonEncode(newAnalysis.toJson()));
      await prefs.setStringList('analyses', analysisListJson);

      debugPrint('Evolution analysis saved to history');
    } catch (e) {
      debugPrint('Failed to save evolution analysis: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  String _getTimeBetween(DateTime older, DateTime newer, bool isTurkish) {
    final difference = newer.difference(older);
    final days = difference.inDays;

    if (days < 30) {
      return '$days ${isTurkish ? "gün" : "days"}';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months ${isTurkish ? "ay" : "months"}';
    } else {
      final years = (days / 365).floor();
      final remainingMonths = ((days % 365) / 30).floor();
      if (remainingMonths > 0) {
        return '$years ${isTurkish ? "yıl" : "years"} $remainingMonths ${isTurkish ? "ay" : "months"}';
      }
      return '$years ${isTurkish ? "yıl" : "years"}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLocalizations.of(context).currentLanguage;
    final isTurkish = Localizations.localeOf(context).languageCode == 'tr';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: Stack(
        children: [
          // Grid background
          CustomPaint(
            painter: _GridBackgroundPainter(),
            size: Size.infinite,
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                _buildHeader(lang),

                // Content
                Expanded(
                  child: _isLoading
                      ? _buildLoadingState()
                      : _analyses.length < 2
                          ? _buildNeedMoreAnalyses(lang)
                          : _errorMessage != null
                              ? _buildErrorState(lang, isTurkish)
                              : _evolutionResult != null
                                  ? _buildResult(lang, isTurkish)
                                  : _isAnalyzing
                                      ? _buildAnalyzingState(lang)
                                      : _buildSelectionView(lang, isTurkish),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(dynamic lang) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lang.evolutionAnalysis.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  lang.evolutionDescription,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),

          // Timeline icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.3),
                  const Color(0xFF22C55E).withValues(alpha: 0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.timeline_rounded,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
      ),
    );
  }

  Widget _buildNeedMoreAnalyses(dynamic lang) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timeline_rounded,
                size: 64,
                color: Colors.white30,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              lang.needTwoAnalyses,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: Colors.white70,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  lang.goToHome,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(dynamic lang, bool isTurkish) {
    // Determine icon and color based on error type
    final IconData errorIcon = _isDateError
        ? Icons.calendar_month_outlined
        : _isDifferentPersonError
            ? Icons.people_outline
            : Icons.error_outline;
    final Color errorColor = _isDateError
        ? const Color(0xFF3B82F6) // Blue for date warning
        : _isDifferentPersonError
            ? const Color(0xFFF59E0B) // Amber for different person warning
            : const Color(0xFFEF4444); // Red for other errors

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),

          // Error icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: errorColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: errorColor.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Icon(
              errorIcon,
              size: 56,
              color: errorColor,
            ),
          ),
          const SizedBox(height: 24),

          // Error title
          Text(
            _isDateError
                ? (isTurkish ? 'Yetersiz Zaman Aralığı' : 'Insufficient Time Gap')
                : _isDifferentPersonError
                    ? (isTurkish ? 'Farklı Kişi Algılandı' : 'Different Person Detected')
                    : (isTurkish ? 'Hata Oluştu' : 'Error Occurred'),
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Error message
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              _errorMessage ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),

          // Tip card for date error
          if (_isDateError) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF3B82F6).withValues(alpha: 0.2),
                    const Color(0xFF6366F1).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF3B82F6),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isTurkish
                          ? 'İpucu: El çizgilerindeki değişimlerin görünür olması için en az 1 ay beklemeniz önerilir.'
                          : 'Tip: It is recommended to wait at least 1 month for changes in palm lines to become visible.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Tip card for different person error
          if (_isDifferentPersonError) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF10B981).withValues(alpha: 0.2),
                    const Color(0xFF22C55E).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF10B981),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isTurkish
                          ? 'İpucu: Kendi ellerinizin farklı zamanlarda çekilmiş fotoğraflarını seçin.'
                          : 'Tip: Select photos of your own hands taken at different times.',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedOlder = null;
                      _selectedNewer = null;
                      _errorMessage = null;
                      _isDifferentPersonError = false;
                      _isDateError = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF22C55E)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.refresh,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isTurkish ? 'Farklı Analiz Seç' : 'Select Different Analyses',
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionView(dynamic lang, bool isTurkish) {
    final canAnalyze = _selectedOlder != null && _selectedNewer != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline view
          Row(
            children: [
              Expanded(
                child: _buildTimelineCard(
                  title: lang.olderReading,
                  subtitle: lang.selectOlderAnalysis,
                  selected: _selectedOlder,
                  onTap: () => _showSelectionDialog(isOlder: true, lang: lang),
                  color: const Color(0xFF6366F1),
                  icon: Icons.history,
                ),
              ),
              const SizedBox(width: 12),
              // Arrow indicator
              Column(
                children: [
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF10B981), Color(0xFF22C55E)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                                blurRadius: 15,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      );
                    },
                  ),
                  if (_selectedOlder != null && _selectedNewer != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _getTimeBetween(
                        _selectedOlder!.createdAt,
                        _selectedNewer!.createdAt,
                        isTurkish,
                      ),
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        color: const Color(0xFF10B981),
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimelineCard(
                  title: lang.newerReading,
                  subtitle: lang.selectNewerAnalysis,
                  selected: _selectedNewer,
                  onTap: () => _showSelectionDialog(isOlder: false, lang: lang),
                  color: const Color(0xFF10B981),
                  icon: Icons.update,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Analyze button
          GestureDetector(
            onTap: canAnalyze ? _analyzeEvolution : null,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: canAnalyze
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF22C55E)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.05),
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: canAnalyze
                    ? [
                        BoxShadow(
                          color: const Color(0xFF10B981).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline_rounded,
                    color: canAnalyze
                        ? Colors.white
                        : Colors.white.withValues(alpha: 0.3),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lang.analyzeEvolution,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: canAnalyze
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.white60,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isTurkish ? 'Nasıl Çalışır?' : 'How It Works?',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  '1',
                  isTurkish
                      ? 'Eski bir analiz ve yeni bir analiz seçin'
                      : 'Select an older and a newer analysis',
                ),
                const SizedBox(height: 8),
                _buildInstructionItem(
                  '2',
                  isTurkish
                      ? 'AI iki analizi karşılaştırır'
                      : 'AI compares both analyses',
                ),
                const SizedBox(height: 8),
                _buildInstructionItem(
                  '3',
                  isTurkish
                      ? 'Çizgilerinizde zaman içindeki değişimleri görün'
                      : 'See how your lines have changed over time',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineCard({
    required String title,
    required String subtitle,
    required PalmAnalysis? selected,
    required VoidCallback onTap,
    required Color color,
    required IconData icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected != null
                ? color.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.1),
            width: selected != null ? 2 : 1,
          ),
        ),
        child: selected != null
            ? _buildSelectedContent(selected, title, color)
            : _buildEmptyContent(title, subtitle, icon, color),
      ),
    );
  }

  Widget _buildEmptyContent(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 32,
            color: color,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.add,
                size: 14,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                'Seç',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedContent(
    PalmAnalysis analysis,
    String title,
    Color color,
  ) {
    return Stack(
      children: [
        // Image preview - resolve path async (iOS UUID fix)
        if (analysis.imagePath != null)
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: FutureBuilder<String?>(
              future: PalmAnalysis.resolveImagePath(analysis.imagePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    color: color.withValues(alpha: 0.1),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ),
                  );
                }
                final resolvedPath = snapshot.data;
                if (resolvedPath == null) {
                  return Container(
                    color: color.withValues(alpha: 0.1),
                    child: Center(
                      child: Icon(
                        Icons.back_hand_rounded,
                        size: 48,
                        color: color.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return Image.file(
                  File(resolvedPath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: color.withValues(alpha: 0.1),
                      child: Center(
                        child: Icon(
                          Icons.back_hand_rounded,
                          size: 48,
                          color: color.withValues(alpha: 0.5),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.back_hand_rounded,
                size: 48,
                color: color.withValues(alpha: 0.5),
              ),
            ),
          ),

        // Overlay
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),

        // Title and date
        Positioned(
          bottom: 12,
          left: 12,
          right: 12,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatDate(analysis.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showSelectionDialog({required bool isOlder, required dynamic lang}) {
    // Sort analyses for dialog (oldest first for older, newest first for newer)
    final sortedAnalyses = List<PalmAnalysis>.from(_analyses);
    if (isOlder) {
      sortedAnalyses.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      sortedAnalyses.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: const BoxDecoration(
            color: Color(0xFF0A0E1A),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  lang.selectFromHistory,
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              // List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedAnalyses.length,
                  itemBuilder: (context, index) {
                    final analysis = sortedAnalyses[index];
                    final isSelected = isOlder
                        ? analysis == _selectedOlder
                        : analysis == _selectedNewer;

                    // Disable if:
                    // - For older selection: analysis is the same as selected newer
                    // - For newer selection: analysis is the same as selected older or older than selected older
                    bool isDisabled = false;
                    if (isOlder && analysis == _selectedNewer) {
                      isDisabled = true;
                    } else if (!isOlder && analysis == _selectedOlder) {
                      isDisabled = true;
                    } else if (!isOlder &&
                        _selectedOlder != null &&
                        analysis.createdAt.isBefore(_selectedOlder!.createdAt)) {
                      isDisabled = true;
                    } else if (isOlder &&
                        _selectedNewer != null &&
                        analysis.createdAt.isAfter(_selectedNewer!.createdAt)) {
                      isDisabled = true;
                    }

                    return GestureDetector(
                      onTap: isDisabled
                          ? null
                          : () {
                              setState(() {
                                if (isOlder) {
                                  _selectedOlder = analysis;
                                  // Clear newer if it's now invalid
                                  if (_selectedNewer != null &&
                                      _selectedNewer!.createdAt
                                          .isBefore(analysis.createdAt)) {
                                    _selectedNewer = null;
                                  }
                                } else {
                                  _selectedNewer = analysis;
                                  // Clear older if it's now invalid
                                  if (_selectedOlder != null &&
                                      _selectedOlder!.createdAt
                                          .isAfter(analysis.createdAt)) {
                                    _selectedOlder = null;
                                  }
                                }
                              });
                              Navigator.of(context).pop();
                            },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF10B981).withValues(alpha: 0.2)
                              : isDisabled
                                  ? Colors.white.withValues(alpha: 0.02)
                                  : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF10B981)
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Thumbnail - resolve path async (iOS UUID fix)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: analysis.imagePath != null
                                  ? FutureBuilder<String?>(
                                      future: PalmAnalysis.resolveImagePath(analysis.imagePath),
                                      builder: (ctx, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                            child: const Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                        final resolvedPath = snapshot.data;
                                        if (resolvedPath == null) {
                                          return Container(
                                            width: 60,
                                            height: 60,
                                            color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                            child: const Icon(
                                              Icons.back_hand_rounded,
                                              color: Color(0xFF10B981),
                                            ),
                                          );
                                        }
                                        return Image.file(
                                          File(resolvedPath),
                                          width: 60,
                                          height: 60,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              width: 60,
                                              height: 60,
                                              color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                              child: const Icon(
                                                Icons.back_hand_rounded,
                                                color: Color(0xFF10B981),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 60,
                                      height: 60,
                                      color: const Color(0xFF10B981)
                                          .withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.back_hand_rounded,
                                        color: Color(0xFF10B981),
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _formatDate(analysis.createdAt),
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDisabled
                                          ? Colors.white30
                                          : Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    analysis.analysis.length > 50
                                        ? '${analysis.analysis.substring(0, 50)}...'
                                        : analysis.analysis,
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      color: isDisabled
                                          ? Colors.white.withValues(alpha: 0.2)
                                          : Colors.white60,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (isSelected)
                              const Icon(
                                Icons.check_circle,
                                color: Color(0xFF10B981),
                                size: 24,
                              )
                            else if (isDisabled)
                              const Icon(
                                Icons.block,
                                color: Colors.white30,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAnalyzingState(dynamic lang) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated timeline
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Rotating ring
                AnimatedBuilder(
                  animation: _scanController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _scanController.value * 6.28,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: CustomPaint(
                          painter: _DashedCirclePainter(
                            color: const Color(0xFF10B981),
                            strokeWidth: 3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                // Pulsing icon
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const Icon(
                        Icons.timeline_rounded,
                        color: Color(0xFF10B981),
                        size: 40,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lang.evolutionLoading,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is comparing your palm analyses...',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white60,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResult(dynamic lang, bool isTurkish) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Success header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF10B981).withValues(alpha: 0.2),
                  const Color(0xFF22C55E).withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF22C55E)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.timeline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lang.evolutionResult,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      if (_selectedOlder != null && _selectedNewer != null)
                        Text(
                          '${lang.timeBetween}: ${_getTimeBetween(_selectedOlder!.createdAt, _selectedNewer!.createdAt, isTurkish)}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Result content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              _evolutionResult ?? '',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.9),
                height: 1.6,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // New analysis button
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedOlder = null;
                _selectedNewer = null;
                _evolutionResult = null;
              });
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.refresh,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isTurkish ? 'Yeni Karşılaştırma' : 'New Comparison',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white70,
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
}

/// Grid background painter
class _GridBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF10B981).withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    const spacing = 40.0;

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

/// Dashed circle painter
class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DashedCirclePainter({
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    const dashCount = 12;
    const dashLength = 0.15;
    const gapLength = (1.0 - (dashCount * dashLength)) / dashCount;

    for (var i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + gapLength)) * 6.28;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashLength * 6.28,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
