import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class MessageService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Messages for a booking
  static Future<MessagesResponse?> getMessages(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat/$bookingId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Messages Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('============================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseMessagesResponse(json);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Messages Error: $e');
      return null;
    }
  }

  // Send a message
  static Future<Message?> sendMessage(int bookingId, String messageText) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/$bookingId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': messageText,
        }),
      );

      print('========== SEND Message Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('============================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null) {
          return _parseMessage(json['data']);
        }
        return null;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('SEND Message Error: $e');
      return null;
    }
  }

  // Mark messages as read
  static Future<bool> markAsRead(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/$bookingId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== Mark Read Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================');

      return response.statusCode == 200;
    } catch (e) {
      print('Mark Read Error: $e');
      return false;
    }
  }

  // Parse messages response
  static MessagesResponse _parseMessagesResponse(Map<String, dynamic> json) {
    List<Message> messages = [];
    
    if (json['data']?['messages'] != null) {
      for (var item in json['data']['messages']) {
        messages.add(_parseMessage(item));
      }
    }

    return MessagesResponse(
      success: json['success'] ?? false,
      messages: messages,
    );
  }

  // Parse single message
  static Message _parseMessage(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      text: json['message'] ?? json['text'] ?? '',
      senderId: json['sender_id'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isRead: json['is_read'] == true || json['read_at'] != null,
    );
  }
}

// Response model for messages
class MessagesResponse {
  final bool success;
  final List<Message> messages;

  MessagesResponse({
    required this.success,
    required this.messages,
  });
}

// Message model
class Message {
  final String id;
  final String text;
  final int senderId;
  final DateTime createdAt;
  final bool isRead;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.createdAt,
    this.isRead = false,
  });
}
