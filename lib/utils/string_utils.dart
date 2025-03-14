import 'turkish_encoding_fixer.dart';

/// Türkçe karakter sorunlarını çözmek için yardımcı sınıf
class StringUtils {
  /// API yanıtlarındaki bozuk Türkçe karakterleri düzeltir
  static String fixTurkishCharacters(String text) {
    if (text.isEmpty) return text;

    // Basit düzeltmeler
    String result = text;

    // Manuel karakter düzeltmeleri - 'const map' yerine doğrudan replaceAll kullan
    result = result
        // Türkçe karakterler
        .replaceAll('Ã¼', 'ü')
        .replaceAll('Ã¶', 'ö')
        .replaceAll('Ã§', 'ç')
        .replaceAll('Ä±', 'ı')
        .replaceAll('ÅŸ', 'ş')
        .replaceAll('ÄŸ', 'ğ')
        .replaceAll('Ä°', 'İ')
        .replaceAll('Ãœ', 'Ü')
        .replaceAll('Ã–', 'Ö')
        .replaceAll('Ã‡', 'Ç')
        .replaceAll('ÅŠ', 'Ş')
        // Yaygın hatalı kelimeler
        .replaceAll('deÄŸil', 'değil')
        .replaceAll('yaÅŸam', 'yaşam')
        .replaceAll('kiÅŸisel', 'kişisel')
        .replaceAll('baÅŸarÄ±', 'başarı')
        .replaceAll('iliÅŸki', 'ilişki')
        .replaceAll('çizgisÄ', 'çizgisi')
        .replaceAll('çalÄ±ÅŸma', 'çalışma')
        .replaceAll('saÄŸlÄ±k', 'sağlık')
        .replaceAll('kiÅŸi', 'kişi')
        .replaceAll('iÅŸaret', 'işaret')
        .replaceAll('dÄ±ÅŸÄ±nda', 'dışında')
        .replaceAll('Ä°liÅŸkim', 'İlişkim')
        .replaceAll('yaklaÅŸ', 'yaklaş')
        .replaceAll('geliÅŸ', 'geliş')
        .replaceAll('ÅŸekil', 'şekil')
        // Özel karakterleri düzeltme
        .replaceAll('Åž', 'Ş')
        .replaceAll('Åş', 'ş')
        .replaceAll('Åı', 'ı')
        .replaceAll('Šı', 'Şı')
        .replaceAll('ŠŸ', 'ş')
        .replaceAll('Š', 'Ş')
        .replaceAll('Å', 'Ş')
        .replaceAll('Şekilde', 'şekilde')
        .replaceAll('Şêekil', 'şekil')
        .replaceAll('Ðzgünüm', 'Üzgünüm')
        .replaceAll('gðnder', 'gönder')
        .replaceAll('görsel', 'görsel')
        .replaceAll('aviç', 'avuç')
        .replaceAll('aviç içi', 'avuç içi')
        .replaceAll('kiiðye', 'kişiye')
        .replaceAll('kiiðsel', 'kişisel')
        .replaceAll('el falınza', 'el falınıza')
        .replaceAll('mištik', 'mistik')
        .replaceAll('Ä', 'İ')
        .replaceAll('Ã', '')
        .replaceAll('Â', '')
        .replaceAll('±', 'ı');

    return result;
  }

  // El çizgisi analizi için özel kelime düzeltmeleri
  static String fixPalmReadingSpecificTerms(String text) {
    String result = text
        .replaceAll('Kalp izgi', 'Kalp çizgi')
        .replaceAll('Akal izgi', 'Akıl çizgi')
        .replaceAll('Yal izgi', 'Yaşam çizgi')
        .replaceAll('Kader izgi', 'Kader çizgi')
        .replaceAll('Evlilik izgi', 'Evlilik çizgi')
        .replaceAll('Zenginlik izgi', 'Zenginlik çizgi');

    return result;
  }

  /// Toplu düzeltme fonksiyonu
  static String fixAllIssues(String text) {
    // Önce kendi iç düzeltme fonksiyonlarımızı çağır
    String result = fixTurkishCharacters(text);

    // Sonra el çizgisine özel terimleri düzelt
    result = fixPalmReadingSpecificTerms(result);

    // Özel Türkçe karakter düzelticimizi kullan
    result = TurkishEncodingFixer.fix(result);

    // Son düzeltmeler
    result = result
        .replaceAll('Akl Çizgisi', 'Akıl Çizgisi')
        .replaceAll('Kalp çizgisi', 'Kalp Çizgisi')
        .replaceAll('Yaşam çizgisi', 'Yaşam Çizgisi')
        .replaceAll('Kader çizgisi', 'Kader Çizgisi')
        .replaceAll('Evlilik çizgisi', 'Evlilik Çizgisi')
        .replaceAll('Zenginlik çizgisi', 'Zenginlik Çizgisi');

    return result;
  }
}
