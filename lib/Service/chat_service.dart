import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getchatmodel.dart';
import '../utils/api_constants.dart';

class ChatService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Chats API
  static Future<GetchatModel?> getChats() async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Chats Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseChatsResponse(json);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Chats Error: $e');
      return null;
    }
  }

  // Parse JSON response to Model
  static GetchatModel _parseChatsResponse(Map<String, dynamic> json) {
    // Parse chats list
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

  // Parse OtherUser
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
}
