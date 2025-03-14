/// Çok agresif Türkçe karakter düzeltici - son çare olarak kullanılır
class TurkishEncodingFixer {
  // Ana düzeltme fonksiyonu
  static String fix(String text) {
    if (text.isEmpty) return text;
    
    // Basit karakter düzeltmeleri
    String result = text
      .replaceAll("Ä±", "ı")
      .replaceAll("±", "ı")
      .replaceAll("ÅŸ", "ş")
      .replaceAll("ÄŸ", "ğ")
      .replaceAll("Ä°", "İ")
      .replaceAll("Ã¶", "ö")
      .replaceAll("Ã¼", "ü")
      .replaceAll("Ã§", "ç")
      .replaceAll("Ãœ", "Ü")
      .replaceAll("Ã–", "Ö")
      .replaceAll("Ã‡", "Ç")
      .replaceAll("Š", "Ş")
      .replaceAll("Å", "Ş")
      .replaceAll("ÅŸ", "ş")
      .replaceAll("ŠŸ", "ş")
      .replaceAll("Š'", "ş")
      .replaceAll("Åž", "Ş")
      .replaceAll("Åş", "ş")
      .replaceAll("Åı", "ı");
      
    // El çizgisi metinlerinde sık görülen problemli kısımları düzelt
    result = result
      .replaceAll("akÄ±l", "akıl")
      .replaceAll("yaÅŸam", "yaşam")
      .replaceAll("iliÅŸki", "ilişki")
      .replaceAll("kiÅŸi", "kişi")
      .replaceAll("Ã‡izgi", "Çizgi")
      .replaceAll("deÄŸil", "değil")
      .replaceAll("gÃ¼ven", "güven")
      .replaceAll("baÅŸar", "başar")
      .replaceAll("Ã¶nem", "önem")
      .replaceAll("iÅŸaret", "işaret")
      .replaceAll("Ã§alÄ±ÅŸ", "çalış")
      .replaceAll("miÅŸtik", "mistik")
      .replaceAll("görsêl", "görsel")
      .replaceAll("aviç", "avuç")
      .replaceAll("aviç içi", "avuç içi")
      .replaceAll("Ðzgünüm", "Üzgünüm")
      .replaceAll("gðnder", "gönder")
      .replaceAll("kiiðye", "kişiye")
      .replaceAll("kiiði", "kişi")
      .replaceAll("Åeekil", "şekil")
      .replaceAll("Ã¾ekil", "şekil")
      .replaceAll("Åekilde", "şekilde");
      
    // El çizgisi başlıklarını düzelt
    result = result
      .replaceAll("Kalp çizgi", "Kalp Çizgisi")
      .replaceAll("Akıl çizgi", "Akıl Çizgisi")
      .replaceAll("Yaşam çizgi", "Yaşam Çizgisi")
      .replaceAll("Kader çizgi", "Kader Çizgisi")
      .replaceAll("Evlilik çizgi", "Evlilik Çizgisi")
      .replaceAll("Zenginlik çizgi", "Zenginlik Çizgisi");
      
    return result;
  }
}
