import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/GetcompletionstatusModel.dart';
import '../utils/api_constants.dart';

class CompletionStatusService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Completion Status API
  static Future<GetcompletionstatusModel?> getCompletionStatus() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/profile/completion-status'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Completion Status Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=====================================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetcompletionstatusModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Completion Status Error: $e');
      return null;
    }
  }
}
