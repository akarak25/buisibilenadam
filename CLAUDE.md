# El Cizgisi Analizi - Flutter Mobile App

## Project Overview

**App Name:** El Cizgisi Analizi (Palm Analysis)
**Type:** Flutter Mobile Application (iOS + Android)
**Backend:** elcizgisi.com (Next.js + MongoDB)
**Purpose:** AI-powered palm reading app - Mobile client for existing web platform

---

## CRITICAL: Backend Integration

**Flutter uygulamasi kendi API cagrisi YAPMAYACAK!**
**Web sitesinin mevcut backend'ini kullanacak.**

```
Flutter App -> elcizgisi.com/api/* -> OpenAI GPT-4o-mini
                    |
              MongoDB (shared data)
                    |
Web Site -> elcizgisi.com/api/* -> OpenAI GPT-4o-mini
```

**Avantajlar:**
- Tek API key yonetimi (backend'de)
- Ortak kullanici veritabani
- Ortak analiz gecmisi
- Tek premium sistem

---

## Current Implementation Status (Phase 5 Complete)

### Phase 1: Core Infrastructure ✅
- [x] Removed billing_service.dart, usage_service.dart, user_usage.dart
- [x] Removed IAP packages from pubspec.yaml
- [x] Removed .env and flutter_dotenv
- [x] Cleaned Runner.entitlements
- [x] Created API Service layer (lib/services/api_service.dart)
- [x] Created Auth Service (lib/services/auth_service.dart)
- [x] Created Token Service (lib/services/token_service.dart)
- [x] Created User Model (lib/models/user.dart)
- [x] Created Query Model (lib/models/query.dart)
- [x] Created Auth Response models (lib/models/auth_response.dart)
- [x] Created API Config (lib/config/api_config.dart)
- [x] Updated Theme to match web design (lib/utils/theme.dart)
- [x] Updated palm_analysis_service.dart to use backend API
- [x] Cleaned main.dart (removed dotenv)

### Phase 2: Auth & Onboarding ✅
- [x] Created GlassCard widget (glassmorphism)
- [x] Created GradientButton, SecondaryButton, GhostButton widgets
- [x] Created GradientText widget
- [x] Created AnimatedBackground widget
- [x] Updated Splash Screen (gradient bg, logo animation, auth check)
- [x] Updated Onboarding Screen (glassmorphism cards, page indicators)
- [x] Created Login Screen (web design style)
- [x] Created Register Screen (web design style)
- [x] Updated Premium Screen ("Coming Soon" placeholder)

### Phase 3: Main Features ✅
- [x] Updated Home Screen (gradient bg, glassmorphism cards, user greeting)
- [x] Updated Camera/Upload Screen (web design, glassmorphism controls)
- [x] Updated Analysis Screen (glassmorphism cards, status indicators)
- [x] Updated History Screen (card list, delete functionality, detail modal)
- [x] Added comingSoon localization key (TR/EN)
- [x] Removed UsageService dependencies from all screens
- [x] Removed flutter_dotenv from analysis_screen

### Phase 4: User Features ✅
- [x] Created Profile Screen (lib/screens/profile_screen.dart)
  - User avatar with gradient
  - Stats cards (total analyses, membership days)
  - Personal info card
  - Logout functionality
- [x] Created Settings Screen (lib/screens/settings_screen.dart)
  - Account section (Profile, Premium links)
  - App Settings section (Language settings)
  - About section (Privacy policy, Terms, About app)
  - App info footer with elcizgisi.com links
- [x] Updated Language Settings Screen (glassmorphism design)
- [x] Updated Home Screen (Settings icon navigation)
- [x] Added 30+ profile-related localization keys (TR/EN)

### Phase 5: Polish & Config ✅
- [x] Created SnackbarHelper utility (lib/utils/snackbar_helper.dart)
  - showSuccess, showError, showWarning, showInfo methods
  - showLoading with spinner
  - showWithAction for custom actions
- [x] Created Loading widgets (lib/widgets/common/loading_overlay.dart)
  - LoadingOverlay (full screen with glassmorphism)
  - LoadingSpinner (inline)
  - CenteredLoading (centered with message)
- [x] Updated ShimmerLoading to use new theme colors
- [x] Updated Premium Screen with localized strings
- [x] Updated iOS Info.plist (elcizgisi.com domain)
- [x] Updated Android Manifest (removed BILLING permission)
- [x] Added url_launcher to pubspec.yaml

### New/Updated Files
```
lib/
├── config/
│   └── api_config.dart          # API URLs, endpoints, headers
├── models/
│   ├── user.dart                # User model (web backend compatible)
│   ├── query.dart               # Query/analysis model
│   └── auth_response.dart       # Auth & API response models
├── services/
│   ├── api_service.dart         # Base HTTP client for elcizgisi.com
│   ├── auth_service.dart        # Login, register, token management
│   ├── token_service.dart       # Secure token storage
│   └── palm_analysis_service.dart # Updated - uses backend API
├── utils/
│   ├── theme.dart               # UPDATED - web design colors
│   └── snackbar_helper.dart     # NEW - Toast/Snackbar utility
├── widgets/common/
│   ├── glass_card.dart          # Glassmorphism card widget
│   ├── gradient_button.dart     # Primary, Secondary, Ghost buttons
│   ├── gradient_text.dart       # Gradient text widgets
│   ├── animated_background.dart # Animated gradient blobs
│   └── loading_overlay.dart     # NEW - Loading widgets
├── screens/
│   ├── splash_screen.dart       # UPDATED - auth check, animations
│   ├── onboarding_screen.dart   # UPDATED - glassmorphism design
│   ├── home_screen.dart         # UPDATED - settings navigation
│   ├── camera_screen.dart       # UPDATED - web design
│   ├── analysis_screen.dart     # UPDATED - web design
│   ├── history_screen.dart      # UPDATED - web design
│   ├── premium_screen.dart      # UPDATED - Coming Soon + localization
│   ├── profile_screen.dart      # NEW - user profile
│   ├── settings_screen.dart     # NEW - app settings
│   ├── language_settings_screen.dart # UPDATED - glassmorphism
│   └── auth/
│       ├── login_screen.dart    # NEW - web design style
│       └── register_screen.dart # NEW - web design style
├── l10n/languages/
│   ├── app_language.dart        # UPDATED - profile keys
│   ├── language_tr.dart         # UPDATED - profile translations
│   └── language_en.dart         # UPDATED - profile translations
```

---

## API Configuration

### Base URL
```dart
class ApiConfig {
  static const String baseUrl = 'https://elcizgisi.com/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/giris';
  static const String registerEndpoint = '/auth/kayit';

  // Analysis endpoint
  static const String analyzeEndpoint = '/analyze';

  // Queries endpoints
  static const String queriesEndpoint = '/queries';
}
```

### Authentication
- JWT tokens stored securely with flutter_secure_storage
- 7-day token expiry
- Bearer token in Authorization header

---

## Design System (Web-Synced)

### Color Palette
```dart
// Primary Colors
static const primaryIndigo = Color(0xFF6366F1);  // indigo-500
static const primaryPurple = Color(0xFFA855F7);  // purple-500

// Gradients
static const primaryGradient = LinearGradient(
  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
);

static const backgroundGradient = LinearGradient(
  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
);

// Status Colors
static const successGreen = Color(0xFF10B981);
static const warningAmber = Color(0xFFF59E0B);
static const dangerRed = Color(0xFFEF4444);
```

### Typography
- Font: Inter (Google Fonts)
- Weights: 400-800

### Border Radius
```dart
static const double radiusSmall = 8.0;
static const double radiusMedium = 12.0;
static const double radiusLarge = 16.0;
static const double radiusXLarge = 20.0;
static const double radiusXXLarge = 24.0;
```

### Glassmorphism
```dart
static BoxDecoration glassDecoration({
  double opacity = 0.8,
  double borderRadius = radiusXLarge,
}) {
  return BoxDecoration(
    color: surfaceWhite.withOpacity(opacity),
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(color: surfaceWhite.withOpacity(0.5)),
    boxShadow: cardShadow,
  );
}
```

---

## Premium System

### CURRENT STATUS: DISABLED
- Odeme sistemi su an DEVRE DISI
- Tum kullanicilar FREE tier olarak kullanacak
- Premium ekraninda "Coming Soon" bildirimi gosterilecek
- Ileride App Store / Google Play IAP entegre edilecek

---

## Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
  flutter_localizations:
  cupertino_icons: ^1.0.8
  camera: ^0.10.5+9
  image_picker: ^1.0.7
  http: ^1.2.1
  lottie: ^3.0.0
  provider: ^6.1.2
  path_provider: ^2.1.2
  path: ^1.9.0
  google_fonts: ^6.2.0
  flutter_markdown: ^0.7.1
  shared_preferences: ^2.2.2
  intl: ^0.19.0
  flutter_secure_storage: ^9.0.0  # Secure token storage
  url_launcher: ^6.2.5           # NEW - External links

# REMOVED
# in_app_purchase: REMOVED
# in_app_purchase_android: REMOVED
# in_app_purchase_storekit: REMOVED
# flutter_dotenv: REMOVED
```

---

## Platform Configuration

### iOS Configuration
- **Bundle ID:** com.elcizgisi.palmanalysis
- **Min iOS:** 13.0
- **Permissions:** Camera, Photo Library
- **ATS Domain:** elcizgisi.com (HTTPS only)
- **In-App Purchase:** DISABLED

### Android Configuration
- **Min SDK:** 21
- **Permissions:** INTERNET, CAMERA
- **BILLING permission:** REMOVED
- **Network Security:** HTTPS to elcizgisi.com

---

## Next Steps (Phase 6: Testing)

1. Manual testing on iOS simulator
2. Manual testing on Android emulator
3. Backend API integration testing
4. Edge case testing (network errors, auth failures)
5. UI/UX review and polish

---

## File Structure

```
lib/
├── main.dart                    # UPDATED - removed dotenv
├── config/
│   └── api_config.dart          # API configuration
├── models/
│   ├── palm_analysis.dart       # Analysis model
│   ├── user.dart                # User model
│   ├── query.dart               # Query model
│   └── auth_response.dart       # Auth response models
├── providers/
│   └── locale_provider.dart     # Language provider
├── screens/
│   ├── splash_screen.dart       # Splash with auth check
│   ├── onboarding_screen.dart   # Glassmorphism onboarding
│   ├── home_screen.dart         # Main home with settings
│   ├── camera_screen.dart       # Camera/upload
│   ├── analysis_screen.dart     # Analysis display
│   ├── history_screen.dart      # Analysis history
│   ├── premium_screen.dart      # Coming Soon
│   ├── profile_screen.dart      # User profile
│   ├── settings_screen.dart     # App settings
│   ├── language_settings_screen.dart # Language selection
│   └── auth/
│       ├── login_screen.dart    # Login
│       └── register_screen.dart # Register
├── services/
│   ├── api_service.dart         # Base HTTP client
│   ├── auth_service.dart        # Authentication
│   ├── token_service.dart       # Token storage
│   ├── palm_analysis_service.dart # Analysis API
│   └── camera_service.dart      # Camera handling
├── utils/
│   ├── theme.dart               # Web-synced design
│   ├── snackbar_helper.dart     # Toast/Snackbar utility
│   ├── constants.dart           # App constants
│   └── markdown_formatter.dart  # Markdown processing
├── widgets/
│   ├── camera_guide_overlay.dart # Camera guide
│   ├── shimmer_loading.dart     # Shimmer loading
│   └── common/
│       ├── glass_card.dart      # Glassmorphism card
│       ├── gradient_button.dart # Buttons
│       ├── gradient_text.dart   # Gradient text
│       ├── animated_background.dart # Animated bg
│       └── loading_overlay.dart # Loading widgets
└── l10n/
    ├── app_localizations.dart   # Localization helper
    └── languages/
        ├── app_language.dart    # Abstract language
        ├── language_tr.dart     # Turkish
        └── language_en.dart     # English
```

---

## Important Notes

- **Token Storage:** flutter_secure_storage (NOT SharedPreferences for tokens)
- **Image Upload:** multipart/form-data to /api/analyze
- **Error Messages:** Localized (TR/EN)
- **Premium:** Show "Coming Soon" - no payment processing
- **All users:** FREE tier
- **External Links:** Use url_launcher for privacy/terms links

---

## Last Updated
- Date: 2025-11-26
- Status: Phase 5 Complete - All screens updated, config finalized
- Next: Phase 6 - Testing (Manual + API integration)
