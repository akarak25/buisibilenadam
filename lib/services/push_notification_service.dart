import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:palm_analysis/config/api_config.dart';
import 'package:palm_analysis/services/token_service.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
}

/// Push notification service for handling FCM
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final TokenService _tokenService = TokenService();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize push notification service
  Future<void> initialize() async {
    try {
      // Set background message handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Request permission
      await _requestPermission();

      // Get FCM token
      await _getToken();

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle message open (when user taps notification)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Check if app was opened from notification
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleInitialMessage(initialMessage);
      }

      debugPrint('Push notification service initialized');
    } catch (e) {
      debugPrint('Error initializing push notifications: $e');
    }
  }

  /// Request notification permission
  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('Notification permission status: ${settings.authorizationStatus}');
  }

  /// Get FCM token
  Future<void> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await _sendTokenToServer(_fcmToken!);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  /// Handle token refresh
  void _onTokenRefresh(String token) {
    debugPrint('FCM Token refreshed: $token');
    _fcmToken = token;
    _sendTokenToServer(token);
  }

  /// Send FCM token to backend
  Future<void> _sendTokenToServer(String fcmToken) async {
    try {
      final authToken = await _tokenService.getToken();
      if (authToken == null) {
        debugPrint('No auth token, skipping device token registration');
        return;
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deviceTokenEndpoint}'),
        headers: ApiConfig.authHeaders(authToken),
        body: jsonEncode({
          'token': fcmToken,
          'platform': Platform.isIOS ? 'ios' : 'android',
        }),
      );

      if (response.statusCode == 200) {
        debugPrint('Device token registered successfully');
      } else {
        debugPrint('Failed to register device token: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error sending token to server: $e');
    }
  }

  /// Register token after user login
  Future<void> registerTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _sendTokenToServer(_fcmToken!);
    } else {
      await _getToken();
    }
  }

  /// Unregister token on logout
  Future<void> unregisterToken() async {
    try {
      final authToken = await _tokenService.getToken();
      if (authToken == null || _fcmToken == null) return;

      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.deviceTokenEndpoint}'),
        headers: ApiConfig.authHeaders(authToken),
        body: jsonEncode({'token': _fcmToken}),
      );

      debugPrint('Device token unregistered');
    } catch (e) {
      debugPrint('Error unregistering token: $e');
    }
  }

  /// Handle foreground message
  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('Foreground message received: ${message.notification?.title}');

    // You can show a local notification or snackbar here
    // For now, just log it
    if (message.notification != null) {
      debugPrint('Title: ${message.notification!.title}');
      debugPrint('Body: ${message.notification!.body}');
    }
  }

  /// Handle when user taps notification (app in background)
  void _handleMessageOpenedApp(RemoteMessage message) {
    debugPrint('Message opened app: ${message.data}');
    _handleNotificationTap(message.data);
  }

  /// Handle initial message (app opened from terminated state)
  void _handleInitialMessage(RemoteMessage message) {
    debugPrint('Initial message: ${message.data}');
    _handleNotificationTap(message.data);
  }

  /// Handle notification tap - navigate to relevant screen
  void _handleNotificationTap(Map<String, dynamic> data) {
    // Handle navigation based on notification data
    final type = data['type'];

    switch (type) {
      case 'daily_reading':
        // Navigate to daily reading screen
        debugPrint('Navigate to daily reading');
        break;
      case 'streak_reminder':
        // Navigate to home screen
        debugPrint('Navigate to home for streak');
        break;
      default:
        debugPrint('Unknown notification type: $type');
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Open app settings for notifications
  Future<void> openNotificationSettings() async {
    await _messaging.requestPermission();
  }
}
