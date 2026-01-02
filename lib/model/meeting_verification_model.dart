
class MeetingVerificationResponse {
  final bool success;
  final String? message;

  MeetingVerificationResponse({
    required this.success,
    this.message,
  });

  factory MeetingVerificationResponse.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationResponse(
      success: json['success'] ?? false,
      message: json['message'],
    );
  }
}

class MeetingVerificationStatusResponse {
  final bool success;
  final MeetingVerificationData? data;

  MeetingVerificationStatusResponse({
    required this.success,
    this.data,
  });

  factory MeetingVerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationStatusResponse(
      success: json['success'] ?? false,
      data: json['data'] != null 
          ? MeetingVerificationData.fromJson(json['data']) 
          : null,
    );
  }
}

class MeetingVerificationData {
  final VerificationDetails? verification;

  MeetingVerificationData({
    this.verification,
  });

  factory MeetingVerificationData.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationData(
      verification: json['verification'] != null
          ? VerificationDetails.fromJson(json['verification'])
          : null,
    );
  }
}

class VerificationDetails {
  final bool hasStartPhoto;
  final bool hasEndPhoto;
  final String? startTime;
  final String? endTime;
  final String? startPhotoUrl;
  final String? endPhotoUrl;
  final double? startLatitude;
  final double? startLongitude;
  final double? endLatitude;
  final double? endLongitude;

  VerificationDetails({
    required this.hasStartPhoto,
    required this.hasEndPhoto,
    this.startTime,
    this.endTime,
    this.startPhotoUrl,
    this.endPhotoUrl,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  });

  factory VerificationDetails.fromJson(Map<String, dynamic> json) {
    return VerificationDetails(
      hasStartPhoto: json['has_start_photo'] ?? false,
      hasEndPhoto: json['has_end_photo'] ?? false,
      startTime: json['start_time'],
      endTime: json['end_time'],
      startPhotoUrl: json['start_photo_url'],
      endPhotoUrl: json['end_photo_url'],
      startLatitude: json['start_latitude']?.toDouble(),
      startLongitude: json['start_longitude']?.toDouble(),
      endLatitude: json['end_latitude']?.toDouble(),
      endLongitude: json['end_longitude']?.toDouble(),
    );
  }

  bool get isMeetingInProgress => hasStartPhoto && !hasEndPhoto;

  bool get isMeetingCompleted => hasStartPhoto && hasEndPhoto;
}
