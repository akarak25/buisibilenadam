import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/models/palm_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import 'package:palm_analysis/utils/string_utils.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<PalmAnalysis> _analyses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalyses();
  }

  Future<void> _loadAnalyses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final analysisListJson = prefs.getStringList('analyses') ?? [];
      
      final analysisList = analysisListJson
          .map((json) => PalmAnalysis.fromJson(jsonDecode(json)))
          .toList();
      
      // Tarihe göre sırala (en yeniler üstte)
      analysisList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      setState(() {
        _analyses = analysisList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analizler yüklenemedi: $e')),
      );
    }
  }

  Future<void> _deleteAnalysis(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Silinecek analizi listeden kaldır
      final deletedAnalysis = _analyses.removeAt(index);
      
      // Güncellenmiş listeyi kaydet
      final updatedJsonList = _analyses
          .map((analysis) => jsonEncode(analysis.toJson()))
          .toList();
      
      await prefs.setStringList('analyses', updatedJsonList);
      
      // Toplam analiz sayısını güncelle
      final totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      if (totalAnalyses > 0) {
        await prefs.setInt('total_analyses', totalAnalyses - 1);
      }
      
      setState(() {});
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).currentLanguage.analysisSaved)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Analiz silinemedi: $e')),
      );
    }
  }

  void _showAnalysisDetail(PalmAnalysis analysis) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Kapat çubuğu
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.5),
                ),
              ),
              const SizedBox(height: 16),
              
              // Başlık
              Text(
                AppLocalizations.of(context).currentLanguage.analysisDetail,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat('dd MMMM yyyy, HH:mm').format(analysis.createdAt),
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textColorLight,
                ),
              ),
              const SizedBox(height: 24),
              
              // Markdown içerik
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  child: MarkdownBody(
                    data: StringUtils.fixAllIssues(analysis.analysis),
                    styleSheet: MarkdownStyleSheet(
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.secondaryColor,
                      ),
                      p: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.textColor,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).currentLanguage.historyTitle),
        actions: [
          if (_analyses.isNotEmpty)
            IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(AppLocalizations.of(context).currentLanguage.deleteAllAnalyses),
                    content: Text(
                      AppLocalizations.of(context).currentLanguage.deleteAllConfirmation,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(AppLocalizations.of(context).currentLanguage.cancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          Navigator.of(ctx).pop();
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('analyses');
                          await prefs.setInt('total_analyses', 0);
                          setState(() {
                            _analyses = [];
                          });
                        },
                        child: Text(
                          AppLocalizations.of(context).currentLanguage.deleteAll,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Tüm analizleri sil',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : _analyses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.history,
                        size: 80,
                        color: AppTheme.textColorLight,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context).currentLanguage.noAnalysisYet,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AppLocalizations.of(context).currentLanguage.analyzeHandFromHome,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textColorLight,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.home),
                        label: Text(AppLocalizations.of(context).currentLanguage.goToHome),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _analyses.length,
                  itemBuilder: (ctx, index) {
                    final analysis = _analyses[index];
                    return Dismissible(
                      key: Key(analysis.createdAt.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        color: Colors.red,
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                      _deleteAnalysis(index);
                      },
                      child: Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      onTap: () => _showAnalysisDetail(analysis),
                      title: Text(
                      AppLocalizations.of(context).currentLanguage.palmReadingAnalysis,
                      style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      ),
                      ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('dd MMMM yyyy, HH:mm')
                                    .format(analysis.createdAt),
                                style: const TextStyle(
                                  color: AppTheme.textColorLight,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _getAnalysisPreview(analysis.analysis),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _getAnalysisPreview(String analysis) {
    // Markdown başlıklarını ve sembollerini temizle
    String preview = analysis.replaceAll(RegExp(r'#+ '), '');
    preview = preview.replaceAll(RegExp(r'\*\*|\*|__|\n'), ' ');
    return preview.trim();
  }
}
