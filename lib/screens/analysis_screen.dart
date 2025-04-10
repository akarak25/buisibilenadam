import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:palm_analysis/utils/theme.dart';
import 'package:palm_analysis/services/palm_analysis_service.dart';
import 'package:palm_analysis/models/palm_analysis.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:palm_analysis/widgets/shimmer_loading.dart';
import 'package:palm_analysis/utils/markdown_formatter.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class AnalysisScreen extends StatefulWidget {
  final File imageFile;

  const AnalysisScreen({super.key, required this.imageFile});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  // Markdown başlıklarını doğru formatta düzenler
  String _formatMarkdownHeadings(String text) {
    try {
      // ## işaretini kaldır ve başlıkları düzelt
      String result = text;
      
      // ## işaretleri arasındaki bölümleri başlık olarak düzenle
      final headingPattern = RegExp(r'##\s*(.*?)\s*##', dotAll: true);
      result = result.replaceAllMapped(headingPattern, (match) {
        String heading = match.group(1) ?? '';
        // Trim ve başlığı düzenle
        heading = heading.trim();
        
        // Markdown başlık formatına dönüştür
        return '\n### $heading\n';
      });
      
      return result;
    } catch (e) {
      print('Markdown başlık düzenleme hatası: $e');
      return text; // Hata durumunda orijinal metni döndür
    }
  }
  
  bool _isAnalyzing = true;
  String _analysis = '';
  final PalmAnalysisService _analysisService = PalmAnalysisService();
  
  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      // API anahtarını .env dosyasından al
      final apiKey = dotenv.get('CLAUDE_API_KEY', fallback: '');
      
      if (apiKey.isEmpty || apiKey == 'your_api_key_here') {
        setState(() {
          _isAnalyzing = false;
          _analysis = '# API Anahtarı Eksik\n\nLütfen bir Claude API anahtarı ekleyin.';
        });
        return;
      }
      
      // Resmi analiz et
      final analysis = await _analysisService.analyzeHandImage(widget.imageFile, context: context);

      if (!mounted) return;
      
      try {
        // Metni doğrudan markdown formatına dönüştür
        String formattedAnalysis = MarkdownFormatter.format(analysis);
        
        try {
          // Metni kullanarak analiz nesnesini oluştur
          final palmAnalysis = PalmAnalysis(analysis: formattedAnalysis);
          await _saveAnalysis(palmAnalysis);
        } catch (e) {
          print('Analiz kaydetme hatası: $e');
          // Kaydetme hatası olsa bile devam et
        }
        
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _analysis = formattedAnalysis;
          });
        }
      } catch (e) {
        print('Analiz işleme hatası: $e');
        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            _analysis = '# İşleme Hatası\n\nAnaliz sonucu işlenirken bir hata oluştu, ancak ham veriyi görebilirsiniz:\n\n$analysis';
          });
        }
      }
    } catch (e) {
      print('Analiz hatası: $e');
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _analysis = '# Hata Oluştu\n\nEl çizgisi analizi yapılırken bir hata oluştu: $e';
        });
      }
    }
  }

  Future<void> _saveAnalysis(PalmAnalysis analysis) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mevcut analizleri al
      final analysisListJson = prefs.getStringList('analyses') ?? [];
      final analysisList = analysisListJson
          .map((json) => PalmAnalysis.fromJson(jsonDecode(json)))
          .toList();
      
      // Yeni analizi ekle
      analysisList.add(analysis);
      
      // Analizleri JSON olarak kaydet
      final updatedJsonList = analysisList
          .map((analysis) => jsonEncode(analysis.toJson()))
          .toList();
      
      await prefs.setStringList('analyses', updatedJsonList);
      
      // Toplam analiz sayısını artır
      final totalAnalyses = prefs.getInt('total_analyses') ?? 0;
      await prefs.setInt('total_analyses', totalAnalyses + 1);
    } catch (e) {
      print('Analiz kaydedilemedi: $e');
      // Burada hata atmıyoruz, sessizce devam ediyoruz
    }
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).currentLanguage.appName),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              tooltip: 'Ana Sayfaya Dön',
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // El resmi
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 250,
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print('Resim yükleme hatası: $error');
                        return Container(
                          width: double.infinity,
                          height: 250,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Analiz başlığı
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.psychology,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        AppLocalizations.of(context).currentLanguage.analysisComplete,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // Analiz içeriği
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: _isAnalyzing
                      ? const ShimmerLoading()
                      : Builder(
                          builder: (context) {
                            try {
                              return MarkdownBody(
                                data: _analysis,
                                styleSheetTheme: MarkdownStyleSheetBaseTheme.cupertino,
                                styleSheet: MarkdownStyleSheet(
                                  blockSpacing: 16.0,
                                  h2Padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                                  h3Padding: const EdgeInsets.only(top: 12.0, bottom: 4.0),
                                  h1: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                  h2: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                    color: AppTheme.primaryColor,
                                    height: 1.5,
                                    backgroundColor: Color(0xFFF3E5F5),
                                  ),
                                  p: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.textColor,
                                    height: 1.5,
                                  ),
                                  listBullet: const TextStyle(
                                    fontSize: 16,
                                    color: AppTheme.primaryColor,
                                  ),
                                  listIndent: 24.0,
                                  listBulletPadding: const EdgeInsets.only(right: 8),
                                ),

                              );
                            } catch (e) {
                              print('Markdown render hatası: $e');
                              return Text(
                                'Analiz gösterilirken hata oluştu: $e\n\nHam metin:\n$_analysis',
                                style: const TextStyle(color: Colors.red),
                              );
                            }
                          },
                        ),
                ),
                
                const SizedBox(height: 24),
                
                // Paylaşım butonu
                if (!_isAnalyzing)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Paylaşma özelliği ileride eklenebilir
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Paylaşım özelliği yakında eklenecek!'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.share),
                      label: Text(AppLocalizations.of(context).currentLanguage.shareAnalysis),
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Yeni analiz butonu
                if (!_isAnalyzing)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: Text(AppLocalizations.of(context).currentLanguage.analyzeHand),
                    ),
                  ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      // Herhangi bir hata durumunda basit bir hata ekranı göster
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).currentLanguage.errorTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              tooltip: 'Ana Sayfaya Dön',
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 80,
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).currentLanguage.errorTitle,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Uygulama ekranı oluşturulurken hata meydana geldi: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home),
                  label: Text(AppLocalizations.of(context).currentLanguage.tryAgain),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
