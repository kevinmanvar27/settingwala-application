import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/PuttimespendingModel.dart';
import '../utils/api_constants.dart';

class TimeSpendingService {
  // Get auth token from SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // PUT Time Spending API - Update time spending data
  Future<PuttimespendingModel?> updateTimeSpending({
    required int hourlyRate,
    required String serviceLocation,
    required AvailabilitySchedule availabilitySchedule,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      // Build request body
      final Map<String, dynamic> body = {
        'hourly_rate': hourlyRate,
        'service_location': serviceLocation,
        'availability_schedule': availabilitySchedule.toJson(),
      };

      print('========== PUT Time Spending Request ==========');
      print('URL: ${ApiConstants.baseUrl}/profile/time-spending');
      print('Body: ${jsonEncode(body)}');
      print('================================================');

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/profile/time-spending'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== PUT Time Spending Response ==========');
      print('========== PUT Time Spending Response ==========');
      print('========== PUT Time Spending Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PuttimespendingModel.fromJson(responseData);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('PUT Time Spending Error: $e');
      return null;
    }
  }
}
