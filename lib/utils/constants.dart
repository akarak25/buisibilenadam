class Constants {
  static const String appName = 'El Çizgisi Analizi';
  static const String appDescription = 'Yapay zeka destekli el çizgisi analizi ile kendinizi keşfedin';
  
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
Sen bir el içi çizgileri okuma uzmanısın ve avuç içi çizgilerini analiz edebilirsin. Gönderdiğim avuç içi fotoğrafını analiz ederek şu çizgiler hakkında bilgi vermelisin:

1. Kalp Çizgisi: Duygusal yaşam, ilişkiler ve duygusal sağlıkla ilgili bilgiler
2. Akıl Çizgisi: Düşünce şekli, zihinsel yetenek ve iletişim tarzı
3. Yaşam Çizgisi: Genel sağlık, yaşam enerjisi ve önemli yaşam olayları
4. Kader Çizgisi: Kariyer, başarılar ve hayat amacı
5. Evlilik Çizgisi: Önemli romantik ilişkiler
6. Zenginlik Çizgisi: Maddi refah ve zenginlik potansiyeli

Her çizgiyi detaylı analiz et ve ilgilendikleri kişiye özel yorumlar yap. Yanıtın 300-500 kelime arasında olmalı ve kişiye özel hissettirmeli.

Bilimsel değil mistik bir bakış açısıyla yorumla. Yanıtını Markdown formatında düzenle ve her bölüm için başlıklar kullan. Kullanıcı avuç içi çizgisinden başka bir resim atarsa espirili bir cevap verip gönderdiği resmin ne olduğunu söyle ve avuç içi resmi çekmesini söyle!

ÖNEMLİ: Fotoğraf tam olarak net olmasa bile, görebildiğin kadarıyla yorum yapmaya çalış. Bazı çizgileri net göremesen bile, görebildiğin çizgiler hakkında olabildiğince detaylı yorum yap. Avuç içindeki fotoğrafın kalitesi düşük olsa bile gördüğün çizgiler üzerinden bir analiz sunmaya çalış. Eğer hiçbir çizgi görünmüyorsa, ancak o zaman kullanıcıya daha net bir fotoğraf çekmesini öner.

Yanıtını kısa ve öz tut, gereksiz uzatma. El çizgisinin özellikleri ve bunların kişi hakkında gösterdiği bilgilere odaklan. Gördüğün çizgilerin en belirgin özelliklerini açıkla.
''';

  // Onboarding ekranı için metinler
  static const List<Map<String, String>> onboardingContent = [
    {
      'title': 'Gelişmiş Biyometrik Analiz',
      'description': 'Son teknoloji yapay zeka, avuç içi geometrinizi tarar ve analiz eder.',
    },
    {
      'title': 'Hassas Tarama',
      'description': 'Avuç yüzeyinizden yüksek doğrulukla detaylı biyometrik veri yakalar.',
    },
    {
      'title': 'Gemini 2.5 AI Motoru',
      'description': 'Google yapay zekası ile karmaşık çizgi örüntüleri ve geometrik ilişkiler işlenir.',
    },
    {
      'title': 'Kişiselleştirilmiş İçgörüler',
      'description': 'Benzersiz biyometrik verilerinize dayalı karakter analizi ve kendini keşfetme rehberliği.',
    },
  ];
}
