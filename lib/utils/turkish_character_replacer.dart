/// Çok agresif Türkçe karakter düzeltici - son çare olarak kullanılır
class TurkishCharacterReplacer {
  // Türkçe karakter problemleri için özel char-by-char düzelticiler
  static final Map<String, String> _replacements = {
    "Å": "Ş", "Å": "ş", "Ã": "Ö", "Ã": "Ü", "Ã": "Ç", "Ä": "İ", "Ä": "ğ",
    "±": "ı", "Ä": "ğ", "Ä": "İ", "Ã¼": "ü", "Ã¶": "ö", "Ã§": "ç",
    "â": "i", "Â": "İ", "â": "ı", "Å¾": "ş", "ÅŸ": "ş", "Ã¯": "i", "Ã®": "i",
    "ÅŸ": "ş", "Ä±": "ı", "ÄŸ": "ğ", "Ä°": "İ", "Ã": "ç", "ð": "ğ"
  };
  
  // Özel problemli durumlar için kelime bazlı düzeltmeler
  static final List<_Replacement> _problemPatterns = [
    _Replacement("Ã‡izgi", "Çizgi"),
    _Replacement("AkÄ±l", "Akıl"), 
    _Replacement("YaÅŸam", "Yaşam"),
    _Replacement("yaÅŸam", "yaşam"),
    _Replacement("Ä°liÅŸki", "İlişki"),
    _Replacement("iliÅŸki", "ilişki"),
    _Replacement("kiÅŸi", "kişi"),
    _Replacement("KiÅŸi", "Kişi"),
    _Replacement("baÅŸar", "başar"),
    _Replacement("BaÅŸar", "Başar"),
    _Replacement("gÄ±ven", "güven"),
    _Replacement("gÃ¼ven", "güven"),
    _Replacement("dÃ¼ÅŸÃ¼n", "düşün"),
    _Replacement("dÄ±ÅŸÄ±nda", "dışında"),
    _Replacement("ÅŸekil", "şekil"),
    _Replacement("saÄŸlÄ±", "sağlı"),
    _Replacement("saÄŸlam", "sağlam"),
    _Replacement("deÄŸil", "değil"),
    _Replacement("deÄŸer", "değer"),
    _Replacement("gÄ±stariy", "gösteri"),
    _Replacement("gÃ¶steri", "gösteri"),
    _Replacement("bÄ±nye", "bünye"),
    _Replacement("bÃ¼nye", "bünye"),
    _Replacement("çalÄ±ÅŸ", "çalış"),
    _Replacement("Ã§alÄ±ÅŸ", "çalış"),
    _Replacement("yÄ±ksek", "yüksek"),
    _Replacement("yÃ¼ksek", "yüksek"),
    _Replacement("aÄŸÄ±k", "açık"),
    _Replacement("aÃ§Ä±k", "açık"),
    _Replacement("danÄ±ÅŸ", "danış"),
    _Replacement("danÄ±ÅŸan", "danışan"),
    _Replacement("gÄ±ç", "güç"),
    _Replacement("gÃ¼Ã§", "güç"),
  ];
  
  // Her kelimeyi kontrol edip düzeltmeler uygula
  static String fixText(String text) {
    if (text.isEmpty) return text;
    
    String result = text;
    
    // Özel kelime düzeltmeleri
    for (var pattern in _problemPatterns) {
      result = result.replaceAll(pattern.pattern, pattern.replacement);
    }
    
    // Karakter düzeltmeleri
    _replacements.forEach((key, value) {
      result = result.replaceAll(key, value);
    });
    
    // Kalp Çizgisi isimlendirmelerini düzelt
    final lineTypes = [
      "Kalp Çizgi",
      "Akıl Çizgi", 
      "Yaşam Çizgi",
      "Kader Çizgi", 
      "Evlilik Çizgi", 
      "Zenginlik Çizgi"
    ];
    
    for (var type in lineTypes) {
      if (result.contains(type)) {
        result = result.replaceAll(type, "$type si");
      }
    }
    
    return result;
  }
}

// Değişiklik yardımcı sınıfı
class _Replacement {
  final String pattern;
  final String replacement;
  
  _Replacement(this.pattern, this.replacement);
}
