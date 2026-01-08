import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getsubscriptionmodel.dart';
import '../model/getpaymentstatusmodel.dart';
import '../model/postpurchasemodel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class SubscriptionService {
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<Map<String, String>?> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      return null;
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get subscription plans - API Section 2.1
  /// URL: GET /subscription-plans (Public - No Auth Required)
  Future<GetsubscriptionModel?> getSubscriptionPlans() async {
    final url = '${ApiConstants.baseUrl}/subscription-plans';
    try {
      // Note: This endpoint doesn't require auth per API docs, but we'll include it if available
      final headers = await _getHeaders() ?? {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return GetsubscriptionModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get subscription plans');
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  Future<PostpurchaseModel?> purchaseSubscription({
    required int planId,
    String paymentMethod = 'cashfree',
  }) async {
    final url = '${ApiConstants.baseUrl}/subscription/purchase';
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final body = {
        'plan_id': planId,
        'payment_method': paymentMethod,
      };

      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return PostpurchaseModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to purchase subscription');
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  Future<VerifyPaymentResponse?> verifyPayment({
    required int subscriptionId,
    required String orderId,
    required String cfOrderId,
    String? cfTransactionId,
  }) async {
    final url = '${ApiConstants.baseUrl}/subscription/verify-payment';
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final body = {
        'subscription_id': subscriptionId,
        'order_id': orderId,
        'cf_order_id': cfOrderId,
        'cf_transaction_id': cfTransactionId,
      };

      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: body);

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return VerifyPaymentResponse.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Payment verification failed');
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  Future<GetpaymentstatusModel?> getSubscriptionStatus() async {
    final url = '${ApiConstants.baseUrl}/subscription/status';
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final data = jsonDecode(response.body);
        return GetpaymentstatusModel.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Failed to get subscription status');
        return null;
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return null;
    }
  }

  /// Cancel the current active subscription
  /// Note: This cancels auto-renewal but keeps access until expiry date
  Future<CancelSubscriptionResponse> cancelSubscription() async {
    final url = '${ApiConstants.baseUrl}/subscription/cancel';
    try {
      final headers = await _getHeaders();
      if (headers == null) {
        return CancelSubscriptionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CancelSubscriptionResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: 404, error: data['message'] ?? 'No active subscription found');
        return CancelSubscriptionResponse(
          success: false,
          message: data['message'] ?? 'No active subscription found.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Failed to cancel subscription');
        return CancelSubscriptionResponse(
          success: false,
          message: data['message'] ?? 'Failed to cancel subscription.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CancelSubscriptionResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get subscription history with pagination
  Future<SubscriptionHistoryResponse> getSubscriptionHistory({
    int page = 1,
    int perPage = 10,
  }) async {
    final queryParams = {
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    final url = Uri.parse('${ApiConstants.baseUrl}/subscription/history')
        .replace(queryParameters: queryParams)
        .toString();
    try {
      final headers = await _getHeaders();
      if (headers == null) {
        return SubscriptionHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      ApiLogger.logApiCall(endpoint: url, method: 'GET');

      final response = await http.get(Uri.parse(url), headers: headers);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return SubscriptionHistoryResponse.fromJson(data);
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: data['message'] ?? 'Failed to get subscription history');
        return SubscriptionHistoryResponse(
          success: false,
          message: data['message'] ?? 'Failed to get subscription history.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return SubscriptionHistoryResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}

class VerifyPaymentResponse {
  final bool success;
  final String? message;
  final SubscriptionData? subscription;

  VerifyPaymentResponse({
    required this.success,
    this.message,
    this.subscription,
  });

  factory VerifyPaymentResponse.fromJson(Map<String, dynamic> json) {
    return VerifyPaymentResponse(
      success: json['success'] ?? false,
      message: json['message'],
      subscription: json['data']?['subscription'] != null
          ? SubscriptionData.fromJson(json['data']['subscription'])
          : null,
    );
  }
}

class SubscriptionData {
  final int id;
  final String planName;
  final String? expiresAt;

  SubscriptionData({
    required this.id,
    required this.planName,
    this.expiresAt,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    return SubscriptionData(
      id: json['id'] ?? 0,
      planName: json['plan_name'] ?? '',
      expiresAt: json['expires_at'],
    );
  }
}

// ============================================
// Cancel Subscription Response Model
// ============================================

class CancelSubscriptionResponse {
  final bool success;
  final String? message;
  final String? expiresAt;

  CancelSubscriptionResponse({
    required this.success,
    this.message,
    this.expiresAt,
  });

  factory CancelSubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return CancelSubscriptionResponse(
      success: json['success'] ?? false,
      message: json['message'],
      expiresAt: json['data']?['expires_at'],
    );
  }
}

// ============================================
// Subscription History Response Model
// ============================================

class SubscriptionHistoryResponse {
  final bool success;
  final String? message;
  final List<SubscriptionHistoryItem>? subscriptions;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  SubscriptionHistoryResponse({
    required this.success,
    this.message,
    this.subscriptions,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
  });

  factory SubscriptionHistoryResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    final pagination = data['pagination'] ?? {};

    List<SubscriptionHistoryItem>? subscriptions;
    if (data['subscriptions'] != null) {
      subscriptions = (data['subscriptions'] as List)
          .map((s) => SubscriptionHistoryItem.fromJson(s))
          .toList();
    }

    return SubscriptionHistoryResponse(
      success: json['success'] ?? false,
      message: json['message'],
      subscriptions: subscriptions,
      currentPage: pagination['current_page'] ?? 1,
      lastPage: pagination['last_page'] ?? 1,
      perPage: pagination['per_page'] ?? 10,
      total: pagination['total'] ?? 0,
    );
  }
}

class SubscriptionHistoryItem {
  final int id;
  final SubscriptionPlanInfo? plan;
  final String? status;
  final String? startedAt;
  final String? expiresAt;
  final String? cancelledAt;
  final String? transactionId;

  SubscriptionHistoryItem({
    required this.id,
    this.plan,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.cancelledAt,
    this.transactionId,
  });

  // Convenience getters for UI
  String? get planName => plan?.name;
  double? get amount => plan?.amount;
  String? get startDate => startedAt;
  String? get endDate => expiresAt;

  factory SubscriptionHistoryItem.fromJson(Map<String, dynamic> json) {
    return SubscriptionHistoryItem(
      id: json['id'] ?? 0,
      plan: json['plan'] != null
          ? SubscriptionPlanInfo.fromJson(json['plan'])
          : null,
      status: json['status'],
      startedAt: json['started_at'],
      expiresAt: json['expires_at'],
      cancelledAt: json['cancelled_at'],
      transactionId: json['transaction_id'],
    );
  }
}

class SubscriptionPlanInfo {
  final int id;
  final String name;
  final double amount;

  SubscriptionPlanInfo({
    required this.id,
    required this.name,
    required this.amount,
  });

  factory SubscriptionPlanInfo.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanInfo(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      amount: _parseDouble(json['amount']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
