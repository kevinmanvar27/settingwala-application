import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getprofilemodel.dart';
import '../utils/api_constants.dart';

class ProfileService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // GET Profile API - Fetch current user's profile
  // Endpoint: GET /api/v1/profile
  static Future<GetProfileModel?> getProfile() async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
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

      print('========== GET Profile Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==========================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetProfileModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET Profile Error: $e');
      return null;
    }
  }

  // GET User Profile API - Fetch another user's profile by ID
  // Endpoint: GET /api/v1/users/{userId}
  static Future<GetProfileModel?> getUserProfile(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
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

      print('========== GET User Profile Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('================================================');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetProfileModel.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('GET User Profile Error: $e');
      return null;
    }
  }

  // PUT Profile API - Update user profile
  // Endpoint: PUT /api/v1/profile
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
    String? city,
    String? state,
    String? country,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      // Build request body - only include non-null values
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
      if (city != null) body['city'] = city;
      if (state != null) body['state'] = state;
      if (country != null) body['country'] = country;

      print('========== PUT Profile Request ==========');
      print('Body: ${jsonEncode(body)}');
      print('=========================================');

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== PUT Profile Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        // Return error response for better error handling
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'Failed to update profile'};
        }
      }
    } catch (e) {
      print('PUT Profile Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

  // PUT Privacy Settings API - Update privacy settings
  // Endpoint: PUT /api/v1/profile/privacy-settings
  static Future<Map<String, dynamic>?> updatePrivacySettings({
    bool? isPublicProfile,
    bool? showContactNumber,
    bool? showDateOfBirth,
    bool? hideDobYear,
    bool? showInterestsHobbies,
    bool? showExpectations,
    bool? showGalleryImages,
    bool? isTimeSpendingEnabled,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return null;
      }

      // Build request body - only include non-null values
      final Map<String, dynamic> body = {};

      if (isPublicProfile != null) body['is_public_profile'] = isPublicProfile;
      if (showContactNumber != null) body['show_contact_number'] = showContactNumber;
      if (showDateOfBirth != null) body['show_date_of_birth'] = showDateOfBirth;
      if (hideDobYear != null) body['hide_dob_year'] = hideDobYear;
      if (showInterestsHobbies != null) body['show_interests_hobbies'] = showInterestsHobbies;
      if (showExpectations != null) body['show_expectations'] = showExpectations;
      if (showGalleryImages != null) body['show_gallery_images'] = showGalleryImages;
      if (isTimeSpendingEnabled != null) body['is_time_spending_enabled'] = isTimeSpendingEnabled;

      print('========== PUT Privacy Settings Request ==========');
      print('Body: ${jsonEncode(body)}');
      print('==================================================');

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/profile/privacy-settings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== PUT Privacy Settings Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===================================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'Failed to update privacy settings'};
        }
      }
    } catch (e) {
      print('PUT Privacy Settings Error: $e');
      return {'success': false, 'message': e.toString()};
    }
  }
}
