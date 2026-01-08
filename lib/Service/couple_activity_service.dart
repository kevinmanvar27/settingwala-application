import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class CoupleActivityService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Future<CoupleActivityRequestsResponse> getRequests({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/requests?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityRequestsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        return CoupleActivityRequestsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityRequestsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get couple activity requests');
        return CoupleActivityRequestsResponse(
          success: false,
          message: 'Failed to get couple activity requests.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityRequestsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> sendRequest(int userId) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/request';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {'user_id': userId};

      // Log API call with body
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

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Cannot send request to this user');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot send request to this user.',
        );
      } else if (response.statusCode == 422) {
        ApiLogger.logApiError(endpoint: url, statusCode: 422, error: 'Invalid request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid request.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to send request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to send request.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> acceptRequest(int requestId) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/request/$requestId/accept';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Request not found');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Request not found.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Cannot accept this request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot accept this request.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to accept request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to accept request.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> rejectRequest(int requestId) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/request/$requestId/reject';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Request not found');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Request not found.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Cannot reject this request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot reject this request.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to reject request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reject request.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> cancelRequest(int requestId) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/request/$requestId';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Request not found');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Request not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to cancel request');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel request.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<PartnershipResponse> getPartnership() async {
    final url = '${ApiConstants.baseUrl}/couple-activity/partnership';
    try {
      final token = await _getToken();

      if (token == null) {
        return PartnershipResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        return PartnershipResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return PartnershipResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'No active partnership found');
        return PartnershipResponse(
          success: false,
          message: 'No active partnership found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get partnership details');
        return PartnershipResponse(
          success: false,
          message: 'Failed to get partnership details.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return PartnershipResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> endPartnership() async {
    final url = '${ApiConstants.baseUrl}/couple-activity/partnership';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'No active partnership to end');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'No active partnership to end.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to end partnership');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to end partnership.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> blockUser(int userId) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Cannot block this user');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot block this user.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to block user');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to block user.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityActionResponse> unblockUser(int userId) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/block/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found or not blocked');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found or not blocked.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to unblock user');
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to unblock user.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CoupleActivityHistoryResponse> getHistory({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/couple-activity/history?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        return CoupleActivityHistoryResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return CoupleActivityHistoryResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get couple activity history');
        return CoupleActivityHistoryResponse(
          success: false,
          message: 'Failed to get couple activity history.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CoupleActivityHistoryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // REMOVED: getBlockedUsers() - Endpoint /couple-activity/blocked does NOT exist. Use ChatService.getBlockedUsers() instead.
}


/// FIX: API Section 14.1 returns separate 'sent_requests' and 'received_requests' arrays
class CoupleActivityRequestsResponse {
  final bool success;
  final String message;
  final List<CoupleActivityRequest> sentRequests;
  final List<CoupleActivityRequest> receivedRequests;
  final CoupleActivityPaginationMeta? pagination;

  CoupleActivityRequestsResponse({
    required this.success,
    required this.message,
    this.sentRequests = const [],
    this.receivedRequests = const [],
    this.pagination,
  });

  /// Getter for backward compatibility - returns combined list
  List<CoupleActivityRequest> get data => [...sentRequests, ...receivedRequests];

  factory CoupleActivityRequestsResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = json['data'] as Map<String, dynamic>?;
    return CoupleActivityRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      sentRequests: dataMap?['sent_requests'] != null
          ? (dataMap!['sent_requests'] as List)
              .map((item) => CoupleActivityRequest.fromJson(item))
              .toList()
          : [],
      receivedRequests: dataMap?['received_requests'] != null
          ? (dataMap!['received_requests'] as List)
              .map((item) => CoupleActivityRequest.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? CoupleActivityPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class CoupleActivityRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final String? createdAt;
  final String? updatedAt;
  final CoupleActivityUser? sender;
  final CoupleActivityUser? receiver;

  CoupleActivityRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.sender,
    this.receiver,
  });

  factory CoupleActivityRequest.fromJson(Map<String, dynamic> json) {
    return CoupleActivityRequest(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      status: json['status'] ?? 'pending',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      sender: json['sender'] != null
          ? CoupleActivityUser.fromJson(json['sender'])
          : null,
      receiver: json['receiver'] != null
          ? CoupleActivityUser.fromJson(json['receiver'])
          : null,
    );
  }
}

class CoupleActivityUser {
  final int id;
  final String? name;
  final String? email;
  final String? profilePhoto;
  final int? age;
  final String? gender;
  final String? city;
  final double? rating;

  CoupleActivityUser({
    required this.id,
    this.name,
    this.email,
    this.profilePhoto,
    this.age,
    this.gender,
    this.city,
    this.rating,
  });

  factory CoupleActivityUser.fromJson(Map<String, dynamic> json) {
    return CoupleActivityUser(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      age: json['age'] != null ? (json['age'] is int ? json['age'] : (json['age'] as num).toInt()) : null,
      gender: json['gender'],
      city: json['city'],
      rating: CoupleActivityService._parseDouble(json['rating']),
    );
  }
}

class CoupleActivityActionResponse {
  final bool success;
  final String message;
  final CoupleActivityRequest? data;

  CoupleActivityActionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CoupleActivityActionResponse.fromJson(Map<String, dynamic> json) {
    return CoupleActivityActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? CoupleActivityRequest.fromJson(json['data'])
          : null,
    );
  }
}

class PartnershipResponse {
  final bool success;
  final String message;
  final Partnership? data;

  PartnershipResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PartnershipResponse.fromJson(Map<String, dynamic> json) {
    return PartnershipResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Partnership.fromJson(json['data']) : null,
    );
  }
}

class Partnership {
  final int id;
  final int user1Id;
  final int user2Id;
  final String status;
  final String? startedAt;
  final String? endedAt;
  final CoupleActivityUser? partner;
  final int? totalBookings;
  final double? totalEarnings;

  Partnership({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    required this.status,
    this.startedAt,
    this.endedAt,
    this.partner,
    this.totalBookings,
    this.totalEarnings,
  });

  factory Partnership.fromJson(Map<String, dynamic> json) {
    return Partnership(
      id: json['id'] ?? 0,
      user1Id: json['user1_id'] ?? json['user_1_id'] ?? 0,
      user2Id: json['user2_id'] ?? json['user_2_id'] ?? 0,
      status: json['status'] ?? 'active',
      startedAt: json['started_at'] ?? json['created_at'],
      endedAt: json['ended_at'],
      partner: json['partner'] != null
          ? CoupleActivityUser.fromJson(json['partner'])
          : null,
      totalBookings: json['total_bookings'],
      totalEarnings: CoupleActivityService._parseDouble(json['total_earnings']),
    );
  }
}

class CoupleActivityHistoryResponse {
  final bool success;
  final String message;
  final List<CoupleActivityHistoryItem> data;
  final CoupleActivityPaginationMeta? pagination;

  CoupleActivityHistoryResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory CoupleActivityHistoryResponse.fromJson(Map<String, dynamic> json) {
    return CoupleActivityHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => CoupleActivityHistoryItem.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? CoupleActivityPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class CoupleActivityHistoryItem {
  final int id;
  final String type;
  final String action;
  final String? description;
  final String? createdAt;
  final CoupleActivityUser? relatedUser;
  final Map<String, dynamic>? metadata;

  CoupleActivityHistoryItem({
    required this.id,
    required this.type,
    required this.action,
    this.description,
    this.createdAt,
    this.relatedUser,
    this.metadata,
  });

  factory CoupleActivityHistoryItem.fromJson(Map<String, dynamic> json) {
    return CoupleActivityHistoryItem(
      id: json['id'] ?? 0,
      type: json['type'] ?? '',
      action: json['action'] ?? '',
      description: json['description'],
      createdAt: json['created_at'],
      relatedUser: json['related_user'] != null
          ? CoupleActivityUser.fromJson(json['related_user'])
          : null,
      metadata: json['metadata'],
    );
  }
}

class BlockedUsersResponse {
  final bool success;
  final String message;
  final List<BlockedUser> data;
  final CoupleActivityPaginationMeta? pagination;

  BlockedUsersResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory BlockedUsersResponse.fromJson(Map<String, dynamic> json) {
    return BlockedUsersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => BlockedUser.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? CoupleActivityPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class BlockedUser {
  final int id;
  final int blockedUserId;
  final String? blockedAt;
  final CoupleActivityUser? user;

  BlockedUser({
    required this.id,
    required this.blockedUserId,
    this.blockedAt,
    this.user,
  });

  factory BlockedUser.fromJson(Map<String, dynamic> json) {
    return BlockedUser(
      id: json['id'] ?? 0,
      blockedUserId: json['blocked_user_id'] ?? 0,
      blockedAt: json['blocked_at'] ?? json['created_at'],
      user: json['user'] != null
          ? CoupleActivityUser.fromJson(json['user'])
          : null,
    );
  }
}

class CoupleActivityPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  CoupleActivityPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory CoupleActivityPaginationMeta.fromJson(Map<String, dynamic> json) {
    return CoupleActivityPaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
