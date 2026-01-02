import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class PrivacySettingsService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<Map<String, dynamic>> updatePrivacySettings({
    bool? isPublicProfile,
    bool? showContactNumber,
    bool? showDateOfBirth,
    bool? hideDobYear,
    bool? showInterestsHobbies,
    bool? showExpectations,
    bool? showGalleryImages,
    bool? isTimeSpendingEnabled,
    bool? interestedInSugarPartner,
    bool? hideSugarPartnerNotifications,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'Authentication required',
        };
      }

      final Map<String, dynamic> body = {};

      if (isPublicProfile != null) body['is_public_profile'] = isPublicProfile;
      if (showContactNumber != null) body['show_contact_number'] = showContactNumber;
      if (showDateOfBirth != null) body['show_date_of_birth'] = showDateOfBirth;
      if (hideDobYear != null) body['hide_dob_year'] = hideDobYear;
      if (showInterestsHobbies != null) body['show_interests_hobbies'] = showInterestsHobbies;
      if (showExpectations != null) body['show_expectations'] = showExpectations;
      if (showGalleryImages != null) body['show_gallery_images'] = showGalleryImages;
      if (isTimeSpendingEnabled != null) body['is_time_spending_enabled'] = isTimeSpendingEnabled;
      if (interestedInSugarPartner != null) body['interested_in_sugar_partner'] = interestedInSugarPartner;
      if (hideSugarPartnerNotifications != null) body['hide_sugar_partner_notifications'] = hideSugarPartnerNotifications;

      
      
      

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/profile/privacy-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
      
      

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        if (isPublicProfile != null) await prefs.setBool('is_public_profile', isPublicProfile);
        if (showContactNumber != null) await prefs.setBool('show_contact_number', showContactNumber);
        if (showDateOfBirth != null) await prefs.setBool('show_date_of_birth', showDateOfBirth);
        if (hideDobYear != null) await prefs.setBool('hide_dob_year', hideDobYear);
        if (showInterestsHobbies != null) await prefs.setBool('show_interests_hobbies', showInterestsHobbies);
        if (showExpectations != null) await prefs.setBool('show_expectations', showExpectations);
        if (showGalleryImages != null) await prefs.setBool('show_gallery_images', showGalleryImages);
        if (isTimeSpendingEnabled != null) await prefs.setBool('is_time_spending_enabled', isTimeSpendingEnabled);
        if (interestedInSugarPartner != null) await prefs.setBool('interested_in_sugar_partner', interestedInSugarPartner);
        if (hideSugarPartnerNotifications != null) await prefs.setBool('hide_sugar_partner_notifications', hideSugarPartnerNotifications);

        return {
          'success': true,
          'message': data['message'] ?? 'Privacy settings updated successfully',
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update privacy settings',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>?> getPrivacySettings() async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data']?['user'] != null) {
          final user = data['data']['user'];
          
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('is_public_profile', user['is_public_profile'] ?? false);
          await prefs.setBool('show_contact_number', user['show_contact_number'] ?? false);
          await prefs.setBool('show_date_of_birth', user['show_date_of_birth'] ?? true);
          await prefs.setBool('hide_dob_year', user['hide_dob_year'] ?? false);
          await prefs.setBool('show_interests_hobbies', user['show_interests_hobbies'] ?? true);
          await prefs.setBool('show_expectations', user['show_expectations'] ?? true);
          await prefs.setBool('show_gallery_images', user['show_gallery_images'] ?? true);
          await prefs.setBool('is_time_spending_enabled', user['is_time_spending_enabled'] ?? false);
          await prefs.setBool('interested_in_sugar_partner', user['interested_in_sugar_partner'] ?? false);
          await prefs.setBool('hide_sugar_partner_notifications', user['hide_sugar_partner_notifications'] ?? false);

          return {
            'is_public_profile': user['is_public_profile'] ?? false,
            'show_contact_number': user['show_contact_number'] ?? false,
            'show_date_of_birth': user['show_date_of_birth'] ?? true,
            'hide_dob_year': user['hide_dob_year'] ?? false,
            'show_interests_hobbies': user['show_interests_hobbies'] ?? true,
            'show_expectations': user['show_expectations'] ?? true,
            'show_gallery_images': user['show_gallery_images'] ?? true,
            'is_time_spending_enabled': user['is_time_spending_enabled'] ?? false,
            'interested_in_sugar_partner': user['interested_in_sugar_partner'] ?? false,
            'hide_sugar_partner_notifications': user['hide_sugar_partner_notifications'] ?? false,
          };
        }
      }
      return null;
    } catch (e) {
      
      return null;
    }
  }

  static Future<Map<String, dynamic>> getOfflinePrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'is_public_profile': prefs.getBool('is_public_profile') ?? false,
      'show_contact_number': prefs.getBool('show_contact_number') ?? false,
      'show_date_of_birth': prefs.getBool('show_date_of_birth') ?? true,
      'hide_dob_year': prefs.getBool('hide_dob_year') ?? false,
      'show_interests_hobbies': prefs.getBool('show_interests_hobbies') ?? true,
      'show_expectations': prefs.getBool('show_expectations') ?? true,
      'show_gallery_images': prefs.getBool('show_gallery_images') ?? true,
      'is_time_spending_enabled': prefs.getBool('is_time_spending_enabled') ?? false,
      'interested_in_sugar_partner': prefs.getBool('interested_in_sugar_partner') ?? false,
      'hide_sugar_partner_notifications': prefs.getBool('hide_sugar_partner_notifications') ?? false,
    };
  }
}
