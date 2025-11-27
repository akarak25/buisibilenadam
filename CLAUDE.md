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

**ONEMLI:** OpenAI API key FLUTTER'DA DEGIL, VPS'te .env dosyasinda olmali!

---

## Current Implementation Status (Phase 6 - Testing Complete)

### Phase 1-5: TAMAMLANDI ✅
### Phase 6: Device Testing ✅
- [x] iOS Simulator build basarili
- [x] Physical iPhone test basarili
- [x] Image upload MIME type fix (http_parser paketi)
- [x] Backend API entegrasyonu calisiyor

---

## Build Hatalari ve Cozumleri (ONEMLI!)

### 1. Generated.xcconfig not found
```
error: could not find included file 'Generated.xcconfig'
```
**Cozum:** `flutter pub get` calistir

### 2. intl version conflict
```
Because palm_analysis depends on flutter_localizations... intl 0.20.2 is required
```
**Cozum:** pubspec.yaml'da `intl: ^0.20.2` yap

### 3. Module 'camera_avfoundation' not found
```
error: Module 'camera_avfoundation' not found
```
**Cozum:**
```bash
cd ios
pod deintegrate
pod install --repo-update
```

### 4. CardTheme / DialogTheme type error
```
The argument type 'CardTheme' can't be assigned to 'CardThemeData?'
```
**Cozum:** theme.dart'ta `CardTheme(` -> `CardThemeData(`, `DialogTheme(` -> `DialogThemeData(`

### 5. successGradient not found
**Cozum:** theme.dart'a ekle:
```dart
static const LinearGradient successGradient = LinearGradient(
  colors: [Color(0xFF10B981), Color(0xFF22C55E)],
);
```

### 6. "Lutfen gecerli bir resim dosyasi yukleyin" hatasi
**Sebep:** MIME type gonderilmiyordu
**Cozum:**
- `http_parser: ^4.0.2` paketini ekle
- api_service.dart'ta MediaType.parse() kullan:
```dart
import 'package:http_parser/http_parser.dart';
// ...
contentType: MediaType.parse(_getMimeType(imageFile.path)),
```

### 7. Code signing error (Physical device)
```
Signing for "Runner" requires a development team
```
**Cozum:** Xcode -> Runner -> Signing & Capabilities -> Team sec (Apple ID)

---

## iOS Build Adimlari

```bash
# 1. Paketleri guncelle
flutter pub get

# 2. iOS pod'larini yukle
cd ios
pod install
cd ..

# 3. Build (Simulator)
flutter build ios --simulator

# 4. Build (Device) - Xcode'dan yap, code signing gerekli
```

**Physical Device icin:**
1. Xcode'da Runner project -> Signing & Capabilities
2. Team dropdown'dan Apple ID sec
3. iPhone'da: Ayarlar -> Genel -> VPN ve Aygit Yonetimi -> Developer App'i guvenilir yap

---

## Google Sign-In Setup (YAPILACAK)

### Google Cloud Console Bilgileri
- **Email:** akarak25@gmail.com
- **Mevcut Web Client ID:** 1090526264689-9pl3vb8rrp2d89g993r4uo1l2nsub1lq.apps.googleusercontent.com
- **Proje numarasi:** 1090526264689

### Yapilmasi Gerekenler
1. Google Cloud Console'a gir (akarak25@gmail.com)
2. Proje numarasi 1090526264689 olan projeyi bul
3. iOS OAuth client olustur (Bundle ID: com.elcizgisi.palmanalysis)
4. Android OAuth client olustur (SHA-1 fingerprint gerekli)
5. Flutter'a google_sign_in paketi ekle
6. Backend'e mobil Google auth endpoint ekle

---

## API Kullanim ve Maliyetler

| API | Maliyet | Konum |
|-----|---------|-------|
| elcizgisi.com | UCRETSIZ (kendi VPS) | Backend |
| OpenAI GPT-4o-mini | ~$0.075-0.15/istek | Backend'den cagrilir |
| MongoDB | Free tier veya VPS | Backend |

**OpenAI API Key:** VPS'te .env dosyasinda OPENAI_API_KEY olarak saklanir

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
  http_parser: ^4.0.2        # MIME type icin GEREKLI!
  lottie: ^3.0.0
  provider: ^6.1.2
  path_provider: ^2.1.2
  path: ^1.9.0
  google_fonts: ^6.2.0
  flutter_markdown: ^0.7.1
  shared_preferences: ^2.2.2
  intl: ^0.20.2              # flutter_localizations ile uyumlu olmali!
  flutter_secure_storage: ^9.0.0
  url_launcher: ^6.2.5
```

---

## Platform Configuration

### iOS Configuration
- **Bundle ID:** com.elcizgisi.palmanalysis
- **Min iOS:** 13.0
- **Permissions:** Camera, Photo Library
- **ATS Domain:** elcizgisi.com (HTTPS only)

### Android Configuration
- **Min SDK:** 21
- **Permissions:** INTERNET, CAMERA
- **BILLING permission:** REMOVED

---

## Design System (Web-Synced)

### Color Palette
```dart
static const primaryIndigo = Color(0xFF6366F1);  // indigo-500
static const primaryPurple = Color(0xFFA855F7);  // purple-500
static const successGreen = Color(0xFF10B981);   // emerald-500
static const warningAmber = Color(0xFFF59E0B);   // amber-500
static const dangerRed = Color(0xFFEF4444);      // red-500
```

### Typography
- Font: Inter (Google Fonts)

---

## File Structure

```
lib/
├── main.dart
├── config/
│   └── api_config.dart
├── models/
│   ├── palm_analysis.dart
│   ├── user.dart
│   ├── query.dart
│   └── auth_response.dart
├── providers/
│   └── locale_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── home_screen.dart
│   ├── camera_screen.dart
│   ├── analysis_screen.dart
│   ├── history_screen.dart
│   ├── premium_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   ├── language_settings_screen.dart
│   └── auth/
│       ├── login_screen.dart
│       └── register_screen.dart
├── services/
│   ├── api_service.dart         # http_parser ile MIME type
│   ├── auth_service.dart
│   ├── token_service.dart
│   ├── palm_analysis_service.dart
│   └── camera_service.dart
├── utils/
│   ├── theme.dart               # successGradient EKLENDI
│   ├── snackbar_helper.dart
│   └── ...
├── widgets/
│   └── common/
│       ├── glass_card.dart
│       ├── gradient_button.dart
│       └── loading_overlay.dart
└── l10n/
    └── languages/
        ├── app_language.dart
        ├── language_tr.dart
        └── language_en.dart
```

---

## Premium System

### CURRENT STATUS: DISABLED
- Tum kullanicilar FREE tier
- Premium ekraninda "Coming Soon" gosteriliyor
- Ileride App Store / Google Play IAP entegre edilecek

---

## Next Steps

1. **Google Sign-In entegrasyonu**
   - iOS/Android OAuth client'lari olustur
   - google_sign_in paketi ekle
   - Backend endpoint ekle

2. **App Store / Play Store hazirlik**
   - Screenshots
   - App descriptions
   - Privacy policy

---

## Last Updated
- Date: 2025-11-27
- Status: Phase 6 Complete - Device testing basarili, analiz calisiyor
- Next: Google Sign-In entegrasyonu
