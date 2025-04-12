import 'package:palm_analysis/l10n/languages/app_language.dart';

class LanguageEn implements AppLanguage {
  @override
  String get appName => 'Palm Reading Analysis';
  
  @override
  String get appDescription => 'Discover your future from your palm lines';
  
  // Palm line types
  @override
  String get heartLine => 'Heart Line';
  
  @override
  String get headLine => 'Head Line';
  
  @override
  String get lifeLine => 'Life Line';
  
  @override
  String get fateLine => 'Fate Line';
  
  @override
  String get sunLine => 'Sun Line';
  
  @override
  String get marriageLine => 'Marriage Line';
  
  @override
  String get wealthLine => 'Wealth Line';
  
  // Palm line descriptions
  @override
  Map<String, String> get lineDescriptions => {
    heartLine: 'The heart line shows your emotional life, relationships, and emotional health.',
    headLine: 'The head line represents your thinking style, mental abilities, and communication style.',
    lifeLine: 'The life line shows your general health, life energy, and significant life events.',
    fateLine: 'The fate line represents your career path, achievements, and life purpose.',
    sunLine: 'The sun line shows your fame, success, and creative potential.',
    marriageLine: 'The marriage line represents your significant romantic relationships and their quality.',
    wealthLine: 'The wealth line shows your material prosperity and wealth potential.',
  };
  
  // Onboarding screen texts
  @override
  List<Map<String, String>> get onboardingContent => [
    {
      'title': 'Discover Your Palm Lines',
      'description': 'Discover your personality, past, and future from your palm lines.',
    },
    {
      'title': 'Take a Photo',
      'description': 'Take a clear photo of your palm or upload from gallery.',
    },
    {
      'title': 'AI Analysis',
      'description': 'AI technology analyzes your lines and provides personalized interpretations.',
    },
    {
      'title': 'Illuminate Your Life',
      'description': 'Learn the hidden information in your love, career, health, and wealth lines.',
    },
  ];
  
  // Error messages
  @override
  String get errorTitle => 'An Error Occurred';
  
  @override
  String get generalError => 'Something went wrong. Please try again.';
  
  @override
  String get tryAgain => 'Try Again';
  
  @override
  String get appStartError => 'Failed to start application';
  
  @override
  String get uiLoadError => 'Failed to load interface';
  
  @override
  String get contactDeveloper => 'Please restart the application or contact the developer.';
  
  // Main screen
  @override
  String get takePicture => 'Take Photo';
  
  @override
  String get selectFromGallery => 'Select from Gallery';
  
  @override
  String get analyzeHand => 'Analyze Your Palm';
  
  @override
  String get analysisHistory => 'Analysis History';
  
  @override
  String get settings => 'Settings';
  
  // Analysis screen
  @override
  String get analyzing => 'Analyzing...';
  
  @override
  String get analysisComplete => 'Analysis Complete';
  
  @override
  String get analysisError => 'Analysis Failed';
  
  @override
  String get saveAnalysis => 'Save Analysis';
  
  @override
  String get shareAnalysis => 'Share Analysis';
  
  @override
  String get analyzingPalm => 'Analyzing your palm lines...';
  
  // Settings screen
  @override
  String get settingsTitle => 'Settings';
  
  @override
  String get languageSettings => 'Language Settings';
  
  @override
  String get themeSettings => 'Theme Settings';
  
  @override
  String get notificationSettings => 'Notification Settings';
  
  @override
  String get aboutApp => 'About App';
  
  @override
  String get privacyPolicy => 'Privacy Policy';
  
  @override
  String get termsOfService => 'Terms of Service';
  
  @override
  String get lightTheme => 'Light Theme';
  
  @override
  String get darkTheme => 'Dark Theme';
  
  @override
  String get systemTheme => 'System Theme';
  
  // Language selection
  @override
  String get selectLanguage => 'Select Language';
  
  @override
  String get turkish => 'Turkish';
  
  @override
  String get english => 'English';
  
  @override
  String get german => 'German';
  
  @override
  String get french => 'French';
  
  @override
  String get spanish => 'Spanish';
  
  // History screen
  @override
  String get historyTitle => 'Analysis History';
  
  @override
  String get noAnalysisYet => 'No analyses yet';
  
  @override
  String get analyzeHandFromHome => 'Go to home screen to analyze your palm';
  
  @override
  String get goToHome => 'Go to Home';
  
  @override
  String get deleteAllAnalyses => 'Delete All Analyses';
  
  @override
  String get deleteAllConfirmation => 'All your analyses will be deleted. This action cannot be undone. Do you want to continue?';
  
  @override
  String get cancel => 'Cancel';
  
  @override
  String get deleteAll => 'Delete All';
  
  @override
  String get analysisSaved => 'Analysis saved';
  
  @override
  String get analysisDetail => 'Analysis Details';
  
  @override
  String get palmReadingAnalysis => 'Palm Reading Analysis';
  
  // Camera guide overlay
  @override
  String get handDetection => 'Hand Detection';
  
  @override
  String get handPosition => 'Hand Position';
  
  @override
  String get lightLevel => 'Light Level';
  
  @override
  String get placeYourHand => 'Place your palm in this area';
  
  // Premium/Subscription
  @override
  String get premium => 'Premium';
  
  @override
  String get premiumFeatures => 'Premium Features';
  
  @override
  String get unlimitedAnalyses => 'Unlimited Palm Analyses';
  
  @override
  String get noAds => 'No Advertisements';
  
  @override
  String get compareAnalyses => 'Compare Multiple Analyses';
  
  @override
  String get prioritySupport => 'Priority Customer Support';
  
  @override
  String get subscribe => 'Subscribe Now';
  
  @override
  String get restorePurchases => 'Restore Purchases';
  
  @override
  String get purchaseError => 'There was an error with your purchase. Please try again.';
  
  @override
  String get purchaseRestored => 'Your purchases have been restored.';
  
  @override
  String get premiumActive => 'Premium Active';
  
  @override
  String get premiumInactive => 'Premium Inactive';
  
  @override
  String get remainingAnalyses => '{count} analyses remaining this month';
  
  @override
  String get limitReached => 'Monthly Limit Reached';
  
  @override
  String get upgradeToPremium => 'Upgrade to Premium';
  
  @override
  String get backToApp => 'Back to App';
  
  @override
  String get usageLimit => 'Free users can perform 3 analyses per month. Upgrade to premium for unlimited analyses.';
  
  // System prompt for Claude API requests
  @override
  String get systemPrompt => '''
You are a palm reading expert who can analyze palm lines. Analyze the palm image I'm sending and provide information about these lines:

1. Heart Line: Information about emotional life, relationships, and emotional health
2. Head Line: Thinking style, mental abilities, and communication style
3. Life Line: General health, life energy, and significant life events
4. Fate Line: Career, achievements, and life purpose
5. Marriage Line: Significant romantic relationships
6. Wealth Line: Material prosperity and wealth potential

Analyze each line in detail and make personalized interpretations for the person. Your response should be between 300-500 words and feel personalized.

Interpret with a mystical rather than scientific perspective. Format your response in Markdown with headings for each section. If the user sends an image other than a palm image, provide a humorous response, tell them what the image is, and ask them to take a palm image!

IMPORTANT: Even if the photo is not perfectly clear, try to comment on what you can see. Even if you cannot clearly see some lines, provide as detailed a commentary as possible on the lines you can see. Try to provide an analysis based on the lines you can see even if the quality of the palm image is low. Only suggest that the user take a clearer photo if you cannot see any lines at all.
''';
}
