import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

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
    };
  }
}

class EventService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<List<EventModel>> getEvents() async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/events'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          final eventsList = data['data']['events'] as List<dynamic>? ?? [];
          return eventsList.map((e) => EventModel.fromJson(e)).toList();
        }
      }
      return [];
    } catch (e) {
      
      return [];
    }
  }

  static Future<EventModel?> getEventDetails(int eventId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/events/$eventId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return EventModel.fromJson(data['data']['event']);
        }
      }
      return null;
    } catch (e) {
      
      return null;
    }
  }

  static Future<Map<String, dynamic>> joinEvent(int eventId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/events/$eventId/join'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': data['success'] ?? true,
          'message': data['message'] ?? 'Successfully joined the event',
          'payment_required': data['data']?['payment_required'] ?? false,
          'payment_amount': data['data']?['payment_amount'] ?? 0,
          'event_payment_id': data['data']?['event_payment_id'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to join event',
        };
      }
    } catch (e) {
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
}
