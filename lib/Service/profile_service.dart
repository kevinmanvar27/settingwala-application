import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getprofilemodel.dart';
import '../utils/api_constants.dart';

class ProfileService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetProfileModel?> getProfile() async {
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
        return GetProfileModel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<GetProfileModel?> getUserProfile(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetProfileModel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  static Future<Map<String, dynamic>?> updateProfile({
    String? name,
    String? email,
    String? contactNumber,
    String? dateOfBirth,
    String? gender,
    double? height,
    double? weight,
    String? bodyType,
    String? education,
    String? occupation,
    String? income,
    String? relationshipStatus,
    String? smoking,
    String? drinking,
    List<String>? interests,
    List<String>? languages,
    String? expectation,
    String? iAm,
    String? iWant,
    String? city,
    String? state,
    String? country,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return null;
      }

      final Map<String, dynamic> body = {};

      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (contactNumber != null) body['contact_number'] = contactNumber;
      if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
      if (gender != null) body['gender'] = gender;
      if (height != null) body['height'] = height;
      if (weight != null) body['weight'] = weight;
      if (bodyType != null) body['body_type'] = bodyType;
      if (education != null) body['education'] = education;
      if (occupation != null) body['occupation'] = occupation;
      if (income != null) body['income'] = income;
      if (relationshipStatus != null) body['relationship_status'] = relationshipStatus;
      if (smoking != null) body['smoking'] = smoking;
      if (drinking != null) body['drinking'] = drinking;
      if (interests != null) body['interests'] = interests;
      if (languages != null) body['languages'] = languages;
      if (expectation != null) body['expectation'] = expectation;
      if (iAm != null) body['what_i_am'] = iAm;
      if (iWant != null) body['what_i_want'] = iWant;
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (country != null) body['country'] = country;

      
      
      

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'Failed to update profile'};
        }
      }
    } catch (e) {
      
      return {'success': false, 'message': e.toString()};
    }
  }

  static Future<Map<String, dynamic>?> updatePrivacySettings({
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
        
        return null;
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

      
      
      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'Failed to update privacy settings'};
        }
      }
    } catch (e) {
      
      return {'success': false, 'message': e.toString()};
    }
  }
}
