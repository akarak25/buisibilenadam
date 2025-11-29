import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:palm_analysis/utils/theme.dart';

/// Styled analysis view that parses and displays palm analysis beautifully
class StyledAnalysisView extends StatelessWidget {
  final String analysisText;
  final String languageCode;

  const StyledAnalysisView({
    super.key,
    required this.analysisText,
    this.languageCode = 'en',
  });

  bool get isEnglish => languageCode == 'en';

  @override
  Widget build(BuildContext context) {
    final sections = _parseAnalysis(analysisText);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Intro section if exists
        if (sections['intro'] != null && sections['intro']!.isNotEmpty)
          _buildIntroCard(sections['intro']!),

        // Palm line sections
        ...sections.entries
            .where((e) => e.key != 'intro' && e.key != 'conclusion')
            .map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSectionCard(e.key, e.value),
                )),

        // Conclusion if exists
        if (sections['conclusion'] != null &&
            sections['conclusion']!.isNotEmpty)
          _buildConclusionCard(sections['conclusion']!),
      ],
    );
  }

  /// Parse analysis text into sections
  Map<String, String> _parseAnalysis(String text) {
    final Map<String, String> sections = {};

    // Common section patterns (Turkish & English)
    final sectionPatterns = [
      // Turkish
      RegExp(r'(?:^|\n)\**\s*Yaşam Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Kalp Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Akıl Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Kafa Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Kader Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Güneş Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Sağlık Çizgisi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Evlilik Çizgi[^:]*:\**\s*', caseSensitive: false),
      // English
      RegExp(r'(?:^|\n)\**\s*Life Line[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Heart Line[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Head Line[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Fate Line[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Sun Line[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Health Line[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Marriage Line[^:]*:\**\s*', caseSensitive: false),
      // Mounts
      RegExp(r'(?:^|\n)\**\s*Venüs Tepesi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Jüpiter Tepesi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Satürn Tepesi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Ay Tepesi[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Mount of Venus[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Mount of Jupiter[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Mount of Saturn[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Mount of Moon[^:]*:\**\s*', caseSensitive: false),
      // Genel/Sonuç
      RegExp(r'(?:^|\n)\**\s*Genel Yorum[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Sonuç[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Overall[^:]*:\**\s*', caseSensitive: false),
      RegExp(r'(?:^|\n)\**\s*Conclusion[^:]*:\**\s*', caseSensitive: false),
      // Genel olarak başlayan paragraflar (conclusion pattern)
      RegExp(r'(?:^|\n)\s*Genel olarak,?\s+', caseSensitive: false),
      RegExp(r'(?:^|\n)\s*Sonuç olarak,?\s+', caseSensitive: false),
      RegExp(r'(?:^|\n)\s*Özet olarak,?\s+', caseSensitive: false),
      RegExp(r'(?:^|\n)\s*In summary,?\s+', caseSensitive: false),
      RegExp(r'(?:^|\n)\s*Overall,?\s+', caseSensitive: false),
    ];

    // Find all section matches with their positions
    List<MapEntry<int, String>> sectionStarts = [];

    for (final pattern in sectionPatterns) {
      final matches = pattern.allMatches(text);
      for (final match in matches) {
        String sectionName = _extractSectionName(match.group(0) ?? '');
        sectionStarts.add(MapEntry(match.start, sectionName));
      }
    }

    // Sort by position
    sectionStarts.sort((a, b) => a.key.compareTo(b.key));

    // If no sections found, return all as intro
    if (sectionStarts.isEmpty) {
      sections['intro'] = _cleanText(text);
      return sections;
    }

    // Extract intro (text before first section)
    if (sectionStarts.first.key > 0) {
      sections['intro'] = _cleanText(text.substring(0, sectionStarts.first.key));
    }

    // Extract each section
    for (int i = 0; i < sectionStarts.length; i++) {
      final currentStart = sectionStarts[i].key;
      final currentName = sectionStarts[i].value;

      int endPos;
      if (i < sectionStarts.length - 1) {
        endPos = sectionStarts[i + 1].key;
      } else {
        endPos = text.length;
      }

      String content = text.substring(currentStart, endPos);
      // Remove the section header from content
      content = content.replaceFirst(
          RegExp(r'^\**\s*[^:]+:\**\s*', caseSensitive: false), '');
      content = _cleanText(content);

      // Map to standard key
      String key = _normalizeKey(currentName);
      // Check if this is a conclusion section
      if (key == 'sonuç' ||
          key == 'genel yorum' ||
          key == 'conclusion' ||
          key == 'overall' ||
          key.startsWith('genel olarak') ||
          key.startsWith('sonuç olarak') ||
          key.startsWith('özet olarak') ||
          key.startsWith('in summary') ||
          key.startsWith('overall')) {
        // For "Genel olarak" style conclusions - content already contains the phrase
        // Don't duplicate it - just use content as-is
        sections['conclusion'] = content;
      } else {
        sections[key] = content;
      }
    }

    return sections;
  }

  String _extractSectionName(String match) {
    return match
        .replaceAll(RegExp(r'[\*\n:]'), '')
        .trim();
  }

  String _normalizeKey(String name) {
    return name.toLowerCase().trim();
  }

  String _cleanText(String text) {
    String result = text;

    // Remove markdown bold formatting (**text** or __text__)
    result = result.replaceAllMapped(
      RegExp(r'\*\*([^*]+)\*\*'),
      (match) => match.group(1) ?? '',
    );
    result = result.replaceAllMapped(
      RegExp(r'__([^_]+)__'),
      (match) => match.group(1) ?? '',
    );

    // Remove markdown italic formatting (*text* or _text_)
    result = result.replaceAllMapped(
      RegExp(r'\*([^*]+)\*'),
      (match) => match.group(1) ?? '',
    );
    result = result.replaceAllMapped(
      RegExp(r'_([^_]+)_'),
      (match) => match.group(1) ?? '',
    );

    // Clean bullet points
    result = result.replaceAll(RegExp(r'^\s*[\*\-•]\s*', multiLine: true), '• ');

    // Remove extra whitespace
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    result = result.replaceAll(RegExp(r' {2,}'), ' ');

    return result.trim();
  }

  Widget _buildIntroCard(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryIndigo.withOpacity(0.1),
            AppTheme.primaryPurple.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryIndigo.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEnglish ? 'Welcome' : 'Hoş Geldiniz',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryIndigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormattedText(text),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String sectionKey, String content) {
    final sectionInfo = _getSectionInfo(sectionKey);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: sectionInfo.color.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  sectionInfo.color.withOpacity(0.15),
                  sectionInfo.color.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: sectionInfo.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sectionInfo.icon,
                    color: sectionInfo.color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sectionInfo.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: sectionInfo.color,
                        ),
                      ),
                      if (sectionInfo.subtitle.isNotEmpty)
                        Text(
                          sectionInfo.subtitle,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  sectionInfo.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
          ),
          // Section content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildFormattedText(content),
          ),
        ],
      ),
    );
  }

  Widget _buildConclusionCard(String text) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.successGreen.withOpacity(0.1),
            AppTheme.primaryIndigo.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.successGreen.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppTheme.successGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                isEnglish ? 'Overall Assessment' : 'Genel Değerlendirme',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildFormattedText(text),
        ],
      ),
    );
  }

  Widget _buildFormattedText(String text) {
    final lines = text.split('\n');
    List<Widget> widgets = [];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        widgets.add(const SizedBox(height: 8));
        continue;
      }

      if (line.trim().startsWith('•') || line.trim().startsWith('-')) {
        // Bullet point
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigo,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    line.trim().replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppTheme.textPrimary,
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              line.trim(),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  _SectionInfo _getSectionInfo(String key) {
    final keyLower = key.toLowerCase();

    // Yaşam/Life Line
    if (keyLower.contains('yaşam') || keyLower.contains('life')) {
      return _SectionInfo(
        title: isEnglish ? 'Life Line' : 'Yaşam Çizgisi',
        subtitle: isEnglish ? '' : 'Life Line',
        icon: Icons.favorite_rounded,
        color: const Color(0xFFE91E63),
        emoji: '💗',
      );
    }

    // Kalp/Heart Line
    if (keyLower.contains('kalp') || keyLower.contains('heart')) {
      return _SectionInfo(
        title: isEnglish ? 'Heart Line' : 'Kalp Çizgisi',
        subtitle: isEnglish ? '' : 'Heart Line',
        icon: Icons.volunteer_activism_rounded,
        color: const Color(0xFFE53935),
        emoji: '❤️',
      );
    }

    // Akıl/Kafa/Head Line
    if (keyLower.contains('akıl') || keyLower.contains('kafa') || keyLower.contains('head')) {
      return _SectionInfo(
        title: isEnglish ? 'Head Line' : 'Akıl Çizgisi',
        subtitle: isEnglish ? '' : 'Head Line',
        icon: Icons.psychology_rounded,
        color: const Color(0xFF3F51B5),
        emoji: '🧠',
      );
    }

    // Kader/Fate Line
    if (keyLower.contains('kader') || keyLower.contains('fate')) {
      return _SectionInfo(
        title: isEnglish ? 'Fate Line' : 'Kader Çizgisi',
        subtitle: isEnglish ? '' : 'Fate Line',
        icon: Icons.auto_awesome_rounded,
        color: const Color(0xFF9C27B0),
        emoji: '✨',
      );
    }

    // Güneş/Sun Line
    if (keyLower.contains('güneş') || keyLower.contains('sun')) {
      return _SectionInfo(
        title: isEnglish ? 'Sun Line' : 'Güneş Çizgisi',
        subtitle: isEnglish ? '' : 'Sun Line',
        icon: Icons.wb_sunny_rounded,
        color: const Color(0xFFFF9800),
        emoji: '☀️',
      );
    }

    // Sağlık/Health Line
    if (keyLower.contains('sağlık') || keyLower.contains('health')) {
      return _SectionInfo(
        title: isEnglish ? 'Health Line' : 'Sağlık Çizgisi',
        subtitle: isEnglish ? '' : 'Health Line',
        icon: Icons.health_and_safety_rounded,
        color: const Color(0xFF4CAF50),
        emoji: '💚',
      );
    }

    // Evlilik/Marriage Line
    if (keyLower.contains('evlilik') || keyLower.contains('marriage')) {
      return _SectionInfo(
        title: isEnglish ? 'Marriage Line' : 'Evlilik Çizgisi',
        subtitle: isEnglish ? '' : 'Marriage Line',
        icon: Icons.favorite_border_rounded,
        color: const Color(0xFFFF4081),
        emoji: '💍',
      );
    }

    // Venüs Tepesi
    if (keyLower.contains('venüs') || keyLower.contains('venus')) {
      return _SectionInfo(
        title: isEnglish ? 'Mount of Venus' : 'Venüs Tepesi',
        subtitle: isEnglish ? '' : 'Mount of Venus',
        icon: Icons.spa_rounded,
        color: const Color(0xFFEC407A),
        emoji: '🌸',
      );
    }

    // Jüpiter Tepesi
    if (keyLower.contains('jüpiter') || keyLower.contains('jupiter')) {
      return _SectionInfo(
        title: isEnglish ? 'Mount of Jupiter' : 'Jüpiter Tepesi',
        subtitle: isEnglish ? '' : 'Mount of Jupiter',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFFFB300),
        emoji: '👑',
      );
    }

    // Satürn Tepesi
    if (keyLower.contains('satürn') || keyLower.contains('saturn')) {
      return _SectionInfo(
        title: isEnglish ? 'Mount of Saturn' : 'Satürn Tepesi',
        subtitle: isEnglish ? '' : 'Mount of Saturn',
        icon: Icons.architecture_rounded,
        color: const Color(0xFF607D8B),
        emoji: '🪐',
      );
    }

    // Ay Tepesi
    if (keyLower.contains('ay tepesi') || keyLower.contains('moon')) {
      return _SectionInfo(
        title: isEnglish ? 'Mount of Moon' : 'Ay Tepesi',
        subtitle: isEnglish ? '' : 'Mount of Moon',
        icon: Icons.nightlight_round,
        color: const Color(0xFF5C6BC0),
        emoji: '🌙',
      );
    }

    // Default
    return _SectionInfo(
      title: _capitalizeFirst(key),
      subtitle: '',
      icon: Icons.touch_app_rounded,
      color: AppTheme.primaryIndigo,
      emoji: '✋',
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

class _SectionInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String emoji;

  _SectionInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.emoji,
  });
}
