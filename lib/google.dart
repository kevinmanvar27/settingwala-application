

import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:settingwala/utils/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Service/fcm_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get saved user data
  Future<Map<String, dynamic>?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    if (userJson != null) {
      return jsonDecode(userJson);
    }
    return null;
  }

  // Google Sign In (Direct Mode)
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Step 1: Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('User cancelled sign-in');
        return null;
      }

      // Step 2: Print all data (for debugging)
      print('========== Google User Data ==========');
      print('Google ID: ${googleUser.id}');
      print('Email: ${googleUser.email}');
      print('Name: ${googleUser.displayName}');
      print('Avatar: ${googleUser.photoUrl}');
      print('======================================');

      // Step 3: Send to Backend (Direct Mode)
      final backendData = await _sendToBackend(
        googleId: googleUser.id,
        email: googleUser.email,
        name: googleUser.displayName,
        avatar: googleUser.photoUrl,
      );

      // Step 4: Save data locally
      if (backendData != null) {
        await _saveUserData(backendData);
      }

      return backendData;

    } catch (e) {
      print('Google Sign-In Error: $e');
      rethrow;
    }
  }

  // Send data to Backend (Direct Mode)
  Future<Map<String, dynamic>?> _sendToBackend({
    required String googleId,
    required String email,
    String? name,
    String? avatar,
  }) async {
    try {
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

      print('========== API Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        print('Login Success!');
        print('Token: ${data['data']['token']}');
        return data['data'];
      } else {
        print('Backend Error: ${data['message']}');
        throw Exception(data['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Network Error: $e');
      rethrow;
    }
  }

  // Save user data locally
  Future<void> _saveUserData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', data['token']);
    await prefs.setString('user_data', jsonEncode(data['user']));
    await prefs.setBool('is_new_user', data['is_new_user'] ?? false);
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await FcmService().deleteFcmToken();
      // Clear local data
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      await prefs.remove('is_new_user');

      print('Signed out successfully');
    } catch (e) {
      print('Sign out error: $e');
    }
  }
}