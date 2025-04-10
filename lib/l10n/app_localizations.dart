import 'package:flutter/material.dart';
import 'package:palm_analysis/l10n/languages/language_tr.dart';
import 'package:palm_analysis/l10n/languages/language_en.dart';
import 'package:palm_analysis/l10n/languages/language_de.dart';
import 'package:palm_analysis/l10n/languages/language_fr.dart';
import 'package:palm_analysis/l10n/languages/language_es.dart';
import 'package:palm_analysis/l10n/languages/app_language.dart';

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  // Desteklenen diller
  static final Map<String, AppLanguage> _localizedValues = {
    'tr': LanguageTr(),
    'en': LanguageEn(),
    'de': LanguageDe(),
    'fr': LanguageFr(),
    'es': LanguageEs(),
  };
  
  // Desteklenen dil listesi
  static List<Locale> get supportedLocales {
    return _localizedValues.keys.map((code) => Locale(code)).toList();
  }
  
  // Şu anki dildeki metinleri al
  AppLanguage get currentLanguage {
    return _localizedValues[locale.languageCode] ?? LanguageTr();  // Varsayılan olarak Türkçe
  }

  // AppLocalizations'ı contextten almak için statik yardımcı metod
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? AppLocalizations(const Locale('tr'));
  }
}

// Localization delegesi
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations._localizedValues.containsKey(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizations> old) => false;
}
