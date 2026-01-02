double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class Postbookingsmodel {
  int providerId;
  String bookingDate;
  String startTime;
  String endTime;
  String? meetingLocation;
  String? notes;

  Postbookingsmodel({
    required this.providerId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    this.meetingLocation,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'provider_id': providerId,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
    };
    if (meetingLocation != null) data['meeting_location'] = meetingLocation;
    if (notes != null) data['notes'] = notes;
    return data;
  }

  factory Postbookingsmodel.fromJson(Map<String, dynamic> json) {
    return Postbookingsmodel(
      providerId: json['provider_id'] ?? 0,
      bookingDate: json['booking_date'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
    );
  }
}

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

class BookingResponseData {
  final BookingData? booking;

  BookingResponseData({this.booking});

  factory BookingResponseData.fromJson(Map<String, dynamic> json) {
    return BookingResponseData(
      booking: json['booking'] != null ? BookingData.fromJson(json['booking']) : null,
    );
  }
}

class BookingData {
  final int id;
  final String? bookingDate;
  final String? bookingDatetime;
  final String? startTime;
  final String? endTime;
  final String? durationHours;
  final double? actualDurationHours;
  final String? hourlyRate;
  final String? baseAmount;
  final String? platformFee;
  final String? totalAmount;
  final String? commissionPercentage;
  final String? commissionAmount;
  final String? providerAmount;
  final String status;
  final String? providerStatus;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? walletAmountUsed;
  final String? cfAmountPaid;
  final String? paidAt;
  final String? role;
  final OtherUser? otherUser;
  final String? providerServiceLocation;
  final String? meetingLocation;
  final String? notes;
  final String? cancelledAt;
  final String? cancellationReason;
  final BookingVerification? verification;
  final BookingRating? rating;
  final String? createdAt;

  BookingData({
    required this.id,
    this.bookingDate,
    this.bookingDatetime,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.actualDurationHours,
    this.hourlyRate,
    this.baseAmount,
    this.platformFee,
    this.totalAmount,
    this.commissionPercentage,
    this.commissionAmount,
    this.providerAmount,
    required this.status,
    this.providerStatus,
    this.paymentStatus,
    this.paymentMethod,
    this.walletAmountUsed,
    this.cfAmountPaid,
    this.paidAt,
    this.role,
    this.otherUser,
    this.providerServiceLocation,
    this.meetingLocation,
    this.notes,
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
      bookingDatetime: json['booking_datetime'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      durationHours: json['duration_hours']?.toString(),
      actualDurationHours: _safeParseDouble(json['actual_duration_hours']),
      hourlyRate: json['hourly_rate']?.toString(),
      baseAmount: json['base_amount']?.toString(),
      platformFee: json['platform_fee']?.toString(),
      totalAmount: json['total_amount']?.toString(),
      commissionPercentage: json['commission_percentage']?.toString(),
      commissionAmount: json['commission_amount']?.toString(),
      providerAmount: json['provider_amount']?.toString(),
      status: json['status'] ?? 'pending',
      providerStatus: json['provider_status'],
      paymentStatus: json['payment_status'],
      paymentMethod: json['payment_method'],
      walletAmountUsed: json['wallet_amount_used']?.toString(),
      cfAmountPaid: json['cf_amount_paid']?.toString(),
      paidAt: json['paid_at'],
      role: json['role'],
      otherUser: json['other_user'] != null ? OtherUser.fromJson(json['other_user']) : null,
      providerServiceLocation: json['provider_service_location'],
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
      cancelledAt: json['cancelled_at'],
      cancellationReason: json['cancellation_reason'],
      verification: json['verification'] != null ? BookingVerification.fromJson(json['verification']) : null,
      rating: json['rating'] != null ? BookingRating.fromJson(json['rating']) : null,
      createdAt: json['created_at'],
    );
  }
}

class OtherUser {
  final int? id;
  final String? name;
  final String? profilePicture;
  final String? hourlyRate;
  final String? serviceLocation;

  OtherUser({
    this.id,
    this.name,
    this.profilePicture,
    this.hourlyRate,
    this.serviceLocation,
  });

  factory OtherUser.fromJson(Map<String, dynamic> json) {
    return OtherUser(
      id: json['id'],
      name: json['name'],
      profilePicture: json['profile_picture'],
      hourlyRate: json['hourly_rate']?.toString(),
      serviceLocation: json['service_location'],
    );
  }
}

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

class GetBookingsResponse {
  final bool success;
  final String message;
  final List<BookingData> bookings;

  GetBookingsResponse({
    required this.success,
    required this.message,
    required this.bookings,
  });

  factory GetBookingsResponse.fromJson(Map<String, dynamic> json) {
    List<BookingData> bookingsList = [];
    
    if (json['data'] != null && json['data']['bookings'] != null) {
      bookingsList = (json['data']['bookings'] as List)
          .map((e) => BookingData.fromJson(e))
          .toList();
    }
    else if (json['data'] != null && json['data'] is List) {
      bookingsList = (json['data'] as List)
          .map((e) => BookingData.fromJson(e))
          .toList();
    }
    
    return GetBookingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookings: bookingsList,
    );
  }
}
