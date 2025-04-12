import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:palm_analysis/providers/locale_provider.dart';
import 'package:palm_analysis/l10n/app_localizations.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(appLocalizations.currentLanguage.languageSettings),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _buildLanguageOption(
              context: context,
              flag: '🇹🇷',
              language: appLocalizations.currentLanguage.turkish,
              locale: const Locale('tr'),
            ),
            _buildLanguageOption(
              context: context,
              flag: '🇬🇧',
              language: appLocalizations.currentLanguage.english,
              locale: const Locale('en'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String flag,
    required String language,
    required Locale locale,
  }) {
    final provider = Provider.of<LocaleProvider>(context);
    final isSelected = provider.locale.languageCode == locale.languageCode;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected
              ? BorderSide(color: Theme.of(context).primaryColor, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: () => provider.setLocale(locale),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Text(
                  flag,
                  style: const TextStyle(fontSize: 30),
                ),
                const SizedBox(width: 16),
                Text(
                  language,
                  style: const TextStyle(fontSize: 18),
                ),
                const Spacer(),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
