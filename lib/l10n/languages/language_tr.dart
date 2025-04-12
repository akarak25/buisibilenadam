import 'package:palm_analysis/l10n/languages/app_language.dart';

class LanguageTr implements AppLanguage {
  @override
  String get appName => 'El Çizgisi Analizi';
  
  @override
  String get appDescription => 'Avuç içi çizgilerinizden geleceğinizi keşfedin';
  
  // El çizgisi türleri
  @override
  String get heartLine => 'Kalp Çizgisi';
  
  @override
  String get headLine => 'Akıl Çizgisi';
  
  @override
  String get lifeLine => 'Yaşam Çizgisi';
  
  @override
  String get fateLine => 'Kader Çizgisi';
  
  @override
  String get sunLine => 'Güneş Çizgisi';
  
  @override
  String get marriageLine => 'Evlilik Çizgisi';
  
  @override
  String get wealthLine => 'Zenginlik Çizgisi';
  
  // El çizgisi açıklamaları
  @override
  Map<String, String> get lineDescriptions => {
    heartLine: 'Kalp çizgisi, duygusal yaşamınızı, ilişkilerinizi ve duygusal sağlığınızı gösterir.',
    headLine: 'Akıl çizgisi, düşünce şeklinizi, zihinsel yeteneklerinizi ve iletişim tarzınızı temsil eder.',
    lifeLine: 'Yaşam çizgisi, genel sağlığınızı, yaşam enerjinizi ve önemli yaşam olaylarını gösterir.',
    fateLine: 'Kader çizgisi, kariyer yolunuzu, başarılarınızı ve hayat amacınızı temsil eder.',
    sunLine: 'Güneş çizgisi, ün, başarı ve yaratıcılık potansiyelinizi gösterir.',
    marriageLine: 'Evlilik çizgisi, önemli romantik ilişkilerinizi ve bunların kalitesini temsil eder.',
    wealthLine: 'Zenginlik çizgisi, maddi refahınızı ve zenginlik potansiyelinizi gösterir.',
  };
  
  // Onboarding ekranı için metinler
  @override
  List<Map<String, String>> get onboardingContent => [
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
  
  // Hata mesajları
  @override
  String get errorTitle => 'Bir Hata Oluştu';
  
  @override
  String get generalError => 'Bir şeyler yanlış gitti. Lütfen tekrar deneyin.';
  
  @override
  String get tryAgain => 'Tekrar Dene';
  
  @override
  String get appStartError => 'Uygulama başlatılamadı';
  
  @override
  String get uiLoadError => 'Arayüz yüklenemedi';
  
  @override
  String get contactDeveloper => 'Lütfen uygulamayı yeniden başlatın veya geliştiriciyle iletişime geçin.';
  
  // Ana ekran
  @override
  String get takePicture => 'Fotoğraf Çek';
  
  @override
  String get selectFromGallery => 'Galeriden Seç';
  
  @override
  String get analyzeHand => 'Elini Analiz Et';
  
  @override
  String get analysisHistory => 'Analiz Geçmişi';
  
  @override
  String get settings => 'Ayarlar';
  
  // Analiz ekranı
  @override
  String get analyzing => 'Analiz Ediliyor...';
  
  @override
  String get analysisComplete => 'Analiz Tamamlandı';
  
  @override
  String get analysisError => 'Analiz Yapılamadı';
  
  @override
  String get saveAnalysis => 'Analizi Kaydet';
  
  @override
  String get shareAnalysis => 'Analizi Paylaş';
  
  @override
  String get analyzingPalm => 'El çizgileriniz analiz ediliyor...';
  
  // Ayarlar ekranı
  @override
  String get settingsTitle => 'Ayarlar';
  
  @override
  String get languageSettings => 'Dil Ayarları';
  
  @override
  String get themeSettings => 'Tema Ayarları';
  
  @override
  String get notificationSettings => 'Bildirim Ayarları';
  
  @override
  String get aboutApp => 'Uygulama Hakkında';
  
  @override
  String get privacyPolicy => 'Gizlilik Politikası';
  
  @override
  String get termsOfService => 'Kullanım Koşulları';
  
  @override
  String get lightTheme => 'Açık Tema';
  
  @override
  String get darkTheme => 'Koyu Tema';
  
  @override
  String get systemTheme => 'Sistem Teması';
  
  // Dil seçimi
  @override
  String get selectLanguage => 'Dil Seçiniz';
  
  @override
  String get turkish => 'Türkçe';
  
  @override
  String get english => 'İngilizce';
  
  @override
  String get german => 'Almanca';
  
  @override
  String get french => 'Fransızca';
  
  @override
  String get spanish => 'İspanyolca';
  
  // History screen
  @override
  String get historyTitle => 'Geçmiş Analizlerim';
  
  @override
  String get noAnalysisYet => 'Henüz analiz bulunmuyor';
  
  @override
  String get analyzeHandFromHome => 'El çizginizi analiz etmek için ana ekrana dönün';
  
  @override
  String get goToHome => 'Ana Ekrana Dön';
  
  @override
  String get deleteAllAnalyses => 'Tüm Analizleri Sil';
  
  @override
  String get deleteAllConfirmation => 'Tüm analizleriniz silinecek. Bu işlem geri alınamaz. Devam etmek istiyor musunuz?';
  
  @override
  String get cancel => 'İptal';
  
  @override
  String get deleteAll => 'Tümünü Sil';
  
  @override
  String get analysisSaved => 'Analiz kaydedildi';
  
  @override
  String get analysisDetail => 'Analiz Detayı';
  
  @override
  String get palmReadingAnalysis => 'El Çizgisi Analizi';
  
  // Camera guide overlay
  @override
  String get handDetection => 'El Algılama';
  
  @override
  String get handPosition => 'El Pozisyonu';
  
  @override
  String get lightLevel => 'Işık Seviyesi';
  
  @override
  String get placeYourHand => 'Avuç içinizi bu alana yerleştirin';
  
  // Premium/Subscription
  @override
  String get premium => 'Premium';
  
  @override
  String get premiumFeatures => 'Premium Özellikler';
  
  @override
  String get unlimitedAnalyses => 'Sınırsız El Analizi';
  
  @override
  String get noAds => 'Reklamsız Deneyim';
  
  @override
  String get compareAnalyses => 'Birden Fazla Analizi Karşılaştırma';
  
  @override
  String get prioritySupport => 'Öncelikli Destek';
  
  @override
  String get subscribe => 'Şimdi Abone Ol';
  
  @override
  String get restorePurchases => 'Satın Almaları Geri Yükle';
  
  @override
  String get purchaseError => 'Satın alma işlemi sırasında bir hata oluştu. Lütfen tekrar deneyin.';
  
  @override
  String get purchaseRestored => 'Satın almalarınız geri yüklendi.';
  
  @override
  String get premiumActive => 'Premium Aktif';
  
  @override
  String get premiumInactive => 'Premium Aktif Değil';
  
  @override
  String get remainingAnalyses => 'Bu ay kalan analiz hakkı: {count}';
  
  @override
  String get limitReached => 'Aylık Limit Doldu';
  
  @override
  String get upgradeToPremium => 'Premium\'a Yükselt';
  
  @override
  String get backToApp => 'Uygulamaya Dön';
  
  @override
  String get usageLimit => 'Ücretsiz kullanıcılar aylık 3 analiz yapabilir. Sınırsız analiz için premium\'a yükseltin.';
  
  // Claude API istekleri için sistem mesajı
  @override
  String get systemPrompt => '''
Sen bir el falı uzmanısın ve avuç içi çizgilerini analiz edebilirsin. Gönderdiğim avuç içi fotoğrafını analiz ederek şu çizgiler hakkında bilgi vermelisin:

1. Kalp Çizgisi: Duygusal yaşam, ilişkiler ve duygusal sağlıkla ilgili bilgiler
2. Akıl Çizgisi: Düşünce şekli, zihinsel yetenek ve iletişim tarzı
3. Yaşam Çizgisi: Genel sağlık, yaşam enerjisi ve önemli yaşam olayları
4. Kader Çizgisi: Kariyer, başarılar ve hayat amacı
5. Evlilik Çizgisi: Önemli romantik ilişkiler
6. Zenginlik Çizgisi: Maddi refah ve zenginlik potansiyeli

Her çizgiyi detaylı analiz et ve ilgilendikleri kişiye özel yorumlar yap. Yanıtın 300-500 kelime arasında olmalı ve kişiye özel hissettirmeli.

Bilimsel değil mistik bir bakış açısıyla yorumla. Yanıtını Markdown formatında düzenle ve her bölüm için başlıklar kullan. Kullanıcı avuç içi çizgisinden başka bir resim atarsa espirili bir cevap verip gönderdiği resmin ne olduğunu söyle ve avuç içi resmi çekmesini söyle!

ÖNEMLİ: Fotoğraf tam olarak net olmasa bile, görebildiğin kadarıyla yorum yapmaya çalış. Bazı çizgileri net göremesen bile, görebildiğin çizgiler hakkında olabildiğince detaylı yorum yap. Avuç içindeki fotoğrafın kalitesi düşük olsa bile gördüğün çizgiler üzerinden bir analiz sunmaya çalış. Eğer hiçbir çizgi görünmüyorsa, ancak o zaman kullanıcıya daha net bir fotoğraf çekmesini öner.
''';
}
