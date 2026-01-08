import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class ReviewService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
  static Future<SubmitReviewResponse> submitRating({
    required int bookingId,
    required int rating,
    String? review,
  }) async {
    final url = '${ApiConstants.baseUrl}/reviews';
    try {
      final token = await _getToken();

      if (token == null) {
        return SubmitReviewResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'booking_id': bookingId,
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
      };

      // API call થઈ રહી છે
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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return SubmitReviewResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return SubmitReviewResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot submit review for this booking.',
        );
      } else if (response.statusCode == 422) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid rating data.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Booking not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to submit review.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SubmitReviewResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<PendingReviewsResponse> getPendingReviews({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/reviews/pending?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return PendingReviewsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return PendingReviewsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return PendingReviewsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get pending reviews');
        return PendingReviewsResponse(
          success: false,
          message: 'Failed to get pending reviews.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return PendingReviewsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CanReviewResponse> canReview(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/reviews/can-review/$bookingId';
    try {
      final token = await _getToken();

      if (token == null) {
        return CanReviewResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          canReview: false,
        );
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
        final responseData = jsonDecode(response.body);
        return CanReviewResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return CanReviewResponse(
          success: false,
          message: 'Session expired. Please login again.',
          canReview: false,
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Booking not found');
        return CanReviewResponse(
          success: false,
          message: 'Booking not found.',
          canReview: false,
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to check review eligibility');
        return CanReviewResponse(
          success: false,
          message: 'Failed to check review eligibility.',
          canReview: false,
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CanReviewResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        canReview: false,
      );
    }
  }

  // REMOVED: getMyReviews() - Endpoint /reviews/my-reviews does NOT exist in API documentation.
  // REMOVED: getReceivedReviews() - Endpoint /reviews/received does NOT exist in API documentation.
  // REMOVED: getReviews(userId) - Endpoint /reviews/user/{userId} does NOT exist in API documentation.
  // Use UserService.getUserReviews() for /users/{id}/reviews endpoint instead.
}


class SubmitReviewResponse {
  final bool success;
  final String message;
  final ReviewData? data;

  SubmitReviewResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SubmitReviewResponse.fromJson(Map<String, dynamic> json) {
    return SubmitReviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ReviewData.fromJson(json['data']) : null,
    );
  }
}

class ReviewData {
  final int id;
  final int bookingId;
  final int reviewerId;
  final int revieweeId;
  final int rating;
  final String? review;
  final String? createdAt;
  final ReviewUser? reviewer;
  final ReviewUser? reviewee;

  ReviewData({
    required this.id,
    required this.bookingId,
    required this.reviewerId,
    required this.revieweeId,
    required this.rating,
    this.review,
    this.createdAt,
    this.reviewer,
    this.reviewee,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      reviewerId: json['reviewer_id'] ?? 0,
      revieweeId: json['reviewee_id'] ?? 0,
      rating: json['rating'] ?? 0,
      review: json['review'],
      createdAt: json['created_at'],
      reviewer: json['reviewer'] != null
          ? ReviewUser.fromJson(json['reviewer'])
          : null,
      reviewee: json['reviewee'] != null
          ? ReviewUser.fromJson(json['reviewee'])
          : null,
    );
  }
}

class ReviewUser {
  final int id;
  final String? name;
  final String? profilePhoto;

  ReviewUser({
    required this.id,
    this.name,
    this.profilePhoto,
  });

  factory ReviewUser.fromJson(Map<String, dynamic> json) {
    return ReviewUser(
      id: json['id'] ?? 0,
      name: json['name'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
    );
  }
}

class PendingReviewsResponse {
  final bool success;
  final String message;
  final List<PendingReviewBooking> data;
  final ReviewPaginationMeta? pagination;

  PendingReviewsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory PendingReviewsResponse.fromJson(Map<String, dynamic> json) {
    return PendingReviewsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => PendingReviewBooking.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? ReviewPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class PendingReviewBooking {
  final int id;
  final String? bookingDate;
  final String? bookingTime;
  final int? duration;
  final String? status;
  final ReviewUser? provider;
  final ReviewUser? client;
  final String? completedAt;

  PendingReviewBooking({
    required this.id,
    this.bookingDate,
    this.bookingTime,
    this.duration,
    this.status,
    this.provider,
    this.client,
    this.completedAt,
  });

  factory PendingReviewBooking.fromJson(Map<String, dynamic> json) {
    return PendingReviewBooking(
      id: json['id'] ?? 0,
      bookingDate: json['booking_date'],
      bookingTime: json['booking_time'],
      duration: json['duration'],
      status: json['status'],
      provider: json['provider'] != null
          ? ReviewUser.fromJson(json['provider'])
          : null,
      client: json['client'] != null
          ? ReviewUser.fromJson(json['client'])
          : null,
      completedAt: json['completed_at'],
    );
  }
}

class CanReviewResponse {
  final bool success;
  final String message;
  final bool canReview;
  final String? reason;
  final ReviewData? existingReview;

  CanReviewResponse({
    required this.success,
    required this.message,
    required this.canReview,
    this.reason,
    this.existingReview,
  });

  factory CanReviewResponse.fromJson(Map<String, dynamic> json) {
    return CanReviewResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      canReview: ReviewService._parseBool(json['data']?['can_review'] ?? json['can_review']),
      reason: json['data']?['reason'] ?? json['reason'],
      existingReview: json['data']?['existing_review'] != null
          ? ReviewData.fromJson(json['data']['existing_review'])
          : null,
    );
  }
}

// FIX: Removed MyReviewsResponse class - API endpoint /reviews/my-reviews does not exist
// FIX: Removed ReceivedReviewsResponse class - API endpoint /reviews/received does not exist
// These classes were used by removed methods getMyReviews() and getReceivedReviews()

class ReviewPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ReviewPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ReviewPaginationMeta.fromJson(Map<String, dynamic> json) {
    return ReviewPaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
