import 'dart:convert';

// UTF-8 çözme problemlerini ele alacak özel bir araç
class UTF8Decoder {
  // UTF-8 kodlamasını çözmeyi dene
  static String decodeUTF8(String text) {
    try {
      // UTF-8 byte listesine dönüştür
      List<int> bytes = utf8.encode(text);
      
      // Tekrar decode et (bozuk encoding için çözüm olabiliyor)
      String result = utf8.decode(bytes, allowMalformed: true);
      
      return _postProcess(result);
    } catch (e) {
      // Çözümlenemezse orijinal metni döndür
      return text;
    }
  }
  
  // URL içeriğinde bile bozulmuş Türkçe karakterleri düzeltmeyi dene
  static String decodeURLEncoded(String text) {
    try {
      // URL decodingden geçir
      String decoded = Uri.decodeFull(text);
      // UTF-8 düzeltmesini uygula
      return decodeUTF8(decoded);
    } catch (e) {
      return text;
    }
  }
  
  // Çözülmüş metnin son işlemleri
  static String _postProcess(String text) {
    // UTF-8 düzeltmeden sonra hala bozuk olabilen bazı karakterleri düzelt
    return text
      .replaceAll('Ã§', 'ç')
      .replaceAll('Ã¶', 'ö')
      .replaceAll('Ã¼', 'ü')
      .replaceAll('Ä\u011f', 'ğ')
      .replaceAll('Ä\u0131', 'ı')
      .replaceAll('Å\u015f', 'ş')
      .replaceAll('Ä°', 'İ');
  }
}
