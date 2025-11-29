import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/services/token_service.dart';

/// Service for tracking daily app usage streaks
/// Syncs with backend when user is logged in, uses local storage as fallback
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  final TokenService _tokenService = TokenService();

  static const String _lastOpenDateKey = 'streak_last_open_date';
  static const String _currentStreakKey = 'streak_current';
  static const String _longestStreakKey = 'streak_longest';

  /// Get current streak data
  Future<StreakData> getStreakData() async {
    // Try to get from backend first if logged in
    final token = await _tokenService.getToken();
    if (token != null) {
      try {
        final response = await http.get(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.activityDailyEndpoint}'),
          headers: ApiConfig.authHeaders(token),
        ).timeout(const Duration(seconds: 5));

        if (response.statusCode == 200) {
          final jsonBody = utf8.decode(response.bodyBytes);
          final data = jsonDecode(jsonBody);
          final streakData = data['streakData'];

          // Update local cache
          await _saveToLocal(
            streakData['currentStreak'] ?? 0,
            streakData['longestStreak'] ?? 0,
            streakData['lastStreakDate'] != null
                ? DateTime.parse(streakData['lastStreakDate'])
                : null,
          );

          return StreakData(
            currentStreak: streakData['currentStreak'] ?? 0,
            longestStreak: streakData['longestStreak'] ?? 0,
            lastOpenDate: streakData['lastStreakDate'] != null
                ? DateTime.parse(streakData['lastStreakDate'])
                : null,
            isStreakAtRisk: data['isStreakAtRisk'] ?? false,
          );
        }
      } catch (e) {
        debugPrint('Failed to get streak from backend: $e');
      }
    }

    // Fall back to local storage
    return _getFromLocal();
  }

  /// Record today's app open and update streak
  /// Syncs with backend if user is logged in
  Future<StreakData> recordAppOpen() async {
    final token = await _tokenService.getToken();

    // If logged in, sync with backend
    if (token != null) {
      try {
        final response = await http.post(
          Uri.parse('${ApiConfig.baseUrl}${ApiConfig.activityDailyEndpoint}'),
          headers: ApiConfig.authHeaders(token),
        ).timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          final jsonBody = utf8.decode(response.bodyBytes);
          final data = jsonDecode(jsonBody);
          final streakData = data['streakData'];

          debugPrint('Streak synced with backend: ${streakData['currentStreak']}');

          // Update local cache
          await _saveToLocal(
            streakData['currentStreak'] ?? 0,
            streakData['longestStreak'] ?? 0,
            streakData['lastStreakDate'] != null
                ? DateTime.parse(streakData['lastStreakDate'])
                : null,
          );

          return StreakData(
            currentStreak: streakData['currentStreak'] ?? 0,
            longestStreak: streakData['longestStreak'] ?? 0,
            lastOpenDate: streakData['lastStreakDate'] != null
                ? DateTime.parse(streakData['lastStreakDate'])
                : null,
            isNewDay: data['isNewDay'] ?? false,
            streakBroken: data['streakBroken'] ?? false,
          );
        }
      } catch (e) {
        debugPrint('Failed to sync streak with backend: $e');
      }
    }

    // Fall back to local calculation
    return _recordAppOpenLocal();
  }

  /// Get streak data from local storage
  Future<StreakData> _getFromLocal() async {
    final prefs = await SharedPreferences.getInstance();

    final lastOpenDateStr = prefs.getString(_lastOpenDateKey);
    final currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    final longestStreak = prefs.getInt(_longestStreakKey) ?? 0;

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastOpenDate: lastOpenDateStr != null
          ? DateTime.parse(lastOpenDateStr)
          : null,
    );
  }

  /// Save streak data to local storage
  Future<void> _saveToLocal(
    int currentStreak,
    int longestStreak,
    DateTime? lastOpenDate,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_currentStreakKey, currentStreak);
    await prefs.setInt(_longestStreakKey, longestStreak);
    if (lastOpenDate != null) {
      await prefs.setString(_lastOpenDateKey, lastOpenDate.toIso8601String());
    }
  }

  /// Record app open locally (fallback when offline or not logged in)
  Future<StreakData> _recordAppOpenLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastOpenDateStr = prefs.getString(_lastOpenDateKey);
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int longestStreak = prefs.getInt(_longestStreakKey) ?? 0;

    bool isNewDay = false;
    bool streakBroken = false;

    if (lastOpenDateStr != null) {
      final lastOpenDate = DateTime.parse(lastOpenDateStr);
      final lastOpen = DateTime(lastOpenDate.year, lastOpenDate.month, lastOpenDate.day);

      final difference = today.difference(lastOpen).inDays;

      if (difference == 0) {
        // Same day, no change
        return StreakData(
          currentStreak: currentStreak,
          longestStreak: longestStreak,
          lastOpenDate: lastOpenDate,
          isNewDay: false,
        );
      } else if (difference == 1) {
        // Consecutive day, increment streak
        currentStreak += 1;
        isNewDay = true;
      } else {
        // Streak broken, reset to 1
        streakBroken = currentStreak > 0;
        currentStreak = 1;
        isNewDay = true;
      }
    } else {
      // First time opening, start streak
      currentStreak = 1;
      isNewDay = true;
    }

    // Update longest streak if current is higher
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }

    // Save to local
    await _saveToLocal(currentStreak, longestStreak, today);

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastOpenDate: today,
      isNewDay: isNewDay,
      streakBroken: streakBroken,
    );
  }

  /// Clear local streak data (for logout)
  Future<void> clearLocalStreak() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lastOpenDateKey);
    await prefs.remove(_currentStreakKey);
    await prefs.remove(_longestStreakKey);
    debugPrint('Local streak data cleared');
  }

  /// Get streak message based on count
  String getStreakMessage(int streak, bool isTurkish) {
    if (streak == 0) {
      return isTurkish ? 'Bugün ilk günün!' : 'Today is your first day!';
    } else if (streak == 1) {
      return isTurkish ? 'Harika başlangıç!' : 'Great start!';
    } else if (streak < 7) {
      return isTurkish
          ? '$streak gün üst üste!'
          : '$streak days in a row!';
    } else if (streak < 30) {
      return isTurkish
          ? 'Muhteşem! $streak günlük seri!'
          : 'Amazing! $streak day streak!';
    } else {
      return isTurkish
          ? 'İnanılmaz! $streak günlük seri!'
          : 'Incredible! $streak day streak!';
    }
  }

  /// Get streak emoji based on count
  String getStreakEmoji(int streak) {
    if (streak == 0) return '';
    if (streak < 3) return '🔥';
    if (streak < 7) return '🔥🔥';
    if (streak < 14) return '🔥🔥🔥';
    if (streak < 30) return '⭐';
    if (streak < 60) return '🌟';
    return '💎';
  }
}

/// Data class for streak information
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastOpenDate;
  final bool isNewDay;
  final bool streakBroken;
  final bool isStreakAtRisk;

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastOpenDate,
    this.isNewDay = false,
    this.streakBroken = false,
    this.isStreakAtRisk = false,
  });
}
