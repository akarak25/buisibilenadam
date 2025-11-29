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

## KRITIK: Proje Yapısı ve VPS Deploy

**ÇOK ÖNEMLİ - ASLA UNUTMA:**

```
/Users/yusufkamil/Desktop/elcizgisi    -> Flutter mobil uygulama (iOS/Android)
/Users/yusufkamil/Desktop/elyorumweb   -> Next.js backend + web sitesi (VPS'e deploy edilir)
```

**VPS Backend Değişiklikleri:**
- Backend API değişiklikleri `elyorumweb` projesinde yapılmalı
- VPS, `elyorumweb` reposundan `git pull` ile güncellenir
- Flutter projesi (`elcizgisi`) sadece mobil uygulama kodunu içerir

**Deploy Akışı:**
1. Backend değişikliği `elyorumweb`'de yapılır
2. `elyorumweb`'de commit & push
3. VPS'te: `cd /var/www/elcizgisi && git pull && npm run build && pm2 restart el-cizgisi-yorum`

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

### Phase 12: Daily Engagement Features (2025-11-29) ✅
- [x] daily_astrology_screen.dart oluşturuldu
  - Ay fazı hero kartı (animasyonlu)
  - Ay burcu kartı
  - Dolunay/Yeni ay geri sayımı
  - Günlük el çizgisi yorumu
  - Günün ipucu (burç elementine göre)
- [x] Ana sayfa astroloji kartı tıklanabilir yapıldı
- [x] Streak sistemi eklendi (streak_service.dart)
  - Günlük uygulama açılış takibi
  - Üst üste gün sayacı
  - Streak emoji sistemi (🌱 -> 🔥 -> ⭐ -> 💎)
  - Greeting kartında streak göstergesi

### Phase 13: Astrology UX Fix (2025-11-29) ✅
**Sorun:** Kullanıcı henüz analiz yapmadan astroloji kartı el çizgisi referansları içeriyordu (ör. "Kalp Çizginiz aktif!"). Bu kullanıcıya saçma görünüyordu.

**Çözüm:** Koşullu içerik sistemi eklendi:
- [x] astrology_service.dart'a genel içerikler eklendi (el çizgisi referansı olmadan)
  - `getGeneralDailyInsightTr/En()` - Genel günlük yorum
  - `getGeneralMoonPhaseInsightTr/En()` - Genel ay fazı yorumu
- [x] home_screen.dart güncellendi
  - `hasAnalysis = _totalAnalyses > 0` kontrolü
  - Analiz yoksa genel içerik, varsa el çizgisi referanslı içerik
  - DailyAstrologyScreen'e hasAnalysis parametresi geçiriliyor
- [x] daily_astrology_screen.dart güncellendi
  - `hasAnalysis` parametresi eklendi
  - İçerikler koşullu (genel vs el çizgisi referanslı)
  - Analiz yoksa "Günün İpucu" yerine CTA gösteriliyor
  - CTA: "İlk Analizimi Yap" butonu ile kullanıcıyı analiz yapmaya yönlendiriyor

### Phase 14: Personalized Daily Reading System (2025-11-29) ✅ TAMAMLANDI
**Amaç:** El çizgisi + Astroloji kombinasyonu ile kişiselleştirilmiş günlük yorumlar

**Backend (elyorumweb):**
- [x] User model güncellendi - PalmProfile interface eklendi
  - heartLine, headLine, lifeLine, fateLine, sunLine, healthLine, marriageLine
  - mounts: venus, jupiter, saturn, apollo, mercury, moon, mars
  - dominantElement, keyTraits, summary
- [x] palmProfileParser.ts oluşturuldu - Analiz metninden yapılandırılmış veri çıkarıyor
- [x] /api/palm-profile endpoint oluşturuldu (GET/POST)
- [x] /api/daily-reading endpoint oluşturuldu
  - Kullanıcının palm profile + günün astronomi verileri
  - Gemini 2.5 Flash ile kişiselleştirilmiş yorum üretimi
  - 6 saatlik cache sistemi
  - JSON formatında: greeting, dailyEnergy, activeLineReading, moonInfluence, advice, luckyElements, warning
- [x] /api/queries güncellendi - Analiz kaydedilirken palmProfile otomatik kaydediliyor

**Flutter (elcizgisi):**
- [x] daily_reading.dart model oluşturuldu
- [x] daily_reading_service.dart oluşturuldu
- [x] personalized_daily_screen.dart oluşturuldu
- [x] home_screen.dart güncellendi
- [x] **KRİTİK FIX:** Cache izolasyonu düzeltildi (kullanıcı değiştiğinde cache karışması)
  - Cache key artık userId içeriyor: `daily_reading_${userId}_$today`
  - `clearAllDailyReadingCache()` public metodu eklendi
  - AuthService logout/signInWithGoogle sırasında cache temizleniyor
- [x] Lucky Elements UI geliştirildi (açıklamalar + ExpansionTile)
- [x] "Genel olarak Genel olarak" çift tekrar hatası düzeltildi
- [x] Yenileme butonu kaldırıldı (gereksizdi)

### Phase 15: Push Notification System (SONRAKI OTURUM) ⏳ BEKLEMEDE
**ÖNEMLİ:** Bu projenin en kritik ve can alıcı aşaması!

**Planlanan Özellikler:**
- [ ] Firebase Cloud Messaging (FCM) entegrasyonu
- [ ] APNs (Apple Push Notification service) kurulumu
- [ ] Günlük kişiselleştirilmiş bildirim (sabah yorumu)
- [ ] Streak hatırlatma bildirimi
- [ ] Backend push notification gönderme sistemi
- [ ] Kullanıcı bildirim tercihleri

**Gerekli Adımlar:**
1. Firebase projesi oluştur
2. Flutter firebase_messaging paketi ekle
3. iOS APNs sertifikası ve provisioning profile
4. Backend'de cron job ile günlük bildirim gönderimi
5. Device token kaydetme endpoint'i

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
│   ├── home_screen.dart         # Günlük astroloji + Streak EKLENDI
│   ├── camera_screen.dart
│   ├── analysis_screen.dart     # Chat butonu EKLENDI
│   ├── chat_screen.dart         # YENİ - Chatbot ekranı
│   ├── daily_astrology_screen.dart  # YENİ - Detaylı astroloji
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
│   ├── streak_service.dart      # YENİ - Günlük streak takibi
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
- **Status:** Phase 14 TAMAMLANDI - Personalized Daily Reading System
- **Bu Oturumda Tamamlananlar:**
  - Kişiselleştirilmiş günlük yorum sistemi çalışıyor
  - **KRİTİK:** Cache izolasyonu düzeltildi (kullanıcı değiştiğinde cache karışması sorunu)
    - Cache key artık userId içeriyor: `daily_reading_${userId}_$today`
    - logout/signInWithGoogle sırasında tüm daily_reading cache'i temizleniyor
  - Lucky Elements UI geliştirildi (açıklamalar + ExpansionTile)
  - "Genel olarak Genel olarak" çift tekrar hatası düzeltildi
  - Yenileme butonu kaldırıldı
- **Güncellenmiş Dosyalar:**
  - `lib/services/daily_reading_service.dart` - userId'li cache key + clearAllDailyReadingCache()
  - `lib/services/auth_service.dart` - logout/signInWithGoogle'da cache temizleme
  - `lib/widgets/styled_analysis_view.dart` - çift "Genel olarak" fix
  - `lib/screens/personalized_daily_screen.dart` - refresh button kaldırıldı
- **SONRAKI OTURUM - EN KRİTİK AŞAMA:**
  - **Phase 15: Push Notification System**
  - Firebase Cloud Messaging entegrasyonu
  - APNs kurulumu (iOS)
  - Günlük kişiselleştirilmiş bildirimler
  - Streak hatırlatma bildirimleri
- **Test için:**
  ```bash
  cd /Users/yusufkamil/Desktop/elcizgisi
  flutter clean && flutter pub get
  flutter build ios --simulator
  ```
