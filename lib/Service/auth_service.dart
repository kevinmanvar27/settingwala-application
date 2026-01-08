import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class AuthService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  /// FIX: API Section 1.1 uses 'phone' not 'contact_number'
  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,  // FIX: renamed from contactNumber to phone
    String? dateOfBirth,
    String? gender,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/register';
    try {
      final body = {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,  // FIX: API expects 'phone' not 'contact_number'
        if (dateOfBirth != null) 'date_of_birth': dateOfBirth,
        if (gender != null) 'gender': gender,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 422) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
          errors: responseData['errors'],
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/login';
    try {
      final body = {
        'email': email,
        'password': password,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'email': email, 'password': '***'});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Invalid credentials');
        return AuthResponse(
          success: false,
          message: 'Invalid email or password.',
        );
      } else if (response.statusCode == 422) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error.',
          errors: responseData['errors'],
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> googleLogin({
    required String idToken,
    String? accessToken,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/google';
    try {
      final body = {
        'id_token': idToken,
        if (accessToken != null) 'access_token': accessToken,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Google login failed.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> forgotPassword({
    required String email,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/forgot-password';
    try {
      final body = {'email': email};

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 404) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Email not found');
        return AuthResponse(
          success: false,
          message: 'No account found with this email.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to send reset code.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/reset-password';
    try {
      final body = {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': passwordConfirmation,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'email': email, 'otp': otp});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Invalid OTP');
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid or expired OTP.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reset password.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> verifyOtp({
    required String email,
    required String otp,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/verify-otp';
    try {
      final body = {
        'email': email,
        'otp': otp,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 400) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Invalid OTP');
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid or expired OTP.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'OTP verification failed.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> resendOtp({
    required String email,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/resend-otp';
    try {
      final body = {'email': email};

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return AuthResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to resend OTP.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> logout() async {
    final url = '${ApiConstants.baseUrl}/auth/logout';
    try {
      final token = await _getToken();

      if (token == null) {
        await _clearToken();
        return AuthResponse(success: true, message: 'Logged out successfully.');
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      await _clearToken();

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return AuthResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ પણ logout થઈ ગયું
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return AuthResponse(success: true, message: 'Logged out successfully.');
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      await _clearToken();
      return AuthResponse(success: true, message: 'Logged out successfully.');
    }
  }

  static Future<AuthResponse> refreshToken() async {
    final url = '${ApiConstants.baseUrl}/auth/refresh-token';
    try {
      final token = await _getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'No token to refresh.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        if (responseData['data']?['token'] != null) {
          await _saveToken(responseData['data']['token']);
        }
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        await _clearToken();
        return AuthResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to refresh token.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AuthResponse> deleteAccount({
    String? password,
    String? reason,
  }) async {
    final url = '${ApiConstants.baseUrl}/auth/delete-account';
    try {
      final token = await _getToken();

      if (token == null) {
        return AuthResponse(
          success: false,
          message: 'Authentication required.',
        );
      }

      final body = {
        if (password != null) 'password': password,
        if (reason != null) 'reason': reason,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        await _clearToken();
        return AuthResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Invalid password');
        return AuthResponse(
          success: false,
          message: 'Invalid password.',
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return AuthResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete account.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AuthResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AppSettingsResponse> getAppSettings() async {
    final url = '${ApiConstants.baseUrl}/app-settings';
    try {
      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return AppSettingsResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return AppSettingsResponse(
          success: false,
          message: 'Failed to get app settings.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return AppSettingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  static Future<String?> getToken() async {
    return await _getToken();
  }
}


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
