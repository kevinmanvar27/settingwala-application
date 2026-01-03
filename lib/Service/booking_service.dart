import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/postbookingsmodel.dart';
import '../model/booking_payment_model.dart';
import '../model/booking_payment_details_model.dart';
import '../model/postbookingpaymentmodel.dart';
import '../utils/api_constants.dart';

class BookingService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<BookingResponse?> createBooking(Postbookingsmodel booking) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final body = booking.toJson();

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      
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
      
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<GetBookingsResponse?> getBookings() async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return GetBookingsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
          bookings: [],
        );
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return GetBookingsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return GetBookingsResponse(
          success: false,
          message: 'Session expired. Please login again.',
          bookings: [],
        );
      } else {
        return GetBookingsResponse(
          success: false,
          message: 'Failed to fetch bookings.',
          bookings: [],
        );
      }
    } catch (e) {
      
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
    try {
      final token = await _getToken();

      if (token == null) {
        
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
      
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> cancelBooking(int bookingId, {String? reason}) async {
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

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

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
        body['booking_date'] = bookingDate.toIso8601String().split('T')[0];
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

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId';

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
        return UpdateBookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return UpdateBookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 402) {
        // Payment required - need to pay extra amount
        return UpdateBookingResponse.fromJson(responseData);
      } else if (response.statusCode == 403) {
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Only the client can update the booking.',
        );
      } else if (response.statusCode == 400) {
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot update booking in current status.',
        );
      } else if (response.statusCode == 422) {
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Validation error. Please check your input.',
        );
      } else {
        return UpdateBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to update booking.',
        );
      }
    } catch (e) {
      return UpdateBookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Initiate payment for booking update difference
  /// Called when duration increases and extra payment is needed
  static Future<BookingPaymentModel?> initiateUpdatePayment(
    int bookingId,
    double differenceAmount, {
    String preferredPaymentMethod = 'wallet',
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        return BookingPaymentModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/initiate-update-payment';
      final body = {
        'amount': differenceAmount,
        'payment_method': preferredPaymentMethod,
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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
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
          message: responseData['message'] ?? 'Failed to initiate update payment.',
        );
      }
    } catch (e) {
      return BookingPaymentModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  /// Cancel booking and refund to wallet
  /// Money will be refunded to user's wallet
  static Future<CancelBookingResponse> cancelBookingWithRefund(int bookingId, {String? reason}) async {
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

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/bookings/$bookingId/cancel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CancelBookingResponse.fromJson(responseData);
      } else {
        return CancelBookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to cancel booking.',
        );
      }
    } catch (e) {
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
        body['booking_date'] = bookingDate.toIso8601String().split('T')[0];
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

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId';

      
      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return BookingResponse(
          success: false,
          message: 'Only the client can update the booking.',
        );
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Cannot update booking in current status.',
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
          message: responseData['message'] ?? 'Failed to update booking.',
        );
      }
    } catch (e) {
      
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingPaymentModel?> initiatePayment(
      int bookingId,
      double amount, {
        String preferredPaymentMethod = 'wallet',
      }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BookingPaymentModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/initiate-payment';
      final body = {
        'amount': amount,
        'payment_method': preferredPaymentMethod,
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

      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        
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
      
      return BookingPaymentModel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingPaymentDetailsModel?> getBookingPaymentDetails(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BookingPaymentDetailsModel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/payment';

       
      
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
    try {
      final token = await _getToken();

      if (token == null) {
        
        return PostBookingPaymentmodel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/process-payment';

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
        final responseData = jsonDecode(response.body);
        

        final result = PostBookingPaymentmodel.fromJson(responseData);

        return result;
      } else {
        final responseData = jsonDecode(response.body);
        return PostBookingPaymentmodel(
          success: false,
          message: responseData['message'] ?? 'Failed to process payment.',
        );
      }
    } catch (e) {
      
      return PostBookingPaymentmodel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> acceptBooking(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/accept';

       
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return BookingResponse(
          success: false,
          message: 'Only the provider can accept this booking.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to accept booking.',
        );
      }
    } catch (e) {
      
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<BookingResponse?> rejectBooking(int bookingId, {String? reason}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return BookingResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/reject';
      final body = <String, dynamic>{}; 
      if (reason != null && reason.isNotEmpty) {
        body['reason'] = reason;
      }

       
      
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
        final responseData = jsonDecode(response.body);
        return BookingResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return BookingResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 403) {
        return BookingResponse(
          success: false,
          message: 'Only the provider can reject this booking.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return BookingResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to reject booking.',
        );
      }
    } catch (e) {
      
      return BookingResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<AvailableSlotsResponse?> getAvailableSlots(int providerId, {required String date}) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return AvailableSlotsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$providerId/available-slots?date=$date';

       
      
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
        return AvailableSlotsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return AvailableSlotsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return AvailableSlotsResponse(
          success: false,
          message: 'Provider not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return AvailableSlotsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get available slots.',
        );
      }
    } catch (e) {
      
      return AvailableSlotsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<CalendarBookingsResponse?> getCalendarBookings(String date) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return CalendarBookingsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/calendar/bookings/$date';

       
      
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
        return CalendarBookingsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return CalendarBookingsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return CalendarBookingsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get calendar bookings.',
        );
      }
    } catch (e) {
      
      return CalendarBookingsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<UserAvailabilityResponse?> getUserAvailability(int userId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return UserAvailabilityResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/users/$userId/availability';

       
      
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
        return UserAvailabilityResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return UserAvailabilityResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return UserAvailabilityResponse(
          success: false,
          message: 'User not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return UserAvailabilityResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get user availability.',
        );
      }
    } catch (e) {
      
      return UserAvailabilityResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<ChatDetailsResponse?> getChatDetails(int bookingId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return ChatDetailsResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/chat-details';

       
      
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
        return ChatDetailsResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ChatDetailsResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return ChatDetailsResponse(
          success: false,
          message: 'Booking not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return ChatDetailsResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get chat details.',
        );
      }
    } catch (e) {
      
      return ChatDetailsResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<ProviderBookingStatusResponse?> getProviderBookingStatus(int providerId) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return ProviderBookingStatusResponse(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/provider/$providerId/status';

       
      
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
        return ProviderBookingStatusResponse.fromJson(responseData);
      } else if (response.statusCode == 401) {
        return ProviderBookingStatusResponse(
          success: false,
          message: 'Session expired. Please login again.',
        );
      } else if (response.statusCode == 404) {
        return ProviderBookingStatusResponse(
          success: false,
          message: 'Provider not found.',
        );
      } else {
        final responseData = jsonDecode(response.body);
        return ProviderBookingStatusResponse(
          success: false,
          message: responseData['message'] ?? 'Failed to get booking status.',
        );
      }
    } catch (e) {
      
      return ProviderBookingStatusResponse(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
  }

  static Future<PostBookingPaymentmodel> processDifferencePayment({
    required int bookingId,
    required double amount,
    String? cfOrderId,
    String? cfTransactionId,
    String? cfSignature,
    String paymentMethod = 'wallet',
  }) async {
    try {
      final token = await _getToken();

      if (token == null) {
        
        return PostBookingPaymentmodel(
          success: false,
          message: 'Authentication required. Please login again.',
        );
      }

      final url = '${ApiConstants.baseUrl}/bookings/$bookingId/process-difference-payment';

      final Map<String, dynamic> body = {
        'amount': amount,
        'payment_method': paymentMethod,
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
        final responseData = jsonDecode(response.body);
        
        return PostBookingPaymentmodel.fromJson(responseData);
      } else {
        final responseData = jsonDecode(response.body);
        return PostBookingPaymentmodel(
          success: false,
          message: responseData['message'] ?? 'Failed to process difference payment.',
        );
      }
    } catch (e) {
      
      return PostBookingPaymentmodel(
        success: false,
        message: 'Network error. Please check your connection.',
      );
    }
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

  UpdateBookingResponse({
    required this.success,
    required this.message,
    this.data,
    this.requiresPayment = false,
    this.paymentRequirement,
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
