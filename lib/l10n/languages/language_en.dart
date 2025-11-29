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

  @override
  String get skip => 'Skip';

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

  @override
  String get comingSoon => 'Coming Soon';

  // Profile screen
  @override
  String get profile => 'Profile';
  @override
  String get profileSettings => 'Profile Settings';
  @override
  String get personalInfo => 'Personal Information';
  @override
  String get fullName => 'Full Name';
  @override
  String get email => 'Email';
  @override
  String get emailPlaceholder => 'example@email.com';
  @override
  String get password => 'Password';
  @override
  String get age => 'Age';
  @override
  String get gender => 'Gender';
  @override
  String get profession => 'Profession';
  @override
  String get male => 'Male';
  @override
  String get female => 'Female';
  @override
  String get other => 'Other';
  @override
  String get select => 'Select';
  @override
  String get editProfile => 'Edit Profile';
  @override
  String get saveChanges => 'Save Changes';
  @override
  String get changePassword => 'Change Password';
  @override
  String get currentPassword => 'Current Password';
  @override
  String get newPassword => 'New Password';
  @override
  String get confirmPassword => 'Confirm Password';
  @override
  String get passwordsDontMatch => 'Passwords do not match';
  @override
  String get passwordTooShort => 'Password must be at least 6 characters';
  @override
  String get deleteAccount => 'Delete Account';
  @override
  String get deleteAccountConfirmation => 'Are you sure you want to delete your account? This action cannot be undone.';
  @override
  String get totalAnalyses => 'Total Analyses';
  @override
  String get memberSince => 'Member Since';
  @override
  String get days => 'days';
  @override
  String get logout => 'Logout';
  @override
  String get logoutConfirmation => 'Are you sure you want to logout?';
  @override
  String get accountDeleted => 'Your account has been deleted';
  @override
  String get profileUpdated => 'Profile updated';
  @override
  String get account => 'Account';

  // Chatbot
  @override
  String get askQuestion => 'Ask Question';
  @override
  String get chatWithAI => 'Chat with AI';
  @override
  String get typeYourQuestion => 'Type your question...';
  @override
  String get chatPlaceholder => 'Ask anything about your palm lines...';
  @override
  String get sendMessage => 'Send';

  // Daily Astrology
  @override
  String get dailyInsight => 'Daily Insight';
  @override
  String get moonPhase => 'Moon Phase';
  @override
  String get moonIn => 'Moon in';
  @override
  String get todaysEnergy => 'Today\'s Energy';
  @override
  String get weeklyForecast => 'Weekly Forecast';
  @override
  String get daysUntilFullMoon => 'Days until Full Moon';
  @override
  String get daysUntilNewMoon => 'Days until New Moon';

  // Greetings
  @override
  String get goodMorning => 'Good morning';
  @override
  String get goodAfternoon => 'Good afternoon';
  @override
  String get goodEvening => 'Good evening';
  @override
  String get loginRequired => 'Please login';

  // Login/Register screen
  @override
  String get welcome => 'Welcome';
  @override
  String get loginToAccount => 'Login to your account';
  @override
  String get login => 'Login';
  @override
  String get orText => 'or';
  @override
  String get signInWithGoogle => 'Sign in with Google';
  @override
  String get continueWithoutLogin => 'Continue without login';
  @override
  String get dontHaveAccount => "Don't have an account? ";
  @override
  String get signUp => 'Sign Up';
  @override
  String get emailRequired => 'Email is required';
  @override
  String get invalidEmail => 'Enter a valid email';
  @override
  String get passwordRequired => 'Password is required';
  @override
  String get googleSignInFailed => 'Google sign-in failed. Please try again.';

  // System prompt for Claude API requests
  @override
  String get systemPrompt => '''
You are an experienced palmistry (chiromancy) expert. You can analyze palm photographs and provide personalized, in-depth interpretations.

## ANALYSIS STRUCTURE

Divide your analysis into these sections:

### 1. MAJOR LINES (Core Analysis)
- **Heart Line:** Emotional world, love life, relationship style, empathy capacity
- **Head Line:** Thought patterns, decision making, creativity, analytical ability
- **Life Line:** Life energy, resilience, important turning points
- **Fate Line:** Career path, life purpose, success potential

### 2. MINOR LINES (Detailed Analysis)
- **Sun Line (Apollo):** Luck, fame, artistic talent, success
- **Health Line (Mercury):** Overall health condition, nervous system
- **Marriage Lines:** Important relationships, emotional bonds
- **Intuition Line:** Sixth sense, spiritual awareness

### 3. MOUNTS (Mount Analysis)
- **Mount of Venus:** Love capacity, passion, artistic sensitivity
- **Mount of Jupiter:** Leadership, ambition, self-confidence
- **Mount of Saturn:** Responsibility, seriousness, destiny
- **Mount of Moon:** Imagination, intuition, creativity

## WRITING RULES

1. Use a **mystical but friendly** tone - neither too serious nor too playful
2. Separate each section with **Markdown headings** (use ## and ###)
3. Make important words **bold**
4. Keep total length between **400-600 words**
5. Address the person directly, use "you" and "your"
6. Be positive and constructive, express even negative observations hopefully

## SPECIAL CASES

- If photo is unclear: Interpret what you can see, don't apologize
- If not a palm: Humorously point it out and request a palm photo
- If line is unclear: Use positive interpretation like "there's growth potential in this area"

## CONCLUSION

End the analysis with a brief **overall assessment** - 2-3 sentences about the person's general character and potential.
''';

  @override
  String get chatSystemPrompt => '''
You are a palm reading expert. You answer user questions based on their previous palm analysis results.

RULES:
1. Only help with palm lines, palm analysis, and related topics
2. Keep your answers short and concise (100-200 words)
3. Use a mystical but friendly tone
4. Reference the user's previous analysis
5. Respond in Markdown format
6. Politely redirect off-topic questions to palm reading

User's previous palm analysis:
{analysis}
''';
}
