import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

/// SugarPartnerService handles sugar partner exchanges and payments
/// Endpoints: /api/v1/sugar-partner/*
class SugarPartnerService {
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
  // GET EXCHANGES - Get list of sugar partner exchanges
  // Endpoint: GET /api/v1/sugar-partner/exchanges
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerExchangesResponse> getExchanges({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchanges?page=$page';

      print('========== GET Sugar Partner Exchanges ==========');
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

      print('========== GET Sugar Partner Exchanges Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===========================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerExchangesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Failed to get exchanges.',
        );
      }
    } catch (e) {
      print('GET Sugar Partner Exchanges Error: $e');
      return SugarPartnerExchangesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET EXCHANGE DETAILS - Get details of a specific exchange
  // Endpoint: GET /api/v1/sugar-partner/exchange/{id}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerExchangeDetailsResponse> getExchangeDetails(int exchangeId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId';

      print('========== GET Exchange Details ==========');
      print('URL: $url');
      print('==========================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Exchange Details Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('====================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerExchangeDetailsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Exchange not found.',
        );
      } else {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Failed to get exchange details.',
        );
      }
    } catch (e) {
      print('GET Exchange Details Error: $e');
      return SugarPartnerExchangeDetailsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VIEW PROFILES - View profiles for an exchange (may require payment)
  // Endpoint: POST /api/v1/sugar-partner/exchange/{id}/view-profiles
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ViewProfilesResponse> viewProfiles(int exchangeId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ViewProfilesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/view-profiles';

      print('========== POST View Profiles ==========');
      print('URL: $url');
      print('========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST View Profiles Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ViewProfilesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ViewProfilesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 402) {
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Payment required to view profiles.',
          requiresPayment: true,
        );
      } else if (response.statusCode == 404) {
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else {
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to view profiles.',
        );
      }
    } catch (e) {
      print('POST View Profiles Error: $e');
      return ViewProfilesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // RESPOND TO EXCHANGE - Accept or reject an exchange
  // Endpoint: POST /api/v1/sugar-partner/exchange/{id}/respond
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerActionResponse> respondToExchange(
    int exchangeId, {
    required String action, // 'accept' or 'reject'
    String? message,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/respond';
      final body = {
        'action': action,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      print('========== POST Respond to Exchange ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('==============================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== POST Respond to Exchange Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('========================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot respond to this exchange.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else if (response.statusCode == 422) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid action.',
        );
      } else {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to respond to exchange.',
        );
      }
    } catch (e) {
      print('POST Respond to Exchange Error: $e');
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET EXCHANGE PAYMENT - Get payment details for an exchange
  // Endpoint: GET /api/v1/sugar-partner/exchange/{id}/payment
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ExchangePaymentResponse> getExchangePayment(int exchangeId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/payment';

      print('========== GET Exchange Payment ==========');
      print('URL: $url');
      print('==========================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Exchange Payment Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('====================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ExchangePaymentResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Exchange or payment not found.',
        );
      } else {
        return ExchangePaymentResponse(
          success: false,
          message: 'Failed to get payment details.',
        );
      }
    } catch (e) {
      print('GET Exchange Payment Error: $e');
      return ExchangePaymentResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET PENDING COUNT - Get count of pending exchanges
  // Endpoint: GET /api/v1/sugar-partner/pending-count
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<PendingCountResponse> getPendingCount() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return PendingCountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/pending-count';

      print('========== GET Pending Count ==========');
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

      print('========== GET Pending Count Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PendingCountResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return PendingCountResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return PendingCountResponse(
          success: false,
          message: 'Failed to get pending count.',
        );
      }
    } catch (e) {
      print('GET Pending Count Error: $e');
      return PendingCountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET HISTORY - Get sugar partner exchange history
  // Endpoint: GET /api/v1/sugar-partner/history
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerHistoryResponse> getHistory({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/history?page=$page';

      print('========== GET Sugar Partner History ==========');
      print('URL: $url');
      print('===============================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Sugar Partner History Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerHistoryResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Failed to get history.',
        );
      }
    } catch (e) {
      print('GET Sugar Partner History Error: $e');
      return SugarPartnerHistoryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET HARD REJECTS - Get list of hard rejected users
  // Endpoint: GET /api/v1/sugar-partner/hard-rejects
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<HardRejectsResponse> getHardRejects({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return HardRejectsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/hard-rejects?page=$page';

      print('========== GET Hard Rejects ==========');
      print('URL: $url');
      print('======================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Hard Rejects Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return HardRejectsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return HardRejectsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return HardRejectsResponse(
          success: false,
          message: 'Failed to get hard rejects.',
        );
      }
    } catch (e) {
      print('GET Hard Rejects Error: $e');
      return HardRejectsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ADD HARD REJECT - Add a user to hard reject list
  // Endpoint: POST /api/v1/sugar-partner/hard-reject/{userId}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerActionResponse> addHardReject(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/hard-reject/$userId';

      print('========== POST Add Hard Reject ==========');
      print('URL: $url');
      print('==========================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Add Hard Reject Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('====================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot hard reject this user.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found.',
        );
      } else {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add hard reject.',
        );
      }
    } catch (e) {
      print('POST Add Hard Reject Error: $e');
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REMOVE HARD REJECT - Remove a user from hard reject list
  // Endpoint: DELETE /api/v1/sugar-partner/hard-reject/{userId}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerActionResponse> removeHardReject(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/hard-reject/$userId';

      print('========== DELETE Remove Hard Reject ==========');
      print('URL: $url');
      print('===============================================');

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== DELETE Remove Hard Reject Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found in hard reject list.',
        );
      } else {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to remove hard reject.',
        );
      }
    } catch (e) {
      print('DELETE Remove Hard Reject Error: $e');
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET PAYMENTS - Get list of sugar partner payments
  // Endpoint: GET /api/v1/sugar-partner/payments
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SugarPartnerPaymentsResponse> getPayments({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/payments?page=$page';

      print('========== GET Sugar Partner Payments ==========');
      print('URL: $url');
      print('================================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Sugar Partner Payments Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==========================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerPaymentsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Failed to get payments.',
        );
      }
    } catch (e) {
      print('GET Sugar Partner Payments Error: $e');
      return SugarPartnerPaymentsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Response for sugar partner exchanges list
class SugarPartnerExchangesResponse {
  final bool success;
  final String message;
  final List<SugarPartnerExchange> data;
  final SugarPartnerPaginationMeta? pagination;

  SugarPartnerExchangesResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory SugarPartnerExchangesResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerExchangesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => SugarPartnerExchange.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Sugar partner exchange model
class SugarPartnerExchange {
  final int id;
  final int initiatorId;
  final int receiverId;
  final String status; // 'pending', 'accepted', 'rejected', 'expired', 'completed'
  final String? exchangeType;
  final double? amount;
  final String? message;
  final String? createdAt;
  final String? updatedAt;
  final String? expiresAt;
  final SugarPartnerUser? initiator;
  final SugarPartnerUser? receiver;
  final bool? profilesViewed;
  final bool? requiresPayment;

  SugarPartnerExchange({
    required this.id,
    required this.initiatorId,
    required this.receiverId,
    required this.status,
    this.exchangeType,
    this.amount,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.initiator,
    this.receiver,
    this.profilesViewed,
    this.requiresPayment,
  });

  factory SugarPartnerExchange.fromJson(Map<String, dynamic> json) {
    return SugarPartnerExchange(
      id: json['id'] ?? 0,
      initiatorId: json['initiator_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      status: json['status'] ?? 'pending',
      exchangeType: json['exchange_type'] ?? json['type'],
      amount: json['amount'] != null ? (json['amount']).toDouble() : null,
      message: json['message'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expiresAt: json['expires_at'],
      initiator: json['initiator'] != null
          ? SugarPartnerUser.fromJson(json['initiator'])
          : null,
      receiver: json['receiver'] != null
          ? SugarPartnerUser.fromJson(json['receiver'])
          : null,
      profilesViewed: SugarPartnerService._parseBool(json['profiles_viewed']),
      requiresPayment: SugarPartnerService._parseBool(json['requires_payment']),
    );
  }
}

/// User model for sugar partner
class SugarPartnerUser {
  final int id;
  final String? name;
  final String? email;
  final String? profilePhoto;
  final int? age;
  final String? gender;
  final String? city;
  final double? rating;
  final bool? isVerified;
  final String? bio;

  SugarPartnerUser({
    required this.id,
    this.name,
    this.email,
    this.profilePhoto,
    this.age,
    this.gender,
    this.city,
    this.rating,
    this.isVerified,
    this.bio,
  });

  factory SugarPartnerUser.fromJson(Map<String, dynamic> json) {
    return SugarPartnerUser(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      age: json['age'],
      gender: json['gender'],
      city: json['city'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      isVerified: SugarPartnerService._parseBool(json['is_verified']),
      bio: json['bio'],
    );
  }
}

/// Response for exchange details
class SugarPartnerExchangeDetailsResponse {
  final bool success;
  final String message;
  final SugarPartnerExchange? data;

  SugarPartnerExchangeDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SugarPartnerExchangeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerExchangeDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerExchange.fromJson(json['data'])
          : null,
    );
  }
}

/// Response for view profiles
class ViewProfilesResponse {
  final bool success;
  final String message;
  final List<SugarPartnerUser> profiles;
  final bool requiresPayment;
  final double? paymentAmount;

  ViewProfilesResponse({
    required this.success,
    required this.message,
    this.profiles = const [],
    this.requiresPayment = false,
    this.paymentAmount,
  });

  factory ViewProfilesResponse.fromJson(Map<String, dynamic> json) {
    return ViewProfilesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profiles: json['data']?['profiles'] != null
          ? (json['data']['profiles'] as List)
              .map((item) => SugarPartnerUser.fromJson(item))
              .toList()
          : (json['profiles'] != null
              ? (json['profiles'] as List)
                  .map((item) => SugarPartnerUser.fromJson(item))
                  .toList()
              : []),
      requiresPayment: SugarPartnerService._parseBool(json['requires_payment']),
      paymentAmount: json['payment_amount'] != null
          ? (json['payment_amount']).toDouble()
          : null,
    );
  }
}

/// Response for sugar partner actions
class SugarPartnerActionResponse {
  final bool success;
  final String message;
  final SugarPartnerExchange? data;

  SugarPartnerActionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SugarPartnerActionResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerExchange.fromJson(json['data'])
          : null,
    );
  }
}

/// Response for exchange payment
class ExchangePaymentResponse {
  final bool success;
  final String message;
  final SugarPartnerPayment? data;

  ExchangePaymentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ExchangePaymentResponse.fromJson(Map<String, dynamic> json) {
    return ExchangePaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerPayment.fromJson(json['data'])
          : null,
    );
  }
}

/// Sugar partner payment model
class SugarPartnerPayment {
  final int id;
  final int exchangeId;
  final int userId;
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String? paymentMethod;
  final String? transactionId;
  final String? createdAt;
  final String? completedAt;
  final Map<String, dynamic>? metadata;

  SugarPartnerPayment({
    required this.id,
    required this.exchangeId,
    required this.userId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory SugarPartnerPayment.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPayment(
      id: json['id'] ?? 0,
      exchangeId: json['exchange_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      amount: json['amount'] != null ? (json['amount']).toDouble() : 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
      metadata: json['metadata'],
    );
  }
}

/// Response for pending count
class PendingCountResponse {
  final bool success;
  final String message;
  final int count;

  PendingCountResponse({
    required this.success,
    required this.message,
    this.count = 0,
  });

  factory PendingCountResponse.fromJson(Map<String, dynamic> json) {
    return PendingCountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['data']?['count'] ?? json['count'] ?? 0,
    );
  }
}

/// Response for sugar partner history
class SugarPartnerHistoryResponse {
  final bool success;
  final String message;
  final List<SugarPartnerExchange> data;
  final SugarPartnerPaginationMeta? pagination;

  SugarPartnerHistoryResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory SugarPartnerHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => SugarPartnerExchange.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Response for hard rejects list
class HardRejectsResponse {
  final bool success;
  final String message;
  final List<HardRejectUser> data;
  final SugarPartnerPaginationMeta? pagination;

  HardRejectsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory HardRejectsResponse.fromJson(Map<String, dynamic> json) {
    return HardRejectsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => HardRejectUser.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Hard reject user model
class HardRejectUser {
  final int id;
  final int rejectedUserId;
  final String? rejectedAt;
  final SugarPartnerUser? user;

  HardRejectUser({
    required this.id,
    required this.rejectedUserId,
    this.rejectedAt,
    this.user,
  });

  factory HardRejectUser.fromJson(Map<String, dynamic> json) {
    return HardRejectUser(
      id: json['id'] ?? 0,
      rejectedUserId: json['rejected_user_id'] ?? 0,
      rejectedAt: json['rejected_at'] ?? json['created_at'],
      user: json['user'] != null
          ? SugarPartnerUser.fromJson(json['user'])
          : null,
    );
  }
}

/// Response for sugar partner payments list
class SugarPartnerPaymentsResponse {
  final bool success;
  final String message;
  final List<SugarPartnerPayment> data;
  final SugarPartnerPaginationMeta? pagination;
  final double? totalAmount;

  SugarPartnerPaymentsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
    this.totalAmount,
  });

  factory SugarPartnerPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPaymentsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => SugarPartnerPayment.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
      totalAmount: json['total_amount'] != null
          ? (json['total_amount']).toDouble()
          : null,
    );
  }
}

/// Pagination metadata for sugar partner
class SugarPartnerPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SugarPartnerPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SugarPartnerPaginationMeta.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
