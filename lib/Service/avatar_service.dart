import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/postavatarmodel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class AvatarService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<PostavatarModel?> uploadAvatar(File imageFile) async {
    final url = '${ApiConstants.baseUrl}/profile/avatar';
    try {
      final token = await _getToken();
      
      if (token == null) {
        return null;
      }

      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'file_count': 1, 'file_name': imageFile.path.split('/').last});

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return PostavatarModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to upload avatar');
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }
}
