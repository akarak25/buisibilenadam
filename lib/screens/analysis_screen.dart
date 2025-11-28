import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/services/palm_analysis_service.dart';
import 'package:palm_analysis/services/api_service.dart';
import 'package:palm_analysis/models/palm_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:palm_analysis/widgets/shimmer_loading.dart';
import 'package:palm_analysis/utils/markdown_formatter.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:palm_analysis/widgets/common/gradient_button.dart';
import 'package:palm_analysis/screens/chat_screen.dart';

class AnalysisScreen extends StatefulWidget {
  final File imageFile;

  const AnalysisScreen({super.key, required this.imageFile});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isAnalyzing = true;
  String _analysis = '';
  String? _errorMessage;
  late PalmAnalysisService _analysisService;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _analysisService = PalmAnalysisService();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // Get current locale
      String deviceLanguage = 'tr';
      try {
        if (mounted) {
          final locale = Localizations.localeOf(context);
          deviceLanguage = locale.languageCode;
        }
      } catch (e) {
        print('Language detection error: $e');
      }

      // Analyze image via backend API
      final analysis = await _analysisService.analyzeHandImage(
        widget.imageFile,
        locale: Locale(deviceLanguage),
      );

      if (!mounted) return;

      try {
        // Format the analysis text
        String formattedAnalysis = MarkdownFormatter.format(analysis);

        // Save image and analysis locally
        String imagePath = '';
        try {
          imagePath = await _saveImageFile(widget.imageFile);

          final palmAnalysis = PalmAnalysis(
            analysis: formattedAnalysis,
            imagePath: imagePath,
          );
          await _saveAnalysis(palmAnalysis);
        } catch (e) {
          print('Local save error: $e');
        }

        // Save to backend database for sync across platforms
        try {
          await _apiService.saveQuery(
            imageUrl: imagePath.isNotEmpty ? imagePath : 'mobile://local',
            question: 'El çizgilerimi yorumlar mısın?',
            response: formattedAnalysis,
          );
          print('Query saved to backend successfully');
        } catch (e) {
          print('Backend save error: $e');
        }

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _analysis = formattedAnalysis;
          });
        }
      } catch (e) {
        print('Processing error: $e');
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _analysis = analysis; // Show raw text
          });
        }
      }
    } catch (e) {
      print('Analysis error: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<String> _saveImageFile(File imageFile) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final palmImagesDir = Directory('${appDir.path}/palm_images');
      if (!await palmImagesDir.exists()) {
        await palmImagesDir.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'palm_$timestamp.jpg';
      final savedImagePath = path.join(palmImagesDir.path, fileName);

      final savedImage = await imageFile.copy(savedImagePath);
      return savedImage.path;
    } catch (e) {
      print('Image save error: $e');
      return imageFile.path;
    }
  }

  Future<void> _saveAnalysis(PalmAnalysis analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final analysisListJson = prefs.getStringList('analyses') ?? [];
      final analysisList = analysisListJson
          .map((json) => PalmAnalysis.fromJson(jsonDecode(json)))
          .toList();

      analysisList.add(analysis);

      final updatedJsonList = analysisList
          .map((analysis) => jsonEncode(analysis.toJson()))
          .toList();

      await prefs.setStringList('analyses', updatedJsonList);

      final totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      await prefs.setInt('total_analyses', totalAnalyses + 1);
    } catch (e) {
      print('Analysis save error: $e');
    }
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

            // Main content
            SafeArea(
              child: Column(
                children: [
                  // App bar
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        _buildIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lang.palmReadingAnalysis,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        _buildIconButton(
                          icon: Icons.home_rounded,
                          onTap: () => Navigator.of(context)
                              .popUntil((route) => route.isFirst),
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
                          // Image preview
                          _buildImageCard(),

                          const SizedBox(height: 20),

                          // Status card
                          _buildStatusCard(lang),

                          const SizedBox(height: 20),

                          // Analysis content
                          if (_errorMessage != null)
                            _buildErrorCard(lang)
                          else if (_isAnalyzing)
                            _buildLoadingCard(lang)
                          else
                            _buildAnalysisCard(),

                          const SizedBox(height: 24),

                          // Action buttons
                          if (!_isAnalyzing && _errorMessage == null) ...[
                            // Ask Question button - Chat with AI
                            GradientButton(
                              text: lang.askQuestion,
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      analysisResult: _analysis,
                                    ),
                                  ),
                                );
                              },
                              icon: Icons.chat_bubble_outline_rounded,
                            ),
                            const SizedBox(height: 12),
                            SecondaryButton(
                              text: lang.analyzeHand,
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icons.camera_alt_rounded,
                            ),
                          ],

                          if (_errorMessage != null) ...[
                            GradientButton(
                              text: lang.tryAgain,
                              onPressed: () {
                                setState(() {
                                  _isAnalyzing = true;
                                  _errorMessage = null;
                                  _analysis = '';
                                });
                                _analyzeImage();
                              },
                              icon: Icons.refresh_rounded,
                            ),
                            const SizedBox(height: 12),
                            SecondaryButton(
                              text: lang.goToHome,
                              onPressed: () => Navigator.of(context)
                                  .popUntil((route) => route.isFirst),
                              icon: Icons.home_rounded,
                            ),
                          ],

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

  Widget _buildImageCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryIndigo.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            Image.file(
              widget.imageFile,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 64,
                      color: AppTheme.textMuted,
                    ),
                  ),
                );
              },
            ),
            // Gradient overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(dynamic lang) {
    final isComplete = !_isAnalyzing && _errorMessage == null;
    final hasError = _errorMessage != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        gradient: hasError
            ? LinearGradient(
                colors: [
                  AppTheme.dangerRed.withOpacity(0.9),
                  AppTheme.dangerRed,
                ],
              )
            : isComplete
                ? AppTheme.successGradient
                : LinearGradient(
                    colors: [
                      AppTheme.warningAmber.withOpacity(0.9),
                      AppTheme.warningAmber,
                    ],
                  ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: hasError
                ? AppTheme.dangerRed.withOpacity(0.3)
                : isComplete
                    ? AppTheme.successGreen.withOpacity(0.3)
                    : AppTheme.warningAmber.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            hasError
                ? Icons.error_outline_rounded
                : isComplete
                    ? Icons.check_circle_rounded
                    : Icons.psychology_rounded,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            hasError
                ? lang.analysisError
                : isComplete
                    ? lang.analysisComplete
                    : lang.analyzing,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          if (_isAnalyzing) ...[
            const Spacer(),
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingCard(dynamic lang) {
    return Container(
      padding: const EdgeInsets.all(24),
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
          child: ShimmerLoading(
            loadingText: lang.analyzingPalm,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorCard(dynamic lang) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.dangerRed.withOpacity(0.2),
        ),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.dangerRed.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            lang.analysisError,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage ?? lang.generalError,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
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
          child: MarkdownBody(
            data: _analysis,
            styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
            styleSheet: MarkdownStyleSheet(
              blockSpacing: 16.0,
              h2Padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 0),
              h3Padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
              h1: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryIndigo,
              ),
              h2: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryIndigo,
                height: 1.5,
              ),
              h3: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryPurple,
              ),
              p: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
              listBullet: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.primaryIndigo,
              ),
              listIndent: 24.0,
              listBulletPadding: const EdgeInsets.only(right: 8),
              strong: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
              em: GoogleFonts.inter(
                fontStyle: FontStyle.italic,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
