import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class DisputeService {
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

  static Future<DisputesResponse> getDisputes({int page = 1, String? status}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      String url = '${ApiConstants.baseUrl}/disputes?page=$page';
      if (status != null && status.isNotEmpty) {
        url += '&status=$status';
      }

      
      
      

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
        return DisputesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return DisputesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return DisputesResponse(
          success: false,
          message: 'Failed to get disputes.',
        );
      }
    } catch (e) {
      
      return DisputesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<RaiseDisputeResponse> raiseDispute({
    required int bookingId,
    required String reason,
    required String description,
    List<File>? evidenceFiles,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return RaiseDisputeResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/disputes/raise';

      
      
      
      
      
      
      

      if (evidenceFiles != null && evidenceFiles.isNotEmpty) {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

        request.fields['booking_id'] = bookingId.toString();
        request.fields['reason'] = reason;
        request.fields['description'] = description;

        for (int i = 0; i < evidenceFiles.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'evidence[$i]',
              evidenceFiles[i].path,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        
        
        
        

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return RaiseDisputeResponse.fromJson(responseData);
        } else if (response.statusCode == 401) {
          return RaiseDisputeResponse(
            success: false,
            message: 'Session expired. Please login again.',
          );
        } else if (response.statusCode == 400) {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Cannot raise dispute for this booking.',
          );
        } else if (response.statusCode == 404) {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Booking not found.',
          );
        } else if (response.statusCode == 422) {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Invalid dispute data.',
          );
        } else {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Failed to raise dispute.',
          );
        }
      } else {
        final body = {
          'booking_id': bookingId,
          'reason': reason,
          'description': description,
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

        if (response.statusCode == 200 || response.statusCode == 201) {
          return RaiseDisputeResponse.fromJson(responseData);
        } else if (response.statusCode == 401) {
          return RaiseDisputeResponse(
            success: false,
            message: 'Session expired. Please login again.',
          );
        } else if (response.statusCode == 400) {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Cannot raise dispute for this booking.',
          );
        } else if (response.statusCode == 404) {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Booking not found.',
          );
        } else if (response.statusCode == 422) {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Invalid dispute data.',
          );
        } else {
          return RaiseDisputeResponse(
            success: false,
            message: responseData['message'] ?? 'Failed to raise dispute.',
          );
        }
      }
    } catch (e) {
      
      return RaiseDisputeResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<DisputeDetailsResponse> getDisputeDetails(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputeDetailsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/disputes/$bookingId/details';

      
      
      

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
        return DisputeDetailsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return DisputeDetailsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return DisputeDetailsResponse(
          success: false,
          message: 'Dispute not found for this booking.',
        );
      } else {
        return DisputeDetailsResponse(
          success: false,
          message: 'Failed to get dispute details.',
        );
      }
    } catch (e) {
      
      return DisputeDetailsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<DisputeActionResponse> addMessage({
    required int disputeId,
    required String message,
    List<File>? attachments,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputeActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/disputes/$disputeId/message';

      
      
      
      
      

      if (attachments != null && attachments.isNotEmpty) {
        final request = http.MultipartRequest('POST', Uri.parse(url));
        request.headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        });

        request.fields['message'] = message;

        for (int i = 0; i < attachments.length; i++) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'attachments[$i]',
              attachments[i].path,
            ),
          );
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        
        
        
        

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          return DisputeActionResponse.fromJson(responseData);
        } else if (response.statusCode == 401) {
          return DisputeActionResponse(
            success: false,
            message: 'Session expired. Please login again.',
          );
        } else if (response.statusCode == 400) {
          return DisputeActionResponse(
            success: false,
            message: responseData['message'] ?? 'Cannot add message to this dispute.',
          );
        } else if (response.statusCode == 404) {
          return DisputeActionResponse(
            success: false,
            message: responseData['message'] ?? 'Dispute not found.',
          );
        } else {
          return DisputeActionResponse(
            success: false,
            message: responseData['message'] ?? 'Failed to add message.',
          );
        }
      } else {
        final body = {'message': message};

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
          return DisputeActionResponse.fromJson(responseData);
        } else if (response.statusCode == 401) {
          return DisputeActionResponse(
            success: false,
            message: 'Session expired. Please login again.',
          );
        } else if (response.statusCode == 400) {
          return DisputeActionResponse(
            success: false,
            message: responseData['message'] ?? 'Cannot add message to this dispute.',
          );
        } else if (response.statusCode == 404) {
          return DisputeActionResponse(
            success: false,
            message: responseData['message'] ?? 'Dispute not found.',
          );
        } else {
          return DisputeActionResponse(
            success: false,
            message: responseData['message'] ?? 'Failed to add message.',
          );
        }
      }
    } catch (e) {
      
      return DisputeActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<DisputeActionResponse> cancelDispute(int disputeId, {String? reason}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputeActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/disputes/$disputeId/cancel';
      final body = reason != null ? {'reason': reason} : {};

      
      
      
      

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
        return DisputeActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return DisputeActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return DisputeActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot cancel this dispute.',
        );
      } else if (response.statusCode == 404) {
        return DisputeActionResponse(
          success: false,
          message: responseData['message'] ?? 'Dispute not found.',
        );
      } else {
        return DisputeActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel dispute.',
        );
      }
    } catch (e) {
      
      return DisputeActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}


class DisputesResponse {
  final bool success;
  final String message;
  final List<Dispute> data;
  final DisputePaginationMeta? pagination;

  DisputesResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory DisputesResponse.fromJson(Map<String, dynamic> json) {
    return DisputesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List).map((item) => Dispute.fromJson(item)).toList()
          : [],
      pagination: json['pagination'] != null
          ? DisputePaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class Dispute {
  final int id;
  final int bookingId;
  final int raisedById;
  final String reason;
  final String description;
  final String status;
  final String? resolution;
  final String? resolvedAt;
  final String? createdAt;
  final String? updatedAt;
  final DisputeUser? raisedBy;
  final DisputeBooking? booking;
  final List<DisputeEvidence>? evidence;
  final List<DisputeMessage>? messages;

  Dispute({
    required this.id,
    required this.bookingId,
    required this.raisedById,
    required this.reason,
    required this.description,
    required this.status,
    this.resolution,
    this.resolvedAt,
    this.createdAt,
    this.updatedAt,
    this.raisedBy,
    this.booking,
    this.evidence,
    this.messages,
  });

  factory Dispute.fromJson(Map<String, dynamic> json) {
    return Dispute(
      id: json['id'] ?? 0,
      bookingId: json['booking_id'] ?? 0,
      raisedById: json['raised_by_id'] ?? json['raised_by'] ?? 0,
      reason: json['reason'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'pending',
      resolution: json['resolution'],
      resolvedAt: json['resolved_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      raisedBy: json['raised_by'] != null && json['raised_by'] is Map
          ? DisputeUser.fromJson(json['raised_by'])
          : null,
      booking: json['booking'] != null
          ? DisputeBooking.fromJson(json['booking'])
          : null,
      evidence: json['evidence'] != null
          ? (json['evidence'] as List)
              .map((item) => DisputeEvidence.fromJson(item))
              .toList()
          : null,
      messages: json['messages'] != null
          ? (json['messages'] as List)
              .map((item) => DisputeMessage.fromJson(item))
              .toList()
          : null,
    );
  }
}

class DisputeUser {
  final int id;
  final String? name;
  final String? email;
  final String? profilePhoto;
  final String? phone;

  DisputeUser({
    required this.id,
    this.name,
    this.email,
    this.profilePhoto,
    this.phone,
  });

  factory DisputeUser.fromJson(Map<String, dynamic> json) {
    return DisputeUser(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      phone: json['phone'],
    );
  }
}

class DisputeBooking {
  final int id;
  final String? bookingNumber;
  final String? status;
  final String? date;
  final String? time;
  final double? amount;
  final DisputeUser? client;
  final DisputeUser? provider;
  final String? serviceName;

  DisputeBooking({
    required this.id,
    this.bookingNumber,
    this.status,
    this.date,
    this.time,
    this.amount,
    this.client,
    this.provider,
    this.serviceName,
  });

  factory DisputeBooking.fromJson(Map<String, dynamic> json) {
    return DisputeBooking(
      id: json['id'] ?? 0,
      bookingNumber: json['booking_number'],
      status: json['status'],
      date: json['date'] ?? json['booking_date'],
      time: json['time'] ?? json['booking_time'],
      amount: json['amount'] != null ? (json['amount']).toDouble() : null,
      client: json['client'] != null
          ? DisputeUser.fromJson(json['client'])
          : null,
      provider: json['provider'] != null
          ? DisputeUser.fromJson(json['provider'])
          : null,
      serviceName: json['service_name'] ?? json['service']?['name'],
    );
  }
}

class DisputeEvidence {
  final int id;
  final int disputeId;
  final String? fileUrl;
  final String? fileType;
  final String? fileName;
  final String? createdAt;

  DisputeEvidence({
    required this.id,
    required this.disputeId,
    this.fileUrl,
    this.fileType,
    this.fileName,
    this.createdAt,
  });

  factory DisputeEvidence.fromJson(Map<String, dynamic> json) {
    return DisputeEvidence(
      id: json['id'] ?? 0,
      disputeId: json['dispute_id'] ?? 0,
      fileUrl: json['file_url'] ?? json['url'],
      fileType: json['file_type'] ?? json['type'],
      fileName: json['file_name'] ?? json['name'],
      createdAt: json['created_at'],
    );
  }
}

class DisputeMessage {
  final int id;
  final int disputeId;
  final int userId;
  final String message;
  final String? createdAt;
  final DisputeUser? user;
  final List<DisputeEvidence>? attachments;
  final bool? isAdmin;

  DisputeMessage({
    required this.id,
    required this.disputeId,
    required this.userId,
    required this.message,
    this.createdAt,
    this.user,
    this.attachments,
    this.isAdmin,
  });

  factory DisputeMessage.fromJson(Map<String, dynamic> json) {
    return DisputeMessage(
      id: json['id'] ?? 0,
      disputeId: json['dispute_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      message: json['message'] ?? '',
      createdAt: json['created_at'],
      user: json['user'] != null
          ? DisputeUser.fromJson(json['user'])
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((item) => DisputeEvidence.fromJson(item))
              .toList()
          : null,
      isAdmin: DisputeService._parseBool(json['is_admin']),
    );
  }
}

class RaiseDisputeResponse {
  final bool success;
  final String message;
  final Dispute? data;

  RaiseDisputeResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory RaiseDisputeResponse.fromJson(Map<String, dynamic> json) {
    return RaiseDisputeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Dispute.fromJson(json['data']) : null,
    );
  }
}

class DisputeDetailsResponse {
  final bool success;
  final String message;
  final Dispute? data;

  DisputeDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DisputeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DisputeDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Dispute.fromJson(json['data']) : null,
    );
  }
}

class DisputeActionResponse {
  final bool success;
  final String message;
  final Dispute? data;

  DisputeActionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DisputeActionResponse.fromJson(Map<String, dynamic> json) {
    return DisputeActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? Dispute.fromJson(json['data']) : null,
    );
  }
}

class DisputePaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  DisputePaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory DisputePaginationMeta.fromJson(Map<String, dynamic> json) {
    return DisputePaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}
