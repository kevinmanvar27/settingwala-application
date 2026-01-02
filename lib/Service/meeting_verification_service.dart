import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

double? _safeParseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

class MeetingVerificationService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<MeetingVerificationResponse> uploadStartPhoto(
      int bookingId,
      File photo, {
        double? latitude,
        double? longitude,
      }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return MeetingVerificationResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/meeting-verification/$bookingId/start-photo';

      
      
      
      

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      
      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MeetingVerificationResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return MeetingVerificationResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return MeetingVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot upload start photo at this time.',
        );
      } else if (response.statusCode == 422) {
        return MeetingVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid photo format.',
        );
      } else {
        return MeetingVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to upload start photo.',
        );
      }
    } catch (e) {
      
      return MeetingVerificationResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<MeetingVerificationResponse> uploadEndPhoto(
      int bookingId,
      File photo, {
        double? latitude,
        double? longitude,
      }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return MeetingVerificationResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/meeting-verification/$bookingId/end-photo';

      
      
      
      

      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      request.files.add(await http.MultipartFile.fromPath('photo', photo.path));

      if (latitude != null) {
        request.fields['latitude'] = latitude.toString();
      }
      if (longitude != null) {
        request.fields['longitude'] = longitude.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      
      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return MeetingVerificationResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return MeetingVerificationResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return MeetingVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot upload end photo at this time.',
        );
      } else if (response.statusCode == 422) {
        return MeetingVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid photo format.',
        );
      } else {
        return MeetingVerificationResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to upload end photo.',
        );
      }
    } catch (e) {
      
      return MeetingVerificationResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<VerificationStatusResponse> getVerificationStatus(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return VerificationStatusResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/meeting-verification/$bookingId/status';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return VerificationStatusResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return VerificationStatusResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return VerificationStatusResponse(
          success: false,
          message: 'Booking not found.',
        );
      } else {
        return VerificationStatusResponse(
          success: false,
          message: 'Failed to get verification status.',
        );
      }
    } catch (e) {
      
      return VerificationStatusResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}


class MeetingVerificationResponse {
  final bool success;
  final String message;
  final MeetingVerificationData? data;

  MeetingVerificationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory MeetingVerificationResponse.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? MeetingVerificationData.fromJson(json['data'])
          : null,
    );
  }
}

class MeetingVerificationData {
  final int? bookingId;
  final String? photoUrl;
  final String? photoType;
  final String? uploadedAt;
  final double? latitude;
  final double? longitude;
  final String? status;

  MeetingVerificationData({
    this.bookingId,
    this.photoUrl,
    this.photoType,
    this.uploadedAt,
    this.latitude,
    this.longitude,
    this.status,
  });

  factory MeetingVerificationData.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationData(
      bookingId: json['booking_id'],
      photoUrl: json['photo_url'],
      photoType: json['photo_type'],
      uploadedAt: json['uploaded_at'],
      latitude: _safeParseDouble(json['latitude']),
      longitude: _safeParseDouble(json['longitude']),
      status: json['status'],
    );
  }
}

class VerificationStatusResponse {
  final bool success;
  final String message;
  final VerificationStatus? data;

  VerificationStatusResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory VerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    return VerificationStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? VerificationStatus.fromJson(json['data'])
          : null,
    );
  }
}

class VerificationStatus {
  final int bookingId;
  final String? overallStatus;
  final VerificationPhoto? startPhoto;
  final VerificationPhoto? endPhoto;
  final bool? canUploadStartPhoto;
  final bool? canUploadEndPhoto;
  final String? meetingStartTime;
  final String? meetingEndTime;
  final double? actualDurationHours;

  VerificationStatus({
    required this.bookingId,
    this.overallStatus,
    this.startPhoto,
    this.endPhoto,
    this.canUploadStartPhoto,
    this.canUploadEndPhoto,
    this.meetingStartTime,
    this.meetingEndTime,
    this.actualDurationHours,
  });

  factory VerificationStatus.fromJson(Map<String, dynamic> json) {
    return VerificationStatus(
      bookingId: json['booking_id'] ?? 0,
      overallStatus: json['overall_status'],
      startPhoto: json['start_photo'] != null
          ? VerificationPhoto.fromJson(json['start_photo'])
          : null,
      endPhoto: json['end_photo'] != null
          ? VerificationPhoto.fromJson(json['end_photo'])
          : null,
      canUploadStartPhoto: _parseBool(json['can_upload_start_photo']),
      canUploadEndPhoto: _parseBool(json['can_upload_end_photo']),
      meetingStartTime: json['meeting_start_time'],
      meetingEndTime: json['meeting_end_time'],
      actualDurationHours: _safeParseDouble(json['actual_duration_hours']),
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

class VerificationPhoto {
  final String? url;
  final String? uploadedAt;
  final double? latitude;
  final double? longitude;
  final String? status;
  final String? verifiedAt;
  final String? rejectionReason;

  VerificationPhoto({
    this.url,
    this.uploadedAt,
    this.latitude,
    this.longitude,
    this.status,
    this.verifiedAt,
    this.rejectionReason,
  });

  factory VerificationPhoto.fromJson(Map<String, dynamic> json) {
    return VerificationPhoto(
      url: json['url'],
      uploadedAt: json['uploaded_at'],
      latitude: _safeParseDouble(json['latitude']),
      longitude: _safeParseDouble(json['longitude']),
      status: json['status'],
      verifiedAt: json['verified_at'],
      rejectionReason: json['rejection_reason'],
    );
  }
}
