import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/models/palm_analysis.dart';
import 'package:palm_analysis/models/query.dart';
import 'package:palm_analysis/services/api_service.dart';
import 'package:palm_analysis/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/widgets/common/gradient_button.dart';
import 'package:palm_analysis/widgets/styled_analysis_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PalmAnalysis> _analyses = [];
  List<Query> _backendQueries = [];
  bool _isLoading = true;
  bool _isOnline = false;
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    setState(() => _isLoading = true);

    // Try to load from backend first (if user is logged in)
    await _loadFromBackend();

    // Also load local analyses
    await _loadFromLocal();

    setState(() => _isLoading = false);
  }

  Future<void> _loadFromBackend() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        _isOnline = false;
        return;
      }

      final queries = await _apiService.getQueries();
      _backendQueries = queries;
      _isOnline = true;
      debugPrint('Loaded ${queries.length} queries from backend');
    } catch (e) {
      debugPrint('Backend load error: $e');
      _isOnline = false;
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analysisListJson = prefs.getStringList('analyses') ?? [];

      final analysisList = analysisListJson
          .map((json) => PalmAnalysis.fromJson(jsonDecode(json)))
          .toList();

      // Sort by date (newest first)
      analysisList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      _analyses = analysisList;
    } catch (e) {
      debugPrint('Local load error: $e');
    }
  }

  // Get combined list - backend queries take priority
  List<dynamic> get _combinedAnalyses {
    if (_isOnline && _backendQueries.isNotEmpty) {
      // Return backend queries (they are the source of truth)
      return _backendQueries;
    }
    // Fallback to local analyses
    return _analyses;
  }

  Future<void> _deleteAnalysis(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final deletedAnalysis = _analyses.removeAt(index);

      // Delete image file if exists
      if (deletedAnalysis.imagePath != null) {
        try {
          final imageFile = File(deletedAnalysis.imagePath!);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          debugPrint('Image delete error: $e');
        }
      }

      final updatedJsonList = _analyses
          .map((analysis) => jsonEncode(analysis.toJson()))
          .toList();

      await prefs.setStringList('analyses', updatedJsonList);

      final totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      if (totalAnalyses > 0) {
        await prefs.setInt('total_analyses', totalAnalyses - 1);
      }

      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to delete: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  /// Delete a query from backend
  Future<void> _deleteBackendQuery(Query query, int index) async {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';

    try {
      await _apiService.deleteQuery(query.id);

      // Remove from local list
      setState(() {
        _backendQueries.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTurkish ? 'Analiz silindi' : 'Analysis deleted'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isTurkish ? 'Silme başarısız: $e' : 'Failed to delete: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
      // Re-add to list if failed (restore state)
      setState(() {});
    }
  }

  /// Show delete confirmation for backend query
  void _showDeleteQueryConfirmation(Query query, int index) {
    final locale = Localizations.localeOf(context);
    final isTurkish = locale.languageCode == 'tr';
    final lang = AppLocalizations.of(context).currentLanguage;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          isTurkish ? 'Analizi Sil' : 'Delete Analysis',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          isTurkish
              ? 'Bu analiz kalıcı olarak silinecek. Bu işlem geri alınamaz.'
              : 'This analysis will be permanently deleted. This action cannot be undone.',
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              lang.cancel,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteBackendQuery(query, index);
            },
            child: Text(
              isTurkish ? 'Sil' : 'Delete',
              style: GoogleFonts.inter(
                color: AppTheme.dangerRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAllAnalyses() async {
    // Delete all image files
    for (var analysis in _analyses) {
      if (analysis.imagePath != null) {
        try {
          final imageFile = File(analysis.imagePath!);
          if (await imageFile.exists()) {
            await imageFile.delete();
          }
        } catch (e) {
          debugPrint('Image delete error: $e');
        }
      }
    }

    // Clear from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('analyses');
    await prefs.setInt('total_analyses', 0);

    setState(() {
      _analyses = [];
    });
  }

  void _showAnalysisDetail(PalmAnalysis analysis) {
    final lang = AppLocalizations.of(context).currentLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.98),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) =>
                                AppTheme.primaryGradient.createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            ),
                            child: Text(
                              lang.analysisDetail,
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMMM yyyy, HH:mm')
                                .format(analysis.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Image preview
              if (analysis.imagePath != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 180,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: _buildAnalysisImage(analysis.imagePath!),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StyledAnalysisView(
                    analysisText: analysis.analysis,
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                ),
              ),

              // Bottom padding
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() {
    final lang = AppLocalizations.of(context).currentLanguage;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          lang.deleteAllAnalyses,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          lang.deleteAllConfirmation,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              lang.cancel,
              style: GoogleFonts.inter(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _deleteAllAnalyses();
            },
            child: Text(
              lang.deleteAll,
              style: GoogleFonts.inter(
                color: AppTheme.dangerRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
              left: -100,
              child: Container(
                width: 300,
                height: 300,
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
                      children: [
                        _buildIconButton(
                          icon: Icons.arrow_back_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lang.historyTitle,
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (_combinedAnalyses.isNotEmpty && !_isOnline)
                          _buildIconButton(
                            icon: Icons.delete_sweep_rounded,
                            onTap: _showDeleteConfirmation,
                          ),
                      ],
                    ),
                  ),

                  // Content
                  Expanded(
                    child: _isLoading
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryIndigo,
                              ),
                            ),
                          )
                        : _combinedAnalyses.isEmpty
                            ? _buildEmptyState(lang)
                            : RefreshIndicator(
                                onRefresh: _loadAnalyses,
                                color: AppTheme.primaryIndigo,
                                child: _buildAnalysisList(),
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

  Widget _buildEmptyState(dynamic lang) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: AppTheme.cardShadow,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 60,
              color: AppTheme.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            lang.noAnalysisYet,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            lang.analyzeHandFromHome,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GradientButton(
            text: lang.goToHome,
            onPressed: () => Navigator.of(context).pop(),
            icon: Icons.home_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisList() {
    final items = _combinedAnalyses;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (ctx, index) {
        final item = items[index];

        // Handle both Query (from backend) and PalmAnalysis (from local)
        if (item is Query) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(item.id),
              direction: DismissDirection.endToStart,
              confirmDismiss: (direction) async {
                _showDeleteQueryConfirmation(item, index);
                return false; // Don't dismiss automatically, wait for confirmation
              },
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              child: _buildQueryCard(item),
            ),
          );
        } else if (item is PalmAnalysis) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(item.createdAt.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                decoration: BoxDecoration(
                  color: AppTheme.dangerRed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.delete_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              onDismissed: (direction) {
                _deleteAnalysis(index);
              },
              child: _buildAnalysisCard(item),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Build card for backend Query
  Widget _buildQueryCard(Query query) {
    final lang = AppLocalizations.of(context).currentLanguage;

    return GestureDetector(
      onTap: () => _showQueryDetail(query),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.back_hand_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang.palmReadingAnalysis,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            // Cloud sync indicator
                            Icon(
                              Icons.cloud_done_rounded,
                              size: 16,
                              color: AppTheme.successGreen,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(query.createdAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getAnalysisPreview(query.response),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppTheme.primaryIndigo,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Show detail for backend Query
  void _showQueryDetail(Query query) {
    final lang = AppLocalizations.of(context).currentLanguage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.white.withValues(alpha: 0.98),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              ShaderMask(
                                blendMode: BlendMode.srcIn,
                                shaderCallback: (bounds) =>
                                    AppTheme.primaryGradient.createShader(
                                  Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                                ),
                                child: Text(
                                  lang.analysisDetail,
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.cloud_done_rounded,
                                size: 18,
                                color: AppTheme.successGreen,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMMM yyyy, HH:mm').format(query.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(ctx).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: AppTheme.textPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: StyledAnalysisView(
                    analysisText: query.response,
                    languageCode: Localizations.localeOf(context).languageCode,
                  ),
                ),
              ),

              // Bottom padding
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisCard(PalmAnalysis analysis) {
    final lang = AppLocalizations.of(context).currentLanguage;

    return GestureDetector(
      onTap: () => _showAnalysisDetail(analysis),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                if (analysis.imagePath != null)
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          child: _buildAnalysisImage(analysis.imagePath!),
                        ),
                        // Gradient overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.back_hand_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lang.palmReadingAnalysis,
                                  style: GoogleFonts.inter(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  DateFormat('dd MMM yyyy, HH:mm')
                                      .format(analysis.createdAt),
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppTheme.primaryIndigo,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _getAnalysisPreview(analysis.analysis),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalysisImage(String imagePath) {
    try {
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          fit: BoxFit.cover,
          cacheHeight: 540, // 180 * 3 for @3x displays (max display height)
          errorBuilder: (context, error, stackTrace) {
            return _buildImagePlaceholder();
          },
        );
      } else {
        return _buildImagePlaceholder();
      }
    } catch (e) {
      return _buildImagePlaceholder();
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: AppTheme.surfaceLight,
      child: Center(
        child: Icon(
          Icons.image_not_supported_rounded,
          color: AppTheme.textMuted,
          size: 40,
        ),
      ),
    );
  }

  String _getAnalysisPreview(String analysis) {
    String preview = analysis.replaceAll(RegExp(r'#+ '), '');
    preview = preview.replaceAll(RegExp(r'\*\*|\*|__|\n'), ' ');
    return preview.trim();
  }
}
