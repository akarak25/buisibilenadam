import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  final String _prefsKey = 'app_locale';
  Locale _locale = const Locale('tr'); // Varsayılan olarak Türkçe
  
  Locale get locale => _locale;
  
  /// Sağlayıcıyı başlatır ve kaydedilmiş dili yükler
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedLocale = prefs.getString(_prefsKey);
      
      if (savedLocale != null) {
        _locale = Locale(savedLocale);
      }
    } catch (e) {
      debugPrint('Dil yüklenirken hata: $e');
      // Hata durumunda varsayılan dil kullanılır (TR)
    }
    
    notifyListeners();
  }
  
  /// Dili değiştirir ve kaydeder
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (e) {
      debugPrint('Dil kaydedilirken hata: $e');
      // Kaydetme hatası iş mantığını etkilemez
    }
  }
}
