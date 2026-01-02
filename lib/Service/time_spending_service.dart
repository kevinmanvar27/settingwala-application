import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/PuttimespendingModel.dart';
import '../utils/api_constants.dart';

class TimeSpendingService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<PuttimespendingModel?> updateTimeSpending({
    required int hourlyRate,
    required String serviceLocation,
    required AvailabilitySchedule availabilitySchedule,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final Map<String, dynamic> body = {
        'hourly_rate': hourlyRate,
        'service_location': serviceLocation,
        'availability_schedule': availabilitySchedule.toJson(),
      };

      
      
      
      

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/profile/time-spending'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PuttimespendingModel.fromJson(responseData);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }
}
