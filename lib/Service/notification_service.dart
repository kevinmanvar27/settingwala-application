import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/GetnotificatonsModel.dart';
import '../utils/api_constants.dart';

class NotificationService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Notifications API
  static Future<GetnotificationsModel?> getNotifications({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/notifications?page=$page'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Notifications Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('================================================');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return _parseNotificationsResponse(json);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Notifications Error: $e');
      return null;
    }
  }

  // Parse JSON response to Model
  static GetnotificationsModel _parseNotificationsResponse(Map<String, dynamic> json) {
    // Parse notifications list
    List<NotificationItem> notifications = [];
    if (json['data']?['notifications'] != null) {
      for (var item in json['data']['notifications']) {
        notifications.add(NotificationItem(
          id: item['id'] ?? 0,
          type: item['type'] ?? '',
          title: item['title'] ?? '',
          message: item['message'] ?? '',
          data: _parseNotificationData(item['data']),
          readAt: item['read_at'] != null 
              ? DateTime.tryParse(item['read_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
          createdAt: item['created_at'] != null 
              ? DateTime.tryParse(item['created_at'].toString()) ?? DateTime.now()
              : DateTime.now(),
        ));
      }
    }

    // Parse pagination
    final paginationJson = json['data']?['pagination'];
    Pagination pagination = Pagination(
      currentPage: paginationJson?['current_page'] ?? 1,
      lastPage: paginationJson?['last_page'] ?? 1,
      perPage: paginationJson?['per_page'] ?? 10,
      total: paginationJson?['total'] ?? 0,
    );

    return GetnotificationsModel(
      success: json['success'] ?? false,
      data: GetnotificationsModelData(
        notifications: notifications,
        pagination: pagination,
      ),
    );
  }

  // Parse NotificationData
  static NotificationData _parseNotificationData(Map<String, dynamic>? json) {
    if (json == null) {
      return NotificationData(
        bookingId: 0,
        clientId: 0,
        providerId: 0,
        amount: '',
        durationHours: '',
        date: DateTime.now(),
        meetingLocation: '',
        notes: '',
      );
    }

    return NotificationData(
      bookingId: json['booking_id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      providerId: json['provider_id'] ?? 0,
      amount: json['amount']?.toString() ?? '',
      durationHours: json['duration_hours']?.toString() ?? '',
      date: json['date'] != null 
          ? DateTime.tryParse(json['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      meetingLocation: json['meeting_location'] ?? '',
      notes: json['notes'] ?? '',
      providerName: json['provider_name'],
      paymentStatus: json['payment_status'],
    );
  }
}
