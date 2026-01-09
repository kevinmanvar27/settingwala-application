import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settingwala/utils/api_constants.dart';
import '../utils/api_logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Callback type for handling foreground FCM messages
typedef FcmMessageCallback = void Function(RemoteMessage message);

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _fcmTokenKey = 'fcm_token';
  
  // Local notifications plugin for showing notifications when app is in foreground
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  // Callback for when a new notification is received in foreground
  FcmMessageCallback? onForegroundMessage;

  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  Future<void> initialize() async {
    try {
      await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      // Initialize local notifications for foreground display
      await _initializeLocalNotifications();

      await _setupFCMToken();

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _handleForegroundMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _handleMessageTap(message);
      });

      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }

    } catch (e) {
      // Handle initialization errors silently
    }
  }
  
  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        // Could navigate to specific screen based on payload
      },
    );
    
    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'settingwala_notifications',
      'Settingwala Notifications',
      description: 'Notifications from Settingwala app',
      importance: Importance.high,
    );
    
    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> _setupFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();

      if (token != null) {
        await _saveFCMToken(token);

        await _checkAndSendTokenToBackend(token);
      }

      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _saveFCMToken(newToken);
        _sendTokenToBackend(newToken);
      });

    } catch (e) {
      // Handle initialization errors silently
    }
  }

  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
    } catch (e) {
      // Handle initialization errors silently
    }
  }

  Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      return null;
    }
  }

  Future<void> _checkAndSendTokenToBackend(String currentToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastSentToken = prefs.getString('last_sent_fcm_token');

      if (lastSentToken != currentToken) {
        await _sendTokenToBackend(currentToken);
        await prefs.setString('last_sent_fcm_token', currentToken);
      } else {
        
      }
    } catch (e) {
      // Handle initialization errors silently
    }
  }
  Future<void> _sendTokenToBackend(String token) async {
    final url = ApiConstants.notificationsFcmToken;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        return;
      }

      // FIX: API Section 12.7 expects 'fcm_token' not 'token'
      final body = {
        'fcm_token': token,
        'device_type': 'android',
      };

      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to send FCM token');
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Log the incoming message
    ApiLogger.logApiSuccess(
      endpoint: 'FCM_FOREGROUND',
      statusCode: 0,
      response: 'Received foreground message: ${message.notification?.title}',
    );
    
    // Show local notification so user sees it even when app is open
    _showLocalNotification(message);
    
    // Notify any registered listeners (e.g., to update notification badge)
    if (onForegroundMessage != null) {
      onForegroundMessage!(message);
    }
  }
  
  /// Show a local notification when app is in foreground
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;
    
    const androidDetails = AndroidNotificationDetails(
      'settingwala_notifications',
      'Settingwala Notifications',
      channelDescription: 'Notifications from Settingwala app',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );
    
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      notificationDetails,
      payload: jsonEncode(message.data),
    );
  }

  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;

    if (data.containsKey('screen')) {
      _navigateToScreen(data['screen'], data);
    }
  }

  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    // Navigation logic to be implemented

  }

  Future<bool> deleteFcmToken() async {
    final url = '${ApiConstants.baseUrl}/notifications/fcm-token';
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final String? fcmToken = prefs.getString(_fcmTokenKey);

      if (authToken == null) {
        return false;
      }

      if (fcmToken == null) {
        return false;
      }

      // FIX: API Section 12.8 expects 'fcm_token' not 'token'
      final body = {
        'fcm_token': fcmToken,
      };

      ApiLogger.logApiCall(endpoint: url, method: 'DELETE', body: body);

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        await prefs.remove('last_sent_fcm_token');
        return true;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to delete FCM token');
        return false;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return false;
    }
  }

}
