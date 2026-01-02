import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getgalerymodel.dart';
import '../model/postgalerymodel.dart';
import '../model/deleteGalerymodel.dart';
import '../utils/api_constants.dart';


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
    try {
      final token = await _getToken();
      
      if (token == null) {
        
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

      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetgaleryModel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<postgalerymodel?> uploadImage(File imageFile) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        
        return null;
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConstants.baseUrl}/gallery/upload'),
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
        final data = jsonDecode(response.body);
        return postgalerymodel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<deleteGaleryModel?> deleteImage(int imageId) async {
    try {
      final token = await _getToken();
      
      if (token == null) {
        
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

      
      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return deleteGaleryModel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }


  static Future<ReorderGalleryResponse?> reorderImages(List<GalleryOrderItem> order) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final url = '${ApiConstants.baseUrl}/gallery/reorder';
      
      final body = {
        'order': order.map((item) => item.toJson()).toList(),
      };

      
      
      
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
        final json = jsonDecode(response.body);
        final result = ReorderGalleryResponse.fromJson(json);
        
        return result;
      } else if (response.statusCode == 422) {
        
        return null;
      } else {
        
        return null;
      }
    } catch (e) {
      
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
