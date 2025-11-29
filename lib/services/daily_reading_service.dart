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

  // Cache key
  String _getCacheKey() {
    final today = DateTime.now().toIso8601String().split('T')[0];
    return 'daily_reading_$today';
  }

  /// Get personalized daily reading
  /// Returns cached version if available for today
  Future<DailyReading?> getDailyReading({String lang = 'tr'}) async {
    try {
      // Check cache first
      final cached = await _getCachedReading();
      if (cached != null) {
        print('Returning cached daily reading');
        return cached;
      }

      // Get token
      final token = await _tokenService.getToken();
      if (token == null) {
        print('No token available for daily reading');
        return null;
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
          // Cache the reading
          await _cacheReading(data);
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
      if (token == null) return false;

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
        await _clearCache();
        return true;
      }
      return false;
    } catch (e) {
      print('Save palm profile error: $e');
      return false;
    }
  }

  /// Get cached reading for today
  Future<DailyReading?> _getCachedReading() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
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

  /// Cache reading for today
  Future<void> _cacheReading(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
      await prefs.setString(cacheKey, jsonEncode(data));
    } catch (e) {
      print('Cache write error: $e');
    }
  }

  /// Clear cache (used when palm profile is updated)
  Future<void> _clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _getCacheKey();
      await prefs.remove(cacheKey);
    } catch (e) {
      print('Cache clear error: $e');
    }
  }

  /// Force refresh daily reading (bypass cache)
  Future<DailyReading?> refreshDailyReading({String lang = 'tr'}) async {
    await _clearCache();
    return getDailyReading(lang: lang);
  }
}
