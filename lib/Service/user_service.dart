import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getusersmodel.dart';
import '../model/getuseravailabilitymodel.dart';
import '../utils/api_constants.dart';

class UserService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Users API - Fetch all users
  // Endpoint: GET /api/v1/users
  static Future<Getusersmodel?> getUsers({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Users Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Getusersmodel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Users Error: $e');
      return null;
    }
  }

  // GET User Availability API - Fetch user availability for a specific date
  // Endpoint: GET /api/v1/users/{userId}/availability?date=YYYY-MM-DD
  static Future<Getuseravailabilitymodel?> getUserAvailability({
    required int userId,
    required DateTime date,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final formattedDate = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      print('========== GET User Availability Request ==========');
      print('URL: ${ApiConstants.baseUrl}/users/$userId/availability?date=$formattedDate');
      print('====================================================');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId/availability?date=$formattedDate'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET User Availability Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=====================================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return Getuseravailabilitymodel.fromJson(json);
      } else if (response.statusCode == 401) {
        print('Error: Session expired');
        return null;
      } else if (response.statusCode == 404) {
        print('Error: User not found or no availability set');
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET User Availability Error: $e');
      return null;
    }
  }
}
