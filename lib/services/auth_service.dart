import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/models/auth_response.dart';
import 'package:palm_analysis/models/user.dart';
import 'package:palm_analysis/services/token_service.dart';
import 'package:palm_analysis/services/daily_reading_service.dart';
import 'package:palm_analysis/services/push_notification_service.dart';
import 'package:palm_analysis/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for login, register, and user management
class AuthService {
  final TokenService _tokenService = TokenService();
  final DailyReadingService _dailyReadingService = DailyReadingService();
  User? _currentUser;

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: '1090526264689-rluovhoc4v3irq65rggr7pjvcootq3kp.apps.googleusercontent.com',
    scopes: ['email', 'profile'],
  );

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  /// Get current logged in user
  User? get currentUser => _currentUser;

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    return await _tokenService.isLoggedIn();
  }

  /// Register a new user
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}');

    final response = await http
        .post(
          uri,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({
            'name': name,
            'email': email,
            'password': password,
          }),
        )
        .timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      final authResponse = AuthResponse.fromJson(data);

      // Save token and user info
      await _tokenService.saveToken(authResponse.token);
      await _tokenService.saveUserId(authResponse.user.id);
      await _saveUserToPrefs(authResponse.user);
      _currentUser = authResponse.user;

      // Register push notification token
      await PushNotificationService.instance.registerTokenAfterLogin();

      return authResponse;
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Login with email and password
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}');

    final response = await http
        .post(
          uri,
          headers: ApiConfig.defaultHeaders,
          body: jsonEncode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      final authResponse = AuthResponse.fromJson(data);

      // Save token and user info
      await _tokenService.saveToken(authResponse.token);
      await _tokenService.saveUserId(authResponse.user.id);
      await _saveUserToPrefs(authResponse.user);
      _currentUser = authResponse.user;

      // Register push notification token
      await PushNotificationService.instance.registerTokenAfterLogin();

      return authResponse;
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    // Unregister push notification token
    await PushNotificationService.instance.unregisterToken();

    // CRITICAL: Clear daily reading cache to prevent data leaking to next user
    await _dailyReadingService.clearAllDailyReadingCache();

    // Clear local streak data
    await StreakService().clearLocalStreak();

    await _tokenService.clearAll();
    await _clearUserFromPrefs();
    await _googleSignIn.signOut();
    _currentUser = null;

    debugPrint('User logged out - all caches cleared');
  }

  /// Sign in with Google
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // CRITICAL: Clear ALL caches before new login to prevent data leaking
      await _dailyReadingService.clearAllDailyReadingCache();

      // Clear previous session data before new login
      await _tokenService.clearAll();
      await _clearUserFromPrefs();
      _currentUser = null;

      // Sign out from previous Google account to allow account selection
      await _googleSignIn.signOut();

      debugPrint('Previous session cleared - starting fresh Google Sign-In');

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw ApiError(error: 'Google girisi iptal edildi', statusCode: 400);
      }

      // Get auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Send to backend
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleAuthEndpoint}');

      final response = await http
          .post(
            uri,
            headers: ApiConfig.defaultHeaders,
            body: jsonEncode({
              'idToken': googleAuth.idToken,
              'accessToken': googleAuth.accessToken,
              'email': googleUser.email,
              'name': googleUser.displayName,
              'photoUrl': googleUser.photoUrl,
            }),
          )
          .timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonBody);
        final authResponse = AuthResponse.fromJson(data);

        // Save token and user info
        await _tokenService.saveToken(authResponse.token);
        await _tokenService.saveUserId(authResponse.user.id);
        await _saveUserToPrefs(authResponse.user);
        _currentUser = authResponse.user;

        // Register push notification token
        await PushNotificationService.instance.registerTokenAfterLogin();

        return authResponse;
      } else {
        final errorBody = utf8.decode(response.bodyBytes);
        final errorData = jsonDecode(errorBody);
        throw ApiError.fromJson(errorData, response.statusCode);
      }
    } catch (e) {
      if (e is ApiError) rethrow;
      throw ApiError(error: 'Google girisi basarisiz: $e', statusCode: 500);
    }
  }

  /// Load user from local storage (for app startup)
  Future<User?> loadStoredUser() async {
    final isLoggedIn = await _tokenService.isLoggedIn();
    if (!isLoggedIn) return null;

    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');

    if (userJson != null) {
      try {
        _currentUser = User.fromJson(jsonDecode(userJson));
        return _currentUser;
      } catch (e) {
        debugPrint('Error loading stored user: $e');
        return null;
      }
    }
    return null;
  }

  /// Update user profile
  Future<User> updateProfile({
    String? name,
    int? age,
    String? profession,
    Gender? gender,
    DateTime? dateOfBirth,
  }) async {
    final token = await _tokenService.getToken();
    if (token == null) {
      throw ApiError(error: 'Oturum bulunamadi', statusCode: 401);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userProfileEndpoint}');

    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (age != null) body['age'] = age;
    if (profession != null) body['profession'] = profession;
    if (gender != null) body['gender'] = gender.value;
    if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth.toIso8601String();

    final response = await http
        .put(
          uri,
          headers: ApiConfig.authHeaders(token),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      final updatedUser = User.fromJson(data['user'] ?? data);

      await _saveUserToPrefs(updatedUser);
      _currentUser = updatedUser;

      return updatedUser;
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Complete onboarding
  Future<User> completeOnboarding({
    int? age,
    String? profession,
    Gender? gender,
  }) async {
    final token = await _tokenService.getToken();
    if (token == null) {
      throw ApiError(error: 'Oturum bulunamadi', statusCode: 401);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userOnboardingEndpoint}');

    final body = <String, dynamic>{
      'hasCompletedOnboarding': true,
    };
    if (age != null) body['age'] = age;
    if (profession != null) body['profession'] = profession;
    if (gender != null) body['gender'] = gender.value;

    final response = await http
        .post(
          uri,
          headers: ApiConfig.authHeaders(token),
          body: jsonEncode(body),
        )
        .timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      final jsonBody = utf8.decode(response.bodyBytes);
      final data = jsonDecode(jsonBody);
      final updatedUser = User.fromJson(data['user'] ?? data);

      await _saveUserToPrefs(updatedUser);
      _currentUser = updatedUser;

      return updatedUser;
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Save user to SharedPreferences
  Future<void> _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(user.toJson()));
  }

  /// Clear user from SharedPreferences
  Future<void> _clearUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }

  /// Delete user account permanently (iOS 17.4+ requirement)
  Future<void> deleteAccount() async {
    final token = await _tokenService.getToken();
    if (token == null) {
      throw ApiError(error: 'Oturum bulunamadi', statusCode: 401);
    }

    final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deleteAccountEndpoint}');

    final response = await http
        .delete(
          uri,
          headers: ApiConfig.authHeaders(token),
        )
        .timeout(ApiConfig.connectionTimeout);

    if (response.statusCode == 200) {
      // Account deleted successfully - clear all local data
      await PushNotificationService.instance.unregisterToken();
      await _dailyReadingService.clearAllDailyReadingCache();
      await StreakService().clearLocalStreak();
      await _tokenService.clearAll();
      await _clearUserFromPrefs();
      await _googleSignIn.signOut();
      _currentUser = null;

      // Clear all analyses from local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('analyses');
      await prefs.remove('total_analyses');

      debugPrint('Account deleted - all local data cleared');
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }
}
