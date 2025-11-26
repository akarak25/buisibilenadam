import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/models/auth_response.dart';
import 'package:palm_analysis/models/user.dart';
import 'package:palm_analysis/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication service for login, register, and user management
class AuthService {
  final TokenService _tokenService = TokenService();
  User? _currentUser;

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

      return authResponse;
    } else {
      final errorBody = utf8.decode(response.bodyBytes);
      final errorData = jsonDecode(errorBody);
      throw ApiError.fromJson(errorData, response.statusCode);
    }
  }

  /// Logout current user
  Future<void> logout() async {
    await _tokenService.clearAll();
    await _clearUserFromPrefs();
    _currentUser = null;
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
        print('Error loading stored user: $e');
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
}
