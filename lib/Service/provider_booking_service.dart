import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class ProviderBookingService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

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

      
      
      

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

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
      
      return ProviderBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: [],
      );
    }
  }

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

      
      
      

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

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
      
      return ProviderBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: [],
      );
    }
  }

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

      
      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({}),
      );

      
      
      
      

      Map<String, dynamic>? responseData;
      try {
        responseData = jsonDecode(response.body);
      } catch (e) {
        
      }

      if (response.statusCode == 200) {
        return ProviderBookingActionResponse.fromJson(responseData ?? {'success': true, 'message': 'Booking accepted'});
      } else if (response.statusCode == 401) {
        return ProviderBookingActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData?['message'] ?? 'You are not authorized to accept this booking.',
        );
      } else if (response.statusCode == 404) {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData?['message'] ?? 'Booking not found.',
        );
      } else if (response.statusCode == 400) {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData?['message'] ?? 'Cannot accept this booking. It may not be in pending status.',
        );
      } else {
        return ProviderBookingActionResponse(
          success: false,
          message: responseData?['message'] ?? 'Failed to accept booking. (Status: ${response.statusCode})',
        );
      }
    } catch (e) {
      
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

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
      
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

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
      
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

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
      
      return ProviderBookingActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}


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

double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

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
      durationHours: _safeParseDouble(json['duration_hours']) ?? 0.0,
      hourlyRate: _safeParseDouble(json['hourly_rate']),
      baseAmount: _safeParseDouble(json['base_amount']),
      platformFee: _safeParseDouble(json['platform_fee']),
      totalAmount: _safeParseDouble(json['total_amount']),
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
      age: json['age'] != null ? (json['age'] is int ? json['age'] : (json['age'] as num).toInt()) : null,
      rating: _safeParseDouble(json['rating']),
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
