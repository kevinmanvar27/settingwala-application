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
