import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:settingwala/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Service/fcm_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return null;
      }

      final backendData = await _sendToBackend(
        googleId: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName,
        avatar: googleUser.photoUrl,
      );

      if (backendData != null) {
        await _saveUserData(backendData);
      }

      return backendData;

    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> _sendToBackend({
    required String googleId,
    required String email,
    String? name,
    String? avatar,
  }) async {
    try {
      print('DEBUG: Calling API: ${ApiConstants.googleLogin}');
      print('DEBUG: Email: $email');
      
      final response = await http.post(
        Uri.parse(ApiConstants.googleLogin),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'google_id': googleId,
          'email': email,
          'name': name ?? '',
          'avatar': avatar ?? '',
        }),
      );

      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');
      
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data['data'];
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('DEBUG: Error in _sendToBackend: $e');
      rethrow;
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['token']);
    await prefs.setString('user_data', jsonEncode(data['user']));
    await prefs.setBool('is_new_user', data['is_new_user'] ?? false);
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FcmService().deleteFcmToken();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('is_new_user');
    } catch (e) {
    }
  }
}
