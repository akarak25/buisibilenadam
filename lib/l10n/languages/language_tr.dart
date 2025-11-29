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

  @override
  String get skip => 'Atla';

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

  @override
  String get comingSoon => 'Yakında';

  // Profil ekranı
  @override
  String get profile => 'Profil';
  @override
  String get profileSettings => 'Profil Ayarları';
  @override
  String get personalInfo => 'Kişisel Bilgiler';
  @override
  String get fullName => 'Ad Soyad';
  @override
  String get email => 'E-posta';
  @override
  String get password => 'Şifre';
  @override
  String get age => 'Yaş';
  @override
  String get gender => 'Cinsiyet';
  @override
  String get profession => 'Meslek';
  @override
  String get male => 'Erkek';
  @override
  String get female => 'Kadın';
  @override
  String get other => 'Diğer';
  @override
  String get select => 'Seçiniz';
  @override
  String get editProfile => 'Profili Düzenle';
  @override
  String get saveChanges => 'Değişiklikleri Kaydet';
  @override
  String get changePassword => 'Şifre Değiştir';
  @override
  String get currentPassword => 'Mevcut Şifre';
  @override
  String get newPassword => 'Yeni Şifre';
  @override
  String get confirmPassword => 'Şifre Tekrar';
  @override
  String get passwordsDontMatch => 'Şifreler eşleşmiyor';
  @override
  String get passwordTooShort => 'Şifre en az 6 karakter olmalı';
  @override
  String get deleteAccount => 'Hesabı Sil';
  @override
  String get deleteAccountConfirmation => 'Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';
  @override
  String get totalAnalyses => 'Toplam Analiz';
  @override
  String get memberSince => 'Üyelik Süresi';
  @override
  String get days => 'gün';
  @override
  String get logout => 'Çıkış Yap';
  @override
  String get logoutConfirmation => 'Çıkış yapmak istediğinize emin misiniz?';
  @override
  String get accountDeleted => 'Hesabınız silindi';
  @override
  String get profileUpdated => 'Profil güncellendi';
  @override
  String get account => 'Hesap';

  // Chatbot
  @override
  String get askQuestion => 'Soru Sor';
  @override
  String get chatWithAI => 'AI ile Sohbet';
  @override
  String get typeYourQuestion => 'Sorunuzu yazın...';
  @override
  String get chatPlaceholder => 'El çizgileriniz hakkında merak ettiklerinizi sorun...';
  @override
  String get sendMessage => 'Gönder';

  // Daily Astrology
  @override
  String get dailyInsight => 'Günlük Yorum';
  @override
  String get moonPhase => 'Ay Fazı';
  @override
  String get moonIn => 'Ay';
  @override
  String get todaysEnergy => 'Bugünün Enerjisi';
  @override
  String get weeklyForecast => 'Haftalık Öngörü';
  @override
  String get daysUntilFullMoon => 'Dolunay\'a kalan';
  @override
  String get daysUntilNewMoon => 'Yeni Ay\'a kalan';

  // Greetings
  @override
  String get goodMorning => 'Günaydın';
  @override
  String get goodAfternoon => 'İyi günler';
  @override
  String get goodEvening => 'İyi akşamlar';
  @override
  String get loginRequired => 'Giriş yapın';

  // Claude API istekleri için sistem mesajı
  @override
  String get systemPrompt => '''
Sen deneyimli bir el falı (chiromancy) uzmanısın. Avuç içi fotoğraflarını analiz ederek kişiye özel, derinlikli yorumlar yapabilirsin.

## ANALİZ YAPISI

Analizini şu bölümlere ayır:

### 1. TEMEL ÇİZGİLER (Ana Analiz)
- **Kalp Çizgisi:** Duygusal dünya, aşk hayatı, ilişki tarzı, empati yeteneği
- **Akıl Çizgisi:** Düşünce yapısı, karar verme, yaratıcılık, analitik yetenek
- **Yaşam Çizgisi:** Yaşam enerjisi, dayanıklılık, önemli dönüm noktaları
- **Kader Çizgisi:** Kariyer yolu, hayat amacı, başarı potansiyeli

### 2. YARDIMCI ÇİZGİLER (Detaylı Analiz)
- **Güneş Çizgisi (Apollo):** Şans, şöhret, sanatsal yetenek, başarı
- **Sağlık Çizgisi (Merkür):** Genel sağlık durumu, sinir sistemi
- **Evlilik Çizgileri:** Önemli ilişkiler, duygusal bağlar
- **Sezgi Çizgisi:** Altıncı his, ruhsal farkındalık

### 3. TEPELER (Mount Analizi)
- **Venüs Tepesi:** Aşk kapasitesi, tutku, sanatsal duyarlılık
- **Jüpiter Tepesi:** Liderlik, hırs, özgüven
- **Satürn Tepesi:** Sorumluluk, ciddiyet, kader
- **Ay Tepesi:** Hayal gücü, sezgi, yaratıcılık

## YAZIM KURALLARI

1. **Mistik ama samimi** bir ton kullan - ne fazla ciddi ne fazla şakacı
2. Her bölümü **Markdown başlıkları** ile ayır (## ve ### kullan)
3. Önemli kelimeleri **kalın** yap
4. Toplam **400-600 kelime** arasında tut
5. Kişiye hitap et, "sizin" veya "senin" kullan
6. Olumlu ve yapıcı ol, olumsuz yorumları bile umut verici şekilde ifade et

## ÖZEL DURUMLAR

- Fotoğraf net değilse: Görebildiğin çizgilerden yorum yap, özür dileme
- Avuç içi değilse: Espirili bir şekilde belirt ve avuç içi fotoğrafı iste
- Çizgi belirsizse: "Bu bölgede gelişim potansiyeli var" gibi pozitif yorumla

## SON

Analizi kısa bir **genel değerlendirme** ile bitir - kişinin genel karakteri ve potansiyeli hakkında 2-3 cümle.
''';

  @override
  String get chatSystemPrompt => '''
Sen bir el falı uzmanısın. Kullanıcının daha önce yapılmış el analizi sonuçlarına dayanarak sorularını yanıtlıyorsun.

KURALLAR:
1. Sadece el çizgileri, avuç içi analizi ve bunlarla ilgili konularda yardımcı ol
2. Yanıtların kısa ve öz olsun (100-200 kelime)
3. Mistik ama samimi bir ton kullan
4. Kullanıcının önceki analizine referans ver
5. Markdown formatında yanıt ver
6. Konu dışı sorularda nazikçe el çizgileri konusuna yönlendir

Kullanıcının önceki el analizi:
{analysis}
''';
}
