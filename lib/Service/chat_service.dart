import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getchatmodel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class ChatService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetchatModel?> getChats() async {
    final url = '${ApiConstants.baseUrl}/chat';
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
        final json = jsonDecode(response.body);
        return _parseChatsResponse(json);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get chats');
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static GetchatModel _parseChatsResponse(Map<String, dynamic> json) {
    List<Chat> chats = [];
    if (json['data']?['chats'] != null) {
      for (var item in json['data']['chats']) {
        chats.add(Chat(
          bookingId: item['booking_id'] ?? 0,
          otherUser: _parseOtherUser(item['other_user']),
          lastMessage: item['last_message'],
          unreadCount: item['unread_count'] ?? 0,
          bookingStatus: item['booking_status'] ?? '',
          bookingDate: item['booking_date'] != null
              ? DateTime.tryParse(item['booking_date'].toString()) ?? DateTime.now()
              : DateTime.now(),
          durationHours: item['duration_hours']?.toString() ?? '',
          updatedAt: item['updated_at'] != null
              ? DateTime.tryParse(item['updated_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ));
      }
    }

    return GetchatModel(
      success: json['success'] ?? false,
      data: GetchatModelData(chats: chats),
    );
  }

  static OtherUser _parseOtherUser(Map<String, dynamic>? json) {
    if (json == null) {
      return OtherUser(
        id: 0,
        name: 'Unknown',
        avatar: '',
      );
    }

    return OtherUser(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'] ?? '',
    );
  }

  /// Unblock a user in chat - DELETE /chat/block/{userId}
  static Future<ChatUnblockResponse> unblockUser(int userId) async {
    final url = '${ApiConstants.baseUrl}/chat/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return ChatUnblockResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return ChatUnblockResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return ChatUnblockResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'User not found');
        return ChatUnblockResponse(
          success: false,
          message: data['message'] ?? 'User not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message']);
        return ChatUnblockResponse(
          success: false,
          message: data['message'] ?? 'Failed to unblock user.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return ChatUnblockResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Block a user in chat - /chat/block/{userId}
  /// FIX: API Section 11.9 requires 'reason' in request body
  static Future<ChatBlockResponse> blockUser(int userId, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/chat/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return ChatBlockResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // FIX: API requires body with 'reason' parameter (API Section 11.9)
      final body = {
        'reason': reason ?? 'User blocked',
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return ChatBlockResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return ChatBlockResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'User not found');
        return ChatBlockResponse(
          success: false,
          message: data['message'] ?? 'User not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message']);
        return ChatBlockResponse(
          success: false,
          message: data['message'] ?? 'Failed to block user.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return ChatBlockResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

/// Response model for chat unblock API
class ChatUnblockResponse {
  final bool success;
  final String message;
  final ChatUnblockData? data;

  ChatUnblockResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChatUnblockResponse.fromJson(Map<String, dynamic> json) {
    return ChatUnblockResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ChatUnblockData.fromJson(json['data']) : null,
    );
  }
}

class ChatUnblockData {
  final int? userId;
  final String? userName;

  ChatUnblockData({
    this.userId,
    this.userName,
  });

  factory ChatUnblockData.fromJson(Map<String, dynamic> json) {
    return ChatUnblockData(
      userId: json['user_id'],
      userName: json['user_name'],
    );
  }
}

/// Response model for chat block API
class ChatBlockResponse {
  final bool success;
  final String message;
  final ChatBlockData? data;

  ChatBlockResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChatBlockResponse.fromJson(Map<String, dynamic> json) {
    return ChatBlockResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ChatBlockData.fromJson(json['data']) : null,
    );
  }
}

class ChatBlockData {
  final int? userId;
  final String? userName;

  ChatBlockData({
    this.userId,
    this.userName,
  });

  factory ChatBlockData.fromJson(Map<String, dynamic> json) {
    return ChatBlockData(
      userId: json['user_id'],
      userName: json['user_name'],
    );
  }
}
