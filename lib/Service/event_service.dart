import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';
import '../model/event_payment_model.dart';
import 'cache_service.dart';

class EventModel {
  final int id;
  final String title;
  final String? description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final DateTime? eventDate;
  final bool isCoupleEvent;
  final double? paymentAmountCouple;
  final double? paymentAmountBoys;
  final double? paymentAmountGirls;
  final String? rulesAndRegulations;
  final bool isEventEnabled;
  final bool isJoined;
  final int participantsCount;
  final int? eventPaymentId; // Added: Payment ID for fetching payment status

  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.location,
    this.latitude,
    this.longitude,
    this.eventDate,
    this.isCoupleEvent = false,
    this.paymentAmountCouple,
    this.paymentAmountBoys,
    this.paymentAmountGirls,
    this.rulesAndRegulations,
    this.isEventEnabled = true,
    this.isJoined = false,
    this.participantsCount = 0,
    this.eventPaymentId, // Added
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      location: json['location'],
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      eventDate: json['event_date'] != null ? DateTime.tryParse(json['event_date']) : null,
      isCoupleEvent: json['is_couple_event'] ?? false,
      paymentAmountCouple: json['payment_amount_couple'] != null
          ? double.tryParse(json['payment_amount_couple'].toString())
          : null,
      paymentAmountBoys: json['payment_amount_boys'] != null
          ? double.tryParse(json['payment_amount_boys'].toString())
          : null,
      paymentAmountGirls: json['payment_amount_girls'] != null
          ? double.tryParse(json['payment_amount_girls'].toString())
          : null,
      rulesAndRegulations: json['rules_and_regulations'],
      isEventEnabled: json['is_event_enabled'] ?? true,
      isJoined: json['is_joined'] ?? false,
      participantsCount: json['participants_count'] ?? 0,
      eventPaymentId: json['event_payment_id'], // Added: Parse event_payment_id from API
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'event_date': eventDate?.toIso8601String(),
      'is_couple_event': isCoupleEvent,
      'payment_amount_couple': paymentAmountCouple,
      'payment_amount_boys': paymentAmountBoys,
      'payment_amount_girls': paymentAmountGirls,
      'rules_and_regulations': rulesAndRegulations,
      'is_event_enabled': isEventEnabled,
      'is_joined': isJoined,
      'participants_count': participantsCount,
      'event_payment_id': eventPaymentId, // Added
    };
  }
}

class EventService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<List<EventModel>> getEvents({bool forceRefresh = false}) async {
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheService.getFromCache(CacheService.eventsListKey);
      if (cachedData != null) {
        try {
          final eventsList = cachedData as List<dynamic>;
          return eventsList.map((e) => EventModel.fromJson(e)).toList();
        } catch (e) {
          // Cache data corrupted, continue to fetch from API
        }
      }
    }
    
    final url = '${ApiConstants.baseUrl}/events';
    try {
      final token = await _getToken();

      if (token == null) {

        return [];
      }

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final eventsList = data['data']['events'] as List<dynamic>? ?? [];
          
          // Cache the events list
          await CacheService.saveToCache(
            key: CacheService.eventsListKey,
            data: eventsList,
            durationMinutes: CacheService.eventsCacheDuration,
          );
          
          return eventsList.map((e) => EventModel.fromJson(e)).toList();
        }
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get events');
      }
      return [];
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return [];
    }
  }

  static Future<EventModel?> getEventDetails(int eventId, {bool forceRefresh = false}) async {
    final cacheKey = '${CacheService.eventDetailsKey}_$eventId';
    
    // Check cache first
    if (!forceRefresh) {
      final cachedData = await CacheService.getFromCache(cacheKey);
      if (cachedData != null) {
        try {
          return EventModel.fromJson(cachedData);
        } catch (e) {
          // Cache data corrupted, continue to fetch from API
        }
      }
    }
    
    final url = '${ApiConstants.baseUrl}/events/$eventId';
    try {
      final token = await _getToken();

      if (token == null) {

        return null;
      }

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final eventData = data['data']['event'];
          
          // Cache the event details
          await CacheService.saveToCache(
            key: cacheKey,
            data: eventData,
            durationMinutes: CacheService.eventsCacheDuration,
          );
          
          return EventModel.fromJson(eventData);
        }
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get event details');
      }
      return null;
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  // REMOVED: getMyEvents() - Endpoint /events/my-events does NOT exist. Use getEvents() and filter by is_joined flag.

  static Future<Map<String, dynamic>> joinEvent(int eventId) async {
    final url = '${ApiConstants.baseUrl}/events/$eventId/join';
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // Debug logging
      debugPrint('=== Event Join API Debug ===');
      debugPrint('URL: $url');
      debugPrint('Status Code: ${response.statusCode}');
      debugPrint('Response Body: ${response.body}');

      // Handle empty response body
      if (response.body.isEmpty) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Empty response body');
        return {
          'success': false,
          'message': 'Server returned empty response',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
      } catch (e) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Invalid JSON: $e');
        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      // Handle success (200) and created (201) status codes
      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        // Parse payment_amount from string to double (API returns "500.00" format)
        final rawAmount = data['data']?['payment_amount'];
        double paymentAmount = 0.0;
        if (rawAmount != null) {
          if (rawAmount is String) {
            paymentAmount = double.tryParse(rawAmount) ?? 0.0;
          } else if (rawAmount is num) {
            paymentAmount = rawAmount.toDouble();
          }
        }

        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Successfully joined the event',
          'payment_required': data['data']?['payment_required'] ?? false,
          'payment_amount': paymentAmount,
          'event_payment_id': data['data']?['event_payment_id'],
        };
      } else {
        // Handle error responses (400, 404, etc.)
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Failed to join event');
        
        // Extract error message from various possible locations
        String errorMessage = 'Failed to join event';
        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['error'] != null) {
          errorMessage = data['error'];
        } else if (data['errors'] != null && data['errors'] is Map) {
          // Handle validation errors
          final errors = data['errors'] as Map;
          errorMessage = errors.values.first is List 
              ? (errors.values.first as List).first.toString()
              : errors.values.first.toString();
        }
        
        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return {
        'success': false,
        'message': 'Network error: ${e.toString()}',
      };
    }
  }

  /// Create Cashfree payment order for event
  /// Call this after joinEvent returns payment_required = true
  static Future<EventPaymentOrderModel?> createPaymentOrder(int eventPaymentId) async {
    final url = ApiConstants.eventCreatePaymentOrder(eventPaymentId);
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return EventPaymentOrderModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Failed to create payment order');
        return EventPaymentOrderModel(
          success: false,
          message: data['message'] ?? 'Failed to create payment order',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  /// Verify Cashfree payment after successful payment
  /// Laravel API expects: order_id (required), transaction_id (optional), signature (optional)
  static Future<EventPaymentVerifyModel?> verifyPayment({
    required int eventPaymentId,
    required String orderId,
    String? transactionId,
    String? signature,
  }) async {
    final url = ApiConstants.eventVerifyPayment(eventPaymentId);
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      final body = <String, dynamic>{
        'order_id': orderId,
      };

      // Add optional fields if provided
      if (transactionId != null) {
        body['transaction_id'] = transactionId;
      }
      if (signature != null) {
        body['signature'] = signature;
      }

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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return EventPaymentVerifyModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Payment verification failed');
        return EventPaymentVerifyModel(
          success: false,
          message: data['message'] ?? 'Payment verification failed',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  /// Get the status of an event payment
  /// Call this to check current payment status after payment process
  static Future<EventPaymentVerifyModel?> getEventPaymentStatus(int eventPaymentId) async {
    final url = ApiConstants.eventPaymentStatus(eventPaymentId);
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return EventPaymentVerifyModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Failed to get payment status');
        return EventPaymentVerifyModel(
          success: false,
          message: data['message'] ?? 'Failed to get payment status',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }
}
