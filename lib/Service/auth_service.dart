import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

/// AuthService handles all authentication-related API calls
/// Endpoints: /api/v1/auth/*
class AuthService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Save auth token to SharedPreferences
  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Clear auth token from SharedPreferences
  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REGISTER - Create new user account
  // Endpoint: POST /api/v1/auth/register
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String contactNumber,
    String? dateOfBirth,
    String? gender,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/register';
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'contact_number': contactNumber,
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
      };

      print('========== POST Register Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('===========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Register Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('============================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token if provided
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 422) {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
          errors: responseData['errors'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      print('POST Register Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGIN - Authenticate user with email and password
  // Endpoint: POST /api/v1/auth/login
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/login';
      final body = {
        'email': email,
        'password': password,
      };

      print('========== POST Login Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Login Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save token if provided
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return AuthResponse(
          success: false,
          message: 'Invalid email or password.',
        );
      } else if (response.statusCode == 422) {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error.',
          errors: responseData['errors'],
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      print('POST Login Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GOOGLE LOGIN - Authenticate user with Google
  // Endpoint: POST /api/v1/auth/google
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> googleLogin({
    required String idToken,
    String? accessToken,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/google';
      final body = {
        'id_token': idToken,
        if (accessToken != null) 'access_token': accessToken,
      };

      print('========== POST Google Login Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('===============================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Google Login Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Save token if provided
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Google login failed.',
        );
      }
    } catch (e) {
      print('POST Google Login Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // FORGOT PASSWORD - Request password reset OTP
  // Endpoint: POST /api/v1/auth/forgot-password
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> forgotPassword({
    required String email,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/forgot-password';
      final body = {'email': email};

      print('========== POST Forgot Password Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('==================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Forgot Password Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 404) {
        return AuthResponse(
          success: false,
          message: 'No account found with this email.',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to send reset code.',
        );
      }
    } catch (e) {
      print('POST Forgot Password Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESET PASSWORD - Reset password with OTP
  // Endpoint: POST /api/v1/auth/reset-password
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/reset-password';
      final body = {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      print('========== POST Reset Password Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('=================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Reset Password Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid or expired OTP.',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reset password.',
        );
      }
    } catch (e) {
      print('POST Reset Password Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VERIFY OTP - Verify email/phone with OTP
  // Endpoint: POST /api/v1/auth/verify-otp
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/verify-otp';
      final body = {
        'email': email,
        'otp': otp,
      };

      print('========== POST Verify OTP Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('=============================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Verify OTP Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==============================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid or expired OTP.',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'OTP verification failed.',
        );
      }
    } catch (e) {
      print('POST Verify OTP Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESEND OTP - Resend verification OTP
  // Endpoint: POST /api/v1/auth/resend-otp
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> resendOtp({
    required String email,
  }) async {
    try {
      final url = '${ApiConstants.baseUrl}/auth/resend-otp';
      final body = {'email': email};

      print('========== POST Resend OTP Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('=============================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      print('========== POST Resend OTP Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==============================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to resend OTP.',
        );
      }
    } catch (e) {
      print('POST Resend OTP Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // LOGOUT - Logout current user
  // Endpoint: POST /api/v1/auth/logout
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> logout() async {
    try {
      final token = await _getToken();

      if (token == null) {
        await _clearToken();
        return AuthResponse(success: true, message: 'Logged out successfully.');
      }

      final url = '${ApiConstants.baseUrl}/auth/logout';

      print('========== POST Logout Request ==========');
      print('URL: $url');
      print('=========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Logout Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==========================================');

      // Clear token regardless of response
      await _clearToken();

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AuthResponse.fromJson(responseData);
      } else {
        return AuthResponse(success: true, message: 'Logged out successfully.');
      }
    } catch (e) {
      print('POST Logout Error: $e');
      await _clearToken();
      return AuthResponse(success: true, message: 'Logged out successfully.');
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REFRESH TOKEN - Refresh authentication token
  // Endpoint: POST /api/v1/auth/refresh-token
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> refreshToken() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'No token to refresh.',
        );
      }

      final url = '${ApiConstants.baseUrl}/auth/refresh-token';

      print('========== POST Refresh Token Request ==========');
      print('URL: $url');
      print('================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Refresh Token Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Save new token if provided
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        await _clearToken();
        return AuthResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to refresh token.',
        );
      }
    } catch (e) {
      print('POST Refresh Token Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // DELETE ACCOUNT - Permanently delete user account
  // Endpoint: DELETE /api/v1/auth/delete-account
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AuthResponse> deleteAccount({
    String? password,
    String? reason,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'Authentication required.',
        );
      }

      final url = '${ApiConstants.baseUrl}/auth/delete-account';
      final body = {
        if (password != null) 'password': password,
        if (reason != null) 'reason': reason,
      };

      print('========== DELETE Account Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('============================================');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== DELETE Account Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=============================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await _clearToken();
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return AuthResponse(
          success: false,
          message: 'Invalid password.',
        );
      } else {
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete account.',
        );
      }
    } catch (e) {
      print('DELETE Account Error: $e');
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET APP SETTINGS - Get public app settings
  // Endpoint: GET /api/v1/app-settings
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<AppSettingsResponse> getAppSettings() async {
    try {
      final url = '${ApiConstants.baseUrl}/app-settings';

      print('========== GET App Settings Request ==========');
      print('URL: $url');
      print('==============================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('========== GET App Settings Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===============================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AppSettingsResponse.fromJson(responseData);
      } else {
        return AppSettingsResponse(
          success: false,
          message: 'Failed to get app settings.',
        );
      }
    } catch (e) {
      print('GET App Settings Error: $e');
      return AppSettingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // Helper: Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Helper: Get current token
  static Future<String?> getToken() async {
    return await _getToken();
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Standard auth response model
class AuthResponse {
  final bool success;
  final String message;
  final AuthData? data;
  final Map<String, dynamic>? errors;

  AuthResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AuthData.fromJson(json['data']) : null,
      errors: json['errors'],
    );
  }
}

/// Auth data containing user and token
class AuthData {
  final String? token;
  final String? tokenType;
  final AuthUser? user;
  final bool? isNewUser;
  final bool? requiresVerification;

  AuthData({
    this.token,
    this.tokenType,
    this.user,
    this.isNewUser,
    this.requiresVerification,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      token: json['token'],
      tokenType: json['token_type'],
      user: json['user'] != null ? AuthUser.fromJson(json['user']) : null,
      isNewUser: json['is_new_user'],
      requiresVerification: json['requires_verification'],
    );
  }
}

/// User data from auth response
class AuthUser {
  final int id;
  final String? name;
  final String? email;
  final String? contactNumber;
  final String? avatar;
  final String? gender;
  final bool? isVerified;
  final bool? isProfileComplete;
  final String? subscriptionStatus;
  final String? createdAt;

  AuthUser({
    required this.id,
    this.name,
    this.email,
    this.contactNumber,
    this.avatar,
    this.gender,
    this.isVerified,
    this.isProfileComplete,
    this.subscriptionStatus,
    this.createdAt,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      contactNumber: json['contact_number'],
      avatar: json['avatar'],
      gender: json['gender'],
      isVerified: _parseBool(json['is_verified']),
      isProfileComplete: _parseBool(json['is_profile_complete']),
      subscriptionStatus: json['subscription_status'],
      createdAt: json['created_at'],
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }
}

/// App settings response
class AppSettingsResponse {
  final bool success;
  final String message;
  final AppSettings? data;

  AppSettingsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AppSettingsResponse.fromJson(Map<String, dynamic> json) {
    return AppSettingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? AppSettings.fromJson(json['data']) : null,
    );
  }
}

/// App settings data
class AppSettings {
  final String? appVersion;
  final String? minAppVersion;
  final bool? maintenanceMode;
  final String? maintenanceMessage;
  final String? termsUrl;
  final String? privacyUrl;
  final String? supportEmail;
  final String? supportPhone;
  final Map<String, dynamic>? features;

  AppSettings({
    this.appVersion,
    this.minAppVersion,
    this.maintenanceMode,
    this.maintenanceMessage,
    this.termsUrl,
    this.privacyUrl,
    this.supportEmail,
    this.supportPhone,
    this.features,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      appVersion: json['app_version'],
      minAppVersion: json['min_app_version'],
      maintenanceMode: json['maintenance_mode'],
      maintenanceMessage: json['maintenance_message'],
      termsUrl: json['terms_url'],
      privacyUrl: json['privacy_url'],
      supportEmail: json['support_email'],
      supportPhone: json['support_phone'],
      features: json['features'],
    );
  }
}
