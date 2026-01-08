import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

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
    final url = '${ApiConstants.baseUrl}/profile/privacy-settings';
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

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
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
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Failed to update privacy settings');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update privacy settings',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }

  static Future<Map<String, dynamic>?> getPrivacySettings() async {
    final url = '${ApiConstants.baseUrl}/profile';
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
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get privacy settings');
      }
      return null;
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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

  // ============================================================================
  // PRIVACY ENFORCEMENT HELPERS
  // ============================================================================
  // These methods help UI components respect OTHER users' privacy settings.
  // When displaying another user's profile, use these methods to filter data.
  // The privacy settings come from the API response for that user's profile.
  // ============================================================================

  /// Check if contact number should be displayed for a user
  /// [userPrivacySettings] - The privacy settings from the user's profile API response
  /// Returns the contact number if allowed, null otherwise
  static String? getDisplayableContactNumber(
    String? contactNumber,
    Map<String, dynamic>? userPrivacySettings,
  ) {
    if (contactNumber == null || contactNumber.isEmpty) return null;
    
    // Check user's privacy setting
    final showContactNumber = userPrivacySettings?['show_contact_number'] ?? false;
    return showContactNumber ? contactNumber : null;
  }

  /// Check if date of birth should be displayed for a user
  /// [userPrivacySettings] - The privacy settings from the user's profile API response
  /// Returns formatted DOB based on privacy settings (may hide year)
  static String? getDisplayableDateOfBirth(
    String? dateOfBirth,
    Map<String, dynamic>? userPrivacySettings,
  ) {
    if (dateOfBirth == null || dateOfBirth.isEmpty) return null;
    
    final showDateOfBirth = userPrivacySettings?['show_date_of_birth'] ?? true;
    if (!showDateOfBirth) return null;
    
    final hideDobYear = userPrivacySettings?['hide_dob_year'] ?? false;
    if (hideDobYear) {
      // Return only month and day (remove year)
      // Assuming format: YYYY-MM-DD or similar
      try {
        final parts = dateOfBirth.split('-');
        if (parts.length >= 3) {
          return '${parts[1]}-${parts[2]}'; // MM-DD
        }
      } catch (_) {}
    }
    
    return dateOfBirth;
  }

  /// Check if interests/hobbies should be displayed for a user
  static List<dynamic>? getDisplayableInterests(
    List<dynamic>? interests,
    Map<String, dynamic>? userPrivacySettings,
  ) {
    if (interests == null || interests.isEmpty) return null;
    
    final showInterests = userPrivacySettings?['show_interests_hobbies'] ?? true;
    return showInterests ? interests : null;
  }

  /// Check if expectations should be displayed for a user
  static String? getDisplayableExpectations(
    String? expectations,
    Map<String, dynamic>? userPrivacySettings,
  ) {
    if (expectations == null || expectations.isEmpty) return null;
    
    final showExpectations = userPrivacySettings?['show_expectations'] ?? true;
    return showExpectations ? expectations : null;
  }

  /// Check if gallery images should be displayed for a user
  static List<dynamic>? getDisplayableGalleryImages(
    List<dynamic>? galleryImages,
    Map<String, dynamic>? userPrivacySettings,
  ) {
    if (galleryImages == null || galleryImages.isEmpty) return null;
    
    final showGallery = userPrivacySettings?['show_gallery_images'] ?? true;
    return showGallery ? galleryImages : null;
  }

  /// Check if user's profile is public
  static bool isProfilePublic(Map<String, dynamic>? userPrivacySettings) {
    return userPrivacySettings?['is_public_profile'] ?? false;
  }

  /// Check if time spending feature is enabled for user
  static bool isTimeSpendingEnabled(Map<String, dynamic>? userPrivacySettings) {
    return userPrivacySettings?['is_time_spending_enabled'] ?? false;
  }

  /// Check if user is interested in sugar partner feature
  static bool isInterestedInSugarPartner(Map<String, dynamic>? userPrivacySettings) {
    return userPrivacySettings?['interested_in_sugar_partner'] ?? false;
  }

  /// Apply all privacy filters to a user profile map
  /// Returns a new map with privacy-filtered data
  /// [userProfile] - The full user profile from API
  /// [privacySettings] - Privacy settings (usually embedded in profile or separate)
  static Map<String, dynamic> applyPrivacyFilters(
    Map<String, dynamic> userProfile,
    Map<String, dynamic>? privacySettings,
  ) {
    // Create a copy to avoid modifying original
    final filtered = Map<String, dynamic>.from(userProfile);
    
    // Extract privacy settings from profile if not provided separately
    final privacy = privacySettings ?? {
      'show_contact_number': userProfile['show_contact_number'] ?? false,
      'show_date_of_birth': userProfile['show_date_of_birth'] ?? true,
      'hide_dob_year': userProfile['hide_dob_year'] ?? false,
      'show_interests_hobbies': userProfile['show_interests_hobbies'] ?? true,
      'show_expectations': userProfile['show_expectations'] ?? true,
      'show_gallery_images': userProfile['show_gallery_images'] ?? true,
      'is_public_profile': userProfile['is_public_profile'] ?? false,
    };
    
    // Apply contact number filter
    if (!(privacy['show_contact_number'] ?? false)) {
      filtered['contact_number'] = null;
      filtered['phone'] = null;
    }
    
    // Apply DOB filter
    if (!(privacy['show_date_of_birth'] ?? true)) {
      filtered['date_of_birth'] = null;
      filtered['dob'] = null;
    } else if (privacy['hide_dob_year'] ?? false) {
      // Keep DOB but mark year as hidden (UI should handle display)
      filtered['dob_year_hidden'] = true;
    }
    
    // Apply interests filter
    if (!(privacy['show_interests_hobbies'] ?? true)) {
      filtered['interests'] = null;
      filtered['hobbies'] = null;
    }
    
    // Apply expectations filter
    if (!(privacy['show_expectations'] ?? true)) {
      filtered['expectations'] = null;
    }
    
    // Apply gallery filter
    if (!(privacy['show_gallery_images'] ?? true)) {
      filtered['gallery'] = null;
      filtered['gallery_images'] = null;
    }
    
    return filtered;
  }
}
