import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

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

  // Helper to safely parse double from dynamic value (handles String, int, double)
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static Future<SugarPartnerExchangesResponse> getExchanges({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/exchanges?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return SugarPartnerExchangesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get exchanges');
        return SugarPartnerExchangesResponse(
          success: false,
          message: 'Failed to get exchanges.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerExchangesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerExchangeDetailsResponse> getExchangeDetails(int exchangeId) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return SugarPartnerExchangeDetailsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Exchange not found');
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Exchange not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get exchange details - Response: ${response.body}');
        return SugarPartnerExchangeDetailsResponse(
          success: false,
          message: 'Failed to get exchange details.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerExchangeDetailsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<ViewProfilesResponse> viewProfiles(int exchangeId) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/view-profiles';
    try {
      final token = await _getToken();

      if (token == null) {
        return ViewProfilesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return ViewProfilesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return ViewProfilesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 402) {
        ApiLogger.logApiError(endpoint: url, statusCode: 402, error: 'Payment required');
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Payment required to view profiles.',
          requiresPayment: true,
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Exchange not found');
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to view profiles');
        return ViewProfilesResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to view profiles.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/respond';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // FIX: API Section 15.4 expects 'response' not 'action'
      // Valid values: "accept", "soft_reject", "hard_reject"
      final body = {
        'response': action,
        if (message != null && message.isNotEmpty) 'message': message,
      };

      // Log API call with body
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Cannot respond to this exchange');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot respond to this exchange.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Exchange not found');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else if (response.statusCode == 422) {
        ApiLogger.logApiError(endpoint: url, statusCode: 422, error: 'Invalid action');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid action.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to respond to exchange');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to respond to exchange.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<ExchangePaymentResponse> getExchangePayment(int exchangeId) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/payment';
    try {
      final token = await _getToken();

      if (token == null) {
        return ExchangePaymentResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return ExchangePaymentResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return ExchangePaymentResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Exchange or payment not found');
        return ExchangePaymentResponse(
          success: false,
          message: 'Exchange or payment not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get payment details');
        return ExchangePaymentResponse(
          success: false,
          message: 'Failed to get payment details.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return ExchangePaymentResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Process payment for a Sugar Partner exchange
  /// Supports wallet-only, wallet+cashfree, or cashfree-only payments
  static Future<SugarPartnerPaymentProcessResponse> processPayment({
    required int exchangeId,
    required String paymentMethod, // 'wallet', 'wallet_cashfree', 'cashfree'
    String? cfOrderId,
    String? cfTransactionId,
    double walletAmountUsed = 0.0,
  }) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/exchange/$exchangeId/process-payment';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPaymentProcessResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final Map<String, dynamic> body = {
        'payment_method': paymentMethod,
        'wallet_amount_used': walletAmountUsed,
      };

      if (cfOrderId != null && cfOrderId.isNotEmpty) {
        body['cf_order_id'] = cfOrderId;
      }
      if (cfTransactionId != null && cfTransactionId.isNotEmpty) {
        body['cf_transaction_id'] = cfTransactionId;
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'payment_method': paymentMethod, 'wallet_amount_used': walletAmountUsed});

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return SugarPartnerPaymentProcessResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerPaymentProcessResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Invalid payment request');
        return SugarPartnerPaymentProcessResponse(
          success: false,
          message: responseData['message'] ?? 'Invalid payment request.',
        );
      } else if (response.statusCode == 402) {
        ApiLogger.logApiError(endpoint: url, statusCode: 402, error: responseData['message'] ?? 'Payment failed');
        return SugarPartnerPaymentProcessResponse(
          success: false,
          message: responseData['message'] ?? 'Payment failed. Insufficient balance.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'Exchange not found');
        return SugarPartnerPaymentProcessResponse(
          success: false,
          message: responseData['message'] ?? 'Exchange not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to process payment');
        return SugarPartnerPaymentProcessResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to process payment.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerPaymentProcessResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<PendingCountResponse> getPendingCount() async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/pending-count';
    try {
      final token = await _getToken();

      if (token == null) {
        return PendingCountResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return PendingCountResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return PendingCountResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get pending count');
        return PendingCountResponse(
          success: false,
          message: 'Failed to get pending count.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return PendingCountResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerHistoryResponse> getHistory({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/history?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return SugarPartnerHistoryResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get history');
        return SugarPartnerHistoryResponse(
          success: false,
          message: 'Failed to get history.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerHistoryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<HardRejectsResponse> getHardRejects({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/hard-rejects?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return HardRejectsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return HardRejectsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return HardRejectsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get hard rejects');
        return HardRejectsResponse(
          success: false,
          message: 'Failed to get hard rejects.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return HardRejectsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerActionResponse> addHardReject(int userId, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/hard-reject/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // FIX: API Section 15.9 requires 'reason' in body
      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: 400, error: responseData['message'] ?? 'Cannot hard reject this user');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot hard reject this user.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to add hard reject');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to add hard reject.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerActionResponse> removeHardReject(int userId) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/hard-reject/$userId';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerActionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
      ApiLogger.logApiCall(endpoint: url, method: 'DELETE');

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
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return SugarPartnerActionResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerActionResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: 'User not found in hard reject list');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'User not found in hard reject list.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to remove hard reject');
        return SugarPartnerActionResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to remove hard reject.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerActionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerPaymentsResponse> getPayments({int page = 1}) async {
    final url = '${ApiConstants.baseUrl}/sugar-partner/payments?page=$page';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        return SugarPartnerPaymentsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get payments');
        return SugarPartnerPaymentsResponse(
          success: false,
          message: 'Failed to get payments.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
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
    // FIX: Use correct endpoint for sugar partner settings
    final url = '${ApiConstants.baseUrl}/profile/sugar-partner';
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

      // FIX: Send what_i_want as proper array, not JSON encoded string
      final body = <String, dynamic>{
        'what_i_am': backendWhatIAm,
        'what_i_want': backendWhatIWant, // Send as array, not jsonEncode
      };

      // Only add optional fields if they have values
      if (bio != null && bio.isNotEmpty) {
        body['sugar_partner_bio'] = bio;
      }
      if (expectations != null && expectations.isNotEmpty) {
        body['sugar_partner_expectations'] = expectations;
      }

      // Log API call with body
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
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
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: 403, error: responseData['message'] ?? 'Sugar Partner feature not available');
        // Sugar Partner feature not available (privacy setting disabled or no gallery images)
        return SugarPartnerPreferencesResponse(
          success: false,
          message: responseData['message'] ?? 'Sugar Partner feature is not available. Please enable it in privacy settings.',
        );
      } else if (response.statusCode == 422) {
        ApiLogger.logApiError(endpoint: url, statusCode: 422, error: responseData['message'] ?? 'Validation error');
        // Validation error - likely missing gallery images
        return SugarPartnerPreferencesResponse(
          success: false,
          message: responseData['message'] ?? 'Please upload photos to your gallery first.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message'] ?? 'Failed to update preferences');
        return SugarPartnerPreferencesResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update preferences.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerPreferencesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<SugarPartnerPreferencesResponse> getPreferences() async {
    final url = '${ApiConstants.baseUrl}/profile';
    try {
      final token = await _getToken();

      if (token == null) {
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // Log API call
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
        final responseData = jsonDecode(response.body);
        final userData = responseData['data']?['user'];

        if (userData != null) {
          // FIX: API returns sugar_partner_types as combined array, NOT what_i_am/what_i_want separately
          final sugarPartnerTypes = userData['sugar_partner_types'];
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

          // Identity types - the first one found is "what I am"
          const identityTypes = ['sugar_daddy', 'sugar_mommy', 'sugar_boy', 'sugar_babe'];

          String? whatIAm;
          List<String> whatIWant = [];

          if (sugarPartnerTypes != null && sugarPartnerTypes is List && sugarPartnerTypes.isNotEmpty) {
            // Find what_i_am (first identity type in the list)
            String? foundIdentity;
            for (final type in sugarPartnerTypes) {
              if (identityTypes.contains(type.toString())) {
                foundIdentity = type.toString();
                break;
              }
            }

            if (foundIdentity != null) {
              whatIAm = backendToUiIAm[foundIdentity];

              // what_i_want = all other types except the identity
              for (final type in sugarPartnerTypes) {
                final typeStr = type.toString();
                if (typeStr != foundIdentity && identityTypes.contains(typeStr)) {
                  final uiValue = backendToUiIWant[typeStr];
                  if (uiValue != null) {
                    whatIWant.add(uiValue);
                  }
                }
              }
            }
          }

          // Save to SharedPreferences for offline access
          final prefs = await SharedPreferences.getInstance();
          if (whatIAm != null) {
            await prefs.setString('sugar_partner_what_i_am', whatIAm);
          }
          if (whatIWant.isNotEmpty) {
            await prefs.setStringList('sugar_partner_what_i_want', whatIWant);
          }
          if (sugarPartnerBio != null) {
            await prefs.setString('sugar_partner_bio', sugarPartnerBio.toString());
          }
          if (sugarPartnerExpectations != null) {
            await prefs.setString('sugar_partner_expectations', sugarPartnerExpectations.toString());
          }

          return SugarPartnerPreferencesResponse(
            success: true,
            message: 'Preferences loaded successfully.',
            whatIAm: whatIAm,
            whatIWant: whatIWant.isNotEmpty ? whatIWant : null,
            bio: sugarPartnerBio?.toString(),
            expectations: sugarPartnerExpectations?.toString(),
          );
        }

        return SugarPartnerPreferencesResponse(
          success: true,
          message: 'No preferences set yet.',
        );
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get preferences');
        return SugarPartnerPreferencesResponse(
          success: false,
          message: 'Failed to get preferences.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SugarPartnerPreferencesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // REMOVED: getSugarPartnerRequests() - Endpoint /sugar-partners/requests does NOT exist. Use getExchanges() instead.
  // REMOVED: respondToSugarPartnerRequest() - Endpoint /sugar-partners/requests/{id}/respond does NOT exist. Use respondToExchange() instead.
  // REMOVED: getMySugarPartners() - Endpoint /sugar-partners/my-partners does NOT exist. Use getExchanges() with status filter.
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
      exchangesList = dataObj['exchanges'] as List<dynamic>? ;
      paginationObj = dataObj['pagination'] as Map<String, dynamic>? ;
    } else if (dataObj != null && dataObj is List) {
      exchangesList = dataObj;
      paginationObj = json['pagination'] as Map<String, dynamic>? ;
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
      amount: SugarPartnerService._parseDouble(json['amount']),
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
      age: json['age'] != null ? (json['age'] is int ? json['age'] : (json['age'] as num).toInt()) : null,
      gender: json['gender'],
      city: json['city'],
      rating: SugarPartnerService._parseDouble(json['rating']),
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
      paymentAmount: SugarPartnerService._parseDouble(json['payment_amount']),
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
  final ExchangePaymentData? data;

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
          ? ExchangePaymentData.fromJson(json['data'])
          : null,
    );
  }
}

/// Payment data for Sugar Partner exchange
/// Contains amount breakdown, wallet balance, and Cashfree order details
class ExchangePaymentData {
  final int? exchangeId;
  final double? amount;
  final double? platformFee;
  final double? totalAmount;
  final String? paymentStatus;
  final double? walletBalance;
  final double? walletUsage;
  final double? cashfreeAmount;
  final bool? paymentRequired;
  final SugarPartnerCashfreeOrder? cashfreeOrder;
  final String? cashfreeKey;
  final String? cashfreeEnv;
  final SugarPartnerUser? otherUser;

  ExchangePaymentData({
    this.exchangeId,
    this.amount,
    this.platformFee,
    this.totalAmount,
    this.paymentStatus,
    this.walletBalance,
    this.walletUsage,
    this.cashfreeAmount,
    this.paymentRequired,
    this.cashfreeOrder,
    this.cashfreeKey,
    this.cashfreeEnv,
    this.otherUser,
  });

  factory ExchangePaymentData.fromJson(Map<String, dynamic> json) {
    return ExchangePaymentData(
      exchangeId: json['exchange_id'],
      amount: SugarPartnerService._parseDouble(json['amount']),
      platformFee: SugarPartnerService._parseDouble(json['platform_fee']),
      totalAmount: SugarPartnerService._parseDouble(json['total_amount']),
      paymentStatus: json['payment_status'],
      walletBalance: SugarPartnerService._parseDouble(json['wallet_balance']),
      walletUsage: SugarPartnerService._parseDouble(json['wallet_usage']),
      cashfreeAmount: SugarPartnerService._parseDouble(json['cashfree_amount']),
      paymentRequired: SugarPartnerService._parseBool(json['payment_required']),
      cashfreeOrder: json['cashfree_order'] != null
          ? SugarPartnerCashfreeOrder.fromJson(json['cashfree_order'])
          : null,
      cashfreeKey: json['cashfree_key'],
      cashfreeEnv: json['cashfree_env'],
      otherUser: json['other_user'] != null
          ? SugarPartnerUser.fromJson(json['other_user'])
          : null,
    );
  }
}

/// Cashfree order details for Sugar Partner payment
class SugarPartnerCashfreeOrder {
  final String? orderId;
  final String? paymentSessionId;
  final String? cfOrderId;
  final String? orderStatus;

  SugarPartnerCashfreeOrder({
    this.orderId,
    this.paymentSessionId,
    this.cfOrderId,
    this.orderStatus,
  });

  factory SugarPartnerCashfreeOrder.fromJson(Map<String, dynamic> json) {
    return SugarPartnerCashfreeOrder(
      orderId: json['order_id'],
      paymentSessionId: json['payment_session_id'],
      cfOrderId: json['cf_order_id'],
      orderStatus: json['order_status'],
    );
  }
}

/// Response for payment processing
class SugarPartnerPaymentProcessResponse {
  final bool success;
  final String message;
  final SugarPartnerPaymentResult? data;

  SugarPartnerPaymentProcessResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory SugarPartnerPaymentProcessResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPaymentProcessResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? SugarPartnerPaymentResult.fromJson(json['data'])
          : null,
    );
  }
}

/// Payment result data
class SugarPartnerPaymentResult {
  final int? exchangeId;
  final String? paymentStatus;
  final String? paymentMethod;
  final double? walletAmountUsed;
  final double? cashfreeAmountPaid;
  final double? totalPaid;
  final String? transactionId;
  final String? paidAt;
  final double? newWalletBalance;

  SugarPartnerPaymentResult({
    this.exchangeId,
    this.paymentStatus,
    this.paymentMethod,
    this.walletAmountUsed,
    this.cashfreeAmountPaid,
    this.totalPaid,
    this.transactionId,
    this.paidAt,
    this.newWalletBalance,
  });

  factory SugarPartnerPaymentResult.fromJson(Map<String, dynamic> json) {
    return SugarPartnerPaymentResult(
      exchangeId: json['exchange_id'],
      paymentStatus: json['payment_status'] ?? json['status'],
      paymentMethod: json['payment_method'],
      walletAmountUsed: SugarPartnerService._parseDouble(json['wallet_amount_used']),
      cashfreeAmountPaid: SugarPartnerService._parseDouble(json['cashfree_amount_paid']),
      totalPaid: SugarPartnerService._parseDouble(json['total_paid']) ?? SugarPartnerService._parseDouble(json['amount']),
      transactionId: json['transaction_id'],
      paidAt: json['paid_at'],
      newWalletBalance: SugarPartnerService._parseDouble(json['new_wallet_balance']) ?? SugarPartnerService._parseDouble(json['wallet_balance']),
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
      amount: SugarPartnerService._parseDouble(json['amount']) ?? 0.0,
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
      totalAmount: SugarPartnerService._parseDouble(json['total_amount']),
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

class SugarPartnerRequestsResponse {
  final bool success;
  final String message;
  final List<SugarPartnerRequest> data;

  SugarPartnerRequestsResponse({
    required this.success,
    required this.message,
    this.data = const [],
  });

  factory SugarPartnerRequestsResponse.fromJson(Map<String, dynamic> json) {
    return SugarPartnerRequestsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
          .map((item) => SugarPartnerRequest.fromJson(item))
          .toList()
          : [],
    );
  }
}

class SugarPartnerRequest {
  final int id;
  final int senderId;
  final int receiverId;
  final String status;
  final String? message;
  final String? createdAt;
  final String? updatedAt;
  final SugarPartnerUser? sender;

  SugarPartnerRequest({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.status,
    this.message,
    this.createdAt,
    this.updatedAt,
    this.sender,
  });

  factory SugarPartnerRequest.fromJson(Map<String, dynamic> json) {
    return SugarPartnerRequest(
      id: json['id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      receiverId: json['receiver_id'] ?? 0,
      status: json['status'] ?? 'pending',
      message: json['message'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      sender: json['sender'] != null
          ? SugarPartnerUser.fromJson(json['sender'])
          : null,
    );
  }
}

class MySugarPartnersResponse {
  final bool success;
  final String message;
  final List<SugarPartnerUser> data;
  final SugarPartnerPaginationMeta? pagination;

  MySugarPartnersResponse({
    required this.success,
    required this.message,
    this.data = const [],
    this.pagination,
  });

  factory MySugarPartnersResponse.fromJson(Map<String, dynamic> json) {
    return MySugarPartnersResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && json['data'] is List
          ? (json['data'] as List)
          .map((item) => SugarPartnerUser.fromJson(item))
          .toList()
          : [],
      pagination: json['pagination'] != null
          ? SugarPartnerPaginationMeta.fromJson(json['pagination'])
          : null,
    );
  }
}