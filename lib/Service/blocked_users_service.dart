import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/blocked_users_model.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class BlockedUsersService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<BlockedUsersModel?> getBlockedUsers() async {
    final url = '${ApiConstants.baseUrl}/chat/blocked-users';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return BlockedUsersModel.fromJson(data);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get blocked users');
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  /// Block a user
  /// 
  /// Laravel API: POST /chat/block/{userId}
  /// Note: The reason parameter is optional but may not be used by the backend
  static Future<Map<String, dynamic>?> blockUser({
    required int userId,
    String? reason,
  }) async {
    final url = '${ApiConstants.baseUrl}/chat/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      // Build request body (reason is optional)
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body.isNotEmpty ? body : null);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: body.isNotEmpty ? jsonEncode(body) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return jsonDecode(response.body);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to block user');
        return jsonDecode(response.body);
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> unblockUser(int userId) async {
    final url = '${ApiConstants.baseUrl}/chat/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true, 'message': 'User unblocked successfully'};
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to unblock user');
        if (response.body.isNotEmpty) {
          try {
            return jsonDecode(response.body);
          } catch (_) {
            return {'success': false, 'message': 'Server error: ${response.statusCode}'};
          }
        }
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }
}
