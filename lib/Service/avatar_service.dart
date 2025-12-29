import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/postavatarmodel.dart';
import '../utils/api_constants.dart';

class AvatarService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // POST Avatar API - Upload profile picture
  static Future<PostavatarModel?> uploadAvatar(File imageFile) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/profile/avatar'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add file - API expects 'profile_picture' field name
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_picture',
          imageFile.path,
        ),
      );

      print('========== POST Avatar Request ==========');
      print('File Path: ${imageFile.path}');
      print('==========================================');

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('========== POST Avatar Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==========================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return PostavatarModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('POST Avatar Error: $e');
      return null;
    }
  }
}
