import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

/// CoupleActivityService handles couple activity requests and partnerships
/// Endpoints: /api/v1/couple-activity/*
class CoupleActivityService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Helper to parse boolean from various formats
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET REQUESTS - Get list of couple activity requests
  // Endpoint: GET /api/v1/couple-activity/requests
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityRequestsResponse> getRequests({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityRequestsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/requests?page=$page';

      print('========== GET Couple Activity Requests ==========');
      print('URL: $url');
      print('==================================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Couple Activity Requests Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('============================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CoupleActivityRequestsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityRequestsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return CoupleActivityRequestsResponse(
          success: false,
          message: 'Failed to get couple activity requests.',
        );
      }
    } catch (e) {
      print('GET Couple Activity Requests Error: $e');
      return CoupleActivityRequestsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SEND REQUEST - Send a couple activity request to another user
  // Endpoint: POST /api/v1/couple-activity/request
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> sendRequest(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/request';
      final body = {'user_id': userId};

      print('========== POST Send Couple Activity Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('========================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== POST Send Couple Activity Request Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot send request to this user.',
        );
      } else if (response.statusCode == 422) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid request.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to send request.',
        );
      }
    } catch (e) {
      print('POST Send Couple Activity Request Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCEPT REQUEST - Accept a couple activity request
  // Endpoint: POST /api/v1/couple-activity/request/{id}/accept
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> acceptRequest(int requestId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/request/$requestId/accept';

      print('========== POST Accept Couple Activity Request ==========');
      print('URL: $url');
      print('==========================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Accept Couple Activity Request Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Request not found.',
        );
      } else if (response.statusCode == 400) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot accept this request.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to accept request.',
        );
      }
    } catch (e) {
      print('POST Accept Couple Activity Request Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REJECT REQUEST - Reject a couple activity request
  // Endpoint: POST /api/v1/couple-activity/request/{id}/reject
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> rejectRequest(int requestId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/request/$requestId/reject';

      print('========== POST Reject Couple Activity Request ==========');
      print('URL: $url');
      print('==========================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Reject Couple Activity Request Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Request not found.',
        );
      } else if (response.statusCode == 400) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot reject this request.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reject request.',
        );
      }
    } catch (e) {
      print('POST Reject Couple Activity Request Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CANCEL REQUEST - Cancel a sent couple activity request
  // Endpoint: DELETE /api/v1/couple-activity/request/{id}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> cancelRequest(int requestId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/request/$requestId';

      print('========== DELETE Cancel Couple Activity Request ==========');
      print('URL: $url');
      print('============================================================');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== DELETE Cancel Couple Activity Request Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=====================================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Request not found.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel request.',
        );
      }
    } catch (e) {
      print('DELETE Cancel Couple Activity Request Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET PARTNERSHIP - Get current partnership details
  // Endpoint: GET /api/v1/couple-activity/partnership
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<PartnershipResponse> getPartnership() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return PartnershipResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/partnership';

      print('========== GET Partnership ==========');
      print('URL: $url');
      print('=====================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Partnership Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===============================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PartnershipResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return PartnershipResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return PartnershipResponse(
          success: false,
          message: 'No active partnership found.',
        );
      } else {
        return PartnershipResponse(
          success: false,
          message: 'Failed to get partnership details.',
        );
      }
    } catch (e) {
      print('GET Partnership Error: $e');
      return PartnershipResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // END PARTNERSHIP - End current partnership
  // Endpoint: DELETE /api/v1/couple-activity/partnership
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> endPartnership() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/partnership';

      print('========== DELETE End Partnership ==========');
      print('URL: $url');
      print('============================================');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== DELETE End Partnership Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('======================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'No active partnership to end.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to end partnership.',
        );
      }
    } catch (e) {
      print('DELETE End Partnership Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BLOCK USER - Block a user from couple activity
  // Endpoint: POST /api/v1/couple-activity/block/{userId}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> blockUser(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/block/$userId';

      print('========== POST Block User ==========');
      print('URL: $url');
      print('=====================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Block User Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===============================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot block this user.',
        );
      } else if (response.statusCode == 404) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to block user.',
        );
      }
    } catch (e) {
      print('POST Block User Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UNBLOCK USER - Unblock a user from couple activity
  // Endpoint: DELETE /api/v1/couple-activity/block/{userId}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityActionResponse> unblockUser(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/block/$userId';

      print('========== DELETE Unblock User ==========');
      print('URL: $url');
      print('=========================================');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== DELETE Unblock User Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CoupleActivityActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found or not blocked.',
        );
      } else {
        return CoupleActivityActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to unblock user.',
        );
      }
    } catch (e) {
      print('DELETE Unblock User Error: $e');
      return CoupleActivityActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET HISTORY - Get couple activity history
  // Endpoint: GET /api/v1/couple-activity/history
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CoupleActivityHistoryResponse> getHistory({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CoupleActivityHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/history?page=$page';

      print('========== GET Couple Activity History ==========');
      print('URL: $url');
      print('=================================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Couple Activity History Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===========================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CoupleActivityHistoryResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CoupleActivityHistoryResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return CoupleActivityHistoryResponse(
          success: false,
          message: 'Failed to get couple activity history.',
        );
      }
    } catch (e) {
      print('GET Couple Activity History Error: $e');
      return CoupleActivityHistoryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET BLOCKED USERS - Get list of blocked users
  // Endpoint: GET /api/v1/couple-activity/blocked
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<BlockedUsersResponse> getBlockedUsers({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return BlockedUsersResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/couple-activity/blocked?page=$page';

      print('========== GET Blocked Users ==========');
      print('URL: $url');
      print('=======================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Blocked Users Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BlockedUsersResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BlockedUsersResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return BlockedUsersResponse(
          success: false,
          message: 'Failed to get blocked users.',
        );
      }
    } catch (e) {
      print('GET Blocked Users Error: $e');
      return BlockedUsersResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Response for couple activity requests list
class CoupleActivityRequestsResponse {
  final bool success;
  final String message;
  final List<CoupleActivityRequest> data;
  final CoupleActivityPaginationMeta? pagination;

  CoupleActivityRequestsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory CoupleActivityRequestsResponse.fromJson(Map<String, dynamic> json) {
    return CoupleActivityRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => CoupleActivityRequest.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? CoupleActivityPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Couple activity request model
class CoupleActivityRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String status; // 'pending', 'accepted', 'rejected', 'cancelled'
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

/// User model for couple activity
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
      age: json['age'],
      gender: json['gender'],
      city: json['city'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
    );
  }
}

/// Response for couple activity actions (accept, reject, cancel, block, unblock)
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

/// Response for partnership details
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

/// Partnership model
class Partnership {
  final int id;
  final int user1Id;
  final int user2Id;
  final String status; // 'active', 'ended'
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
      totalEarnings: json['total_earnings'] != null
          ? (json['total_earnings']).toDouble()
          : null,
    );
  }
}

/// Response for couple activity history
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

/// Couple activity history item
class CoupleActivityHistoryItem {
  final int id;
  final String type; // 'request', 'partnership', 'booking'
  final String action; // 'sent', 'received', 'accepted', 'rejected', 'cancelled', 'started', 'ended'
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

/// Response for blocked users list
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

/// Blocked user model
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

/// Pagination metadata for couple activity
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
