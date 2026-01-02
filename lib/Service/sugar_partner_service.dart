import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class SugarPartnerService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }

  static Future<SugarPartnerExchangesResponse> getExchanges({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchanges?page=$page';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerExchangesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Failed to get exchanges.',
        );
      }
    } catch (e) {
      
      return SugarPartnerExchangesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerExchangeDetailsResponse> getExchangeDetails(int exchangeId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerExchangeDetailsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Exchange not found.',
        );
      } else {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Failed to get exchange details.',
        );
      }
    } catch (e) {
      
      return SugarPartnerExchangeDetailsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<ViewProfilesResponse> viewProfiles(int exchangeId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ViewProfilesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/view-profiles';

      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ViewProfilesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ViewProfilesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 402) {
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Payment required to view profiles.',
          requiresPayment: true,
        );
      } else if (response.statusCode == 404) {
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else {
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to view profiles.',
        );
      }
    } catch (e) {
      
      return ViewProfilesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerActionResponse> respondToExchange(
      int exchangeId, {
        required String action,
        String? message,
      }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/respond';
      final body = {
        'action': action,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      
      
      
      

      final response = await http.post(
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
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot respond to this exchange.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else if (response.statusCode == 422) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid action.',
        );
      } else {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to respond to exchange.',
        );
      }
    } catch (e) {
      
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<ExchangePaymentResponse> getExchangePayment(int exchangeId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/payment';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ExchangePaymentResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Exchange or payment not found.',
        );
      } else {
        return ExchangePaymentResponse(
          success: false,
          message: 'Failed to get payment details.',
        );
      }
    } catch (e) {
      
      return ExchangePaymentResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<PendingCountResponse> getPendingCount() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return PendingCountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/pending-count';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return PendingCountResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return PendingCountResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return PendingCountResponse(
          success: false,
          message: 'Failed to get pending count.',
        );
      }
    } catch (e) {
      
      return PendingCountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerHistoryResponse> getHistory({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/history?page=$page';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerHistoryResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Failed to get history.',
        );
      }
    } catch (e) {
      
      return SugarPartnerHistoryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<HardRejectsResponse> getHardRejects({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return HardRejectsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/hard-rejects?page=$page';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return HardRejectsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return HardRejectsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return HardRejectsResponse(
          success: false,
          message: 'Failed to get hard rejects.',
        );
      }
    } catch (e) {
      
      return HardRejectsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerActionResponse> addHardReject(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/hard-reject/$userId';

      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot hard reject this user.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found.',
        );
      } else {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add hard reject.',
        );
      }
    } catch (e) {
      
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerActionResponse> removeHardReject(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/hard-reject/$userId';

      
      
      

      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found in hard reject list.',
        );
      } else {
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to remove hard reject.',
        );
      }
    } catch (e) {
      
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerPaymentsResponse> getPayments({int page = 1}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/sugar-partner/payments?page=$page';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return SugarPartnerPaymentsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Failed to get payments.',
        );
      }
    } catch (e) {
      
      return SugarPartnerPaymentsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerPreferencesResponse> updatePreferences({
    required String whatIAm,
    required List<String> whatIWant,
    String? bio,
    String? expectations,
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      const Map<String, String> uiToBackendIAm = {
        'I am Sugar Boy': 'sugar_boy',
        'I am Sugar Baby': 'sugar_babe',
        'I am Sugar Mummy': 'sugar_mommy',
        'I am Sugar Daddy': 'sugar_daddy',
      };

      const Map<String, String> uiToBackendIWant = {
        'I want Sugar Boy': 'sugar_boy',
        'I want Sugar Baby': 'sugar_babe',
        'I want Sugar Mummy': 'sugar_mommy',
        'I want Sugar Daddy': 'sugar_daddy',
      };

      final backendWhatIAm = uiToBackendIAm[whatIAm] ?? whatIAm;
      final backendWhatIWant = whatIWant.map((e) => uiToBackendIWant[e] ?? e).toList();

      final url = '${ApiConstants.baseUrl}/profile';
      final body = {
        'what_i_am': backendWhatIAm,
        'what_i_want': backendWhatIWant,
        'sugar_partner_bio': bio ?? '',
        'sugar_partner_expectations': expectations ?? '',
      };

      
      
      
      

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('sugar_partner_what_i_am', whatIAm);
        await prefs.setStringList('sugar_partner_what_i_want', whatIWant);
        if (bio != null) await prefs.setString('sugar_partner_bio', bio);
        if (expectations != null) await prefs.setString('sugar_partner_expectations', expectations);

        return SugarPartnerPreferencesResponse(
          success: true,
          message: responseData['message'] ?? 'Preferences saved successfully.',
          whatIAm: whatIAm,
          whatIWant: whatIWant,
          bio: bio,
          expectations: expectations,
        );
      } else if (response.statusCode == 401) {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 422) {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid preferences data.',
        );
      } else {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update preferences.',
        );
      }
    } catch (e) {
      
      return SugarPartnerPreferencesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerPreferencesResponse> getPreferences() async {
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/profile';

      
      
      

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      
      
      

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final userData = responseData['data']?['user'];

        if (userData != null) {
          final apiWhatIAm = userData['what_i_am'];
          final apiWhatIWant = userData['what_i_want'];
          final sugarPartnerBio = userData['sugar_partner_bio'];
          final sugarPartnerExpectations = userData['sugar_partner_expectations'];

          const Map<String, String> backendToUiIAm = {
            'sugar_boy': 'I am Sugar Boy',
            'sugar_babe': 'I am Sugar Baby',
            'sugar_mommy': 'I am Sugar Mummy',
            'sugar_daddy': 'I am Sugar Daddy',
          };

          const Map<String, String> backendToUiIWant = {
            'sugar_boy': 'I want Sugar Boy',
            'sugar_babe': 'I want Sugar Baby',
            'sugar_mommy': 'I want Sugar Mummy',
            'sugar_daddy': 'I want Sugar Daddy',
          };

          List<String>? whatIWant;
          if (apiWhatIWant != null) {
            List<dynamic> rawList = [];
            if (apiWhatIWant is List) {
              rawList = apiWhatIWant;
            } else if (apiWhatIWant is String && apiWhatIWant.isNotEmpty) {
              try {
                final parsed = jsonDecode(apiWhatIWant);
                if (parsed is List) {
                  rawList = parsed;
                }
              } catch (_) {
                rawList = [apiWhatIWant];
              }
            }
            whatIWant = rawList
                .map((e) => backendToUiIWant[e.toString()] ?? e.toString())
                .toList();
          }

          String? whatIAm;
          if (apiWhatIAm != null && apiWhatIAm.toString().isNotEmpty) {
            whatIAm = backendToUiIAm[apiWhatIAm.toString()] ?? apiWhatIAm.toString();
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('sugar_partner_what_i_am', whatIAm);
          } else {
            final prefs = await SharedPreferences.getInstance();
            whatIAm = prefs.getString('sugar_partner_what_i_am');
          }

          return SugarPartnerPreferencesResponse(
            success: true,
            message: 'Preferences loaded successfully.',
            whatIAm: whatIAm,
            whatIWant: whatIWant,
            bio: sugarPartnerBio?.toString(),
            expectations: sugarPartnerExpectations?.toString(),
          );
        }

        return SugarPartnerPreferencesResponse(
          success: true,
          message: 'No preferences set yet.',
        );
      } else if (response.statusCode == 401) {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Failed to get preferences.',
        );
      }
    } catch (e) {
      
      return SugarPartnerPreferencesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}


class SugarPartnerExchangesResponse {
  final bool success;
  final String message;
  final List<SugarPartnerExchange> data;
  final SugarPartnerPaginationMeta? pagination;

  SugarPartnerExchangesResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory SugarPartnerExchangesResponse.fromJson(Map<String, dynamic> json) {
    final dataObj = json['data'];
    List<dynamic>? exchangesList;
    Map<String, dynamic>? paginationObj;

    if (dataObj != null && dataObj is Map<String, dynamic>) {
      exchangesList = dataObj['exchanges'] as List<dynamic>?;
      paginationObj = dataObj['pagination'] as Map<String, dynamic>?;
    } else if (dataObj != null && dataObj is List) {
      exchangesList = dataObj;
      paginationObj = json['pagination'] as Map<String, dynamic>?;
    }

    return SugarPartnerExchangesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: exchangesList != null
          ? exchangesList
          .map((item) => SugarPartnerExchange.fromJson(item))
          .toList()
          : [],
      pagination: paginationObj != null
          ? SugarPartnerPaginationMeta.fromJson(paginationObj)
          : null,
    );
  }
}

class SugarPartnerExchange {
  final int id;
  final int initiatorId;
  final int receiverId;
  final String status;
  final String? exchangeType;
  final double? amount;
  final String? message;
  final String? createdAt;
  final String? updatedAt;
  final String? expiresAt;
  final SugarPartnerUser? initiator;
  final SugarPartnerUser? receiver;
  final bool? profilesViewed;
  final bool? requiresPayment;

  SugarPartnerExchange({
    required this.id,
    required this.initiatorId,
    required this.receiverId,
    required this.status,
    this.exchangeType,
    this.amount,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
    this.initiator,
    this.receiver,
    this.profilesViewed,
    this.requiresPayment,
  });

  factory SugarPartnerExchange.fromJson(Map<String, dynamic> json) {
    return SugarPartnerExchange(
      id: json['id'] ?? 0,
      initiatorId: json['initiator_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      status: json['status'] ?? 'pending',
      exchangeType: json['exchange_type'] ?? json['type'],
      amount: json['amount'] != null ? (json['amount']).toDouble() : null,
      message: json['message'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      expiresAt: json['expires_at'],
      initiator: json['initiator'] != null
          ? SugarPartnerUser.fromJson(json['initiator'])
          : null,
      receiver: json['receiver'] != null
          ? SugarPartnerUser.fromJson(json['receiver'])
          : null,
      profilesViewed: SugarPartnerService._parseBool(json['profiles_viewed']),
      requiresPayment: SugarPartnerService._parseBool(json['requires_payment']),
    );
  }
}

class SugarPartnerUser {
  final int id;
  final String? name;
  final String? email;
  final String? profilePhoto;
  final int? age;
  final String? gender;
  final String? city;
  final double? rating;
  final bool? isVerified;
  final String? bio;

  SugarPartnerUser({
    required this.id,
    this.name,
    this.email,
    this.profilePhoto,
    this.age,
    this.gender,
    this.city,
    this.rating,
    this.isVerified,
    this.bio,
  });

  factory SugarPartnerUser.fromJson(Map<String, dynamic> json) {
    return SugarPartnerUser(
      id: json['id'] ?? 0,
      name: json['name'],
      email: json['email'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      age: json['age'],
      gender: json['gender'],
      city: json['city'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      isVerified: SugarPartnerService._parseBool(json['is_verified']),
      bio: json['bio'],
    );
  }
}

class SugarPartnerExchangeDetailsResponse {
  final bool success;
  final String message;
  final SugarPartnerExchange? data;

  SugarPartnerExchangeDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SugarPartnerExchangeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerExchangeDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerExchange.fromJson(json['data'])
          : null,
    );
  }
}

class ViewProfilesResponse {
  final bool success;
  final String message;
  final List<SugarPartnerUser> profiles;
  final bool requiresPayment;
  final double? paymentAmount;

  ViewProfilesResponse({
    required this.success,
    required this.message,
    this.profiles = const [],
    this.requiresPayment = false,
    this.paymentAmount,
  });

  factory ViewProfilesResponse.fromJson(Map<String, dynamic> json) {
    return ViewProfilesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      profiles: json['data']?['profiles'] != null
          ? (json['data']['profiles'] as List)
          .map((item) => SugarPartnerUser.fromJson(item))
          .toList()
          : (json['profiles'] != null
          ? (json['profiles'] as List)
          .map((item) => SugarPartnerUser.fromJson(item))
          .toList()
          : []),
      requiresPayment: SugarPartnerService._parseBool(json['requires_payment']),
      paymentAmount: json['payment_amount'] != null
          ? (json['payment_amount']).toDouble()
          : null,
    );
  }
}

class SugarPartnerActionResponse {
  final bool success;
  final String message;
  final SugarPartnerExchange? data;

  SugarPartnerActionResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SugarPartnerActionResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerActionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerExchange.fromJson(json['data'])
          : null,
    );
  }
}

class ExchangePaymentResponse {
  final bool success;
  final String message;
  final SugarPartnerPayment? data;

  ExchangePaymentResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ExchangePaymentResponse.fromJson(Map<String, dynamic> json) {
    return ExchangePaymentResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerPayment.fromJson(json['data'])
          : null,
    );
  }
}

class SugarPartnerPayment {
  final int id;
  final int exchangeId;
  final int userId;
  final double amount;
  final String status;
  final String? paymentMethod;
  final String? transactionId;
  final String? createdAt;
  final String? completedAt;
  final Map<String, dynamic>? metadata;

  SugarPartnerPayment({
    required this.id,
    required this.exchangeId,
    required this.userId,
    required this.amount,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.createdAt,
    this.completedAt,
    this.metadata,
  });

  factory SugarPartnerPayment.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPayment(
      id: json['id'] ?? 0,
      exchangeId: json['exchange_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      amount: json['amount'] != null ? (json['amount']).toDouble() : 0.0,
      status: json['status'] ?? 'pending',
      paymentMethod: json['payment_method'],
      transactionId: json['transaction_id'],
      createdAt: json['created_at'],
      completedAt: json['completed_at'],
      metadata: json['metadata'],
    );
  }
}

class PendingCountResponse {
  final bool success;
  final String message;
  final int count;

  PendingCountResponse({
    required this.success,
    required this.message,
    this.count = 0,
  });

  factory PendingCountResponse.fromJson(Map<String, dynamic> json) {
    return PendingCountResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['data']?['count'] ?? json['count'] ?? 0,
    );
  }
}

class SugarPartnerHistoryResponse {
  final bool success;
  final String message;
  final List<SugarPartnerExchange> data;
  final SugarPartnerPaginationMeta? pagination;

  SugarPartnerHistoryResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory SugarPartnerHistoryResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => SugarPartnerExchange.fromJson(item))
          .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class HardRejectsResponse {
  final bool success;
  final String message;
  final List<HardRejectUser> data;
  final SugarPartnerPaginationMeta? pagination;

  HardRejectsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory HardRejectsResponse.fromJson(Map<String, dynamic> json) {
    return HardRejectsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => HardRejectUser.fromJson(item))
          .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}

class HardRejectUser {
  final int id;
  final int rejectedUserId;
  final String? rejectedAt;
  final SugarPartnerUser? user;

  HardRejectUser({
    required this.id,
    required this.rejectedUserId,
    this.rejectedAt,
    this.user,
  });

  factory HardRejectUser.fromJson(Map<String, dynamic> json) {
    return HardRejectUser(
      id: json['id'] ?? 0,
      rejectedUserId: json['rejected_user_id'] ?? 0,
      rejectedAt: json['rejected_at'] ?? json['created_at'],
      user: json['user'] != null
          ? SugarPartnerUser.fromJson(json['user'])
          : null,
    );
  }
}

class SugarPartnerPaymentsResponse {
  final bool success;
  final String message;
  final List<SugarPartnerPayment> data;
  final SugarPartnerPaginationMeta? pagination;
  final double? totalAmount;

  SugarPartnerPaymentsResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
    this.totalAmount,
  });

  factory SugarPartnerPaymentsResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPaymentsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? (json['data'] as List)
          .map((item) => SugarPartnerPayment.fromJson(item))
          .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
      totalAmount: json['total_amount'] != null
          ? (json['total_amount']).toDouble()
          : null,
    );
  }
}

class SugarPartnerPaginationMeta {
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SugarPartnerPaginationMeta({
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory SugarPartnerPaginationMeta.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPaginationMeta(
      currentPage: json['current_page'] ?? 1,
      lastPage: json['last_page'] ?? 1,
      perPage: json['per_page'] ?? 10,
      total: json['total'] ?? 0,
    );
  }
}

class SugarPartnerPreferencesResponse {
  final bool success;
  final String message;
  final String? whatIAm;
  final List<String>? whatIWant;
  final String? bio;
  final String? expectations;

  SugarPartnerPreferencesResponse({
    required this.success,
    required this.message,
    this.whatIAm,
    this.whatIWant,
    this.bio,
    this.expectations,
  });

  factory SugarPartnerPreferencesResponse.fromJson(Map<String, dynamic> json) {
    List<String>? whatIWantList;
    if (json['what_i_want'] != null) {
      if (json['what_i_want'] is List) {
        whatIWantList = List<String>.from(json['what_i_want']);
      } else if (json['what_i_want'] is String) {
        whatIWantList = (json['what_i_want'] as String).split(',').map((e) => e.trim()).toList();
      }
    }

    return SugarPartnerPreferencesResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      whatIAm: json['what_i_am'],
      whatIWant: whatIWantList,
      bio: json['bio'],
      expectations: json['expectations'],
    );
  }
}
