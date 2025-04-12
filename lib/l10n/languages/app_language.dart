/// Tüm dil sınıfları için temel arayüz
/// Bu sınıf, uygulamadaki tüm metinleri tanımlar ve her dil sınıfının bu metinleri uygulaması gerekir.
abstract class AppLanguage {
  // Uygulama genel
  String get appName;
  String get appDescription;
  
  // El çizgisi türleri
  String get heartLine;
  String get headLine;
  String get lifeLine;
  String get fateLine;
  String get sunLine;
  String get marriageLine;
  String get wealthLine;
  
  // El çizgisi açıklamaları
  Map<String, String> get lineDescriptions;
  
  // Splash ve Onboarding ekranı
  List<Map<String, String>> get onboardingContent;
  
  // Hata mesajları
  String get errorTitle;
  String get generalError;
  String get tryAgain;
  String get appStartError;
  String get uiLoadError;
  String get contactDeveloper;
  
  // Ana ekran
  String get takePicture;
  String get selectFromGallery;
  String get analyzeHand;
  String get analysisHistory;
  String get settings;
  
  // Analiz ekranı
  String get analyzing;
  String get analysisComplete;
  String get analysisError;
  String get saveAnalysis;
  String get shareAnalysis;
  
  // Ayarlar ekranı
  String get settingsTitle;
  String get languageSettings;
  String get themeSettings;
  String get notificationSettings;
  String get aboutApp;
  String get privacyPolicy;
  String get termsOfService;
  String get lightTheme;
  String get darkTheme;
  String get systemTheme;
  
  // Dil seçimi
  String get selectLanguage;
  String get turkish;
  String get english;
  // Artık sadece Türkçe ve İngilizce desteklenmektedir
  // Arayüz bütünlüğü için diğer dil referansları korunmuştur
  String get german;
  String get french;
  String get spanish;
  
  // History screen
  String get historyTitle;
  String get noAnalysisYet;
  String get analyzeHandFromHome;
  String get goToHome;
  String get deleteAllAnalyses;
  String get deleteAllConfirmation;
  String get cancel;
  String get deleteAll;
  String get analysisSaved;
  String get analysisDetail;
  String get palmReadingAnalysis;
  
  // Camera guide overlay
  String get handDetection;
  String get handPosition;
  String get lightLevel;
  String get placeYourHand;
  
  // Claude API istekleri için sistem mesajı
  String get systemPrompt;
}
