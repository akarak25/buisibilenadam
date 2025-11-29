import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/services/token_service.dart';

/// Notification preferences model
class NotificationPreferences {
  final bool enabled;
  final bool dailyReading;
  final String dailyReadingTime;
  final bool streakReminder;
  final bool specialEvents;
  final String timezone;

  NotificationPreferences({
    required this.enabled,
    required this.dailyReading,
    required this.dailyReadingTime,
    required this.streakReminder,
    required this.specialEvents,
    required this.timezone,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      enabled: json['enabled'] ?? true,
      dailyReading: json['dailyReading'] ?? true,
      dailyReadingTime: json['dailyReadingTime'] ?? '09:00',
      streakReminder: json['streakReminder'] ?? true,
      specialEvents: json['specialEvents'] ?? true,
      timezone: json['timezone'] ?? 'Europe/Istanbul',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'dailyReading': dailyReading,
      'dailyReadingTime': dailyReadingTime,
      'streakReminder': streakReminder,
      'specialEvents': specialEvents,
      'timezone': timezone,
    };
  }

  NotificationPreferences copyWith({
    bool? enabled,
    bool? dailyReading,
    String? dailyReadingTime,
    bool? streakReminder,
    bool? specialEvents,
    String? timezone,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      dailyReading: dailyReading ?? this.dailyReading,
      dailyReadingTime: dailyReadingTime ?? this.dailyReadingTime,
      streakReminder: streakReminder ?? this.streakReminder,
      specialEvents: specialEvents ?? this.specialEvents,
      timezone: timezone ?? this.timezone,
    );
  }

  // Default preferences
  static NotificationPreferences get defaults => NotificationPreferences(
    enabled: true,
    dailyReading: true,
    dailyReadingTime: '09:00',
    streakReminder: true,
    specialEvents: true,
    timezone: 'Europe/Istanbul',
  );
}

/// Service for managing notification preferences
class NotificationPreferencesService {
  final TokenService _tokenService = TokenService();

  // Singleton pattern
  static final NotificationPreferencesService _instance =
      NotificationPreferencesService._internal();
  factory NotificationPreferencesService() => _instance;
  NotificationPreferencesService._internal();

  /// Get current notification preferences from server
  Future<NotificationPreferences> getPreferences() async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        debugPrint('No auth token, returning defaults');
        return NotificationPreferences.defaults;
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationPreferencesEndpoint}'),
        headers: ApiConfig.authHeaders(token),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonBody);
        return NotificationPreferences.fromJson(data['preferences']);
      } else {
        debugPrint('Failed to get preferences: ${response.statusCode}');
        return NotificationPreferences.defaults;
      }
    } catch (e) {
      debugPrint('Error getting notification preferences: $e');
      return NotificationPreferences.defaults;
    }
  }

  /// Update notification preferences on server
  Future<NotificationPreferences?> updatePreferences(
    NotificationPreferences preferences,
  ) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        debugPrint('No auth token for updating preferences');
        return null;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationPreferencesEndpoint}'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode(preferences.toJson()),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonBody = utf8.decode(response.bodyBytes);
        final data = jsonDecode(jsonBody);
        debugPrint('Preferences updated successfully');
        return NotificationPreferences.fromJson(data['preferences']);
      } else {
        debugPrint('Failed to update preferences: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Error updating notification preferences: $e');
      return null;
    }
  }

  /// Quick toggle for master notification switch
  Future<bool> toggleNotifications(bool enabled) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        debugPrint('No auth token for toggling notifications');
        return false;
      }

      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationPreferencesEndpoint}'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({'enabled': enabled}),
      ).timeout(ApiConfig.connectionTimeout);

      if (response.statusCode == 200) {
        debugPrint('Notifications ${enabled ? 'enabled' : 'disabled'}');
        return true;
      } else {
        debugPrint('Failed to toggle notifications: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error toggling notifications: $e');
      return false;
    }
  }

  /// Update single preference
  Future<bool> updateSinglePreference(String key, dynamic value) async {
    try {
      final token = await _tokenService.getToken();
      if (token == null) {
        return false;
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.notificationPreferencesEndpoint}'),
        headers: ApiConfig.authHeaders(token),
        body: jsonEncode({key: value}),
      ).timeout(ApiConfig.connectionTimeout);

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error updating single preference: $e');
      return false;
    }
  }
}
