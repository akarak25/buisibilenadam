/// Markdown biçimlendirme işlemleri için yardımcı sınıf
class MarkdownFormatter {
  /// API'den gelen metni düzgün bir markdown formatına dönüştürür
  static String format(String text) {
    if (text.isEmpty) return text;
    
    String result = text;
    
    // ## işaretleri arasındaki metinleri başlık olarak düzenle
    final headingPattern = RegExp(r'##\s*(.*?)\s*##', dotAll: true);
    result = result.replaceAllMapped(headingPattern, (match) {
      String heading = match.group(1) ?? '';
      heading = heading.trim();
      
      // Markdown başlık formatına dönüştür - daha büyük ve koyu şekilde görüntülenmesi için h2 kullan
      return '\n## $heading\n';
    });
    
    // Liste öğelerini düzelt
    result = result.replaceAll('* ', '\n* ');
    
    // Paragrafları düzelt (satır sonlarını)
    result = result.replaceAll('. ', '.\n\n').trim();
    result = result.replaceAll('! ', '!\n\n').trim();
    result = result.replaceAll('? ', '?\n\n').trim();
    
    // Fazla boş satırları temizle
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Çift boşlukları temizle
    result = result.replaceAll(RegExp(r' {2,}'), ' ');
    
    return result;
  }
}
