import 'dart:io';
import 'package:flutter/material.dart';
import 'package:palm_analysis/models/auth_response.dart';
import 'package:palm_analysis/services/api_service.dart';

/// Palm analysis service that uses elcizgisi.com backend
/// No direct OpenAI API calls - all analysis is done through the backend
class PalmAnalysisService {
  final ApiService _apiService = ApiService();
  final BuildContext? context;

  PalmAnalysisService({this.context});

  /// Analyze palm image using backend API
  /// Returns the analysis text or error message
  Future<String> analyzeHandImage(File imageFile, {Locale? locale}) async {
    try {
      // Validate image file
      if (!await imageFile.exists()) {
        return _getErrorMessage('file_not_found', locale);
      }

      final fileSize = await imageFile.length();
      if (fileSize <= 0) {
        return _getErrorMessage('invalid_file', locale);
      }

      // Max 5MB check
      if (fileSize > 5 * 1024 * 1024) {
        return _getErrorMessage('file_too_large', locale);
      }

      // Call backend API with language preference
      final languageCode = locale?.languageCode ?? 'tr';
      final response = await _apiService.analyzeImage(imageFile, language: languageCode);

      // Return the analysis text
      return response.analysis;
    } on ApiError catch (e) {
      debugPrint('API Error: ${e.error}');
      return _getApiErrorMessage(e, locale);
    } catch (e) {
      debugPrint('Analysis error: $e');
      return _getErrorMessage('generic_error', locale);
    }
  }

  /// Get localized error message
  String _getErrorMessage(String errorType, Locale? locale) {
    final isTurkish = locale?.languageCode == 'tr';

    switch (errorType) {
      case 'file_not_found':
        return isTurkish
            ? '# Dosya Bulunamadi\n\nAnaliz edilecek goruntu bulunamadi. Lutfen tekrar bir fotograf cekin veya secin.'
            : '# File Not Found\n\nThe image to analyze was not found. Please take or select a photo again.';

      case 'invalid_file':
        return isTurkish
            ? '# Gecersiz Dosya\n\nFotograf bos veya bozuk. Lutfen yeni bir fotograf cekin.'
            : '# Invalid File\n\nThe photo is empty or corrupted. Please take a new photo.';

      case 'file_too_large':
        return isTurkish
            ? '# Dosya Cok Buyuk\n\nFotograf 5MB\'dan buyuk. Lutfen daha kucuk bir fotograf secin.'
            : '# File Too Large\n\nThe photo is larger than 5MB. Please select a smaller photo.';

      case 'network_error':
        return isTurkish
            ? '# Baglanti Hatasi\n\nInternet baglantinizi kontrol edip tekrar deneyin.'
            : '# Connection Error\n\nPlease check your internet connection and try again.';

      case 'generic_error':
      default:
        return isTurkish
            ? '# Hata\n\nEl analizi sirasinda bir hata olustu. Lutfen tekrar deneyin.'
            : '# Error\n\nAn error occurred during palm analysis. Please try again.';
    }
  }

  /// Get API error message based on status code
  String _getApiErrorMessage(ApiError error, Locale? locale) {
    final isTurkish = locale?.languageCode == 'tr';

    switch (error.statusCode) {
      case 400:
        return isTurkish
            ? '# Gecersiz Istek\n\n${error.error}'
            : '# Invalid Request\n\n${error.error}';

      case 401:
        return isTurkish
            ? '# Oturum Hatasi\n\nLutfen tekrar giris yapin.'
            : '# Session Error\n\nPlease log in again.';

      case 429:
        return isTurkish
            ? '# Cok Fazla Istek\n\nCok fazla istek gonderdiniz. Lutfen birkaç dakika bekleyip tekrar deneyin.'
            : '# Too Many Requests\n\nYou have sent too many requests. Please wait a few minutes and try again.';

      case 500:
        return isTurkish
            ? '# Sunucu Hatasi\n\nSunucularda bir sorun var. Lutfen daha sonra tekrar deneyin.'
            : '# Server Error\n\nThere is a problem with the servers. Please try again later.';

      case 503:
        return isTurkish
            ? '# Hizmet Kullanilmiyor\n\nHizmet gecici olarak kullanilamiyor. Lutfen daha sonra tekrar deneyin.'
            : '# Service Unavailable\n\nThe service is temporarily unavailable. Please try again later.';

      default:
        return isTurkish
            ? '# Hata\n\n${error.error}'
            : '# Error\n\n${error.error}';
    }
  }
}
