/// API configuration for elcizgisi.com backend
class ApiConfig {
  // Base URL for all API calls
  static const String baseUrl = 'https://elcizgisi.com/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/giris';
  static const String registerEndpoint = '/auth/kayit';
  static const String logoutEndpoint = '/auth/cikis';
  static const String profileEndpoint = '/auth/profil';
  static const String googleAuthEndpoint = '/auth/google';
  static const String appleAuthEndpoint = '/auth/apple';

  // Analysis endpoint
  static const String analyzeEndpoint = '/analyze';

  // Chat endpoint (mobile-specific endpoint)
  static const String chatEndpoint = '/chat/mobile';

  // Compatibility analysis endpoint
  static const String compatibilityEndpoint = '/compatibility';

  // Evolution analysis endpoint
  static const String evolutionEndpoint = '/evolution';

  // Queries endpoints
  static const String queriesEndpoint = '/queries';

  // Push notification endpoints
  static const String deviceTokenEndpoint = '/notifications/device-token';
  static const String notificationPreferencesEndpoint = '/notifications/preferences';

  // Activity endpoints
  static const String activityDailyEndpoint = '/activity/daily';

  // User endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String userOnboardingEndpoint = '/user/onboarding';
  static const String deleteAccountEndpoint = '/user/delete-account';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 60);

  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> multipartHeaders(String token) => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
  };
}
