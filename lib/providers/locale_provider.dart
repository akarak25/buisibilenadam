import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  final String _prefsKey = 'app_locale';
  Locale _locale = const Locale('en'); // Default: English

  Locale get locale => _locale;

  /// Initialize provider and load saved language
  /// Detects device language on first launch
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedLocale = prefs.getString(_prefsKey);

      if (savedLocale != null) {
        // User has previously selected a language, use it
        _locale = Locale(savedLocale);
      } else {
        // First launch - detect device language
        final deviceLocale = ui.PlatformDispatcher.instance.locale;
        final deviceLanguage = deviceLocale.languageCode;

        // Supported languages: en, tr
        if (deviceLanguage == 'tr') {
          _locale = const Locale('tr');
        } else {
          // All other languages default to English
          _locale = const Locale('en');
        }

        // Save initial selection
        await prefs.setString(_prefsKey, _locale.languageCode);
        debugPrint('Device language detected: $deviceLanguage, app locale set to: ${_locale.languageCode}');
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
      // On error, default language is used (EN)
    }

    notifyListeners();
  }
  
  /// Dili değiştirir ve kaydeder
  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    // Sadece tr ve en dilleri destekleniyor
    if (locale.languageCode != 'tr' && locale.languageCode != 'en') {
      debugPrint('Desteklenmeyen dil: ${locale.languageCode}');
      return;
    }
    
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
