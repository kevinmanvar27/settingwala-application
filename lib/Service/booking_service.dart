import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/postbookingsmodel.dart';
import '../model/booking_payment_model.dart';
import '../model/booking_payment_details_model.dart';
import '../model/postbookingpaymentmodel.dart';
import '../utils/api_constants.dart';

class BookingService {
  // Get auth token from SharedPreferences
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // POST Booking API - Create a new booking
  // Endpoint: POST /api/v1/bookings
  static Future<BookingResponse?> createBooking(Postbookingsmodel booking) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = booking.toJson();

      print('========== POST Booking Request ==========');
      print('URL: ${ApiConstants.baseUrl}/bookings');
      print('Body: ${jsonEncode(body)}');
      print('==========================================' );

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('========== POST Booking Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===========================================');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to create booking. Please try again.',
        );
      }
    } catch (e) {
      print('POST Booking Error: $e');
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // GET Bookings API - Fetch all bookings for current user
  // Endpoint: GET /api/v1/bookings
  static Future<GetBookingsResponse?> getBookings() async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return GetBookingsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          data: [], bookings: [],
        );
      }

      print('========== GET Bookings Request ==========');
      print('URL: ${ApiConstants.baseUrl}/bookings');
      print('==========================================' );

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Bookings Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('===========================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return GetBookingsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return GetBookingsResponse(
          success: false,
          message: 'Session expired. Please login again.',
          data: [], bookings: [],
        );
      } else {
        return GetBookingsResponse(
          success: false,
          message: 'Failed to fetch bookings.',
          data: [], bookings: [],
        );
      }
    } catch (e) {
      print('GET Bookings Error: $e');
      return GetBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        data: [], bookings: [],
      );
    }
  }

  // GET Single Booking API - Fetch booking by ID
  // Endpoint: GET /api/v1/bookings/{id}
  static Future<BookingResponse?> getBookingById(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== GET Booking By ID Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=================================================');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else {
        return BookingResponse(
          success: false,
          message: 'Booking not found.',
        );
      }
    } catch (e) {
      print('GET Booking By ID Error: $e');
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // CANCEL Booking API - Cancel a booking
  // Endpoint: PUT /api/v1/bookings/{id}/cancel
  static Future<BookingResponse?> cancelBooking(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('========== CANCEL Booking Response ==========');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('==============================================' );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel booking.',
        );
      }
    } catch (e) {
      print('CANCEL Booking Error: $e');
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // INITIATE PAYMENT - Create Cashfree order for booking payment
  // Endpoint: POST /api/v1/bookings/{id}/initiate-payment
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<BookingPaymentModel?> initiatePayment(int bookingId, double amount) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return BookingPaymentModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/initiate-payment';
      final body = {
        'amount': amount,
        'payment_method': 'cashfree',
      };

      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  INITIATE BOOKING PAYMENT                                     ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║  URL: $url');
      print('║  Body: ${jsonEncode(body)}');
      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ INITIATE PAYMENT SUCCESS: Order created');
        print('   📌 booking_id: ${responseData['data']?['booking_id']}');
        print('   📌 order_id: ${responseData['data']?['cashfree_order']?['order_id']}');
        print('   📌 payment_session_id: ${responseData['data']?['cashfree_order']?['payment_session_id']}');
        return BookingPaymentModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BookingPaymentModel(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BookingPaymentModel(
          success: false,
          message: responseData['message'] ?? 'Failed to initiate payment.',
        );
      }
    } catch (e) {
      print('❌ INITIATE PAYMENT ERROR: $e');
      return BookingPaymentModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // GET BOOKING PAYMENT DETAILS - Get complete payment info for a booking
  // Endpoint: GET /api/v1/bookings/{id}/payment
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<BookingPaymentDetailsModel?> getBookingPaymentDetails(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/payment';

      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  GET BOOKING PAYMENT DETAILS                                  ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║  URL: $url');
      print('║  Booking ID: $bookingId');
      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ GET PAYMENT DETAILS SUCCESS');
        return BookingPaymentDetailsModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Booking not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BookingPaymentDetailsModel(
          success: false,
          message: responseData['message'] ?? 'Failed to get payment details.',
        );
      }
    } catch (e) {
      print('❌ GET PAYMENT DETAILS ERROR: $e');
      return BookingPaymentDetailsModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // PROCESS PAYMENT - Process booking payment after Cashfree completion
  // Endpoint: POST /api/v1/bookings/{id}/process-payment
  // Returns: PostBookingPaymentmodel with complete booking and payment details
  // ═══════════════════════════════════════════════════════════════════════════
  static Future<PostBookingPaymentmodel> processPayment({
    required int bookingId,
    required String cfOrderId,
    required String cfTransactionId,
    String? cfSignature,
    double walletAmountUsed = 0.0,
    String paymentMethod = 'wallet_cashfree',
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        print('Error: No auth token found');
        return PostBookingPaymentmodel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/process-payment';
      final body = {
        'payment_method': paymentMethod,
        'wallet_amount_used': walletAmountUsed,
        'cf_order_id': cfOrderId,
        'cf_transaction_id': cfTransactionId,
        if (cfSignature != null) 'cf_signature': cfSignature,
      };

      print('');
      print('╔═══════════════════════════════════════════════════════════════╗');
      print('║  PROCESS BOOKING PAYMENT                                      ║');
      print('╠═══════════════════════════════════════════════════════════════╣');
      print('║  URL: $url');
      print('║  Body: ${jsonEncode(body)}');
      print('╚═══════════════════════════════════════════════════════════════╝');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('📥 Status Code: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ PROCESS PAYMENT SUCCESS: Payment processed');
        
        // Parse response using PostBookingPaymentmodel
        final result = PostBookingPaymentmodel.fromJson(responseData);
        
        // Debug log booking details
        if (result.data?.booking != null) {
          final booking = result.data!.booking!;
          print('');
          print('╔═══════════════════════════════════════════════════════════════╗');
          print('║  BOOKING PAYMENT DETAILS                                      ║');
          print('╠═══════════════════════════════════════════════════════════════╣');
          print('║  Booking ID: ${booking.id}');
          print('║  Status: ${booking.status}');
          print('║  Payment Status: ${booking.paymentStatus}');
          print('║  Total Amount: ₹${booking.totalAmount}');
          print('║  Wallet Used: ₹${booking.walletAmountUsed}');
          print('║  Cashfree Paid: ₹${booking.cfAmountPaid}');
          print('║  Paid At: ${booking.paidAt}');
          print('╚═══════════════════════════════════════════════════════════════╝');
        }
        
        return result;
      } else {
        final responseData = jsonDecode(response.body);
        return PostBookingPaymentmodel(
          success: false,
          message: responseData['message'] ?? 'Failed to process payment.',
        );
      }
    } catch (e) {
      print('❌ PROCESS PAYMENT ERROR: $e');
      return PostBookingPaymentmodel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }
}
