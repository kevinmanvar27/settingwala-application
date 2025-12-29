import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

/// ProviderBookingService handles all provider-side booking management
/// Endpoints: /api/v1/provider/*
class ProviderBookingService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET PROVIDER BOOKINGS - Get all bookings where user is the provider
  // Endpoint: GET /api/v1/provider/bookings
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ProviderBookingsResponse> getProviderBookings({
    int? page,
    int? perPage,
    String? status,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ProviderBookingsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          data: [],
        );
      }

      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();
      if (status != null) queryParams['status'] = status;

      final uri = Uri.parse('${ApiConstants.baseUrl}/provider/bookings')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('========== GET Provider Bookings Request ==========');
      print('URL: $uri');
      print('===================================================');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Provider Bookings Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('====================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProviderBookingsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingsResponse(
          success: false,
          message: 'Session expired. Please login again.',
          data: [],
        );
      } else {
        return ProviderBookingsResponse(
          success: false,
          message: 'Failed to fetch bookings.',
          data: [],
        );
      }
    } catch (e) {
      print('GET Provider Bookings Error: $e');
      return ProviderBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: [],
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET BOOKING REQUESTS - Get pending booking requests for provider
  // Endpoint: GET /api/v1/provider/booking-requests
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ProviderBookingsResponse> getBookingRequests({
    int? page,
    int? perPage,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ProviderBookingsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          data: [],
        );
      }

      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (perPage != null) queryParams['per_page'] = perPage.toString();

      final uri = Uri.parse('${ApiConstants.baseUrl}/provider/booking-requests')
          .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('========== GET Booking Requests Request ==========');
      print('URL: $uri');
      print('==================================================');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Booking Requests Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ProviderBookingsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingsResponse(
          success: false,
          message: 'Session expired. Please login again.',
          data: [],
        );
      } else {
        return ProviderBookingsResponse(
          success: false,
          message: 'Failed to fetch booking requests.',
          data: [],
        );
      }
    } catch (e) {
      print('GET Booking Requests Error: $e');
      return ProviderBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: [],
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ACCEPT BOOKING - Provider accepts a booking request
  // Endpoint: POST /api/v1/provider/booking/{id}/accept
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ProviderBookingActionResponse> acceptBooking(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/provider/booking/$bookingId/accept';

      print('========== POST Accept Booking Request ==========');
      print('URL: $url');
      print('=================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Accept Booking Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProviderBookingActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot accept this booking.',
        );
      } else {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to accept booking.',
        );
      }
    } catch (e) {
      print('POST Accept Booking Error: $e');
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // REJECT BOOKING - Provider rejects a booking request
  // Endpoint: POST /api/v1/provider/booking/{id}/reject
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ProviderBookingActionResponse> rejectBooking(
    int bookingId, {
    String? reason,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/provider/booking/$bookingId/reject';
      final body = {
        if (reason != null) 'reason': reason,
      };

      print('========== POST Reject Booking Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('=================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== POST Reject Booking Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProviderBookingActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reject booking.',
        );
      }
    } catch (e) {
      print('POST Reject Booking Error: $e');
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // BLOCK CLIENT - Provider blocks a client
  // Endpoint: POST /api/v1/provider/booking/{id}/block
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ProviderBookingActionResponse> blockClient(
    int bookingId, {
    String? reason,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/provider/booking/$bookingId/block';
      final body = {
        if (reason != null) 'reason': reason,
      };

      print('========== POST Block Client Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('===============================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== POST Block Client Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProviderBookingActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to block client.',
        );
      }
    } catch (e) {
      print('POST Block Client Error: $e');
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UNBLOCK CLIENT - Provider unblocks a client
  // Endpoint: POST /api/v1/provider/user/{id}/unblock
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ProviderBookingActionResponse> unblockClient(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/provider/user/$userId/unblock';

      print('========== POST Unblock Client Request ==========');
      print('URL: $url');
      print('=================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== POST Unblock Client Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ProviderBookingActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to unblock client.',
        );
      }
    } catch (e) {
      print('POST Unblock Client Error: $e');
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Response for provider bookings list
class ProviderBookingsResponse {
  final bool success;
  final String message;
  final List<ProviderBooking> data;
  final PaginationMeta? pagination;

  ProviderBookingsResponse({
    required this.success,
    required this.message,
    required this.data,
    this.pagination,
  });

  factory ProviderBookingsResponse.fromJson(Map<String, dynamic> json) {
    return ProviderBookingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => ProviderBooking.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? PaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Provider booking data
class ProviderBooking {
  final int id;
  final String? bookingDate;
  final double durationHours;
  final double? hourlyRate;
  final double? baseAmount;
  final double? platformFee;
  final double? totalAmount;
  final String status;
  final String? paymentStatus;
  final String? meetingLocation;
  final String? notes;
  final ProviderBookingClient? client;
  final String? cancelledAt;
  final String? cancellationReason;
  final String? createdAt;

  ProviderBooking({
    required this.id,
    this.bookingDate,
    required this.durationHours,
    this.hourlyRate,
    this.baseAmount,
    this.platformFee,
    this.totalAmount,
    required this.status,
    this.paymentStatus,
    this.meetingLocation,
    this.notes,
    this.client,
    this.cancelledAt,
    this.cancellationReason,
    this.createdAt,
  });

  factory ProviderBooking.fromJson(Map<String, dynamic> json) {
    return ProviderBooking(
      id: json['id'] ?? 0,
      bookingDate: json['booking_date'],
      durationHours: (json['duration_hours'] ?? 0).toDouble(),
      hourlyRate: json['hourly_rate'] != null
          ? (json['hourly_rate']).toDouble()
          : null,
      baseAmount: json['base_amount'] != null
          ? (json['base_amount']).toDouble()
          : null,
      platformFee: json['platform_fee'] != null
          ? (json['platform_fee']).toDouble()
          : null,
      totalAmount: json['total_amount'] != null
          ? (json['total_amount']).toDouble()
          : null,
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'],
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
      client: json['client'] != null
          ? ProviderBookingClient.fromJson(json['client'])
          : null,
      cancelledAt: json['cancelled_at'],
      cancellationReason: json['cancellation_reason'],
      createdAt: json['created_at'],
    );
  }
}

/// Client data in provider booking
class ProviderBookingClient {
  final int id;
  final String? name;
  final String? avatar;
  final String? gender;
  final int? age;
  final double? rating;
  final int? totalBookings;
  final bool? isBlocked;

  ProviderBookingClient({
    required this.id,
    this.name,
    this.avatar,
    this.gender,
    this.age,
    this.rating,
    this.totalBookings,
    this.isBlocked,
  });

  factory ProviderBookingClient.fromJson(Map<String, dynamic> json) {
    return ProviderBookingClient(
      id: json['id'] ?? 0,
      name: json['name'],
      avatar: json['avatar'],
      gender: json['gender'],
      age: json['age'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      totalBookings: json['total_bookings'],
      isBlocked: _parseBool(json['is_blocked']),
    );
  }

  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return null;
  }
}

/// Response for provider booking actions (accept/reject/block/unblock)
class ProviderBookingActionResponse {
  final bool success;
  final String message;
  final ProviderBooking? booking;

  ProviderBookingActionResponse({
    required this.success,
    required this.message,
    this.booking,
  });

  factory ProviderBookingActionResponse.fromJson(Map<String, dynamic> json) {
    return ProviderBookingActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      booking: json['data']?['booking'] != null
          ? ProviderBooking.fromJson(json['data']['booking'])
          : null,
    );
  }
}

/// Pagination metadata
class PaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
