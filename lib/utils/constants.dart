class Constants {
  static const String appName = 'El Çizgisi Analizi';
  static const String appDescription = 'Avuç içi çizgilerinizden geleceğinizi keşfedin';
  
  // El çizgisi türleri
  static const String heartLine = 'Kalp Çizgisi';
  static const String headLine = 'Akıl Çizgisi';
  static const String lifeLine = 'Yaşam Çizgisi';
  static const String fateLine = 'Kader Çizgisi';
  static const String sunLine = 'Güneş Çizgisi';
  static const String marriageLine = 'Evlilik Çizgisi';
  static const String wealthLine = 'Zenginlik Çizgisi';
  
  // El çizgisi açıklamaları
  static const Map<String, String> lineDescriptions = {
    heartLine: 'Kalp çizgisi, duygusal yaşamınızı, ilişkilerinizi ve duygusal sağlığınızı gösterir.',
    headLine: 'Akıl çizgisi, düşünce şeklinizi, zihinsel yeteneklerinizi ve iletişim tarzınızı temsil eder.',
    lifeLine: 'Yaşam çizgisi, genel sağlığınızı, yaşam enerjinizi ve önemli yaşam olaylarını gösterir.',
    fateLine: 'Kader çizgisi, kariyer yolunuzu, başarılarınızı ve hayat amacınızı temsil eder.',
    sunLine: 'Güneş çizgisi, ün, başarı ve yaratıcılık potansiyelinizi gösterir.',
    marriageLine: 'Evlilik çizgisi, önemli romantik ilişkilerinizi ve bunların kalitesini temsil eder.',
    wealthLine: 'Zenginlik çizgisi, maddi refahınızı ve zenginlik potansiyelinizi gösterir.',
  };
  
  // Claude için sistem mesajı
  static const String systemPrompt = '''
Sen bir el falı uzmanısın ve avuç içi çizgilerini analiz edebilirsin. Gönderdiğim avuç içi fotoğrafını analiz ederek şu çizgiler hakkında bilgi vermelisin:

1. Kalp Çizgisi: Duygusal yaşam, ilişkiler ve duygusal sağlıkla ilgili bilgiler
2. Akıl Çizgisi: Düşünce şekli, zihinsel yetenek ve iletişim tarzı
3. Yaşam Çizgisi: Genel sağlık, yaşam enerjisi ve önemli yaşam olayları
4. Kader Çizgisi: Kariyer, başarılar ve hayat amacı
5. Evlilik Çizgisi: Önemli romantik ilişkiler
6. Zenginlik Çizgisi: Maddi refah ve zenginlik potansiyeli

Her çizgiyi detaylı analiz et ve ilgilendikleri kişiye özel yorumlar yap. Yanıtın 300-500 kelime arasında olmalı ve kişiye özel hissettirmeli.

Bilimsel değil mistik bir bakış açısıyla yorumla. Yanıtını Markdown formatında düzenle ve her bölüm için başlıklar kullan.

Ayırt edilebilir el çizgilerini göremiyorsan veya fotoğraf yeterince net değilse, lütfen kullanıcıya daha net bir fotoğraf çekmesini ve avuç içini iyi aydınlatmasını söyle.
''';

  // Onboarding ekranı için metinler
  static const List<Map<String, String>> onboardingContent = [
    {
      'title': 'El Çizginizi Keşfedin',
      'description': 'Avuç içi çizgilerinizden kişiliğinizi, geçmişinizi ve geleceğinizi keşfedin.',
    },
    {
      'title': 'Fotoğrafını Çek',
      'description': 'Avuç içinizin net bir fotoğrafını çekin veya galeriden yükleyin.',
    },
    {
      'title': 'Yapay Zeka Analizi',
      'description': 'Yapay zeka teknolojisi çizgilerinizi analiz ederek kişiselleştirilmiş yorumlar sunar.',
    },
    {
      'title': 'Hayatınıza Işık Tut',
      'description': 'Aşk, kariyer, sağlık ve zenginlik çizgilerinizde saklı olan bilgileri öğrenin.',
    },
  ];
}
