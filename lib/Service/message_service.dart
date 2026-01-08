import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class MessageService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<MessagesResponse?> getMessages(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/chat/booking/$bookingId/messages';
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
        final json = jsonDecode(response.body);
        return _parseMessagesResponse(json);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        
        return null;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get messages');
        
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      if (e.toString().contains('FormatException')) {
        
      }
      return null;
    }
  }

  static Future<Message?> sendMessage(int bookingId, String messageText) async {
    final url = '${ApiConstants.baseUrl}/chat/booking/$bookingId/send';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final body = {'message': messageText};
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

      
      
      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final json = jsonDecode(response.body);
        if (json['success'] == true && json['data'] != null && json['data']['message'] != null) {
          return _parseMessage(json['data']['message']);
        }
        return null;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to send message');
        
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return null;
    }
  }

  static Future<bool> markAsRead(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/chat/booking/$bookingId/mark-read';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return false;
      }

      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return true;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to mark as read');
        return false;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return false;
    }
  }

  static Future<AllChatsResponse?> getAllChats({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/chat?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return AllChatsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return AllChatsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return AllChatsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get chats');
        final responseData = jsonDecode(response.body);
        return AllChatsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get chats.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return AllChatsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<UnreadCountResponse?> getUnreadCount() async {
    final url = '${ApiConstants.baseUrl}/chat/unread-count';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return UnreadCountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return UnreadCountResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return UnreadCountResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get unread count');
        final responseData = jsonDecode(response.body);
        return UnreadCountResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get unread count.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return UnreadCountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BlockedUsersResponse?> getBlockedUsers() async {
    final url = '${ApiConstants.baseUrl}/chat/blocked-users';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BlockedUsersResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return BlockedUsersResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return BlockedUsersResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get blocked users');
        final responseData = jsonDecode(response.body);
        return BlockedUsersResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get blocked users.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return BlockedUsersResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<StartChatResponse?> startChat(int userId) async {
    final url = '${ApiConstants.baseUrl}/chat/start/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return StartChatResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      
      
      
      
      
      
      

      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return StartChatResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return StartChatResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: 403, error: 'Cannot start chat with this user');
        return StartChatResponse(
          success: false,
          message: 'You cannot start a chat with this user.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found');
        return StartChatResponse(
          success: false,
          message: 'User not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to start chat');
        final responseData = jsonDecode(response.body);
        return StartChatResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to start chat.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return StartChatResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<DeleteMessageResponse?> deleteMessage(int messageId) async {
    final url = '${ApiConstants.baseUrl}/chat/message/$messageId';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return DeleteMessageResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      
      
      
      
      
      
      

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return DeleteMessageResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return DeleteMessageResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: 403, error: 'Can only delete own messages');
        return DeleteMessageResponse(
          success: false,
          message: 'You can only delete your own messages.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Message not found');
        return DeleteMessageResponse(
          success: false,
          message: 'Message not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to delete message');
        final responseData = jsonDecode(response.body);
        return DeleteMessageResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to delete message.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return DeleteMessageResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BlockUserResponse?> blockUser(int userId, {String reason = ''}) async {
    final url = '${ApiConstants.baseUrl}/chat/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BlockUserResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {'reason': reason};
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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BlockUserResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return BlockUserResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found');
        return BlockUserResponse(
          success: false,
          message: 'User not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to block user');
        final responseData = jsonDecode(response.body);
        return BlockUserResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to block user.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
      return BlockUserResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BlockUserResponse?> unblockUser(int userId) async {
    final url = '${ApiConstants.baseUrl}/chat/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BlockUserResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      
      
      
      
      
      
      

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BlockUserResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return BlockUserResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found or not blocked');
        return BlockUserResponse(
          success: false,
          message: 'User not found or not blocked.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to unblock user');
        final responseData = jsonDecode(response.body);
        return BlockUserResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to unblock user.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      
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

  // REMOVED: sendTypingStatus() - Endpoint /chat/booking/{bookingId}/typing does NOT exist in API documentation.
  // REMOVED: getTypingStatus() - Endpoint /chat/booking/{bookingId}/typing does NOT exist in API documentation.
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

// FIX: Removed TypingStatusResponse class - API endpoint /chat/booking/{bookingId}/typing
// does not exist in API documentation (Section 11: Chat Routes)
