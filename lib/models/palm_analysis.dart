import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Analiz tipi - History ekranında kategorize etmek için
enum AnalysisType {
  palm,         // Normal el çizgisi analizi
  compatibility, // Çift uyumu analizi
  evolution,    // Zaman içindeki değişim analizi
}

class PalmAnalysis {
  final String analysis;
  final DateTime createdAt;
  final String? imagePath; // Resim dosyasının yolu (relative veya absolute)
  final AnalysisType analysisType; // Analiz tipi (varsayılan: palm)
  final String? secondaryImagePath; // İkili analizler için ikinci resim
  final DateTime? firstAnalysisDate; // Evolution: eski analiz tarihi
  final DateTime? secondAnalysisDate; // Evolution: yeni analiz tarihi

  PalmAnalysis({
    required this.analysis,
    DateTime? createdAt,
    this.imagePath,
    this.analysisType = AnalysisType.palm, // Backward compatible varsayılan
    this.secondaryImagePath,
    this.firstAnalysisDate,
    this.secondAnalysisDate,
  }) : createdAt = createdAt ?? DateTime.now();

  factory PalmAnalysis.fromJson(Map<String, dynamic> json) {
    return PalmAnalysis(
      analysis: json['analysis'],
      createdAt: DateTime.parse(json['createdAt']),
      imagePath: json['imagePath'],
      // Backward compatible - eski verilerde yoksa palm kabul et
      analysisType: json['analysisType'] != null
          ? AnalysisType.values.firstWhere(
              (e) => e.name == json['analysisType'],
              orElse: () => AnalysisType.palm,
            )
          : AnalysisType.palm,
      secondaryImagePath: json['secondaryImagePath'],
      firstAnalysisDate: json['firstAnalysisDate'] != null
          ? DateTime.parse(json['firstAnalysisDate'])
          : null,
      secondAnalysisDate: json['secondAnalysisDate'] != null
          ? DateTime.parse(json['secondAnalysisDate'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analysis': analysis,
      'createdAt': createdAt.toIso8601String(),
      'imagePath': imagePath,
      'analysisType': analysisType.name,
      'secondaryImagePath': secondaryImagePath,
      'firstAnalysisDate': firstAnalysisDate?.toIso8601String(),
      'secondAnalysisDate': secondAnalysisDate?.toIso8601String(),
    };
  }

  /// Relative veya absolute path'i her zaman absolute path'e çevirir.
  /// iOS'ta container UUID değişebileceği için bu metod gerekli.
  /// Geriye dönük uyumluluk: Eski absolute path'ler de desteklenir.
  Future<String?> getAbsoluteImagePath() async {
    if (imagePath == null || imagePath!.isEmpty) return null;

    // Zaten absolute path ise
    if (imagePath!.startsWith('/')) {
      final file = File(imagePath!);
      if (await file.exists()) {
        return imagePath; // Dosya mevcut, path geçerli
      }

      // Dosya bulunamadı - muhtemelen UUID değişmiş
      // Dosya adını çıkarıp yeni absolute path oluştur
      final fileName = imagePath!.split('/').last;
      final appDir = await getApplicationDocumentsDirectory();

      // palm_images klasöründe ara
      final newPath = '${appDir.path}/palm_images/$fileName';
      final newFile = File(newPath);
      if (await newFile.exists()) {
        return newPath;
      }

      // Documents root'ta da ara (eski format)
      final rootPath = '${appDir.path}/$fileName';
      final rootFile = File(rootPath);
      if (await rootFile.exists()) {
        return rootPath;
      }

      return null; // Dosya hiçbir yerde bulunamadı
    }

    // Relative path - absolute'a çevir
    final appDir = await getApplicationDocumentsDirectory();
    final absolutePath = '${appDir.path}/$imagePath';
    final file = File(absolutePath);

    if (await file.exists()) {
      return absolutePath;
    }

    return null; // Dosya bulunamadı
  }

  /// Senkron versiyon - sadece path'in absolute olup olmadığını kontrol eder
  /// Dosya varlığını kontrol etmez
  static Future<String?> resolveImagePath(String? storedPath) async {
    if (storedPath == null || storedPath.isEmpty) return null;

    final appDir = await getApplicationDocumentsDirectory();

    // Zaten absolute path ise kontrol et
    if (storedPath.startsWith('/')) {
      final file = File(storedPath);
      if (await file.exists()) {
        return storedPath;
      }

      // UUID değişmiş olabilir, dosya adını çıkar
      final fileName = storedPath.split('/').last;
      final newPath = '${appDir.path}/palm_images/$fileName';
      if (await File(newPath).exists()) {
        return newPath;
      }

      return null;
    }

    // Relative path - absolute'a çevir
    final absolutePath = '${appDir.path}/$storedPath';
    if (await File(absolutePath).exists()) {
      return absolutePath;
    }

    return null;
  }
}
