import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/getsubscriptionmodel.dart';
import '../model/getpaymentstatusmodel.dart';
import '../model/postpurchasemodel.dart';
import '../utils/api_constants.dart';

/// Subscription Service - Step-by-Step API Implementation
/// 
/// Flow:
/// Step 1: GET /subscription-plans     → Fetch available plans
/// Step 2: POST /subscription/purchase → Create order + get Cashfree session
/// Step 3: Cashfree SDK               → User completes payment (handled in UI)
/// Step 4: POST /verify-payment       → Verify & activate subscription (backend fetches cf_transaction_id)
/// Step 5: GET /subscription/status   → Confirm active subscription
class SubscriptionService {
  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER: Get Auth Token
  // ═══════════════════════════════════════════════════════════════════════════
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // HELPER: Get Common Headers
  // ═══════════════════════════════════════════════════════════════════════════
  Future<Map<String, String>?> _getHeaders() async {
    final token = await _getToken();
    if (token == null) {
      print('❌ Error: No auth token found');
      return null;
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 1: GET Subscription Plans
  // GET /api/subscription-plans
  // ═══════════════════════════════════════════════════════════════════════════
  Future<GetsubscriptionModel?> getSubscriptionPlans() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription-plans';
      
      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  STEP 1: GET Subscription Plans                               ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║  URL: $url');
      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ STEP 1 SUCCESS: Plans fetched');
        return GetsubscriptionModel.fromJson(data);
      } else {
        print('❌ STEP 1 FAILED: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ STEP 1 ERROR: $e');
      return null;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 2: POST Purchase Subscription (Create Cashfree Order)
  // POST /api/subscription/purchase
  // ═══════════════════════════════════════════════════════════════════════════
  Future<PostpurchaseModel?> purchaseSubscription({
    required int planId,
    String paymentMethod = 'cashfree', // Default to cashfree
  }) async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription/purchase';
      final body = {
        'plan_id': planId,
        'payment_method': paymentMethod,
      };

      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  STEP 2: POST Purchase Subscription                           ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║  URL: $url');
      print('║  Body: ${jsonEncode(body)}');
      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ STEP 2 SUCCESS: Order created');
        print('   📌 subscription_id: ${data['data']?['subscription_id']}');
        print('   📌 order_id: ${data['data']?['cashfree_order']?['order_id']}');
        print('   📌 payment_session_id: ${data['data']?['cashfree_order']?['payment_session_id']}');
        return PostpurchaseModel.fromJson(data);
      } else {
        print('❌ STEP 2 FAILED: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ STEP 2 ERROR: $e');
      return null;
    }
  }
  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 4: Verify Payment with Backend
  // POST /subscription/verify-payment
  // Note: Backend fetches cf_transaction_id from Cashfree using order_id
  // ═══════════════════════════════════════════════════════════════════════════
  // Future<VerifyPaymentResponse?> verifyPayment({
  //   required int subscriptionId,
  //   required String orderId,
  //   required String cfOrderId,
  // }) async {
  //   try {
  //     final headers = await _getHeaders();
  //     if (headers == null) return null;
  //
  //     final url = '${ApiConstants.baseUrl}/subscription/verify-payment';
  //     final body = {
  //       'subscription_id': subscriptionId,
  //       'order_id': orderId,
  //       'cf_order_id': cfOrderId,
  //     };
  //
  //     print('');
  //     print('╔═══════════════════════════════════════════════════════════════╗');
  //     print('║  STEP 4: POST Verify Payment                                  ║');
  //     print('╠═══════════════════════════════════════════════════════════════╣');
  //     print('║  URL: $url');
  //     print('║  Body: ${jsonEncode(body)}');
  //     print('╚═══════════════════════════════════════════════════════════════╝');
  //
  //     final response = await http.post(
  //       Uri.parse(url),
  //       headers: headers,
  //       body: jsonEncode(body),
  //     );
  //
  //     print('📥 Status Code: ${response.statusCode}');
  //     print('📥 Response: ${response.body}');
  //
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       final data = jsonDecode(response.body);
  //       print('✅ STEP 4 SUCCESS: Payment verified & subscription activated');
  //       return VerifyPaymentResponse.fromJson(data);
  //     } else {
  //       print('❌ STEP 4 FAILED: ${response.statusCode}');
  //       return null;
  //     }
  //   } catch (e) {
  //     print('❌ STEP 4 ERROR: $e');
  //     return null;
  //   }
  // }
  Future<VerifyPaymentResponse?> verifyPayment({

    required int subscriptionId,

    required String orderId,

    required String cfOrderId,

    String? cfTransactionId,  // Add this parameter

  }) async {

    try {

      final headers = await _getHeaders();

      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription/verify-payment';

      final body = {

        'subscription_id': subscriptionId,

        'order_id': orderId,

        'cf_order_id': cfOrderId,

        'cf_transaction_id': cfTransactionId,  // Add if available

      };

      print('');

      print('╔═══════════════════════════════════════════════════════════════╗');

      print('║  STEP 4: POST Verify Payment                                  ║');

      print('╠═══════════════════════════════════════════════════════════════╣');

      print('║  URL: $url');

      print('║  Body: ${jsonEncode(body)}');

      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.post(

        Uri.parse(url),

        headers: headers,

        body: jsonEncode(body),

      );

      print('📥 Status Code: ${response.statusCode}');

      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {

        final data = jsonDecode(response.body);

        print('✅ STEP 4 SUCCESS: Payment verified & subscription activated');

        return VerifyPaymentResponse.fromJson(data);

      } else {

        print('❌ STEP 4 FAILED: ${response.statusCode}');

        return null;

      }

    } catch (e) {

      print('❌ STEP 4 ERROR: $e');

      return null;

    }

  }


  // ═══════════════════════════════════════════════════════════════════════════
  // STEP 5: GET Subscription Status (Optional - Confirm subscription)
  // GET /api/subscription/status
  // ═══════════════════════════════════════════════════════════════════════════
  Future<GetpaymentstatusModel?> getSubscriptionStatus() async {
    try {
      final headers = await _getHeaders();
      if (headers == null) return null;

      final url = '${ApiConstants.baseUrl}/subscription/status';

      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  STEP 5: GET Subscription Status                              ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║  URL: $url');
      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.get(Uri.parse(url), headers: headers);

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ STEP 5 SUCCESS: Status fetched');
        return GetpaymentstatusModel.fromJson(data);
      } else {
        print('❌ STEP 5 FAILED: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ STEP 5 ERROR: $e');
      return null;
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Response Model for Verify Payment (Step 4)
// ═══════════════════════════════════════════════════════════════════════════
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
