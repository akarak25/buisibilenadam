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
    
    // Numaralı listeleri düzelt
    // Şu şekilde formatları düzeltir: 
    // "1. item" -> "1. item"
    // Her numaralı öğe için yeni satır ekler
    final numberedListPattern = RegExp(r'(^|\n|\s)(\d+)\.\s*([^\n]+)', multiLine: true);
    result = result.replaceAllMapped(numberedListPattern, (match) {
      final prefix = match.group(1) ?? '';
      final number = match.group(2) ?? '';
      final content = match.group(3) ?? '';
      
      // Eğer zaten satır başındaysa veya öncesi boşluksa düzgün formatta
      if (prefix == '\n' || prefix.trim().isEmpty) {
        return '$prefix$number. $content\n';
      }
      // Değilse, yeni satır ekle
      return '$prefix\n$number. $content\n';
    });
    
    // Liste öğelerini düzelt
    result = result.replaceAll('* ', '\n* ');
    
    // Paragrafları düzelt (satır sonlarını)
    // Cümle bitişlerinden sonra paragraf oluştur, ancak numaralandırılmış listeleri bozma
    final sentenceEndPattern = RegExp(r'([.!?])\s+(?!\d+\.\s)', multiLine: true);
    result = result.replaceAllMapped(sentenceEndPattern, (match) {
      return '${match.group(1)}\n\n';
    });
    
    // Fazla boş satırları temizle
    result = result.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    
    // Çift boşlukları temizle
    result = result.replaceAll(RegExp(r' {2,}'), ' ');
    
    return result;
  }
}
