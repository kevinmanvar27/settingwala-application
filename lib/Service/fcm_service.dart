import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settingwala/utils/api_constants.dart';
import '../utils/api_logger.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _fcmTokenKey = 'fcm_token';

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
