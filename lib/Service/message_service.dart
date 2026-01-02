import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class MessageService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<MessagesResponse?> getMessages(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/chat/booking/$bookingId/messages'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseMessagesResponse(json);
      } else if (response.statusCode == 401) {
        
        return null;
      } else {
        
        return null;
      }
    } catch (e) {
      
      if (e.toString().contains('FormatException')) {
        
      }
      return null;
    }
  }

  static Future<Message?> sendMessage(int bookingId, String messageText) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/booking/$bookingId/send'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': messageText,
        }),
      );

      
      
      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null && json['data']['message'] != null) {
          return _parseMessage(json['data']['message']);
        }
        return null;
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<bool> markAsRead(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return false;
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/chat/booking/$bookingId/mark-read'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      return response.statusCode == 200;
    } catch (e) {
      
      return false;
    }
  }

  static Future<AllChatsResponse?> getAllChats({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return AllChatsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat?page=$page';

      
      
      
      
      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return AllChatsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return AllChatsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return AllChatsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get chats.',
        );
      }
    } catch (e) {
      
      return AllChatsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<UnreadCountResponse?> getUnreadCount() async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return UnreadCountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat/unread-count';

      
      
      
      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return UnreadCountResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return UnreadCountResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return UnreadCountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get unread count.',
        );
      }
    } catch (e) {
      
      return UnreadCountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BlockedUsersResponse?> getBlockedUsers() async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BlockedUsersResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat/blocked-users';

      
      
      
      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BlockedUsersResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BlockedUsersResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BlockedUsersResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get blocked users.',
        );
      }
    } catch (e) {
      
      return BlockedUsersResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<StartChatResponse?> startChat(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return StartChatResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat/start/$userId';

      
      
      
      
      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return StartChatResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return StartChatResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return StartChatResponse(
          success: false,
          message: 'You cannot start a chat with this user.',
        );
      } else if (response.statusCode == 404) {
        return StartChatResponse(
          success: false,
          message: 'User not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return StartChatResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to start chat.',
        );
      }
    } catch (e) {
      
      return StartChatResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<DeleteMessageResponse?> deleteMessage(int messageId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return DeleteMessageResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat/message/$messageId';

      
      
      
      
      
      
      

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return DeleteMessageResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return DeleteMessageResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return DeleteMessageResponse(
          success: false,
          message: 'You can only delete your own messages.',
        );
      } else if (response.statusCode == 404) {
        return DeleteMessageResponse(
          success: false,
          message: 'Message not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return DeleteMessageResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete message.',
        );
      }
    } catch (e) {
      
      return DeleteMessageResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BlockUserResponse?> blockUser(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BlockUserResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat/block/$userId';

      
      
      
      
      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BlockUserResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BlockUserResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return BlockUserResponse(
          success: false,
          message: 'User not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BlockUserResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to block user.',
        );
      }
    } catch (e) {
      
      return BlockUserResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BlockUserResponse?> unblockUser(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BlockUserResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/chat/block/$userId';

      
      
      
      
      
      
      

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BlockUserResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BlockUserResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return BlockUserResponse(
          success: false,
          message: 'User not found or not blocked.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BlockUserResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to unblock user.',
        );
      }
    } catch (e) {
      
      return BlockUserResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static MessagesResponse _parseMessagesResponse(Map<String, dynamic> json) {
    List<Message> messages = [];

    try {
      if (json['data'] != null) {
        if (json['data']['messages'] != null) {
          for (var item in json['data']['messages']) {
            try {
              messages.add(_parseMessage(item));
            } catch (e) {
              
            }
          }
        } else if (json['data'] is List) {
          for (var item in json['data']) {
            try {
              messages.add(_parseMessage(item));
            } catch (e) {
              
            }
          }
        }
      }
    } catch (e) {
      
    }

    return MessagesResponse(
      success: json['success'] ?? false,
      messages: messages,
    );
  }

  static Message _parseMessage(Map<String, dynamic> json) {
    try {
      DateTime createdAt = DateTime.now();
      if (json['created_at'] != null) {
        final parsed = DateTime.tryParse(json['created_at'].toString());
        if (parsed != null) {
          createdAt = parsed.toLocal();
        }
      }
      
      
      
      return Message(
        id: json['id']?.toString() ?? '',
        text: json['message'] ?? json['text'] ?? '',
        senderId: json['sender_id'] ?? 0,
        createdAt: createdAt,
        isRead: json['is_read'] == true || json['read_at'] != null,
        isMine: json['is_mine'] == true,
      );
    } catch (e) {
      
      return Message(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Unable to load message',
        senderId: 0,
        createdAt: DateTime.now(),
        isRead: false,
        isMine: false,
      );
    }
  }
}

class MessagesResponse {
  final bool success;
  final List<Message> messages;

  MessagesResponse({
    required this.success,
    required this.messages,
  });
}

class Message {
  final String id;
  final String text;
  final int senderId;
  final DateTime createdAt;
  final bool isRead;
  final bool isMine;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.createdAt,
    this.isRead = false,
    this.isMine = false,
  });
}


class AllChatsResponse {
  final bool success;
  final String message;
  final List<ChatConversation> chats;
  final ChatPagination? pagination;

  AllChatsResponse({
    required this.success,
    required this.message,
    this.chats = const [],
    this.pagination,
  });

  factory AllChatsResponse.fromJson(Map<String, dynamic> json) {
    return AllChatsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      chats: json['data']?['chats'] != null
          ? (json['data']['chats'] as List)
              .map((item) => ChatConversation.fromJson(item))
              .toList()
          : (json['data'] is List
              ? (json['data'] as List)
                  .map((item) => ChatConversation.fromJson(item))
                  .toList()
              : []),
      pagination: json['data']?['pagination'] != null
          ? ChatPagination.fromJson(json['data']['pagination'])
          : (json['pagination'] != null
              ? ChatPagination.fromJson(json['pagination'])
              : null),
    );
  }
}

class ChatConversation {
  final int id;
  final int? bookingId;
  final ChatParticipant? otherUser;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final int unreadCount;
  final bool isBlocked;

  ChatConversation({
    required this.id,
    this.bookingId,
    this.otherUser,
    this.lastMessage,
    this.lastMessageAt,
    required this.unreadCount,
    required this.isBlocked,
  });

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'],
      otherUser: json['other_user'] != null
          ? ChatParticipant.fromJson(json['other_user'])
          : null,
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.tryParse(json['last_message_at'].toString())
          : null,
      unreadCount: json['unread_count'] ?? 0,
      isBlocked: json['is_blocked'] == true,
    );
  }
}

class ChatParticipant {
  final int id;
  final String? name;
  final String? profilePhoto;
  final bool isOnline;
  final DateTime? lastSeen;

  ChatParticipant({
    required this.id,
    this.name,
    this.profilePhoto,
    required this.isOnline,
    this.lastSeen,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] ?? 0,
      name: json['name'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      isOnline: json['is_online'] == true,
      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'].toString())
          : null,
    );
  }
}

class ChatPagination {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ChatPagination({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ChatPagination.fromJson(Map<String, dynamic> json) {
    return ChatPagination(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 15,
      total: json['total'] ?? 0,
    );
  }
}

class UnreadCountResponse {
  final bool success;
  final String message;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    required this.message,
    this.unreadCount = 0,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      unreadCount: json['data']?['unread_count'] ?? json['unread_count'] ?? 0,
    );
  }
}

class BlockedUsersResponse {
  final bool success;
  final String message;
  final List<BlockedUser> blockedUsers;

  BlockedUsersResponse({
    required this.success,
    required this.message,
    this.blockedUsers = const [],
  });

  factory BlockedUsersResponse.fromJson(Map<String, dynamic> json) {
    return BlockedUsersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      blockedUsers: json['data']?['blocked_users'] != null
          ? (json['data']['blocked_users'] as List)
              .map((item) => BlockedUser.fromJson(item))
              .toList()
          : (json['data'] is List
              ? (json['data'] as List)
                  .map((item) => BlockedUser.fromJson(item))
                  .toList()
              : []),
    );
  }
}

class BlockedUser {
  final int id;
  final String? name;
  final String? profilePhoto;
  final DateTime? blockedAt;

  BlockedUser({
    required this.id,
    this.name,
    this.profilePhoto,
    this.blockedAt,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? 0,
      name: json['name'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      blockedAt: json['blocked_at'] != null
          ? DateTime.tryParse(json['blocked_at'].toString())
          : null,
    );
  }
}

class StartChatResponse {
  final bool success;
  final String message;
  final int? chatId;
  final int? bookingId;
  final ChatParticipant? otherUser;

  StartChatResponse({
    required this.success,
    required this.message,
    this.chatId,
    this.bookingId,
    this.otherUser,
  });

  factory StartChatResponse.fromJson(Map<String, dynamic> json) {
    return StartChatResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      chatId: json['data']?['chat_id'] ?? json['data']?['id'],
      bookingId: json['data']?['booking_id'],
      otherUser: json['data']?['other_user'] != null
          ? ChatParticipant.fromJson(json['data']['other_user'])
          : null,
    );
  }
}

class DeleteMessageResponse {
  final bool success;
  final String message;

  DeleteMessageResponse({
    required this.success,
    required this.message,
  });

  factory DeleteMessageResponse.fromJson(Map<String, dynamic> json) {
    return DeleteMessageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class BlockUserResponse {
  final bool success;
  final String message;
  final bool? isBlocked;

  BlockUserResponse({
    required this.success,
    required this.message,
    this.isBlocked,
  });

  factory BlockUserResponse.fromJson(Map<String, dynamic> json) {
    return BlockUserResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      isBlocked: json['data']?['is_blocked'],
    );
  }
}
