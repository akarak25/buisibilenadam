import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/models/daily_reading.dart';
import 'package:palm_analysis/services/token_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for fetching personalized daily readings
class DailyReadingService {
  final TokenService _tokenService = TokenService();

  // Singleton
  static final DailyReadingService _instance = DailyReadingService._internal();
  factory DailyReadingService() => _instance;
  DailyReadingService._internal();

  // Cache key prefix for daily readings
  static const String _cacheKeyPrefix = 'daily_reading_';

  // Cache key - NOW INCLUDES USER ID for privacy isolation
  String _getCacheKey(String userId) {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return '${_cacheKeyPrefix}${userId}_$today';
  }

  /// Clear all daily reading cache for current user (called on logout)
  Future<void> clearAllDailyReadingCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      // Remove all keys that start with daily_reading_
      for (final key in allKeys) {
        if (key.startsWith(_cacheKeyPrefix)) {
          await prefs.remove(key);
          print('Cleared daily reading cache: $key');
        }
      }
    } catch (e) {
      print('Clear all daily reading cache error: $e');
    }
  }

  /// Get personalized daily reading
  /// Returns cached version if available for today
  Future<DailyReading?> getDailyReading({String lang = 'tr'}) async {
    try {
      // Get token and userId first
      final token = await _tokenService.getToken();
      final userId = await _tokenService.getUserId();

      if (token == null || userId == null) {
        print('No token or userId available for daily reading');
        return null;
      }

      // Check cache first (with userId isolation)
      final cached = await _getCachedReading(userId);
      if (cached != null) {
        print('Returning cached daily reading for user: $userId');
        return cached;
      }

      // Fetch from API
      final uri = Uri.parse('${ApiConfig.baseUrl}/daily-reading?lang=$lang');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));

        if (data['success'] == true) {
          final reading = DailyReading.fromJson(data);
          // Cache the reading (with userId isolation)
          await _cacheReading(userId, data);
          return reading;
        } else {
          print('Daily reading API returned success: false');
          print('Message: ${data['message']}');
          return null;
        }
      } else {
        print('Daily reading API error: ${response.statusCode}');
        print('Body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Daily reading service error: $e');
      return null;
    }
  }

  /// Check if user has a palm profile (for determining if personalized readings are available)
  Future<bool> hasPalmProfile() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) return false;

      final uri = Uri.parse('${ApiConfig.baseUrl}/palm-profile');
      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['hasPalmProfile'] == true;
      }
      return false;
    } catch (e) {
      print('Check palm profile error: $e');
      return false;
    }
  }

  /// Save palm profile from analysis text
  Future<bool> savePalmProfile(String analysisText) async {
    try {
      final token = await _tokenService.getToken();
      final userId = await _tokenService.getUserId();
      if (token == null || userId == null) return false;

      final uri = Uri.parse('${ApiConfig.baseUrl}/palm-profile');
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'analysisText': analysisText}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        print('Palm profile saved successfully');
        // Clear daily reading cache to get fresh personalized reading
        await _clearCache(userId);
        return true;
      }
      return false;
    } catch (e) {
      print('Save palm profile error: $e');
      return false;
    }
  }

  /// Get cached reading for today (with user isolation)
  Future<DailyReading?> _getCachedReading(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(userId);
      final cachedJson = prefs.getString(cacheKey);

      if (cachedJson != null) {
        final data = jsonDecode(cachedJson);
        return DailyReading.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Cache read error: $e');
      return null;
    }
  }

  /// Cache reading for today (with user isolation)
  Future<void> _cacheReading(String userId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(userId);
      await prefs.setString(cacheKey, jsonEncode(data));
      print('Cached daily reading for user: $userId');
    } catch (e) {
      print('Cache write error: $e');
    }
  }

  /// Clear cache for specific user (used when palm profile is updated)
  Future<void> _clearCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey(userId);
      await prefs.remove(cacheKey);
      print('Cleared cache for user: $userId');
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  /// Force refresh daily reading (bypass cache)
  Future<DailyReading?> refreshDailyReading({String lang = 'tr'}) async {
    try {
      final userId = await _tokenService.getUserId();
      if (userId != null) {
        await _clearCache(userId);
      }
      return getDailyReading(lang: lang);
    } catch (e) {
      print('Refresh daily reading error: $e');
      return null;
    }
  }
}
