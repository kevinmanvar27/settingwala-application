import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/GetcompletionstatusModel.dart';
import '../utils/api_constants.dart';

class CompletionStatusService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetcompletionstatusModel?> getCompletionStatus() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetcompletionstatusModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
