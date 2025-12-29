class Postbookingsmodel {
  int providerId;
  DateTime bookingDate;
  double durationHours;
  String? meetingLocation;
  String? notes;

  Postbookingsmodel({
    required this.providerId,
    required this.bookingDate,
    required this.durationHours,
    this.meetingLocation,
    this.notes,
  });

  // Convert model to JSON for API request
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'provider_id': providerId,
      'booking_date': '${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}',
      'duration_hours': durationHours,
    };
    if (meetingLocation != null) data['meeting_location'] = meetingLocation;
    if (notes != null) data['notes'] = notes;
    return data;
  }

  // Create model from JSON response
  factory Postbookingsmodel.fromJson(Map<String, dynamic> json) {
    return Postbookingsmodel(
      providerId: json['provider_id'] ?? 0,
      bookingDate: DateTime.tryParse(json['booking_date'] ?? '') ?? DateTime.now(),
      durationHours: (json['duration_hours'] ?? 0).toDouble(),
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
    );
  }
}

// Response model for booking API
class BookingResponse {
  final bool success;
  final String message;
  final BookingResponseData? data;

  BookingResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    return BookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? BookingResponseData.fromJson(json['data']) : null,
    );
  }
}

// Wrapper for booking data in response
class BookingResponseData {
  final BookingData? booking;

  BookingResponseData({this.booking});

  factory BookingResponseData.fromJson(Map<String, dynamic> json) {
    return BookingResponseData(
      booking: json['booking'] != null ? BookingData.fromJson(json['booking']) : null,
    );
  }
}

// Booking data matching Laravel formatBooking() response
class BookingData {
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
  final String? role; // 'client' or 'provider'
  final OtherUser? otherUser;
  final String? cancelledAt;
  final String? cancellationReason;
  final BookingVerification? verification;
  final BookingRating? rating;
  final String? createdAt;

  BookingData({
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
    this.role,
    this.otherUser,
    this.cancelledAt,
    this.cancellationReason,
    this.verification,
    this.rating,
    this.createdAt,
  });

  factory BookingData.fromJson(Map<String, dynamic> json) {
    return BookingData(
      id: json['id'] ?? 0,
      bookingDate: json['booking_date'],
      durationHours: (json['duration_hours'] ?? 0).toDouble(),
      hourlyRate: json['hourly_rate']?.toDouble(),
      baseAmount: json['base_amount']?.toDouble(),
      platformFee: json['platform_fee']?.toDouble(),
      totalAmount: json['total_amount']?.toDouble(),
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'],
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
      role: json['role'],
      otherUser: json['other_user'] != null ? OtherUser.fromJson(json['other_user']) : null,
      cancelledAt: json['cancelled_at'],
      cancellationReason: json['cancellation_reason'],
      verification: json['verification'] != null ? BookingVerification.fromJson(json['verification']) : null,
      rating: json['rating'] != null ? BookingRating.fromJson(json['rating']) : null,
      createdAt: json['created_at'],
    );
  }
}

// Other user in booking (provider or client)
class OtherUser {
  final int? id;
  final String? name;
  final String? profilePicture;
  final double? hourlyRate;

  OtherUser({
    this.id,
    this.name,
    this.profilePicture,
    this.hourlyRate,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'],
      name: json['name'],
      profilePicture: json['profile_picture'],
      hourlyRate: json['hourly_rate']?.toDouble(),
    );
  }
}

// Booking verification data
class BookingVerification {
  final bool hasStartPhoto;
  final bool hasEndPhoto;
  final String? startTime;
  final String? endTime;

  BookingVerification({
    required this.hasStartPhoto,
    required this.hasEndPhoto,
    this.startTime,
    this.endTime,
  });

  factory BookingVerification.fromJson(Map<String, dynamic> json) {
    return BookingVerification(
      hasStartPhoto: json['has_start_photo'] ?? false,
      hasEndPhoto: json['has_end_photo'] ?? false,
      startTime: json['start_time'],
      endTime: json['end_time'],
    );
  }
}

// Booking rating data
class BookingRating {
  final int? rating;
  final String? review;

  BookingRating({
    this.rating,
    this.review,
  });

  factory BookingRating.fromJson(Map<String, dynamic> json) {
    return BookingRating(
      rating: json['rating'],
      review: json['review'],
    );
  }
}

// Model for fetching bookings list
class GetBookingsResponse {
  final bool success;
  final String message;
  final List<BookingData> bookings;

  GetBookingsResponse({
    required this.success,
    required this.message,
    required this.bookings, required List data,
  });

  factory GetBookingsResponse.fromJson(Map<String, dynamic> json) {
    List<BookingData> bookingsList = [];
    
    // API returns { data: { bookings: [...] } }
    if (json['data'] != null && json['data']['bookings'] != null) {
      bookingsList = (json['data']['bookings'] as List)
          .map((e) => BookingData.fromJson(e))
          .toList();
    }
    // Fallback: API might return { data: [...] } directly
    else if (json['data'] != null && json['data'] is List) {
      bookingsList = (json['data'] as List)
          .map((e) => BookingData.fromJson(e))
          .toList();
    }
    
    return GetBookingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookings: bookingsList, data: [],
    );
  }
}
