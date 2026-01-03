import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getsubscriptionmodel.dart';
import '../model/getpaymentstatusmodel.dart';
import '../model/postpurchasemodel.dart';
import '../utils/api_constants.dart';

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

  Future<GetsubscriptionModel?> getSubscriptionPlans() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription-plans';
      
      
      
      
      
      
      

      final response = await http.get(Uri.parse(url), headers: headers);

      
      

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        return GetsubscriptionModel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }

  Future<PostpurchaseModel?> purchaseSubscription({
    required int planId,
    String paymentMethod = 'cashfree',
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription/purchase';
      final body = {
        'plan_id': planId,
        'payment_method': paymentMethod,
      };

      
      
      
      
      
      
      

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      
      

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        
        
        
        return PostpurchaseModel.fromJson(data);
      } else {
        
        return null;
      }
    } catch (e) {
      
      return null;
    }
  }
  Future<VerifyPaymentResponse?> verifyPayment({

    required int subscriptionId,

    required String orderId,

    required String cfOrderId,

    String? cfTransactionId,

  }) async {

    try {

      final headers = await _getHeaders();

      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription/verify-payment';

      final body = {

        'subscription_id': subscriptionId,

        'order_id': orderId,

        'cf_order_id': cfOrderId,

        'cf_transaction_id': cfTransactionId,

      };

      

      

      

      

      

      

      

      

      

      final response = await http.post(

        Uri.parse(url),

        headers: headers,

        body: jsonEncode(body),

      );

      

      

      if (response.statusCode == 200 || response.statusCode == 201) {

        final data = jsonDecode(response.body);

        

        return VerifyPaymentResponse.fromJson(data);

      } else {

        

        return null;

      }

    } catch (e) {

      

      return null;

    }

  }


  Future<GetpaymentstatusModel?> getSubscriptionStatus() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription/status';

      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return GetpaymentstatusModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  /// Cancel the current active subscription
  /// Note: This cancels auto-renewal but keeps access until expiry date
  Future<CancelSubscriptionResponse> cancelSubscription() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) {
        return CancelSubscriptionResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/subscription/cancel';

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CancelSubscriptionResponse.fromJson(data);
      } else if (response.statusCode == 404) {
        return CancelSubscriptionResponse(
          success: false,
          message: data['message'] ?? 'No active subscription found.',
        );
      } else {
        return CancelSubscriptionResponse(
          success: false,
          message: data['message'] ?? 'Failed to cancel subscription.',
        );
      }
    } catch (e) {
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
    try {
      final headers = await _getHeaders();
      if (headers == null) {
        return SubscriptionHistoryResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final queryParams = {
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      final url = Uri.parse('${ApiConstants.baseUrl}/subscription/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(url, headers: headers);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return SubscriptionHistoryResponse.fromJson(data);
      } else {
        return SubscriptionHistoryResponse(
          success: false,
          message: data['message'] ?? 'Failed to get subscription history.',
        );
      }
    } catch (e) {
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

  SubscriptionHistoryItem({
    required this.id,
    this.plan,
    this.status,
    this.startedAt,
    this.expiresAt,
    this.cancelledAt,
  });

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
