import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/blocked_users_model.dart';
import '../utils/api_constants.dart';

class BlockedUsersService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<BlockedUsersModel?> getBlockedUsers() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat/blocked-users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BlockedUsersModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> blockUser({
    required int userId,
    String? reason,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      final body = {
        'blocked_user_id': userId,
        if (reason != null) 'reason': reason,
      };

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/blocked-users'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return jsonDecode(response.body);
      }
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> unblockUser(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {'success': false, 'message': 'Authentication required'};
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/chat/block/$userId'),
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
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body);
        }
        return {'success': true, 'message': 'User unblocked successfully'};
      } else {
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
      return {'success': false, 'message': e.toString()};
    }
  }
}
