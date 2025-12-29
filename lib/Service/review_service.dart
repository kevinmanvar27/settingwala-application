import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

/// ReviewService handles ratings and reviews management
/// Endpoints: /api/v1/reviews/*
class ReviewService {
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
  // SUBMIT RATING - Submit a rating and review for a booking
  // Endpoint: POST /api/v1/reviews
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<SubmitReviewResponse> submitRating({
    required int bookingId,
    required int rating,
    String? review,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SubmitReviewResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/reviews';
      final body = {
        'booking_id': bookingId,
        'rating': rating,
        if (review != null && review.isNotEmpty) 'review': review,
      };

      print('========== POST Submit Rating Request ==========');
      print('URL: $url');
      print('Body: ${jsonEncode(body)}');
      print('================================================');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== POST Submit Rating Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SubmitReviewResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SubmitReviewResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot submit review for this booking.',
        );
      } else if (response.statusCode == 422) {
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid rating data.',
        );
      } else if (response.statusCode == 404) {
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Booking not found.',
        );
      } else {
        return SubmitReviewResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to submit review.',
        );
      }
    } catch (e) {
      print('POST Submit Rating Error: $e');
      return SubmitReviewResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET PENDING REVIEWS - Get list of bookings pending review
  // Endpoint: GET /api/v1/reviews/pending
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<PendingReviewsResponse> getPendingReviews({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return PendingReviewsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/reviews/pending?page=$page';

      print('========== GET Pending Reviews Request ==========');
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

      print('========== GET Pending Reviews Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PendingReviewsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return PendingReviewsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return PendingReviewsResponse(
          success: false,
          message: 'Failed to get pending reviews.',
        );
      }
    } catch (e) {
      print('GET Pending Reviews Error: $e');
      return PendingReviewsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // CAN REVIEW - Check if user can review a specific booking
  // Endpoint: GET /api/v1/reviews/can-review/{bookingId}
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<CanReviewResponse> canReview(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return CanReviewResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          canReview: false,
        );
      }

      final url = '${ApiConstants.baseUrl}/reviews/can-review/$bookingId';

      print('========== GET Can Review Request ==========');
      print('URL: $url');
      print('============================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Can Review Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=============================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return CanReviewResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CanReviewResponse(
          success: false,
          message: 'Session expired. Please login again.',
          canReview: false,
        );
      } else if (response.statusCode == 404) {
        return CanReviewResponse(
          success: false,
          message: 'Booking not found.',
          canReview: false,
        );
      } else {
        return CanReviewResponse(
          success: false,
          message: 'Failed to check review eligibility.',
          canReview: false,
        );
      }
    } catch (e) {
      print('GET Can Review Error: $e');
      return CanReviewResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        canReview: false,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET MY REVIEWS - Get reviews submitted by the current user
  // Endpoint: GET /api/v1/reviews/my-reviews
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<MyReviewsResponse> getMyReviews({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return MyReviewsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/reviews/my-reviews?page=$page';

      print('========== GET My Reviews Request ==========');
      print('URL: $url');
      print('============================================');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET My Reviews Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=============================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return MyReviewsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return MyReviewsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return MyReviewsResponse(
          success: false,
          message: 'Failed to get your reviews.',
        );
      }
    } catch (e) {
      print('GET My Reviews Error: $e');
      return MyReviewsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET RECEIVED REVIEWS - Get reviews received by the current user (provider)
  // Endpoint: GET /api/v1/reviews/received
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<ReceivedReviewsResponse> getReceivedReviews({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ReceivedReviewsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/reviews/received?page=$page';

      print('========== GET Received Reviews Request ==========');
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

      print('========== GET Received Reviews Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ReceivedReviewsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ReceivedReviewsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return ReceivedReviewsResponse(
          success: false,
          message: 'Failed to get received reviews.',
        );
      }
    } catch (e) {
      print('GET Received Reviews Error: $e');
      return ReceivedReviewsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RESPONSE MODELS
// ═══════════════════════════════════════════════════════════════════════════

/// Response for submit rating
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

/// Review data model
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

/// User info in review
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

/// Response for pending reviews
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

/// Booking pending review
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

/// Response for can review check
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

/// Response for my reviews
class MyReviewsResponse {
  final bool success;
  final String message;
  final List<ReviewData> data;
  final ReviewPaginationMeta? pagination;

  MyReviewsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory MyReviewsResponse.fromJson(Map<String, dynamic> json) {
    return MyReviewsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => ReviewData.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? ReviewPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

/// Response for received reviews
class ReceivedReviewsResponse {
  final bool success;
  final String message;
  final List<ReviewData> data;
  final ReviewPaginationMeta? pagination;
  final double? averageRating;
  final int? totalReviews;

  ReceivedReviewsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
    this.averageRating,
    this.totalReviews,
  });

  factory ReceivedReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedReviewsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
              .map((item) => ReviewData.fromJson(item))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? ReviewPaginationMeta.fromJson(json['pagination'])
          : null,
      averageRating: json['average_rating'] != null
          ? (json['average_rating']).toDouble()
          : null,
      totalReviews: json['total_reviews'],
    );
  }
}

/// Pagination metadata for reviews
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
