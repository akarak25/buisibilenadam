/// API configuration for elcizgisi.com backend
class ApiConfig {
  // Base URL for all API calls
  static const String baseUrl = 'https://elcizgisi.com/api';

  // Auth endpoints
  static const String loginEndpoint = '/auth/giris';
  static const String registerEndpoint = '/auth/kayit';
  static const String logoutEndpoint = '/auth/cikis';
  static const String profileEndpoint = '/auth/profil';

  // Analysis endpoint
  static const String analyzeEndpoint = '/analyze';

  // Queries endpoints
  static const String queriesEndpoint = '/queries';

  // User endpoints
  static const String userProfileEndpoint = '/user/profile';
  static const String userOnboardingEndpoint = '/user/onboarding';

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
