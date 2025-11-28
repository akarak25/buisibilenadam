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
Flutter App -> elcizgisi.com/api/* -> Gemini 2.5 Flash
                    |
              MongoDB (shared data)
                    |
Web Site -> elcizgisi.com/api/* -> Gemini 2.5 Flash
```

**Avantajlar:**
- Tek API key yonetimi (backend'de)
- Ortak kullanici veritabani
- Ortak analiz gecmisi
- Tek premium sistem

**ONEMLI:** API key'ler FLUTTER'DA DEGIL, VPS'te .env dosyasinda olmali!

---

## Current Implementation Status (Phase 10 - Major Update)

### Phase 1-6: TAMAMLANDI ✅
### Phase 7: Web-Mobile Sync Fix (2025-11-28) ✅
### Phase 8: History Screen Realtime Sync (2025-11-28) ✅

### Phase 9: App Modernization (2025-11-29) ✅
- [x] Premium sistemi tamamen kaldırıldı
  - premium_screen.dart silindi
  - home_screen.dart ve settings_screen.dart'tan premium referansları kaldırıldı
- [x] Chatbot sistemi eklendi
  - chat_screen.dart oluşturuldu
  - api_service.dart'a sendChatMessage() eklendi
  - api_config.dart'a /chat endpoint eklendi
  - analysis_screen.dart'a "Soru Sor" butonu eklendi
- [x] Sistem promptu profesyonelleştirildi
  - 7+ çizgi analizi (Temel + Yardımcı çizgiler)
  - Tepe analizleri (Venüs, Jüpiter, Satürn, Ay)
  - Gruplandırılmış yapı (kullanıcıyı boğmadan)
- [x] Günlük Astroloji sistemi eklendi
  - astrology_service.dart oluşturuldu
  - Ay fazı hesaplaması
  - Ay burcu hesaplaması
  - Günlük el çizgisi yorumları
  - home_screen.dart'a günlük astroloji kartı eklendi

### Phase 10: UI/UX Fixes (2025-11-29) ✅
- [x] Localization düzeltmeleri
  - home_screen.dart: _getGreeting hardcoded Türkçe -> lang.goodMorning/goodAfternoon/goodEvening
  - settings_screen.dart: "Giris yapin" -> lang.loginRequired
  - app_language.dart, language_tr.dart, language_en.dart: greeting stringleri eklendi
- [x] Chat screen typing indicator animasyonu düzeltildi
  - TweenAnimationBuilder (tek seferlik) -> AnimationController.repeat (sürekli)
  - _TypingDot StatefulWidget oluşturuldu

### Phase 11: Backend Chat Endpoint (2025-11-29) ✅
- [x] /api/chat/mobile endpoint oluşturuldu (elyorumweb/src/app/api/chat/mobile/route.ts)
- [x] Flutter api_config.dart güncellendi (/chat -> /chat/mobile)
- [ ] VPS'e deploy edilmeli
- [ ] Test: flutter clean && flutter pub get && iPhone test

---

## KRITIK DUZELTMELER (2025-11-28)

### 1. Google Sign-In URL Hatasi
**Sorun:** `ApiConfig.baseUrl` zaten `/api` içeriyordu, endpoint'te tekrar `/api` eklenmişti
```dart
// YANLIS:
Uri.parse('${ApiConfig.baseUrl}/api/auth/google');
// Sonuç: https://elcizgisi.com/api/api/auth/google

// DOGRU:
Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleAuthEndpoint}');
// Sonuç: https://elcizgisi.com/api/auth/google
```

### 2. Auth Service - Eski Token Sorunu
**Sorun:** Farkli Google hesabiyla giris yapildiginda eski token kaliyordu
**Cozum:** `signInWithGoogle()` basinda eski verileri temizle:
```dart
Future<AuthResponse> signInWithGoogle() async {
  // Clear previous session data before new login
  await _tokenService.clearAll();
  await _clearUserFromPrefs();
  _currentUser = null;

  // Sign out from previous Google account
  await _googleSignIn.signOut();

  // Then proceed with new login...
}
```

### 3. Web-Mobile Senkronizasyon
**Sorun:** Mobil'den yapilan analizler veritabanina kaydedilmiyordu
**Sebep:** `/api/analyze` sadece analiz yapiyor, kaydetmiyordu. Web'de analiz sonrasi ayrica `/api/queries`'e POST yapiliyordu.
**Cozum:**
- `api_service.dart`'a `saveQuery()` fonksiyonu eklendi
- `analysis_screen.dart`'ta analiz sonrasi backend'e kaydetme eklendi

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

### 8. Google Sign-In HTML Response Hatasi
```
FormatException: Unexpected character (at character 1) <!DOCTYPE html>
```
**Sebep:** Yanlis URL'e istek yapildi, Next.js 404 HTML sayfasi dondu
**Cozum:** URL'deki cift `/api` hatasini duzelt (yukariya bak)

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

## Google Sign-In Setup ✅ TAMAMLANDI

### Konfigürasyon
- **iOS Client ID:** 1090526264689-rluovhoc4v3irq65rggr7pjvcootq3kp.apps.googleusercontent.com
- **Bundle ID:** com.elcizgisi.palmanalysis

### Backend Endpoint
- `/api/auth/google` - Mobil Google auth icin (VPS'te mevcut)

### Flutter Dosyalari
- `auth_service.dart` - GoogleSignIn instance ve signInWithGoogle()
- `api_config.dart` - googleAuthEndpoint eklendi

---

## VPS Admin Bilgileri

### Admin Hesabi
- **Email:** admin@elcizgisi.com
- **Sifre:** 098783Ew**

### Faydali VPS Komutlari
```bash
# Kullanicilari listele
cd /var/www/elcizgisi && node -e "
const mongoose = require('mongoose');
require('dotenv').config();
mongoose.connect(process.env.MONGODB_URI).then(async () => {
  const users = await mongoose.connection.db.collection('users').find({}).toArray();
  console.log('Toplam:', users.length);
  users.forEach(u => console.log(u._id.toString(), u.email, u.provider));
  process.exit(0);
}).catch(console.error);
"

# Sorgulari listele
cd /var/www/elcizgisi && node -e "
const mongoose = require('mongoose');
require('dotenv').config();
mongoose.connect(process.env.MONGODB_URI).then(async () => {
  const queries = await mongoose.connection.db.collection('queries').find({}).toArray();
  console.log('Toplam:', queries.length);
  queries.forEach(q => console.log(q._id.toString(), q.userId.toString(), q.createdAt));
  process.exit(0);
}).catch(console.error);
"

# PM2 status
pm2 list
# el-cizgisi-yorum id=13
```

---

## API Kullanim ve Maliyetler

| API | Maliyet | Konum |
|-----|---------|-------|
| elcizgisi.com | UCRETSIZ (kendi VPS) | Backend |
| Gemini 2.5 Flash | Ucretsiz tier | Backend'den cagrilir |
| MongoDB | Free tier veya VPS | Backend |

**API Keys:** VPS'te .env dosyasinda saklanir (GEMINI_API_KEY, JWT_SECRET, vb.)

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
  google_sign_in: ^6.1.6     # Google ile giris
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
│   └── api_config.dart          # chatEndpoint EKLENDI
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
│   ├── home_screen.dart         # Günlük astroloji kartı EKLENDI
│   ├── camera_screen.dart
│   ├── analysis_screen.dart     # Chat butonu EKLENDI
│   ├── chat_screen.dart         # YENİ - Chatbot ekranı
│   ├── history_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart     # Premium kaldırıldı
│   ├── language_settings_screen.dart
│   └── auth/
│       ├── login_screen.dart
│       └── register_screen.dart
├── services/
│   ├── api_service.dart         # sendChatMessage() EKLENDI
│   ├── astrology_service.dart   # YENİ - Ay fazı ve burç hesaplama
│   ├── auth_service.dart
│   ├── token_service.dart
│   ├── palm_analysis_service.dart
│   └── camera_service.dart
├── utils/
│   ├── theme.dart
│   ├── snackbar_helper.dart
│   └── ...
├── widgets/
│   └── common/
│       ├── glass_card.dart
│       ├── gradient_button.dart
│       └── loading_overlay.dart
└── l10n/
    └── languages/
        ├── app_language.dart    # Astroloji & chat stringleri EKLENDI
        ├── language_tr.dart     # Sistem promptu genişletildi
        └── language_en.dart     # Sistem promptu genişletildi
```

---

## Premium System

### CURRENT STATUS: REMOVED (Phase 9)
- Premium sistemi tamamen kaldırıldı
- Tüm kullanıcılar tüm özelliklere ücretsiz erişebilir
- premium_screen.dart silindi
- Gelecekte IAP eklenebilir

---

## Known Issues / TODO

### Acil
- [ ] Web-Mobile sync test edilmeli (flutter clean && flutter pub get && test)

### Gelecek
- [ ] Resim senkronizasyonu (mobil resimler web'de gorunmuyor - placeholder kullaniliyor)
- [ ] App Store / Play Store hazirlik (Screenshots, descriptions, privacy policy)
- [ ] Push notifications
- [ ] Premium IAP entegrasyonu

---

## Last Updated
- **Date:** 2025-11-29
- **Status:** Phase 10 - UI/UX fixes tamamlandı
- **Tamamlanan (Phase 9-10):**
  - Premium sistemi tamamen kaldırıldı
  - Chatbot sistemi eklendi (chat_screen.dart)
  - Sistem promptu profesyonelleştirildi (7+ çizgi, tepeler)
  - Günlük astroloji sistemi eklendi (astrology_service.dart)
  - Home screen'e günlük enerji kartı eklendi
  - Localization düzeltmeleri yapıldı
  - Typing indicator animasyonu düzeltildi
- **Bekleyen:**
  - VPS'te /api/chat endpoint oluşturulmalı
  - `flutter clean && flutter pub get` sonra test
  - Tüm yeni özellikleri iPhone'da test et
- **Next:** Backend chat endpoint oluşturma
