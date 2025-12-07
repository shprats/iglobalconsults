/// Notification Service
/// Handles push notifications and in-app notifications

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../../core/network/api_client.dart';
import '../../../core/config/app_config.dart';

class NotificationService {
  final ApiClient _apiClient;
  final FirebaseMessaging _firebaseMessaging;

  NotificationService(this._apiClient) : _firebaseMessaging = FirebaseMessaging.instance;

  /// Initialize push notifications
  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _registerDeviceToken(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _registerDeviceToken(newToken);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages (when app is in background)
      FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);
    }
  }

  /// Register device token with backend
  Future<void> _registerDeviceToken(String token) async {
    try {
      await _apiClient.post(
        '${AppConfig.notificationsBase}/register-device',
        data: {
          'device_token': token,
          'platform': 'ios', // TODO: Detect platform
        },
      );
    } catch (e) {
      // Silently fail - token registration is not critical
      print('Failed to register device token: $e');
    }
  }

  /// Handle foreground notification
  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification when app is in foreground
    // This will be handled by the notification handler
    print('Foreground notification: ${message.notification?.title}');
  }

  /// Handle background notification (app opened from notification)
  void _handleBackgroundMessage(RemoteMessage message) {
    // Navigate to relevant screen based on notification type
    print('Background notification opened: ${message.notification?.title}');
  }

  /// Get list of notifications
  Future<List<Map<String, dynamic>>> getNotifications({
    int page = 1,
    int pageSize = 20,
    bool? isRead,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };
      if (isRead != null) {
        queryParams['is_read'] = isRead;
      }

      final response =       await _apiClient.get(
        AppConfig.notificationsBase,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map && data.containsKey('notifications')) {
          return (data['notifications'] as List).cast<Map<String, dynamic>>();
        }
        return [];
      }
      throw Exception('Failed to fetch notifications');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _apiClient.put(
        '${AppConfig.notificationsBase}/$notificationId/read',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await _apiClient.post(
        '${AppConfig.notificationsBase}/mark-all-read',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _apiClient.delete(
        '${AppConfig.notificationsBase}/$notificationId',
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response?.data;
      if (data is Map && data.containsKey('detail')) {
        return data['detail'].toString();
      }
      return 'Error: ${error.response?.statusCode}';
    }
    return error.message ?? 'Network error';
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.notification?.title}');
  // Handle background notification
}

