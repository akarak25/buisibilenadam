abstract class AppLanguage {
  String get appName;
  String get appDescription;
  
  // Palm line types
  String get heartLine;
  String get headLine;
  String get lifeLine;
  String get fateLine;
  String get sunLine;
  String get marriageLine;
  String get wealthLine;
  
  // Palm line descriptions
  Map<String, String> get lineDescriptions;
  
  // Onboarding screen texts
  List<Map<String, String>> get onboardingContent;
  
  // Error messages
  String get errorTitle;
  String get generalError;
  String get tryAgain;
  String get appStartError;
  String get uiLoadError;
  String get contactDeveloper;
  
  // Main screen
  String get takePicture;
  String get selectFromGallery;
  String get analyzeHand;
  String get analysisHistory;
  String get settings;
  
  // Analysis screen
  String get analyzing;
  String get analysisComplete;
  String get analysisError;
  String get saveAnalysis;
  String get shareAnalysis;
  String get analyzingPalm;
  
  // Settings screen
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
  
  // Language selection
  String get selectLanguage;
  String get turkish;
  String get english;
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
  
  // Premium/Subscription
  String get premium;
  String get premiumFeatures;
  String get unlimitedAnalyses;
  String get noAds;
  String get compareAnalyses;
  String get prioritySupport;
  String get subscribe;
  String get restorePurchases;
  String get purchaseError;
  String get purchaseRestored;
  String get premiumActive;
  String get premiumInactive;
  String get remainingAnalyses;
  String get limitReached;
  String get upgradeToPremium;
  String get backToApp;
  String get usageLimit;
  
  // System prompt for Claude API requests
  String get systemPrompt;
}
