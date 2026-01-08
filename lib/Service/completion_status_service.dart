import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/GetcompletionstatusModel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class CompletionStatusService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetcompletionstatusModel?> getCompletionStatus() async {
    final url = '${ApiConstants.baseUrl}/profile/completion-status';
    try {
      final token = await _getToken();
      
      if (token == null) {
        return null;
      }

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return GetcompletionstatusModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get completion status');
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }
}
