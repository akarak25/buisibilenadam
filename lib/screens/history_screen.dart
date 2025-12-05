import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/models/palm_analysis.dart';
import 'package:palm_analysis/models/query.dart';
import 'package:palm_analysis/models/chat_conversation.dart';
import 'package:palm_analysis/services/api_service.dart';
import 'package:palm_analysis/services/token_service.dart';
import 'package:palm_analysis/services/chat_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';
import 'package:palm_analysis/widgets/common/gradient_button.dart';
import 'package:palm_analysis/widgets/styled_analysis_view.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  List<PalmAnalysis> _analyses = [];
  List<Query> _backendQueries = [];
  List<ChatConversation> _chatConversations = [];
  bool _isLoading = true;
  bool _isOnline = false;
  final ApiService _apiService = ApiService();
  final TokenService _tokenService = TokenService();
  final ChatStorageService _chatStorageService = ChatStorageService();

  late TabController _tabController;

  // Filtered lists by analysis type
  List<PalmAnalysis> get _palmAnalyses => _analyses
      .where((a) => a.analysisType == AnalysisType.palm)
      .toList();

  List<PalmAnalysis> get _compatibilityAnalyses => _analyses
      .where((a) => a.analysisType == AnalysisType.compatibility)
      .toList();

  List<PalmAnalysis> get _evolutionAnalyses => _analyses
      .where((a) => a.analysisType == AnalysisType.evolution)
      .toList();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadAnalyses();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAnalyses() async {
    setState(() => _isLoading = true);

    // Try to load from backend first (if user is logged in)
    await _loadFromBackend();

    // Also load local analyses
    await _loadFromLocal();

    // Load chat conversations
    await _loadChatConversations();

    setState(() => _isLoading = false);
  }

  Future<void> _loadChatConversations() async {
    try {
      _chatConversations = await _chatStorageService.getConversations();
      debugPrint('Loaded ${_chatConversations.length} chat conversations');
    } catch (e) {
      debugPrint('Chat conversations load error: $e');
    }
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

  Future<void> _deleteAnalysis(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final deletedAnalysis = _analyses.removeAt(index);

      // Delete image file if exists (resolve path first)
      if (deletedAnalysis.imagePath != null) {
        try {
          final resolvedPath = await PalmAnalysis.resolveImagePath(deletedAnalysis.imagePath);
          if (resolvedPath != null) {
            final imageFile = File(resolvedPath);
            if (await imageFile.exists()) {
              await imageFile.delete();
            }
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
    // Delete all image files (resolve paths first)
    for (var analysis in _analyses) {
      if (analysis.imagePath != null) {
        try {
          final resolvedPath = await PalmAnalysis.resolveImagePath(analysis.imagePath);
          if (resolvedPath != null) {
            final imageFile = File(resolvedPath);
            if (await imageFile.exists()) {
              await imageFile.delete();
            }
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
                        if (_analyses.isNotEmpty && !_isOnline)
                          _buildIconButton(
                            icon: Icons.delete_sweep_rounded,
                            onTap: _showDeleteConfirmation,
                          ),
                      ],
                    ),
                  ),

                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.textSecondary,
                      indicator: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.back_hand_rounded, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  lang.palmAnalysisTab,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.favorite_rounded, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  lang.compatibilityTab,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timeline_rounded, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  lang.evolutionTab,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Tab(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat_bubble_rounded, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  lang.chatHistoryTab,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

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
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              // Palm Analysis Tab
                              _buildPalmTab(lang),
                              // Compatibility Tab
                              _buildCompatibilityTab(lang),
                              // Evolution Tab
                              _buildEvolutionTab(lang),
                              // Chat History Tab
                              _buildChatHistoryTab(lang),
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

  /// Resim widget'ı - relative path'i async olarak resolve eder
  Widget _buildAnalysisImage(String imagePath) {
    return FutureBuilder<String?>(
      future: PalmAnalysis.resolveImagePath(imagePath),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: double.infinity,
            color: AppTheme.surfaceLight,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryIndigo),
                ),
              ),
            ),
          );
        }

        final resolvedPath = snapshot.data;
        if (resolvedPath == null) {
          return _buildImagePlaceholder();
        }

        try {
          final file = File(resolvedPath);
          return Image.file(
            file,
            width: double.infinity,
            fit: BoxFit.cover,
            cacheHeight: 540, // 180 * 3 for @3x displays
            errorBuilder: (context, error, stackTrace) {
              return _buildImagePlaceholder();
            },
          );
        } catch (e) {
          return _buildImagePlaceholder();
        }
      },
    );
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

  // ============== TAB BUILDERS ==============

  /// Palm Analysis Tab - Shows backend queries and local palm analyses
  Widget _buildPalmTab(dynamic lang) {
    // Combine backend queries (which are all palm analyses) with local palm analyses
    final hasBackendData = _isOnline && _backendQueries.isNotEmpty;
    final localPalmAnalyses = _palmAnalyses;

    if (!hasBackendData && localPalmAnalyses.isEmpty) {
      return _buildEmptyState(lang);
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyses,
      color: AppTheme.primaryIndigo,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: hasBackendData ? _backendQueries.length : localPalmAnalyses.length,
        itemBuilder: (ctx, index) {
          if (hasBackendData) {
            final query = _backendQueries[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: Key(query.id),
                direction: DismissDirection.endToStart,
                confirmDismiss: (direction) async {
                  _showDeleteQueryConfirmation(query, index);
                  return false;
                },
                background: _buildDismissBackground(),
                child: _buildQueryCard(query),
              ),
            );
          } else {
            final analysis = localPalmAnalyses[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: Key(analysis.createdAt.toString()),
                direction: DismissDirection.endToStart,
                background: _buildDismissBackground(),
                onDismissed: (direction) {
                  final originalIndex = _analyses.indexOf(analysis);
                  if (originalIndex != -1) {
                    _deleteAnalysis(originalIndex);
                  }
                },
                child: _buildAnalysisCard(analysis),
              ),
            );
          }
        },
      ),
    );
  }

  /// Compatibility Tab - Shows compatibility analyses with dual images
  Widget _buildCompatibilityTab(dynamic lang) {
    final compatibilityList = _compatibilityAnalyses;

    if (compatibilityList.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.favorite_rounded,
        message: lang.noCompatibilityYet,
        buttonText: lang.goToCompatibilityScreen,
        color: const Color(0xFFEC4899),
        onPressed: () {
          Navigator.of(context).pop();
          // Navigate to compatibility screen (will be handled by parent)
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyses,
      color: const Color(0xFFEC4899),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: compatibilityList.length,
        itemBuilder: (ctx, index) {
          final analysis = compatibilityList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(analysis.createdAt.toString()),
              direction: DismissDirection.endToStart,
              background: _buildDismissBackground(),
              onDismissed: (direction) {
                final originalIndex = _analyses.indexOf(analysis);
                if (originalIndex != -1) {
                  _deleteAnalysis(originalIndex);
                }
              },
              child: _buildDualImageCard(
                analysis: analysis,
                icon: Icons.favorite_rounded,
                color: const Color(0xFFEC4899),
                lang: lang,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Evolution Tab - Shows evolution analyses with dual images and date range
  Widget _buildEvolutionTab(dynamic lang) {
    final evolutionList = _evolutionAnalyses;

    if (evolutionList.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.timeline_rounded,
        message: lang.noEvolutionYet,
        buttonText: lang.goToEvolutionScreen,
        color: const Color(0xFF10B981),
        onPressed: () {
          Navigator.of(context).pop();
          // Navigate to evolution screen (will be handled by parent)
        },
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalyses,
      color: const Color(0xFF10B981),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: evolutionList.length,
        itemBuilder: (ctx, index) {
          final analysis = evolutionList[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(analysis.createdAt.toString()),
              direction: DismissDirection.endToStart,
              background: _buildDismissBackground(),
              onDismissed: (direction) {
                final originalIndex = _analyses.indexOf(analysis);
                if (originalIndex != -1) {
                  _deleteAnalysis(originalIndex);
                }
              },
              child: _buildDualImageCard(
                analysis: analysis,
                icon: Icons.timeline_rounded,
                color: const Color(0xFF10B981),
                lang: lang,
                showDateRange: true,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Chat History Tab - Shows chat conversations
  Widget _buildChatHistoryTab(dynamic lang) {
    if (_chatConversations.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.chat_bubble_rounded,
        message: lang.noChatHistoryYet,
        buttonText: lang.goToChatScreen,
        color: AppTheme.primaryPurple,
        onPressed: () {
          Navigator.of(context).pop();
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadChatConversations();
        setState(() {});
      },
      color: AppTheme.primaryPurple,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _chatConversations.length,
        itemBuilder: (ctx, index) {
          final conversation = _chatConversations[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: Key(conversation.id),
              direction: DismissDirection.endToStart,
              background: _buildDismissBackground(),
              onDismissed: (direction) async {
                await _chatStorageService.deleteConversation(conversation.id);
                setState(() {
                  _chatConversations.removeAt(index);
                });
              },
              child: _buildChatConversationCard(conversation, lang),
            ),
          );
        },
      ),
    );
  }

  /// Chat conversation card
  Widget _buildChatConversationCard(ChatConversation conversation, dynamic lang) {
    final messageCount = conversation.messages.length;
    final lastMessage = conversation.messages.isNotEmpty
        ? conversation.messages.last
        : null;

    return GestureDetector(
      onTap: () => _showChatConversationDetail(conversation, lang),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryPurple.withValues(alpha: 0.2),
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
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple,
                          AppTheme.primaryIndigo,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_rounded,
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
                                lang.chatWithAI,
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryPurple.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$messageCount',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primaryPurple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(conversation.updatedAt),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        if (lastMessage != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            lastMessage.isUser
                                ? '${lang.you}: ${lastMessage.content}'
                                : 'AI: ${lastMessage.content}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: AppTheme.primaryPurple,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show chat conversation detail
  void _showChatConversationDetail(ChatConversation conversation, dynamic lang) {
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
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryPurple,
                            AppTheme.primaryIndigo,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.chat_bubble_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              lang.chatWithAI,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            DateFormat('dd MMMM yyyy, HH:mm')
                                .format(conversation.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 12,
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

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: conversation.messages.length,
                  itemBuilder: (_, index) {
                    final message = conversation.messages[index];
                    return _buildChatMessageBubble(message);
                  },
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Chat message bubble
  Widget _buildChatMessageBubble(ChatMessageLocal message) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: message.isUser ? 50 : 0,
        right: message.isUser ? 0 : 50,
      ),
      child: Align(
        alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: message.isUser ? AppTheme.primaryGradient : null,
            color: message.isUser ? null : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20).copyWith(
              bottomRight: message.isUser ? const Radius.circular(4) : null,
              bottomLeft: !message.isUser ? const Radius.circular(4) : null,
            ),
            boxShadow: AppTheme.cardShadow,
          ),
          child: message.isUser
              ? Text(
                  message.content,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: Colors.white,
                    height: 1.5,
                  ),
                )
              : MarkdownBody(
                  data: message.content,
                  styleSheet: MarkdownStyleSheet(
                    p: GoogleFonts.inter(
                      fontSize: 15,
                      color: AppTheme.textPrimary,
                      height: 1.5,
                    ),
                    strong: GoogleFonts.inter(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDismissBackground() {
    return Container(
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
    );
  }

  /// Empty state for specific tabs
  Widget _buildEmptyTabState({
    required IconData icon,
    required String message,
    required String buttonText,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 50,
                color: color.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: GoogleFonts.inter(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onPressed,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  buttonText,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Dual image card for compatibility and evolution analyses
  Widget _buildDualImageCard({
    required PalmAnalysis analysis,
    required IconData icon,
    required Color color,
    required dynamic lang,
    bool showDateRange = false,
  }) {
    return GestureDetector(
      onTap: () => _showAnalysisDetail(analysis),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
          boxShadow: AppTheme.cardShadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Column(
              children: [
                // Dual image row
                SizedBox(
                  height: 120,
                  child: Row(
                    children: [
                      // First image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                          ),
                          child: analysis.imagePath != null
                              ? _buildAnalysisImage(analysis.imagePath!)
                              : _buildImagePlaceholder(),
                        ),
                      ),
                      // Center icon
                      Container(
                        width: 40,
                        color: Colors.white,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              icon,
                              color: color,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                      // Second image
                      Expanded(
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(20),
                          ),
                          child: analysis.secondaryImagePath != null
                              ? _buildAnalysisImage(analysis.secondaryImagePath!)
                              : _buildImagePlaceholder(),
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
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [color, color.withValues(alpha: 0.7)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  analysis.analysisType == AnalysisType.compatibility
                                      ? lang.compatibilityAnalysis
                                      : lang.evolutionAnalysis,
                                  style: GoogleFonts.inter(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                // Show date range for evolution
                                if (showDateRange &&
                                    analysis.firstAnalysisDate != null &&
                                    analysis.secondAnalysisDate != null)
                                  Text(
                                    '${DateFormat('dd MMM').format(analysis.firstAnalysisDate!)} → ${DateFormat('dd MMM yyyy').format(analysis.secondAnalysisDate!)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else
                                  Text(
                                    DateFormat('dd MMM yyyy, HH:mm')
                                        .format(analysis.createdAt),
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: color,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _getAnalysisPreview(analysis.analysis),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
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
}
