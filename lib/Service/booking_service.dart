import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/postbookingsmodel.dart';
import '../model/booking_payment_model.dart';
import '../model/booking_payment_details_model.dart';
import '../model/postbookingpaymentmodel.dart';
import '../utils/api_constants.dart';
import '../utils/api_logger.dart';

class BookingService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<BookingResponse?> createBooking(Postbookingsmodel booking) async {
    final url = '${ApiConstants.baseUrl}/bookings';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = booking.toJson();

      // API call થઈ રહી છે
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to create booking. Please try again.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<GetBookingsResponse?> getBookings() async {
    final url = '${ApiConstants.baseUrl}/bookings';
    try {
      final token = await _getToken();

      if (token == null) {
        return GetBookingsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          bookings: [],
        );
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
        final responseData = jsonDecode(response.body);
        return GetBookingsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return GetBookingsResponse(
          success: false,
          message: 'Session expired. Please login again.',
          bookings: [],
        );
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode);
        return GetBookingsResponse(
          success: false,
          message: 'Failed to fetch bookings.',
          bookings: [],
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return GetBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        bookings: [],
      );
    }
  }

  /// Check if user has any accepted bookings
  /// Returns true if there's at least one booking with status 'accepted'
  static Future<bool> hasAcceptedBookings() async {
    try {
      final response = await getBookings();
      if (response == null || !response.success) {
        return false;
      }

      // Check if any booking has 'accepted' status
      return response.bookings.any(
              (booking) => booking.status.toLowerCase() == 'accepted'
      );
    } catch (e) {
      return false;
    }
  }

  static Future<BookingResponse?> getBookingById(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Booking not found');
        return BookingResponse(
          success: false,
          message: 'Booking not found.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ शक
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> cancelBooking(int bookingId, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId/cancel';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'booking_id': bookingId});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel booking.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Update booking with time change - handles payment difference
  /// If new duration > old duration: charges extra (wallet first, then cashfree)
  /// If new duration < old duration: refunds difference to wallet
  static Future<UpdateBookingResponse> updateBookingWithPayment(
      int bookingId, {
        DateTime? bookingDate,
        String? startTime,
        String? endTime,
        String? notes,
      }) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId';
    try {
      final token = await _getToken();

      if (token == null) {
        return UpdateBookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (bookingDate != null) {
        // Format date as YYYY-MM-DD (ISO format)
        String formattedDate = "${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}";
        body['booking_date'] = formattedDate;
        print('Formatted booking date: $formattedDate');
      }
      if (startTime != null) {
        body['start_time'] = startTime;
      }
      if (endTime != null) {
        body['end_time'] = endTime;
      }
      if (notes != null) {
        body['notes'] = notes;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      // Log the exact request being sent
      print('Sending update booking request:');
      print('URL: $url');
      print('Headers: ${{'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer ${token.substring(0, 10)}...'}}');
      print('Body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      // Log the response
      print('Update booking response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return UpdateBookingResponse.fromJson(responseData);
      } else if (response.statusCode == 422) {
        // Validation error - log full response
        print('API Validation Error - Full Response: ${response.body}');
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Validation failed: ${response.body}');
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Validation failed',
          validationErrors: responseData['errors'],
        );
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return UpdateBookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 402) {
        // Payment required - need to pay extra amount
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Payment required');
        return UpdateBookingResponse.fromJson(responseData);
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Only the client can update the booking.',
        );
      } else if (response.statusCode == 400) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot update booking in current status.',
        );
      } else if (response.statusCode == 409) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update booking.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return UpdateBookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Initiate payment for booking update difference
  /// Called when duration increases and extra payment is needed
  /// NOTE: This method uses process-difference-payment endpoint since initiate-update-payment doesn't exist
  static Future<BookingPaymentModel?> initiateUpdatePayment(
      int bookingId,
      double differenceAmount, {
        String preferredPaymentMethod = 'wallet',
      }) async {
    // FIXED: Use process-difference-payment instead of non-existent initiate-update-payment
    final url = ApiConstants.bookingProcessDifferencePayment(bookingId);
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingPaymentModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'amount': differenceAmount,
        'payment_method': preferredPaymentMethod,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'amount': differenceAmount, 'payment_method': preferredPaymentMethod});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingPaymentModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingPaymentModel(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingPaymentModel(
          success: false,
          message: responseData['message'] ?? 'Failed to initiate update payment.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શક
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingPaymentModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Cancel booking and refund to wallet
  /// Money will be refunded to user's wallet
  static Future<CancelBookingResponse> cancelBookingWithRefund(int bookingId, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId/cancel';
    try {
      final token = await _getToken();

      if (token == null) {
        return CancelBookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'booking_id': bookingId});

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
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return CancelBookingResponse.fromJson(responseData);
      } else {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return CancelBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel booking.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return CancelBookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> updateBooking(
      int bookingId, {
        DateTime? bookingDate,
        String? startTime,
        String? endTime,
        String? notes,
      }) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (bookingDate != null) {
        // Format date as YYYY-MM-DD (ISO format)
        String formattedDate = "${bookingDate.year}-${bookingDate.month.toString().padLeft(2, '0')}-${bookingDate.day.toString().padLeft(2, '0')}";
        body['booking_date'] = formattedDate;
        print('Formatted booking date: $formattedDate');
      }
      if (startTime != null) {
        body['start_time'] = startTime;
      }
      if (endTime != null) {
        body['end_time'] = endTime;
      }
      if (notes != null) {
        body['notes'] = notes;
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'PUT', body: body);

      // Log the exact request being sent
      print('Sending update booking request:');
      print('URL: $url');
      print('Headers: ${{'Content-Type': 'application/json', 'Accept': 'application/json', 'Authorization': 'Bearer ${token.substring(0, 10)}...'}}');
      print('Body: $body');
      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );
      
      // Log the response
      print('Update booking response:');
      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // API call सफल થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Forbidden');
        return BookingResponse(
          success: false,
          message: 'Only the client can update the booking.',
        );
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot update booking in current status.',
        );
      } else if (response.statusCode == 422) {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update booking.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ शक
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Initiate payment for booking
  /// NOTE: This method uses process-payment endpoint since initiate-payment doesn't exist
  static Future<BookingPaymentModel?> initiatePayment(
      int bookingId,
      double amount, {
        String preferredPaymentMethod = 'wallet',
      }) async {
    // FIXED: Use process-payment instead of non-existent initiate-payment
    final url = ApiConstants.bookingProcessPayment(bookingId);
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingPaymentModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'amount': amount,
        'payment_method': preferredPaymentMethod,
      };

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'amount': amount, 'payment_method': preferredPaymentMethod});

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingPaymentModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingPaymentModel(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingPaymentModel(
          success: false,
          message: responseData['message'] ?? 'Failed to initiate payment.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકે
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingPaymentModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingPaymentDetailsModel?> getBookingPaymentDetails(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId/payment';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return BookingPaymentDetailsModel.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Booking not found');
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Booking not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingPaymentDetailsModel(
          success: false,
          message: responseData['message'] ?? 'Failed to get payment details.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingPaymentDetailsModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<PostBookingPaymentmodel> processPayment({
    required int bookingId,
    String? cfOrderId,
    String? cfTransactionId,
    String? cfSignature,
    double walletAmountUsed = 0.0,
    String paymentMethod = 'wallet_cashfree',
  }) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId/process-payment';
    try {
      final token = await _getToken();

      if (token == null) {
        return PostBookingPaymentmodel(
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
      if (cfSignature != null && cfSignature.isNotEmpty) {
        body['cf_signature'] = cfSignature;
      }

      // API call થઈ રહી છે
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        final result = PostBookingPaymentmodel.fromJson(responseData);
        return result;
      } else {
        final responseData = jsonDecode(response.body);
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return PostBookingPaymentmodel(
          success: false,
          message: responseData['message'] ?? 'Failed to process payment.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return PostBookingPaymentmodel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> acceptBooking(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId/accept';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
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
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Forbidden');
        return BookingResponse(
          success: false,
          message: 'Only the provider can accept this booking.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to accept booking.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> rejectBooking(int bookingId, {String? reason}) async {
    final url = '${ApiConstants.baseUrl}/bookings/$bookingId/reject';
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = <String, dynamic>{};
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

      // API call થઈ રહી છે
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

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Forbidden');
        return BookingResponse(
          success: false,
          message: 'Only the provider can reject this booking.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reject booking.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Block client from booking
  static Future<BookingResponse?> blockClient(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/provider/booking/$bookingId/block';

    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
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
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Forbidden');
        return BookingResponse(
          success: false,
          message: 'Only the provider can block this client.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to block client.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Unblock client
  static Future<BookingResponse?> unblockClient(int userId) async {
    final url = '${ApiConstants.baseUrl}/provider/user/$userId/unblock';

    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST');

      final response = await http.post(
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
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to unblock user.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get user disputes
  static Future<DisputesResponse?> getUserDisputes() async {
    final url = '${ApiConstants.baseUrl}/disputes';
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputesResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          disputes: [],
        );
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
        final responseData = jsonDecode(response.body);
        return DisputesResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return DisputesResponse(
          success: false,
          message: 'Session expired. Please login again.',
          disputes: [],
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return DisputesResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to fetch disputes.',
          disputes: [],
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return DisputesResponse(
        success: false,
        message: 'Network error. Please check your connection.',
        disputes: [],
      );
    }
  }

  /// Raise dispute for a booking
  static Future<DisputeResponse?> raiseDispute({
    required int bookingId,
    required String reason,
    String type = 'other',
    List<String> evidence = const [],
  }) async {
    final url = '${ApiConstants.baseUrl}/disputes/raise';
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputeResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = {
        'booking_id': bookingId,
        'reason': reason,
        'type': type,
        'evidence': evidence,
      };

      // API call થઈ રહી છે
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return DisputeResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return DisputeResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return DisputeResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to raise dispute.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return DisputeResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get dispute details
  static Future<DisputeDetailsResponse?> getDisputeDetails(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/disputes/$bookingId/details';
    try {
      final token = await _getToken();

      if (token == null) {
        return DisputeDetailsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return DisputeDetailsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return DisputeDetailsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return DisputeDetailsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get dispute details.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return DisputeDetailsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Upload start meeting photo
  static Future<MeetingVerificationResponse> uploadStartPhoto({
    required int bookingId,
    required String photoPath, // File path for image upload
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
    String? fullAddress,
  }) async {
    final url = '${ApiConstants.baseUrl}/meeting-verification/$bookingId/start-photo';
    try {
      final token = await _getToken();

      if (token == null) {
        return MeetingVerificationResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'photo': 'file', 'latitude': latitude, 'longitude': longitude});

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add file with proper filename and content type
      final fileName = path.basename(photoPath);
      final extension = path.extension(photoPath).toLowerCase().replaceFirst('.', '');
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photoPath,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      // Add other fields
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      if (accuracy != null) request.fields['accuracy'] = accuracy.toString();
      if (address != null) request.fields['address'] = address;
      if (fullAddress != null) request.fields['full_address'] = fullAddress;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return MeetingVerificationResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return MeetingVerificationResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: jsonData['message']);
        return MeetingVerificationResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to upload start photo.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return MeetingVerificationResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Upload end meeting photo
  static Future<MeetingVerificationResponse> uploadEndPhoto({
    required int bookingId,
    required String photoPath, // File path for image upload
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
    String? fullAddress,
  }) async {
    final url = '${ApiConstants.baseUrl}/meeting-verification/$bookingId/end-photo';
    try {
      final token = await _getToken();

      if (token == null) {
        return MeetingVerificationResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      // API call થઈ રહી છે
      ApiLogger.logApiCall(endpoint: url, method: 'POST', body: {'photo': 'file', 'latitude': latitude, 'longitude': longitude});

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.headers['Accept'] = 'application/json';

      // Add file with proper filename and content type
      final fileName = path.basename(photoPath);
      final extension = path.extension(photoPath).toLowerCase().replaceFirst('.', '');
      final mimeType = extension == 'png' ? 'image/png' : 'image/jpeg';
      
      request.files.add(await http.MultipartFile.fromPath(
        'photo',
        photoPath,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      // Add other fields
      request.fields['latitude'] = latitude.toString();
      request.fields['longitude'] = longitude.toString();
      if (accuracy != null) request.fields['accuracy'] = accuracy.toString();
      if (address != null) request.fields['address'] = address;
      if (fullAddress != null) request.fields['full_address'] = fullAddress;

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseBody);

      if (response.statusCode == 200) {
        // API call સફળ થઈ
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        return MeetingVerificationResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return MeetingVerificationResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: jsonData['message']);
        return MeetingVerificationResponse(
          success: false,
          message: jsonData['message'] ?? 'Failed to upload end photo.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return MeetingVerificationResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Get meeting verification status
  static Future<MeetingVerificationStatusResponse> getMeetingVerificationStatus(int bookingId) async {
    final url = '${ApiConstants.baseUrl}/meeting-verification/$bookingId/status';
    try {
      final token = await _getToken();

      if (token == null) {
        return MeetingVerificationStatusResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
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
        final responseData = jsonDecode(response.body);
        return MeetingVerificationStatusResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        // API call નિષ્ફળ થઈ
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: 'Session expired');
        return MeetingVerificationStatusResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return MeetingVerificationStatusResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get verification status.',
        );
      }
    } catch (e) {
      // Network error - API call નથી થઈ શકી
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return MeetingVerificationStatusResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Helper method to upload start photo using File object
  static Future<MeetingVerificationResponse> uploadStartPhotoWithFile({
    required int bookingId,
    required File photoFile,
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
    String? fullAddress,
  }) async {
    return await uploadStartPhoto(
      bookingId: bookingId,
      photoPath: photoFile.path,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
      fullAddress: fullAddress,
    );
  }

  /// Process difference payment for booking updates
  static Future<BookingResponse?> processDifferencePayment({
    required int bookingId,
    required double amount,
    String paymentMethod = 'wallet',
  }) async {
    final url = ApiConstants.bookingProcessDifferencePayment(bookingId);
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final Map<String, dynamic> body = {
        'amount': amount,
        'payment_method': paymentMethod,
      };

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        ApiLogger.logApiSuccess(endpoint: url, statusCode: response.statusCode);
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        ApiLogger.logApiError(endpoint: url, statusCode: 401, error: 'Session expired');
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        ApiLogger.logApiError(endpoint: url, statusCode: response.statusCode, error: responseData['message']);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to process difference payment.',
        );
      }
    } catch (e) {
      ApiLogger.logNetworkError(endpoint: url, error: e.toString());
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Helper method to upload end photo using File object
  static Future<MeetingVerificationResponse> uploadEndPhotoWithFile({
    required int bookingId,
    required File photoFile,
    required double latitude,
    required double longitude,
    double? accuracy,
    String? address,
    String? fullAddress,
  }) async {
    return await uploadEndPhoto(
      bookingId: bookingId,
      photoPath: photoFile.path,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      address: address,
      fullAddress: fullAddress,
    );
  }
}


class MeetingVerificationResponse {
  final bool success;
  final String message;
  final dynamic verificationStatus;
  final bool? meetingStarted;
  final bool? meetingCompleted;
  final String? duration;

  MeetingVerificationResponse({
    required this.success,
    required this.message,
    this.verificationStatus,
    this.meetingStarted,
    this.meetingCompleted,
    this.duration,
  });

  factory MeetingVerificationResponse.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      verificationStatus: json['verification_status'],
      meetingStarted: json['meeting_started'],
      meetingCompleted: json['meeting_completed'],
      duration: json['duration'],
    );
  }
}

class MeetingVerificationStatusResponse {
  final bool success;
  final String message;
  final dynamic verificationStatus;

  MeetingVerificationStatusResponse({
    required this.success,
    required this.message,
    this.verificationStatus,
  });

  factory MeetingVerificationStatusResponse.fromJson(Map<String, dynamic> json) {
    return MeetingVerificationStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      verificationStatus: json['verification_status'],
    );
  }
}

class DisputesResponse {
  final bool success;
  final String message;
  final List<dynamic> disputes;

  DisputesResponse({
    required this.success,
    required this.message,
    this.disputes = const [],
  });

  factory DisputesResponse.fromJson(Map<String, dynamic> json) {
    return DisputesResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      disputes: json['data']?['disputes'] != null
          ? List<dynamic>.from(json['data']['disputes'])
          : [],
    );
  }
}

class DisputeResponse {
  final bool success;
  final String message;
  final dynamic data;

  DisputeResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DisputeResponse.fromJson(Map<String, dynamic> json) {
    return DisputeResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class DisputeDetailsResponse {
  final bool success;
  final String message;
  final dynamic data;

  DisputeDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory DisputeDetailsResponse.fromJson(Map<String, dynamic> json) {
    return DisputeDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'],
    );
  }
}

class AvailableSlotsResponse {
  final bool success;
  final String message;
  final List<TimeSlot> slots;
  final String? date;

  AvailableSlotsResponse({
    required this.success,
    required this.message,
    this.slots = const [],
    this.date,
  });

  factory AvailableSlotsResponse.fromJson(Map<String, dynamic> json) {
    return AvailableSlotsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      slots: json['data']?['slots'] != null
          ? (json['data']['slots'] as List)
          .map((item) => TimeSlot.fromJson(item))
          .toList()
          : [],
      date: json['data']?['date'],
    );
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool isAvailable;

  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      isAvailable: json['is_available'] == true,
    );
  }
}

class ChatDetailsResponse {
  final bool success;
  final String message;
  final ChatDetails? data;

  ChatDetailsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ChatDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ChatDetailsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? ChatDetails.fromJson(json['data']) : null,
    );
  }
}

class ChatDetails {
  final int bookingId;
  final int chatId;
  final ChatUser? otherUser;
  final int unreadCount;
  final String? lastMessage;
  final String? lastMessageAt;
  final bool canChat;

  ChatDetails({
    required this.bookingId,
    required this.chatId,
    this.otherUser,
    required this.unreadCount,
    this.lastMessage,
    this.lastMessageAt,
    required this.canChat,
  });

  factory ChatDetails.fromJson(Map<String, dynamic> json) {
    return ChatDetails(
      bookingId: json['booking_id'] ?? 0,
      chatId: json['chat_id'] ?? 0,
      otherUser: json['other_user'] != null
          ? ChatUser.fromJson(json['other_user'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: json['last_message'],
      lastMessageAt: json['last_message_at'],
      canChat: json['can_chat'] == true,
    );
  }
}

class ChatUser {
  final int id;
  final String? name;
  final String? profilePhoto;
  final bool? isOnline;

  ChatUser({
    required this.id,
    this.name,
    this.profilePhoto,
    this.isOnline,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['id'] ?? 0,
      name: json['name'],
      profilePhoto: json['profile_photo'] ?? json['profile_photo_url'],
      isOnline: json['is_online'] == true,
    );
  }
}

class ProviderBookingStatusResponse {
  final bool success;
  final String message;
  final ProviderBookingStatus? data;

  ProviderBookingStatusResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ProviderBookingStatusResponse.fromJson(Map<String, dynamic> json) {
    return ProviderBookingStatusResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? ProviderBookingStatus.fromJson(json['data'])
          : null,
    );
  }
}

class ProviderBookingStatus {
  final int providerId;
  final bool hasActiveBooking;
  final int? activeBookingId;
  final String? activeBookingStatus;
  final int pendingBookingsCount;
  final int completedBookingsCount;
  final bool isAvailable;

  ProviderBookingStatus({
    required this.providerId,
    required this.hasActiveBooking,
    this.activeBookingId,
    this.activeBookingStatus,
    required this.pendingBookingsCount,
    required this.completedBookingsCount,
    required this.isAvailable,
  });

  factory ProviderBookingStatus.fromJson(Map<String, dynamic> json) {
    return ProviderBookingStatus(
      providerId: json['provider_id'] ?? 0,
      hasActiveBooking: json['has_active_booking'] == true,
      activeBookingId: json['active_booking_id'],
      activeBookingStatus: json['active_booking_status'],
      pendingBookingsCount: json['pending_bookings_count'] ?? 0,
      completedBookingsCount: json['completed_bookings_count'] ?? 0,
      isAvailable: json['is_available'] == true,
    );
  }
}


class CalendarBookingsResponse {
  final bool success;
  final String message;
  final List<CalendarBooking> bookings;
  final String? date;

  CalendarBookingsResponse({
    required this.success,
    required this.message,
    this.bookings = const [],
    this.date,
  });

  factory CalendarBookingsResponse.fromJson(Map<String, dynamic> json) {
    return CalendarBookingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      bookings: json['data']?['bookings'] != null
          ? (json['data']['bookings'] as List)
          .map((item) => CalendarBooking.fromJson(item))
          .toList()
          : (json['data'] is List
          ? (json['data'] as List)
          .map((item) => CalendarBooking.fromJson(item))
          .toList()
          : []),
      date: json['data']?['date'] ?? json['date'],
    );
  }
}

class CalendarBooking {
  final int id;
  final int? clientId;
  final int? providerId;
  final String? clientName;
  final String? providerName;
  final String? clientPhoto;
  final String? providerPhoto;
  final String? bookingDate;
  final String? startTime;
  final String? endTime;
  final double? durationHours;
  final String? status;
  final String? paymentStatus;
  final double? totalAmount;
  final String? meetingLocation;
  final String? notes;

  CalendarBooking({
    required this.id,
    this.clientId,
    this.providerId,
    this.clientName,
    this.providerName,
    this.clientPhoto,
    this.providerPhoto,
    this.bookingDate,
    this.startTime,
    this.endTime,
    this.durationHours,
    this.status,
    this.paymentStatus,
    this.totalAmount,
    this.meetingLocation,
    this.notes,
  });

  factory CalendarBooking.fromJson(Map<String, dynamic> json) {
    return CalendarBooking(
      id: json['id'] ?? 0,
      clientId: json['client_id'],
      providerId: json['provider_id'],
      clientName: json['client_name'] ?? json['client']?['name'],
      providerName: json['provider_name'] ?? json['provider']?['name'],
      clientPhoto: json['client_photo'] ?? json['client']?['profile_photo'],
      providerPhoto: json['provider_photo'] ?? json['provider']?['profile_photo'],
      bookingDate: json['booking_date'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      durationHours: json['duration_hours'] != null
          ? double.tryParse(json['duration_hours'].toString())
          : null,
      status: json['status'],
      paymentStatus: json['payment_status'],
      totalAmount: json['total_amount'] != null
          ? double.tryParse(json['total_amount'].toString())
          : null,
      meetingLocation: json['meeting_location'],
      notes: json['notes'],
    );
  }
}


class UserAvailabilityResponse {
  final bool success;
  final String message;
  final UserAvailability? data;

  UserAvailabilityResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserAvailabilityResponse.fromJson(Map<String, dynamic> json) {
    return UserAvailabilityResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserAvailability.fromJson(json['data']) : null,
    );
  }
}

class UserAvailability {
  final int userId;
  final bool isAvailable;
  final String? timezone;
  final List<DayAvailability> weeklySchedule;
  final List<String>? blockedDates;
  final String? nextAvailableDate;
  final String? nextAvailableTime;

  UserAvailability({
    required this.userId,
    required this.isAvailable,
    this.timezone,
    this.weeklySchedule = const [],
    this.blockedDates,
    this.nextAvailableDate,
    this.nextAvailableTime,
  });

  factory UserAvailability.fromJson(Map<String, dynamic> json) {
    return UserAvailability(
      userId: json['user_id'] ?? json['id'] ?? 0,
      isAvailable: json['is_available'] == true,
      timezone: json['timezone'],
      weeklySchedule: json['weekly_schedule'] != null
          ? (json['weekly_schedule'] as List)
          .map((item) => DayAvailability.fromJson(item))
          .toList()
          : (json['availability'] != null
          ? (json['availability'] as List)
          .map((item) => DayAvailability.fromJson(item))
          .toList()
          : []),
      blockedDates: json['blocked_dates'] != null
          ? List<String>.from(json['blocked_dates'])
          : null,
      nextAvailableDate: json['next_available_date'],
      nextAvailableTime: json['next_available_time'],
    );
  }
}

class DayAvailability {
  final String day;
  final int? dayOfWeek;
  final bool isAvailable;
  final List<AvailabilitySlot> slots;

  DayAvailability({
    required this.day,
    this.dayOfWeek,
    required this.isAvailable,
    this.slots = const [],
  });

  factory DayAvailability.fromJson(Map<String, dynamic> json) {
    return DayAvailability(
      day: json['day'] ?? json['day_name'] ?? '',
      dayOfWeek: json['day_of_week'],
      isAvailable: json['is_available'] == true || json['available'] == true,
      slots: json['slots'] != null
          ? (json['slots'] as List)
          .map((item) => AvailabilitySlot.fromJson(item))
          .toList()
          : (json['time_slots'] != null
          ? (json['time_slots'] as List)
          .map((item) => AvailabilitySlot.fromJson(item))
          .toList()
          : []),
    );
  }
}

class AvailabilitySlot {
  final String startTime;
  final String endTime;
  final bool isBooked;

  AvailabilitySlot({
    required this.startTime,
    required this.endTime,
    this.isBooked = false,
  });

  factory AvailabilitySlot.fromJson(Map<String, dynamic> json) {
    return AvailabilitySlot(
      startTime: json['start_time'] ?? json['from'] ?? '',
      endTime: json['end_time'] ?? json['to'] ?? '',
      isBooked: json['is_booked'] == true || json['booked'] == true,
    );
  }
}

/// Response model for update booking with payment handling
class UpdateBookingResponse {
  final bool success;
  final String message;
  final UpdateBookingData? data;
  final bool requiresPayment;
  final PaymentRequirement? paymentRequirement;
  final Map<String, dynamic>? validationErrors;

  UpdateBookingResponse({
    required this.success,
    required this.message,
    this.data,
    this.requiresPayment = false,
    this.paymentRequirement,
    this.validationErrors,
  });

  factory UpdateBookingResponse.fromJson(Map<String, dynamic> json) {
    return UpdateBookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UpdateBookingData.fromJson(json['data']) : null,
      requiresPayment: json['requires_payment'] ?? false,
      paymentRequirement: json['payment_requirement'] != null
          ? PaymentRequirement.fromJson(json['payment_requirement'])
          : null,
      validationErrors: json['errors'] is Map ? json['errors'] : null,
    );
  }
}

class UpdateBookingData {
  final BookingData? booking;
  final RefundInfo? refundInfo;
  final double? newTotalAmount;
  final double? oldTotalAmount;
  final double? differenceAmount;

  UpdateBookingData({
    this.booking,
    this.refundInfo,
    this.newTotalAmount,
    this.oldTotalAmount,
    this.differenceAmount,
  });

  factory UpdateBookingData.fromJson(Map<String, dynamic> json) {
    return UpdateBookingData(
      booking: json['booking'] != null ? BookingData.fromJson(json['booking']) : null,
      refundInfo: json['refund_info'] != null ? RefundInfo.fromJson(json['refund_info']) : null,
      newTotalAmount: _parseDoubleValue(json['new_total_amount']),
      oldTotalAmount: _parseDoubleValue(json['old_total_amount']),
      differenceAmount: _parseDoubleValue(json['difference_amount']),
    );
  }

  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class RefundInfo {
  final double amount;
  final String refundedTo;
  final String? transactionId;

  RefundInfo({
    required this.amount,
    required this.refundedTo,
    this.transactionId,
  });

  factory RefundInfo.fromJson(Map<String, dynamic> json) {
    return RefundInfo(
      amount: _parseDoubleValue(json['amount']) ?? 0.0,
      refundedTo: json['refunded_to'] ?? 'wallet',
      transactionId: json['transaction_id'],
    );
  }

  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

class PaymentRequirement {
  final double totalDue;
  final double walletBalance;
  final double walletAmountToUse;
  final double cashfreeAmountDue;
  final bool canPayFromWallet;

  PaymentRequirement({
    required this.totalDue,
    required this.walletBalance,
    required this.walletAmountToUse,
    required this.cashfreeAmountDue,
    required this.canPayFromWallet,
  });

  factory PaymentRequirement.fromJson(Map<String, dynamic> json) {
    return PaymentRequirement(
      totalDue: _parseDoubleValue(json['total_due']) ?? 0.0,
      walletBalance: _parseDoubleValue(json['wallet_balance']) ?? 0.0,
      walletAmountToUse: _parseDoubleValue(json['wallet_amount_to_use']) ?? 0.0,
      cashfreeAmountDue: _parseDoubleValue(json['cashfree_amount_due']) ?? 0.0,
      canPayFromWallet: json['can_pay_from_wallet'] ?? false,
    );
  }

  static double? _parseDoubleValue(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

/// Response model for cancel booking with refund
class CancelBookingResponse {
  final bool success;
  final String message;
  final CancelBookingData? data;

  CancelBookingResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory CancelBookingResponse.fromJson(Map<String, dynamic> json) {
    return CancelBookingResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CancelBookingData.fromJson(json['data']) : null,
    );
  }
}

class CancelBookingData {
  final int? bookingId;
  final String? status;
  final RefundInfo? refundInfo;

  CancelBookingData({
    this.bookingId,
    this.status,
    this.refundInfo,
  });

  factory CancelBookingData.fromJson(Map<String, dynamic> json) {
    return CancelBookingData(
      bookingId: json['booking_id'] ?? json['booking']?['id'],
      status: json['status'] ?? json['booking']?['status'],
      refundInfo: json['refund_info'] != null
          ? RefundInfo.fromJson(json['refund_info'])
          : (json['refund'] != null ? RefundInfo.fromJson(json['refund']) : null),
    );
  }
}
