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
  String get skip;
  
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
  String get comingSoon;

  // Profile screen
  String get profile;
  String get profileSettings;
  String get personalInfo;
  String get fullName;
  String get email;
  String get emailPlaceholder;
  String get password;
  String get age;
  String get gender;
  String get profession;
  String get male;
  String get female;
  String get other;
  String get select;
  String get editProfile;
  String get saveChanges;
  String get changePassword;
  String get currentPassword;
  String get newPassword;
  String get confirmPassword;
  String get passwordsDontMatch;
  String get passwordTooShort;
  String get deleteAccount;
  String get deleteAccountConfirmation;
  String get totalAnalyses;
  String get memberSince;
  String get days;
  String get logout;
  String get logoutConfirmation;
  String get accountDeleted;
  String get profileUpdated;
  String get account;

  // Chatbot
  String get askQuestion;
  String get chatWithAI;
  String get typeYourQuestion;
  String get chatPlaceholder;
  String get sendMessage;

  // Daily Astrology
  String get dailyInsight;
  String get moonPhase;
  String get moonIn;
  String get todaysEnergy;
  String get weeklyForecast;
  String get daysUntilFullMoon;
  String get daysUntilNewMoon;

  // Greetings
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get loginRequired;

  // Login/Register screen
  String get welcome;
  String get loginToAccount;
  String get login;
  String get orText;
  String get signInWithGoogle;
  String get signInWithApple;
  String get continueWithoutLogin;
  String get dontHaveAccount;
  String get signUp;
  String get emailRequired;
  String get invalidEmail;
  String get passwordRequired;
  String get googleSignInFailed;
  String get appleSignInFailed;

  // Register screen
  String get createAccount;
  String get registerForFree;
  String get namePlaceholder;
  String get nameRequired;
  String get nameTooShort;
  String get passwordHint;
  String get confirmPasswordHint;
  String get confirmPasswordRequired;
  String get register;
  String get alreadyHaveAccount;

  // System prompt for Claude API requests
  String get systemPrompt;
  String get chatSystemPrompt;

  // Entertainment Disclaimer (Apple App Store requirement)
  String get entertainmentDisclaimer;
  String get disclaimerTitle;
}
