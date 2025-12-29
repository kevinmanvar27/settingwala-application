import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getgalerymodel.dart';
import '../model/postgalerymodel.dart';
import '../model/deleteGalerymodel.dart';
import '../utils/api_constants.dart';

class GalleryService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Gallery API - Fetch all gallery images
  // Endpoint: GET /api/v1/gallery
  static Future<GetgaleryModel?> getGallery() async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/gallery'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Gallery Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==========================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetgaleryModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Gallery Error: $e');
      return null;
    }
  }

  // POST Gallery Upload API - Upload a new image
  // Endpoint: POST /api/v1/gallery/upload
  static Future<postgalerymodel?> uploadImage(File imageFile) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/gallery/upload'),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      print('========== POST Gallery Upload Request ==========');
      print('File Path: ${imageFile.path}');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('========== POST Gallery Upload Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return postgalerymodel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('POST Gallery Upload Error: $e');
      return null;
    }
  }

  // DELETE Gallery Image API - Delete an image by ID
  // Endpoint: DELETE /api/v1/gallery/{id}
  static Future<deleteGaleryModel?> deleteImage(int imageId) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.delete(
        Uri.parse('${ApiConstants.baseUrl}/gallery/$imageId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== DELETE Gallery Image Response ==========');
      print('Image ID: $imageId');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return deleteGaleryModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('DELETE Gallery Image Error: $e');
      return null;
    }
  }
}
