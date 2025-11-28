import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking daily app usage streaks
class StreakService {
  static final StreakService _instance = StreakService._internal();
  factory StreakService() => _instance;
  StreakService._internal();

  static const String _lastOpenDateKey = 'streak_last_open_date';
  static const String _currentStreakKey = 'streak_current';
  static const String _longestStreakKey = 'streak_longest';

  /// Get current streak data
  Future<StreakData> getStreakData() async {
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

  /// Record today's app open and update streak
  Future<StreakData> recordAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastOpenDateStr = prefs.getString(_lastOpenDateKey);
    int currentStreak = prefs.getInt(_currentStreakKey) ?? 0;
    int longestStreak = prefs.getInt(_longestStreakKey) ?? 0;

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
      } else {
        // Streak broken, reset to 1
        currentStreak = 1;
      }
    } else {
      // First time opening, start streak
      currentStreak = 1;
    }

    // Update longest streak if current is higher
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
      await prefs.setInt(_longestStreakKey, longestStreak);
    }

    // Save current streak and date
    await prefs.setInt(_currentStreakKey, currentStreak);
    await prefs.setString(_lastOpenDateKey, today.toIso8601String());

    return StreakData(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastOpenDate: today,
      isNewDay: true,
    );
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
    if (streak == 0) return '🌱';
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

  StreakData({
    required this.currentStreak,
    required this.longestStreak,
    this.lastOpenDate,
    this.isNewDay = false,
  });
}
