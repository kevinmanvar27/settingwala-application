import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getgalerymodel.dart';
import '../model/postgalerymodel.dart';
import '../model/deleteGalerymodel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';


class GalleryOrderItem {
  final int id;
  final int sortOrder;

  GalleryOrderItem({
    required this.id,
    required this.sortOrder,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sort_order': sortOrder,
    };
  }
}

class ReorderGalleryResponse {
  final bool success;
  final String message;

  ReorderGalleryResponse({
    required this.success,
    required this.message,
  });

  factory ReorderGalleryResponse.fromJson(Map<String, dynamic> json) {
    return ReorderGalleryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}


class GalleryService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetgaleryModel?> getGallery() async {
    final url = '${ApiConstants.baseUrl}/gallery';
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
        return GetgaleryModel.fromJson(data);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get gallery');
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<postgalerymodel?> uploadImage(File imageFile) async {
    final url = '${ApiConstants.baseUrl}/gallery/upload';
    try {
      final token = await _getToken();
      
      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'image': 'file'});

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
          'image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return postgalerymodel.fromJson(data);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to upload image');
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<deleteGaleryModel?> deleteImage(int imageId) async {
    final url = '${ApiConstants.baseUrl}/gallery/$imageId';
    try {
      final token = await _getToken();
      
      if (token == null) {
        return null;
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
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return deleteGaleryModel.fromJson(data);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to delete image');
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }


  /// FIX: API Section 4.3 expects 'order' as simple array of IDs [3, 1, 2]
  /// Not objects with id/sort_order
  static Future<ReorderGalleryResponse?> reorderImages(List<int> imageIds) async {
    final url = '${ApiConstants.baseUrl}/gallery/reorder';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }
      
      // FIX: API expects simple array of image IDs, not objects
      final body = {
        'order': imageIds,  // [3, 1, 2] format as per API spec
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final json = jsonDecode(response.body);
        final result = ReorderGalleryResponse.fromJson(json);
        return result;
      } else if (response.statusCode == 422) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Validation error');
        return null;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to reorder images');
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static List<GalleryOrderItem> createReorderList(List<int> imageIds) {
    return imageIds.asMap().entries.map((entry) {
      return GalleryOrderItem(
        id: entry.value,
        sortOrder: entry.key,
      );
    }).toList();
  }
}
