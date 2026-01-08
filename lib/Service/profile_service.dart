import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getprofilemodel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class ProfileService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<GetProfileModel?> getProfile() async {
    final url = '${ApiConstants.baseUrl}/profile';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return GetProfileModel.fromJson(data);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  static Future<GetProfileModel?> getUserProfile(int userId) async {
    final url = '${ApiConstants.baseUrl}/users/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // API call થઈ રહી છે
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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return GetProfileModel.fromJson(data);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return null;
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/profile';
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

      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return data;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to update profile');
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'Failed to update profile'};
        }
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/profile/privacy-settings';
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

      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return data;
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to update privacy settings');
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {'success': false, 'message': 'Failed to update privacy settings'};
        }
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return {'success': false, 'message': e.toString()};
    }
  }

  /// Update couple activity settings
  /// Enables/disables couple activity feature for the user
  static Future<ProfileUpdateResponse> updateCoupleActivitySettings({
    required bool isCoupleActivityEnabled,
  }) async {
    final url = '${ApiConstants.baseUrl}/profile/couple-activity';
    try {
      final token = await _getToken();

      if (token == null) {
        return ProfileUpdateResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'is_couple_activity_enabled': isCoupleActivityEnabled,
      };

      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      final response = await http.put(
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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return ProfileUpdateResponse.fromJson(responseData);
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: 403, error: responseData['message'] ?? 'Couple Activity feature not available');
        return ProfileUpdateResponse(
          success: false,
          message: responseData['message'] ?? 'Couple Activity feature is not available.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to update couple activity settings');
        return ProfileUpdateResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update couple activity settings.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return ProfileUpdateResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Update sugar partner settings
  /// Sets sugar partner types, bio, and expectations
  static Future<ProfileUpdateResponse> updateSugarPartnerSettings({
    String? whatIAm, // sugar_daddy, sugar_mommy, sugar_boy, sugar_babe
    List<String>? whatIWant, // List of sugar partner types user is looking for
    String? sugarPartnerBio,
    String? sugarPartnerExpectations,
  }) async {
    final url = '${ApiConstants.baseUrl}/profile/sugar-partner';
    try {
      final token = await _getToken();

      if (token == null) {
        return ProfileUpdateResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (whatIAm != null) body['what_i_am'] = whatIAm;
      if (whatIWant != null) body['what_i_want'] = whatIWant;
      if (sugarPartnerBio != null) body['sugar_partner_bio'] = sugarPartnerBio;
      if (sugarPartnerExpectations != null) body['sugar_partner_expectations'] = sugarPartnerExpectations;

      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      final response = await http.put(
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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return ProfileUpdateResponse.fromJson(responseData);
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: 403, error: responseData['message'] ?? 'Sugar Partner feature not available');
        return ProfileUpdateResponse(
          success: false,
          message: responseData['message'] ?? 'Sugar Partner feature is not available.',
        );
      } else if (response.statusCode == 422) {
        // Validation error - likely missing gallery images
        ApiLogger.logApiError(endpoint: url, statusCode: 422, error: responseData['message'] ?? 'Validation error');
        return ProfileUpdateResponse(
          success: false,
          message: responseData['message'] ?? 'Please upload photos to your gallery first.',
          errors: responseData['errors'],
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to update sugar partner settings');
        return ProfileUpdateResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update sugar partner settings.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return ProfileUpdateResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

// ============================================
// Profile Update Response Model
// ============================================

class ProfileUpdateResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? errors;

  ProfileUpdateResponse({
    required this.success,
    this.message,
    this.user,
    this.errors,
  });

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    return ProfileUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'],
      user: json['data']?['user'],
      errors: json['errors'],
    );
  }
}
