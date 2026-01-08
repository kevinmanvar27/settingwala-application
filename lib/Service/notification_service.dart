import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/GetnotificatonsModel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';


class UnreadCountResponse {
  final bool success;
  final int unreadCount;

  UnreadCountResponse({
    required this.success,
    required this.unreadCount,
  });

  factory UnreadCountResponse.fromJson(Map<String, dynamic> json) {
    return UnreadCountResponse(
      success: json['success'] ?? false,
      unreadCount: json['data']?['unread_count'] ?? 0,
    );
  }
}

class MarkAllReadResponse {
  final bool success;
  final String message;
  final int markedCount;

  MarkAllReadResponse({
    required this.success,
    required this.message,
    required this.markedCount,
  });

  factory MarkAllReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkAllReadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      markedCount: json['data']?['marked_count'] ?? 0,
    );
  }
}

class ClearAllNotificationsResponse {
  final bool success;
  final String message;
  final int deletedCount;

  ClearAllNotificationsResponse({
    required this.success,
    required this.message,
    required this.deletedCount,
  });

  factory ClearAllNotificationsResponse.fromJson(Map<String, dynamic> json) {
    return ClearAllNotificationsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      deletedCount: json['data']?['deleted_count'] ?? 0,
    );
  }
}

class NotificationPreferences {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool bookingNotifications;
  final bool chatNotifications;
  final bool paymentNotifications;
  final bool promotionalNotifications;

  NotificationPreferences({
    required this.pushEnabled,
    required this.emailEnabled,
    required this.bookingNotifications,
    required this.chatNotifications,
    required this.paymentNotifications,
    required this.promotionalNotifications,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      pushEnabled: json['push_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      bookingNotifications: json['booking_notifications'] ?? true,
      chatNotifications: json['chat_notifications'] ?? true,
      paymentNotifications: json['payment_notifications'] ?? true,
      promotionalNotifications: json['promotional_notifications'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'booking_notifications': bookingNotifications,
      'chat_notifications': chatNotifications,
      'payment_notifications': paymentNotifications,
      'promotional_notifications': promotionalNotifications,
    };
  }
}

class GetPreferencesResponse {
  final bool success;
  final NotificationPreferences preferences;

  GetPreferencesResponse({
    required this.success,
    required this.preferences,
  });

  factory GetPreferencesResponse.fromJson(Map<String, dynamic> json) {
    return GetPreferencesResponse(
      success: json['success'] ?? false,
      preferences: NotificationPreferences.fromJson(json['data']?['preferences'] ?? {}),
    );
  }
}

class UpdatePreferencesResponse {
  final bool success;
  final String message;
  final NotificationPreferences preferences;

  UpdatePreferencesResponse({
    required this.success,
    required this.message,
    required this.preferences,
  });

  factory UpdatePreferencesResponse.fromJson(Map<String, dynamic> json) {
    return UpdatePreferencesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      preferences: NotificationPreferences.fromJson(json['data']?['preferences'] ?? {}),
    );
  }
}

class MarkAsReadResponse {
  final bool success;
  final String message;

  MarkAsReadResponse({
    required this.success,
    required this.message,
  });

  factory MarkAsReadResponse.fromJson(Map<String, dynamic> json) {
    return MarkAsReadResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class DeleteNotificationResponse {
  final bool success;
  final String message;

  DeleteNotificationResponse({
    required this.success,
    required this.message,
  });

  factory DeleteNotificationResponse.fromJson(Map<String, dynamic> json) {
    return DeleteNotificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class FcmTokenResponse {
  final bool success;
  final String message;

  FcmTokenResponse({
    required this.success,
    required this.message,
  });

  factory FcmTokenResponse.fromJson(Map<String, dynamic> json) {
    return FcmTokenResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}


class NotificationService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetnotificationsModel?> getNotifications({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/notifications?page=$page';
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
        final result = _parseNotificationsResponse(json);
        return result;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static GetnotificationsModel _parseNotificationsResponse(Map<String, dynamic> json) {
    List<NotificationItem> notifications = [];
    
    
    
    
    
    if (json['data']?['notifications'] != null) {
      final notificationsList = json['data']['notifications'];
      
      
      for (var item in notificationsList) {
        try {
          notifications.add(NotificationItem(
            id: item['id'] ?? 0,
            type: item['type'] ?? '',
            title: item['title'] ?? '',
            message: item['message'] ?? '',
            data: _parseNotificationData(item['data']),
            readAt: item['read_at'] != null 
                ? DateTime.tryParse(item['read_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
            createdAt: item['created_at'] != null 
                ? DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now()
                : DateTime.now(),
          ));
        } catch (e) {
          
          
        }
      }
    }

    final paginationJson = json['data']?['pagination'];
    Pagination pagination = Pagination(
      currentPage: paginationJson?['current_page'] ?? 1,
      lastPage: paginationJson?['last_page'] ?? 1,
      perPage: paginationJson?['per_page'] ?? 10,
      total: paginationJson?['total'] ?? 0,
    );

    return GetnotificationsModel(
      success: json['success'] ?? false,
      data: GetnotificationsModelData(
        notifications: notifications,
        pagination: pagination,
      ),
    );
  }

  static NotificationData _parseNotificationData(dynamic json) {
    if (json == null) {
      return NotificationData(
        bookingId: 0,
        clientId: 0,
        providerId: 0,
        amount: '',
        durationHours: '',
        date: DateTime.now(),
        meetingLocation: '',
        notes: '',
      );
    }

    if (json is Map<String, dynamic>) {
      return NotificationData(
        bookingId: json['booking_id'] ?? 0,
        clientId: json['client_id'] ?? 0,
        providerId: json['provider_id'] ?? 0,
        amount: json['amount']?.toString() ?? '',
        durationHours: json['duration_hours']?.toString() ?? '',
        date: json['date'] != null 
            ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
            : DateTime.now(),
        meetingLocation: json['meeting_location'] ?? '',
        notes: json['notes'] ?? '',
        providerName: json['provider_name'],
        paymentStatus: json['payment_status'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        status: json['status'],
        providerStatus: json['provider_status'],

      );
    }

    return NotificationData(
      bookingId: 0,
      clientId: 0,
      providerId: 0,
      amount: '',
      durationHours: '',
      date: DateTime.now(),
      meetingLocation: '',
      notes: '',
    );
  }


  static Future<UnreadCountResponse?> getUnreadCount() async {
    final url = '${ApiConstants.baseUrl}/notifications/unread-count';
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
        final result = UnreadCountResponse.fromJson(json);
        return result;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<MarkAllReadResponse?> markAllAsRead() async {
    final url = '${ApiConstants.baseUrl}/notifications/mark-all-read';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final json = jsonDecode(response.body);
        final result = MarkAllReadResponse.fromJson(json);
        return result;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<ClearAllNotificationsResponse?> clearAll() async {
    final url = '${ApiConstants.baseUrl}/notifications/clear-all';
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
        final json = jsonDecode(response.body);
        final result = ClearAllNotificationsResponse.fromJson(json);
        return result;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<GetPreferencesResponse?> getPreferences() async {
    final url = '${ApiConstants.baseUrl}/notifications/preferences';
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
        final result = GetPreferencesResponse.fromJson(json);
        return result;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<UpdatePreferencesResponse?> updatePreferences({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? bookingNotifications,
    bool? chatNotifications,
    bool? paymentNotifications,
    bool? promotionalNotifications,
  }) async {
    final url = '${ApiConstants.baseUrl}/notifications/preferences';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // FIX: API expects 'push_notifications' and 'email_notifications' (API Section 12.6)
      final Map<String, dynamic> body = {};
      if (pushEnabled != null) body['push_notifications'] = pushEnabled;
      if (emailEnabled != null) body['email_notifications'] = emailEnabled;
      if (bookingNotifications != null) body['booking_notifications'] = bookingNotifications;
      if (chatNotifications != null) body['chat_notifications'] = chatNotifications;
      if (paymentNotifications != null) body['payment_notifications'] = paymentNotifications;
      if (promotionalNotifications != null) body['promotional_notifications'] = promotionalNotifications;

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      final response = await http.put(
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
        final result = UpdatePreferencesResponse.fromJson(json);
        return result;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<MarkAsReadResponse?> markAsRead(int notificationId) async {
    final url = '${ApiConstants.baseUrl}/notifications/$notificationId/mark-read';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final json = jsonDecode(response.body);
        final result = MarkAsReadResponse.fromJson(json);
        return result;
      } else if (response.statusCode == 404) {
        // API call નિષ્ફળ થઈ - Not found
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Notification not found');
        return null;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<DeleteNotificationResponse?> deleteNotification(int notificationId) async {
    final url = '${ApiConstants.baseUrl}/notifications/$notificationId';
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
        final json = jsonDecode(response.body);
        final result = DeleteNotificationResponse.fromJson(json);
        return result;
      } else if (response.statusCode == 404) {
        // API call નિષ્ફળ થઈ - Not found
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Notification not found');
        return null;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<FcmTokenResponse?> registerFcmToken({
    required String token,
    required String deviceType,
    String? deviceId,
  }) async {
    final url = '${ApiConstants.baseUrl}/notifications/fcm-token';
    try {
      final authToken = await _getToken();

      if (authToken == null) {
        return null;
      }

      // FIX: API expects 'fcm_token' not 'token' (API Section 12.7)
      final Map<String, dynamic> body = {
        'fcm_token': token,
        'device_type': deviceType,
      };
      if (deviceId != null && deviceId.isNotEmpty) {
        body['device_id'] = deviceId;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'device_type': deviceType});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final json = jsonDecode(response.body);
        final result = FcmTokenResponse.fromJson(json);
        return result;
      } else if (response.statusCode == 422) {
        // API call નિષ્ફળ થઈ - Validation error
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Validation error');
        return null;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<FcmTokenResponse?> removeFcmToken({
    required String token,
  }) async {
    final url = '${ApiConstants.baseUrl}/notifications/fcm-token';
    try {
      final authToken = await _getToken();

      if (authToken == null) {
        return null;
      }

      // FIX: API expects 'fcm_token' not 'token' (API Section 12.8)
      final Map<String, dynamic> body = {
        'fcm_token': token,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final json = jsonDecode(response.body);
        final result = FcmTokenResponse.fromJson(json);
        return result;
      } else if (response.statusCode == 422) {
        // API call નિષ્ફળ થઈ - Validation error
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Validation error');
        return null;
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }
}
