import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settingwala/utils/api_constants.dart';

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final String _fcmTokenKey = 'fcm_token';

  // Singleton pattern
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  // Initialize FCM
  Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      print('Notification permission: ${settings.authorizationStatus}');

      // Get token
      await _setupFCMToken();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Foreground message received: ${message.notification?.title}');
        _handleForegroundMessage(message);
      });

      // Handle background/terminated messages
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print('App opened from notification: ${message.notification?.title}');
        _handleMessageTap(message);
      });

      // Handle initial message when app is terminated
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage);
      }

    } catch (e) {
      print('FCM initialization error: $e');
    }
  }

  // Setup and save FCM token
  Future<void> _setupFCMToken() async {
    try {
      // Get current token
      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');

      if (token != null) {
        // Save locally
        await _saveFCMToken(token);

        // Check if token needs to be sent to backend
        await _checkAndSendTokenToBackend(token);
      }

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        _saveFCMToken(newToken);
        _sendTokenToBackend(newToken);
      });

    } catch (e) {
      print('Error getting FCM token: $e');
    }
  }

  // Save FCM token locally
  Future<void> _saveFCMToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fcmTokenKey, token);
      print('FCM token saved locally');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Get saved FCM token
  Future<String?> getSavedFCMToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_fcmTokenKey);
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Check if token needs to be sent to backend
  Future<void> _checkAndSendTokenToBackend(String currentToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? lastSentToken = prefs.getString('last_sent_fcm_token');

      // Send only if token is new or changed
      if (lastSentToken != currentToken) {
        await _sendTokenToBackend(currentToken);
        await prefs.setString('last_sent_fcm_token', currentToken);
      } else {
        print('FCM token already sent to backend');
      }
    } catch (e) {
      print('Error checking FCM token: $e');
    }
  }
// notification_service.dart માં સુધારો
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');

      if (authToken == null) {
        print('User not logged in, skipping FCM token send');
        return;
      }

      final response = await http.post(
        Uri.parse(ApiConstants.fcmToken), // હવે આ કામ કરશે
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': token,
          'device_type': 'android', // Change based on platform
        }),
      );

      print('========== FCM Token API Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('============================================');

      if (response.statusCode == 200) {
        print('FCM token sent successfully to backend');
      } else {
        print('Failed to send FCM token: ${response.body}');
      }
    } catch (e) {
      print('Error sending FCM token to backend: $e');
    }
  }
  // Send FCM token to backend
  // Future<void> _sendTokenToBackend(String token) async {
  //   try {
  //     final prefs = await SharedPreferences.getInstance();
  //     final String? authToken = prefs.getString('auth_token');
  //
  //     if (authToken == null) {
  //       print('User not logged in, skipping FCM token send');
  //       return;
  //     }
  //
  //     final response = await http.post(
  //       Uri.parse(ApiConstants.fcmToken),
  //       headers: {
  //         'Content-Type': 'application/json',
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $authToken',
  //       },
  //       body: jsonEncode({
  //         'token': token,
  //         'device_type': 'android', // Change based on platform
  //       }),
  //     );
  //
  //     print('========== FCM Token API Response ==========');
  //     print('Status Code: ${response.statusCode}');
  //     print('Body: ${response.body}');
  //     print('============================================');
  //
  //     if (response.statusCode == 200) {
  //       print('FCM token sent successfully to backend');
  //     } else {
  //       print('Failed to send FCM token: ${response.body}');
  //     }
  //   } catch (e) {
  //     print('Error sending FCM token to backend: $e');
  //   }
  // }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    // You can show a local notification or update UI here
    // For now, just print the message
    print('''
    Foreground Message:
    Title: ${message.notification?.title}
    Body: ${message.notification?.body}
    Data: ${message.data}
    ''');
  }

  // Handle when user taps on notification
  void _handleMessageTap(RemoteMessage message) {
    final data = message.data;

    // Navigate to appropriate screen based on data
    if (data.containsKey('screen')) {
      _navigateToScreen(data['screen'], data);
    }
  }

  // Navigation logic
  void _navigateToScreen(String screen, Map<String, dynamic> data) {
    // You'll need to implement navigation based on your app structure
    print('Navigate to: $screen with data: $data');

    // Example:
    // if (screen == 'events') {
    //   Navigator.pushNamed(context, '/events', arguments: data);
    // } else if (screen == 'messages') {
    //   Navigator.pushNamed(context, '/messages', arguments: data);
    // }
  }

  // Delete FCM token from backend
  Future<bool> deleteFcmToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('auth_token');
      final String? fcmToken = prefs.getString(_fcmTokenKey);

      if (authToken == null) {
        print('User not logged in, skipping FCM token delete');
        return false;
      }

      if (fcmToken == null) {
        print('No FCM token found to delete');
        return false;
      }

      print('========== DELETE FCM Token Request ==========');
      print('URL: ${ApiConstants.baseUrl}/notifications/fcm-token');
      print('Token: $fcmToken');
      print('===============================================');

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/notifications/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'token': fcmToken,
        }),
      );

      print('========== DELETE FCM Token Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('================================================');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Clear locally saved token references
        await prefs.remove('last_sent_fcm_token');
        print('FCM token deleted successfully from backend');
        return true;
      } else {
        print('Failed to delete FCM token: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error deleting FCM token: $e');
      return false;
    }
  }

}