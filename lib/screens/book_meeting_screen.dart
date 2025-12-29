// import 'package:flutter/material.dart';
// // Cashfree SDK imports
// import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
// import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
// import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
// import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
// import 'package:intl/intl.dart';
// import '../widgets/base_screen.dart';
// import '../theme/app_colors.dart';
// import '../theme/theme.dart';
// import '../utils/responsive.dart';
// import '../Service/user_service.dart';
// import '../Service/booking_service.dart';
// import '../model/getuseravailabilitymodel.dart';
// import '../model/postbookingsmodel.dart';
// import '../model/booking_payment_model.dart';
// import '../model/postbookingpaymentmodel.dart';
//
// /// Book Meeting Screen - Complete Booking Flow with Cashfree Payment
// ///
// /// Flow:
// /// Step 1: User selects date and time
// /// Step 2: Create booking → POST /api/v1/bookings
// /// Step 3: Initiate payment → POST /api/v1/bookings/{id}/initiate-payment
// /// Step 4: Open Cashfree SDK → User completes payment
// /// Step 5: Process payment → POST /api/v1/bookings/{id}/process-payment
// /// Step 6: Display success with complete booking details
// class BookMeetingScreen extends StatefulWidget {
//   final Map<String, dynamic> person;
//
//   const BookMeetingScreen({super.key, required this.person});
//
//   @override
//   State<BookMeetingScreen> createState() => _BookMeetingScreenState();
// }
//
// class _BookMeetingScreenState extends State<BookMeetingScreen> {
//   // Booking form state
//   DateTime? _selectedDate;
//   String? _startTime;  // Using String for proper dropdown comparison (format: "HH:MM")
//   String? _endTime;    // Using String for proper dropdown comparison (format: "HH:MM")
//
//   // Availability state
//   bool _isLoadingAvailability = false;
//   Getuseravailabilitymodel? _availability;
//   String? _availabilityError;
//
//   // Booking state
//   bool _isCreatingBooking = false;
//   bool _bookingSuccess = false;
//   BookingData? _bookingData;
//
//   // Payment state
//   bool _isProcessingPayment = false;
//   BookingPaymentData? _currentPaymentData;
//
//   // Payment result from process-payment API
//   PostBookingPaymentmodel? _paymentResult;
//
//   // Available time slots for dropdown (30-minute intervals as String "HH:MM")
//   List<String> _availableStartTimes = [];
//   List<String> _availableEndTimes = [];
//
//   @override
//   void initState() {
//     super.initState();
//     // Availability is fetched when date is selected
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // FETCH AVAILABILITY - Get provider's available time slots for selected date
//   // ═══════════════════════════════════════════════════════════════════════════
//   Future<void> _fetchAvailability() async {
//     if (_selectedDate == null) {
//       // No date selected yet, skip fetching
//       return;
//     }
//
//     setState(() {
//       _isLoadingAvailability = true;
//       _availabilityError = null;
//       _availability = null;
//       _startTime = null;
//       _endTime = null;
//       _availableStartTimes = [];
//       _availableEndTimes = [];
//     });
//
//     try {
//       final userId = widget.person['id'];
//       if (userId == null) {
//         setState(() {
//           _availabilityError = 'Invalid user ID';
//           _isLoadingAvailability = false;
//         });
//         return;
//       }
//
//       final result = await UserService.getUserAvailability(
//         userId: userId,
//         date: _selectedDate!,
//       );
//
//       if (!mounted) return;
//
//       if (result != null && result.success) {
//         setState(() {
//           _availability = result;
//           _isLoadingAvailability = false;
//           // Generate time slots from availability
//           _generateTimeSlots();
//         });
//         print('✅ Availability loaded: ${result.availableSlots.length} slots');
//       } else {
//         setState(() {
//           _availabilityError = 'No availability for this date';
//           _isLoadingAvailability = false;
//         });
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() {
//         _availabilityError = 'Error loading availability: $e';
//         _isLoadingAvailability = false;
//       });
//     }
//   }
//
//   // Convert time string "HH:MM" to display format "H:MM AM/PM"
//   String _formatTimeString(String time) {
//     final parts = time.split(':');
//     if (parts.length < 2) return time;
//     int hour = int.tryParse(parts[0]) ?? 0;
//     int minute = int.tryParse(parts[1]) ?? 0;
//     final period = hour >= 12 ? 'PM' : 'AM';
//     final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
//     return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
//   }
//
//   // Convert time string "HH:MM" to total minutes for comparison
//   int _timeToMinutes(String time) {
//     final parts = time.split(':');
//     if (parts.length < 2) return 0;
//     int hour = int.tryParse(parts[0]) ?? 0;
//     int minute = int.tryParse(parts[1]) ?? 0;
//     return hour * 60 + minute;
//   }
//
//   // Generate time slots from availability data (using available_slots array)
//   void _generateTimeSlots() {
//     if (_availability == null) return;
//
//     final startSlots = <String>[];
//     final endSlots = <String>[];
//     final now = DateTime.now();
//     final isToday = _selectedDate != null &&
//         _selectedDate!.year == now.year &&
//         _selectedDate!.month == now.month &&
//         _selectedDate!.day == now.day;
//     final currentMinutes = now.hour * 60 + now.minute;
//
//     // Generate 30-minute interval slots from available_slots array
//     for (final slot in _availability!.availableSlots) {
//       final startParts = slot.start.split(':');
//       final endParts = slot.end.split(':');
//
//       if (startParts.length >= 2 && endParts.length >= 2) {
//         int hour = int.tryParse(startParts[0]) ?? 9;
//         int minute = int.tryParse(startParts[1]) ?? 0;
//         final endHour = int.tryParse(endParts[0]) ?? 17;
//         final endMinute = int.tryParse(endParts[1]) ?? 0;
//         final endTotalMinutes = endHour * 60 + endMinute;
//
//         // Generate all 30-minute slots within this available slot
//         while (hour * 60 + minute < endTotalMinutes) {
//           final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
//           final slotMinutes = hour * 60 + minute;
//
//           // For start times: filter out past times if today
//           if (!isToday || slotMinutes > currentMinutes) {
//             if (!startSlots.contains(timeStr)) {
//               startSlots.add(timeStr);
//             }
//           }
//
//           // Add 30 minutes
//           minute += 30;
//           if (minute >= 60) {
//             hour += 1;
//             minute = 0;
//           }
//         }
//
//         // For end times: also add the final end time
//         final endTimeStr = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
//         if (!endSlots.contains(endTimeStr)) {
//           endSlots.add(endTimeStr);
//         }
//         // Add all start slots to end slots as well
//         for (final s in startSlots) {
//           if (!endSlots.contains(s)) {
//             endSlots.add(s);
//           }
//         }
//       }
//     }
//
//     // Sort slots by time
//     startSlots.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));
//     endSlots.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));
//
//     setState(() {
//       _availableStartTimes = startSlots;
//       _availableEndTimes = endSlots;
//     });
//
//     print('📅 Generated ${startSlots.length} start slots, ${endSlots.length} end slots');
//   }
//
//   // Get valid end times (at least 30 minutes after start time)
//   List<String> _getValidEndTimes() {
//     if (_startTime == null) return [];
//     final startMinutes = _timeToMinutes(_startTime!);
//     const minDurationMinutes = 30; // Minimum 30 minutes duration
//     return _availableEndTimes.where((t) {
//       final minutes = _timeToMinutes(t);
//       return minutes >= startMinutes + minDurationMinutes;
//     }).toList();
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // STEP 1: CREATE BOOKING
//   // ═══════════════════════════════════════════════════════════════════════════
//   Future<void> _step1_createBooking() async {
//     if (_selectedDate == null || _startTime == null || _endTime == null) {
//       _showError('Please select date and time');
//       return;
//     }
//
//     setState(() => _isCreatingBooking = true);
//
//     print('');
//     print('🚀 STEP 1: Creating booking...');
//
//     try {
//       final providerId = widget.person['id'];
//       final durationHours = _calculateDuration();
//
//       // Get meeting location from provider's service_location or use default
//       final meetingLocation = widget.person['service_location']?.toString() ?? 'To be decided';
//
//       final booking = Postbookingsmodel(
//         providerId: providerId,
//         bookingDate: _selectedDate!,
//         durationHours: durationHours,
//         meetingLocation: meetingLocation,
//         notes: '',
//       );
//
//       final response = await BookingService.createBooking(booking);
//
//       if (!mounted) return;
//
//       if (response != null && response.success && response.data != null) {
//         _bookingData = response.data as BookingData?;
//         print('✅ STEP 1 COMPLETE: Booking created');
//         print('   📌 Booking ID: ${_bookingData!.id}');
//         print('   📌 Total Amount: ₹${_bookingData!.totalAmount}');
//
//         // Proceed to Step 2: Initiate Payment
//         await _step2_initiatePayment();
//       } else {
//         setState(() => _isCreatingBooking = false);
//         _showError(response?.message ?? 'Failed to create booking');
//       }
//     } catch (e) {
//       print('❌ STEP 1 ERROR: $e');
//       setState(() => _isCreatingBooking = false);
//       _showError('Error creating booking: $e');
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // STEP 2: INITIATE PAYMENT - Create Cashfree order
//   // ═══════════════════════════════════════════════════════════════════════════
//   Future<void> _step2_initiatePayment() async {
//     if (_bookingData == null) {
//       _showError('No booking data available');
//       return;
//     }
//
//     print('');
//     print('🚀 STEP 2: Initiating payment...');
//
//     try {
//       final totalAmount = _bookingData!.totalAmount ?? 0.0;
//
//       final paymentResult = await BookingService.initiatePayment(
//         _bookingData!.id,
//         totalAmount,
//       );
//
//       if (!mounted) return;
//
//       if (paymentResult == null || !paymentResult.success || paymentResult.data == null) {
//         setState(() => _isCreatingBooking = false);
//         _showError(paymentResult?.message ?? 'Failed to initiate payment');
//         return;
//       }
//
//       _currentPaymentData = paymentResult.data;
//
//       print('✅ STEP 2 COMPLETE: Payment initiated');
//       print('   📌 Order ID: ${_currentPaymentData!.cashfreeOrder.orderId}');
//       print('   📌 Session ID: ${_currentPaymentData!.cashfreeOrder.paymentSessionId}');
//
//       // Check if payment is already completed
//       if (paymentResult.data!.paymentCompleted) {
//         print('⚠️ Payment already completed, skipping to success');
//         setState(() {
//           _isCreatingBooking = false;
//           _bookingSuccess = true;
//         });
//         return;
//       }
//
//       // Proceed to Step 3: Open Cashfree SDK
//       await _step3_openCashfreePayment();
//
//     } catch (e) {
//       print('❌ STEP 2 ERROR: $e');
//       setState(() => _isCreatingBooking = false);
//       _showError('Error initiating payment: $e');
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // STEP 3: OPEN CASHFREE SDK - User completes payment
//   // ═══════════════════════════════════════════════════════════════════════════
//   Future<void> _step3_openCashfreePayment() async {
//     if (_currentPaymentData == null) {
//       _showError('No payment data available');
//       return;
//     }
//
//     print('');
//     print('🚀 STEP 3: Opening Cashfree Payment SDK...');
//     print('   📌 Order ID: ${_currentPaymentData!.cashfreeOrder.orderId}');
//     print('   📌 Session ID: ${_currentPaymentData!.cashfreeOrder.paymentSessionId}');
//     print('   📌 Environment: ${_currentPaymentData!.cashfreeEnv}');
//
//     try {
//       // Determine environment
//       final cfEnvironment = _currentPaymentData!.cashfreeEnv.toLowerCase() == 'production'
//           ? CFEnvironment.PRODUCTION
//           : CFEnvironment.SANDBOX;
//
//       // Build Cashfree Session
//       final cfSession = CFSessionBuilder()
//           .setEnvironment(cfEnvironment)
//           .setOrderId(_currentPaymentData!.cashfreeOrder.orderId)
//           .setPaymentSessionId(_currentPaymentData!.cashfreeOrder.paymentSessionId)
//           .build();
//
//       // Configure payment components
//       // ignore: deprecated_member_use
//       final cfPaymentComponent = CFPaymentComponentBuilder()
//           .setComponents([
//             CFPaymentModes.CARD,
//             CFPaymentModes.UPI,
//             CFPaymentModes.NETBANKING,
//             CFPaymentModes.WALLET,
//           ])
//           .build();
//
//       // Configure theme
//       final cfTheme = CFThemeBuilder()
//           .setNavigationBarBackgroundColorColor("#6750A4")
//           .setNavigationBarTextColor("#FFFFFF")
//           .setButtonBackgroundColor("#6750A4")
//           .setButtonTextColor("#FFFFFF")
//           .setPrimaryTextColor("#000000")
//           .setSecondaryTextColor("#666666")
//           .build();
//
//       // Build drop checkout payment
//       // ignore: deprecated_member_use
//       final cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
//           .setSession(cfSession)
//           .setPaymentComponent(cfPaymentComponent)
//           .setTheme(cfTheme)
//           .build();
//
//       // Get payment gateway service and set callbacks
//       final cfPaymentGatewayService = CFPaymentGatewayService();
//
//       cfPaymentGatewayService.setCallback(
//         // ✅ SUCCESS CALLBACK
//         (String orderId) {
//           print('');
//           print('╔═══════════════════════════════════════════════════════════════╗');
//           print('║  ✅ STEP 3 SUCCESS: Payment Completed                         ║');
//           print('╠═══════════════════════════════════════════════════════════════╣');
//           print('║  Order ID: $orderId');
//           print('║  Booking ID: ${_bookingData?.id}');
//           print('╚═══════════════════════════════════════════════════════════════╝');
//
//           // Proceed to Step 4: Process Payment
//           _step4_processPayment(orderId);
//         },
//         // ❌ FAILURE CALLBACK
//         (CFErrorResponse errorResponse, String orderId) {
//           print('');
//           print('╔═══════════════════════════════════════════════════════════════╗');
//           print('║  ❌ STEP 3 FAILED: Payment Failed                             ║');
//           print('╠═══════════════════════════════════════════════════════════════╣');
//           print('║  Order ID: $orderId');
//           print('║  Error: ${errorResponse.getMessage()}');
//           print('╚═══════════════════════════════════════════════════════════════╝');
//
//           _onPaymentFailure(errorResponse.getMessage() ?? 'Payment failed');
//         },
//       );
//
//       // Start payment
//       cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
//
//     } on CFException catch (e) {
//       print('❌ STEP 3 Cashfree Exception: ${e.message}');
//       _onPaymentFailure(e.message);
//     } catch (e) {
//       print('❌ STEP 3 ERROR: $e');
//       _onPaymentFailure('Something went wrong. Please try again.');
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // STEP 4: PROCESS PAYMENT - Verify and complete payment
//   // Endpoint: POST /api/v1/bookings/{id}/process-payment
//   // ═══════════════════════════════════════════════════════════════════════════
//   Future<void> _step4_processPayment(String orderId) async {
//     if (!mounted) return;
//     if (_bookingData == null || _currentPaymentData == null) {
//       print('❌ STEP 4 ERROR: No booking or payment data available');
//       return;
//     }
//
//     print('');
//     print('🚀 STEP 4: Processing payment...');
//     print('   📌 Order ID: $orderId');
//     print('   📌 CF Order ID: ${_currentPaymentData!.cashfreeOrder.cfOrderId}');
//     print('   📌 Booking ID: ${_bookingData!.id}');
//
//     setState(() => _isProcessingPayment = true);
//     _showMessage('Processing payment...', isLoading: true);
//
//     try {
//       // Call process-payment API
//       final result = await BookingService.processPayment(
//         bookingId: _bookingData!.id,
//         cfOrderId: _currentPaymentData!.cashfreeOrder.cfOrderId,
//         cfTransactionId: orderId, // Use orderId as transaction reference
//         walletAmountUsed: 0.0,
//         paymentMethod: 'wallet_cashfree',
//       );
//
//       if (!mounted) return;
//
//       if (result.success) {
//         print('✅ STEP 4 COMPLETE: Payment processed');
//
//         // Store payment result for display
//         _paymentResult = result;
//
//         // Log booking details
//         if (result.data?.booking != null) {
//           final booking = result.data!.booking!;
//           print('');
//           print('╔═══════════════════════════════════════════════════════════════╗');
//           print('║  PAYMENT DETAILS FROM API                                     ║');
//           print('╠═══════════════════════════════════════════════════════════════╣');
//           print('║  Booking ID: ${booking.id}');
//           print('║  Status: ${booking.status}');
//           print('║  Payment Status: ${booking.paymentStatus}');
//           print('║  Total Amount: ₹${booking.totalAmount}');
//           print('║  Base Amount: ₹${booking.baseAmount}');
//           print('║  Platform Fee: ₹${booking.platformFee}');
//           print('║  Wallet Used: ₹${booking.walletAmountUsed}');
//           print('║  Cashfree Paid: ₹${booking.cfAmountPaid}');
//           print('║  Paid At: ${booking.paidAt}');
//           print('╚═══════════════════════════════════════════════════════════════╝');
//         }
//
//         setState(() {
//           _isProcessingPayment = false;
//           _isCreatingBooking = false;
//           _bookingSuccess = true;
//         });
//
//         _showMessage('Payment successful!', isSuccess: true);
//       } else {
//         print('❌ STEP 4 FAILED: ${result.message}');
//         setState(() {
//           _isProcessingPayment = false;
//           _isCreatingBooking = false;
//         });
//         _showError(result.message);
//       }
//
//     } catch (e) {
//       print('❌ STEP 4 ERROR: $e');
//       setState(() {
//         _isProcessingPayment = false;
//         _isCreatingBooking = false;
//       });
//       _showError('Error processing payment: $e');
//     }
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // HELPER: Handle Payment Failure
//   // ═══════════════════════════════════════════════════════════════════════════
//   void _onPaymentFailure(String errorMessage) {
//     if (!mounted) return;
//
//     setState(() {
//       _isProcessingPayment = false;
//       _isCreatingBooking = false;
//     });
//     _currentPaymentData = null;
//
//     _showError(errorMessage);
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // HELPER: Show Messages
//   // ═══════════════════════════════════════════════════════════════════════════
//   void _showError(String message) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: AppColors.white)),
//         backgroundColor: AppColors.error,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//       ),
//     );
//   }
//
//   void _showMessage(String message, {bool isSuccess = false, bool isLoading = false}) {
//     if (!mounted) return;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             if (isLoading) ...[
//               const SizedBox(
//                 width: 16,
//                 height: 16,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
//                 ),
//               ),
//               const SizedBox(width: 12),
//             ],
//             Expanded(child: Text(message, style: const TextStyle(color: AppColors.white))),
//           ],
//         ),
//         backgroundColor: isSuccess ? AppColors.success : AppColors.primary,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
//         duration: Duration(seconds: isLoading ? 10 : 3),
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // HELPER: Generate time slots based on availability
//   // ═══════════════════════════════════════════════════════════════════════════
//
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // HELPER: Calculate duration and amount
//   // ═══════════════════════════════════════════════════════════════════════════
//   double _calculateDuration() {
//     if (_startTime == null || _endTime == null) return 0;
//
//     final startMinutes = _timeToMinutes(_startTime!);
//     final endMinutes = _timeToMinutes(_endTime!);
//
//     return (endMinutes - startMinutes) / 60.0;
//   }
//
//   double _calculateAmount() {
//     final duration = _calculateDuration();
//     final hourlyRate = double.tryParse(widget.person['hourly_rate']?.toString() ?? '0') ?? 0;
//     return duration * hourlyRate;
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // BUILD UI
//   // ═══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     Responsive.init(context);
//     final colors = context.colors;
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
//
//     return BaseScreen(
//       title: 'Book Meeting',
//       showBackButton: true,
//       body: _bookingSuccess ? _buildSuccessSection(colors, primaryColor) : _buildBookingForm(colors, primaryColor),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // BUILD: Booking Form
//   // ═══════════════════════════════════════════════════════════════════════════
//   Widget _buildBookingForm(AppColorSet colors, Color primaryColor) {
//     final providerName = widget.person['name'] ?? 'Provider';
//     final hourlyRate = widget.person['hourly_rate']?.toString() ?? '0';
//     final profilePicture = widget.person['profile_picture'];
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(Responsive.wp(4)),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Provider Info Card
//           Container(
//             padding: EdgeInsets.all(Responsive.wp(4)),
//             decoration: BoxDecoration(
//               color: colors.card,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   radius: 30,
//                   backgroundImage: profilePicture != null ? NetworkImage(profilePicture) : null,
//                   child: profilePicture == null ? Icon(Icons.person, size: 30, color: colors.textSecondary) : null,
//                 ),
//                 SizedBox(width: Responsive.wp(4)),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         providerName,
//                         style: TextStyle(
//                           fontSize: Responsive.fontSize(18),
//                           fontWeight: FontWeight.bold,
//                           color: colors.textPrimary,
//                         ),
//                       ),
//                       SizedBox(height: Responsive.hp(0.5)),
//                       Text(
//                         '₹$hourlyRate/hour',
//                         style: TextStyle(
//                           fontSize: Responsive.fontSize(16),
//                           color: primaryColor,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           SizedBox(height: Responsive.hp(3)),
//
//           // Date Selection
//           Text(
//             'Select Date',
//             style: TextStyle(
//               fontSize: Responsive.fontSize(16),
//               fontWeight: FontWeight.w600,
//               color: colors.textPrimary,
//             ),
//           ),
//           SizedBox(height: Responsive.hp(1)),
//
//           InkWell(
//             onTap: () async {
//               final date = await showDatePicker(
//                 context: context,
//                 initialDate: DateTime.now().add(const Duration(days: 1)),
//                 firstDate: DateTime.now(),
//                 lastDate: DateTime.now().add(const Duration(days: 30)),
//               );
//               if (date != null) {
//                 setState(() {
//                   _selectedDate = date;
//                   _startTime = null;
//                   _endTime = null;
//                 });
//                 // Fetch availability for the selected date
//                 _fetchAvailability();
//               }
//             },
//             child: Container(
//               padding: EdgeInsets.all(Responsive.wp(4)),
//               decoration: BoxDecoration(
//                 color: colors.card,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: colors.border),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.calendar_today, color: primaryColor),
//                   SizedBox(width: Responsive.wp(3)),
//                   Text(
//                     _selectedDate != null
//                         ? DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!)
//                         : 'Choose a date',
//                     style: TextStyle(
//                       fontSize: Responsive.fontSize(15),
//                       color: _selectedDate != null ? colors.textPrimary : colors.textSecondary,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: Responsive.hp(3)),
//
//           // Time Selection
//           if (_selectedDate != null) ...[
//             Text(
//               'Select Time',
//               style: TextStyle(
//                 fontSize: Responsive.fontSize(16),
//                 fontWeight: FontWeight.w600,
//                 color: colors.textPrimary,
//               ),
//             ),
//             SizedBox(height: Responsive.hp(1)),
//
//             // Loading State
//             if (_isLoadingAvailability) ...[
//               Container(
//                 padding: EdgeInsets.all(Responsive.wp(6)),
//                 child: Center(
//                   child: Column(
//                     children: [
//                       CircularProgressIndicator(color: primaryColor),
//                       SizedBox(height: Responsive.hp(2)),
//                       Text(
//                         'Loading available slots...',
//                         style: TextStyle(
//                           color: colors.textSecondary,
//                           fontSize: Responsive.fontSize(14),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ]
//             // Error State
//             else if (_availabilityError != null) ...[
//               Container(
//                 padding: EdgeInsets.all(Responsive.wp(4)),
//                 decoration: BoxDecoration(
//                   color: AppColors.error.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: AppColors.error.withOpacity(0.3)),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.error_outline, color: AppColors.error),
//                     SizedBox(width: Responsive.wp(3)),
//                     Expanded(
//                       child: Text(
//                         _availabilityError!,
//                         style: TextStyle(
//                           color: AppColors.error,
//                           fontSize: Responsive.fontSize(14),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ]
//             // Empty Slots State
//             else if (_availableStartTimes.isEmpty) ...[
//               Container(
//                 padding: EdgeInsets.all(Responsive.wp(4)),
//                 decoration: BoxDecoration(
//                   color: colors.card,
//                   borderRadius: BorderRadius.circular(12),
//                   border: Border.all(color: colors.border),
//                 ),
//                 child: Row(
//                   children: [
//                     Icon(Icons.schedule, color: colors.textSecondary),
//                     SizedBox(width: Responsive.wp(3)),
//                     Expanded(
//                       child: Text(
//                         'No available slots for this date. Please select another date.',
//                         style: TextStyle(
//                           color: colors.textSecondary,
//                           fontSize: Responsive.fontSize(14),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ]
//             // Time Slots Available
//             else ...[
//               Row(
//                 children: [
//                   // Start Time
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Start Time', style: TextStyle(color: colors.textSecondary, fontSize: Responsive.fontSize(13))),
//                         SizedBox(height: Responsive.hp(0.5)),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: Responsive.wp(3)),
//                           decoration: BoxDecoration(
//                             color: colors.card,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: colors.border),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               isExpanded: true,
//                               value: _startTime,
//                               hint: Text('Select', style: TextStyle(color: colors.textSecondary)),
//                               items: _availableStartTimes.map((time) {
//                                 return DropdownMenuItem<String>(
//                                   value: time,
//                                   child: Text(_formatTimeString(time)),
//                                 );
//                               }).toList(),
//                               onChanged: (value) {
//                                 setState(() {
//                                   _startTime = value;
//                                   // Reset end time if it's not valid anymore
//                                   if (_endTime != null && value != null) {
//                                     final startMin = _timeToMinutes(value);
//                                     final endMin = _timeToMinutes(_endTime!);
//                                     if (endMin < startMin + 30) {
//                                       _endTime = null;
//                                     }
//                                   }
//                                 });
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   SizedBox(width: Responsive.wp(4)),
//                   // End Time
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('End Time', style: TextStyle(color: colors.textSecondary, fontSize: Responsive.fontSize(13))),
//                         SizedBox(height: Responsive.hp(0.5)),
//                         Container(
//                           padding: EdgeInsets.symmetric(horizontal: Responsive.wp(3)),
//                           decoration: BoxDecoration(
//                             color: colors.card,
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: colors.border),
//                           ),
//                           child: DropdownButtonHideUnderline(
//                             child: DropdownButton<String>(
//                               isExpanded: true,
//                               value: _endTime,
//                               hint: Text('Select', style: TextStyle(color: colors.textSecondary)),
//                               items: _getValidEndTimes().map((time) {
//                                 return DropdownMenuItem<String>(
//                                   value: time,
//                                   child: Text(_formatTimeString(time)),
//                                 );
//                               }).toList(),
//                               onChanged: _startTime == null ? null : (value) {
//                                 setState(() => _endTime = value);
//                               },
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ],
//
//           SizedBox(height: Responsive.hp(3)),
//
//           // Booking Summary
//           if (_startTime != null && _endTime != null) ...[
//             Container(
//               padding: EdgeInsets.all(Responsive.wp(4)),
//               decoration: BoxDecoration(
//                 color: primaryColor.withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Booking Summary',
//                     style: TextStyle(
//                       fontSize: Responsive.fontSize(16),
//                       fontWeight: FontWeight.bold,
//                       color: colors.textPrimary,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.hp(1.5)),
//                   _buildSummaryRow('Duration', '${_calculateDuration().toStringAsFixed(1)} hours', colors),
//                   _buildSummaryRow('Rate', '₹$hourlyRate/hour', colors),
//                   Divider(color: colors.border),
//                   _buildSummaryRow(
//                     'Total Amount',
//                     '₹${_calculateAmount().toStringAsFixed(0)}',
//                     colors,
//                     isBold: true,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//
//           SizedBox(height: Responsive.hp(4)),
//
//           // Book Button
//           SizedBox(
//             width: double.infinity,
//             height: Responsive.hp(6),
//             child: ElevatedButton(
//               onPressed: (_isCreatingBooking || _startTime == null || _endTime == null)
//                   ? null
//                   : _step1_createBooking,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 disabledBackgroundColor: colors.border,
//               ),
//               child: _isCreatingBooking
//                   ? const SizedBox(
//                       width: 24,
//                       height: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2,
//                         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                       ),
//                     )
//                   : Text(
//                       'Proceed to Payment',
//                       style: TextStyle(
//                         fontSize: Responsive.fontSize(16),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value, AppColorSet colors, {bool isBold = false}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: Responsive.hp(0.5)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: Responsive.fontSize(14),
//               color: colors.textSecondary,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
//             ),
//           ),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: Responsive.fontSize(14),
//               color: colors.textPrimary,
//               fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ═══════════════════════════════════════════════════════════════════════════
//   // BUILD: Success Section with Complete Payment Details
//   // ═══════════════════════════════════════════════════════════════════════════
//   Widget _buildSuccessSection(AppColorSet colors, Color primaryColor) {
//     final booking = _paymentResult?.data?.booking;
//     final paymentDetails = _paymentResult?.data?.paymentDetails;
//     final otherUser = booking?.otherUser;
//
//     return SingleChildScrollView(
//       padding: EdgeInsets.all(Responsive.wp(4)),
//       child: Column(
//         children: [
//           // Success Icon
//           Container(
//             padding: EdgeInsets.all(Responsive.wp(6)),
//             decoration: BoxDecoration(
//               color: AppColors.success.withOpacity(0.1),
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.check_circle,
//               size: Responsive.wp(20),
//               color: AppColors.success,
//             ),
//           ),
//
//           SizedBox(height: Responsive.hp(3)),
//
//           Text(
//             'Payment Successful!',
//             style: TextStyle(
//               fontSize: Responsive.fontSize(24),
//               fontWeight: FontWeight.bold,
//               color: colors.textPrimary,
//             ),
//           ),
//
//           SizedBox(height: Responsive.hp(1)),
//
//           Text(
//             _paymentResult?.message ?? 'Your booking has been confirmed',
//             style: TextStyle(
//               fontSize: Responsive.fontSize(14),
//               color: colors.textSecondary,
//             ),
//             textAlign: TextAlign.center,
//           ),
//
//           SizedBox(height: Responsive.hp(4)),
//
//           // Booking Details Card
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(Responsive.wp(4)),
//             decoration: BoxDecoration(
//               color: colors.card,
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 10,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Header
//                 Row(
//                   children: [
//                     Icon(Icons.receipt_long, color: primaryColor),
//                     SizedBox(width: Responsive.wp(2)),
//                     Text(
//                       'Booking Details',
//                       style: TextStyle(
//                         fontSize: Responsive.fontSize(18),
//                         fontWeight: FontWeight.bold,
//                         color: colors.textPrimary,
//                       ),
//                     ),
//                   ],
//                 ),
//
//                 Divider(height: Responsive.hp(3), color: colors.border),
//
//                 // Booking ID
//                 _buildDetailRow('Booking ID', '#${booking?.id ?? _bookingData?.id ?? '-'}', colors),
//
//                 // Status
//                 _buildDetailRow('Status', booking?.status?.toUpperCase() ?? 'CONFIRMED', colors,
//                   valueColor: AppColors.success),
//
//                 // Payment Status
//                 _buildDetailRow('Payment Status', booking?.paymentStatus?.toUpperCase() ?? 'PAID', colors,
//                   valueColor: AppColors.success),
//
//                 Divider(height: Responsive.hp(2), color: colors.border),
//
//                 // Provider Info
//                 if (otherUser != null) ...[
//                   _buildDetailRow('Provider', otherUser.name ?? '-', colors),
//                   if (otherUser.serviceLocation != null)
//                     _buildDetailRow('Location', otherUser.serviceLocation!, colors),
//                 ],
//
//                 // Date & Time
//                 if (booking?.bookingDate != null)
//                   _buildDetailRow('Date', DateFormat('EEEE, MMM dd, yyyy').format(booking!.bookingDate!), colors),
//                 _buildDetailRow('Time', '${booking?.startTime ?? (_startTime != null ? _formatTimeString(_startTime!) : '-')} - ${booking?.endTime ?? (_endTime != null ? _formatTimeString(_endTime!) : '-')}', colors),
//                 _buildDetailRow('Duration', '${booking?.durationHours ?? _calculateDuration().toStringAsFixed(1)} hours', colors),
//
//                 Divider(height: Responsive.hp(2), color: colors.border),
//
//                 // Amount Breakdown
//                 Text(
//                   'Payment Breakdown',
//                   style: TextStyle(
//                     fontSize: Responsive.fontSize(14),
//                     fontWeight: FontWeight.w600,
//                     color: colors.textSecondary,
//                   ),
//                 ),
//                 SizedBox(height: Responsive.hp(1)),
//
//                 _buildDetailRow('Hourly Rate', '₹${booking?.hourlyRate ?? widget.person['hourly_rate'] ?? '-'}/hr', colors),
//                 _buildDetailRow('Base Amount', '₹${booking?.baseAmount ?? '-'}', colors),
//                 _buildDetailRow('Platform Fee', '₹${booking?.platformFee ?? '-'}', colors),
//
//                 Divider(height: Responsive.hp(2), color: colors.border),
//
//                 _buildDetailRow('Total Amount', '₹${booking?.totalAmount ?? paymentDetails?.totalAmount ?? '-'}', colors,
//                   isBold: true, valueColor: primaryColor),
//
//                 SizedBox(height: Responsive.hp(1)),
//
//                 // Payment Method Breakdown
//                 Container(
//                   padding: EdgeInsets.all(Responsive.wp(3)),
//                   decoration: BoxDecoration(
//                     color: primaryColor.withOpacity(0.05),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Column(
//                     children: [
//                       _buildDetailRow('Wallet Used', '₹${booking?.walletAmountUsed ?? paymentDetails?.walletUsed ?? '0'}', colors),
//                       _buildDetailRow('Cashfree Paid', '₹${booking?.cfAmountPaid ?? paymentDetails?.cashfreePaid ?? '-'}', colors),
//                       _buildDetailRow('Payment Method', booking?.paymentMethod ?? paymentDetails?.paymentMethod ?? 'cashfree', colors),
//                     ],
//                   ),
//                 ),
//
//                 // Paid At Timestamp
//                 if (booking?.paidAt != null) ...[
//                   SizedBox(height: Responsive.hp(2)),
//                   _buildDetailRow('Paid At', DateFormat('MMM dd, yyyy hh:mm a').format(booking!.paidAt!), colors),
//                 ],
//
//                 // Provider Earnings (if available)
//                 if (booking?.providerAmount != null) ...[
//                   Divider(height: Responsive.hp(2), color: colors.border),
//                   Text(
//                     'Provider Info',
//                     style: TextStyle(
//                       fontSize: Responsive.fontSize(14),
//                       fontWeight: FontWeight.w600,
//                       color: colors.textSecondary,
//                     ),
//                   ),
//                   SizedBox(height: Responsive.hp(1)),
//                   _buildDetailRow('Commission', '${booking?.commissionPercentage ?? '-'}%', colors),
//                   _buildDetailRow('Provider Earnings', '₹${booking?.providerAmount ?? '-'}', colors),
//                 ],
//               ],
//             ),
//           ),
//
//           SizedBox(height: Responsive.hp(4)),
//
//           // Done Button
//           SizedBox(
//             width: double.infinity,
//             height: Responsive.hp(6),
//             child: ElevatedButton(
//               onPressed: () => Navigator.pop(context),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: primaryColor,
//                 foregroundColor: Colors.white,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: Text(
//                 'Done',
//                 style: TextStyle(
//                   fontSize: Responsive.fontSize(16),
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ),
//           ),
//
//           SizedBox(height: Responsive.hp(2)),
//
//           // View Bookings Button
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               // Navigate to my bookings screen
//             },
//             child: Text(
//               'View My Bookings',
//               style: TextStyle(
//                 fontSize: Responsive.fontSize(14),
//                 color: primaryColor,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDetailRow(String label, String value, AppColorSet colors, {bool isBold = false, Color? valueColor}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: Responsive.hp(0.5)),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: Responsive.fontSize(13),
//               color: colors.textSecondary,
//             ),
//           ),
//           SizedBox(width: Responsive.wp(2)),
//           Flexible(
//             child: Text(
//               value,
//               style: TextStyle(
//                 fontSize: Responsive.fontSize(13),
//                 color: valueColor ?? colors.textPrimary,
//                 fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import 'package:intl/intl.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/user_service.dart';
import '../Service/booking_service.dart';
import '../model/getuseravailabilitymodel.dart';
import '../model/postbookingsmodel.dart';
import '../model/booking_payment_model.dart';
import '../model/postbookingpaymentmodel.dart';

class BookMeetingScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const BookMeetingScreen({super.key, required this.person});

  @override
  State<BookMeetingScreen> createState() => _BookMeetingScreenState();
}

class _BookMeetingScreenState extends State<BookMeetingScreen> {
  DateTime? _selectedDate;
  String? _startTime;
  String? _endTime;

  bool _isLoadingAvailability = false;
  Getuseravailabilitymodel? _availability;
  String? _availabilityError;

  bool _isCreatingBooking = false;
  bool _bookingSuccess = false;
  BookingData? _bookingData;

  bool _isProcessingPayment = false;
  BookingPaymentData? _currentPaymentData;
  PostBookingPaymentmodel? _paymentResult;

  List<String> _availableStartTimes = [];
  List<String> _availableEndTimes = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> _fetchAvailability() async {
    if (_selectedDate == null) {
      return;
    }

    setState(() {
      _isLoadingAvailability = true;
      _availabilityError = null;
      _availability = null;
      _startTime = null;
      _endTime = null;
      _availableStartTimes = [];
      _availableEndTimes = [];
    });

    try {
      final userId = widget.person['id'];
      if (userId == null) {
        setState(() {
          _availabilityError = 'Invalid user ID';
          _isLoadingAvailability = false;
        });
        return;
      }

      final result = await UserService.getUserAvailability(
        userId: userId,
        date: _selectedDate!,
      );

      if (!mounted) return;

      if (result != null && result.success) {
        setState(() {
          _availability = result;
          _isLoadingAvailability = false;
          _generateTimeSlots();
        });
      } else {
        setState(() {
          _availabilityError = 'No availability for this date';
          _isLoadingAvailability = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _availabilityError = 'Error loading availability: $e';
        _isLoadingAvailability = false;
      });
    }
  }

  String _formatTimeString(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return 0;
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;
    return hour * 60 + minute;
  }

  String _minutesToTime(int minutes) {
    int hour = minutes ~/ 60;
    int minute = minutes % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  void _generateTimeSlots() {
    if (_availability == null || _availability!.availableSlots.isEmpty) {
      return;
    }

    final startSlots = <String>[];
    final endSlots = <String>[];
    final now = DateTime.now();
    final isToday = _selectedDate != null &&
        _selectedDate!.year == now.year &&
        _selectedDate!.month == now.month &&
        _selectedDate!.day == now.day;

    int currentMinutes = now.hour * 60 + now.minute;

    for (final slot in _availability!.availableSlots) {
      try {
        final startParts = slot.start.split(':');
        final endParts = slot.end.split(':');

        if (startParts.length < 2 || endParts.length < 2) continue;

        int startHour = int.tryParse(startParts[0]) ?? 0;
        int startMinute = int.tryParse(startParts[1]) ?? 0;
        int endHour = int.tryParse(endParts[0]) ?? 0;
        int endMinute = int.tryParse(endParts[1]) ?? 0;

        int startTotalMinutes = startHour * 60 + startMinute;
        int endTotalMinutes = endHour * 60 + endMinute;

        // For today, filter out past times by finding next 30-minute slot
        int firstSlotMinutes = startTotalMinutes;
        if (isToday) {
          // Find next available 30-minute slot
          int next30MinuteSlot = ((currentMinutes + 29) ~/ 30) * 30;
          if (next30MinuteSlot >= startTotalMinutes && next30MinuteSlot < endTotalMinutes) {
            firstSlotMinutes = next30MinuteSlot;
          } else if (next30MinuteSlot < startTotalMinutes) {
            firstSlotMinutes = startTotalMinutes;
          } else {
            continue; // No available slots today
          }
        }

        // Generate 30-minute slots
        for (int slotMinutes = firstSlotMinutes; slotMinutes + 30 <= endTotalMinutes; slotMinutes += 30) {
          final startTimeStr = _minutesToTime(slotMinutes);
          final endTimeStr = _minutesToTime(slotMinutes + 30);

          if (!startSlots.contains(startTimeStr)) {
            startSlots.add(startTimeStr);
          }
          if (!endSlots.contains(endTimeStr)) {
            endSlots.add(endTimeStr);
          }
        }
      } catch (e) {
        print('Error processing slot: $e');
      }
    }

    startSlots.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));
    endSlots.sort((a, b) => _timeToMinutes(a).compareTo(_timeToMinutes(b)));

    setState(() {
      _availableStartTimes = startSlots;
      _availableEndTimes = endSlots;
    });
  }

  List<String> _getValidEndTimes() {
    if (_startTime == null) return [];
    final startMinutes = _timeToMinutes(_startTime!);
    return _availableEndTimes.where((t) {
      final minutes = _timeToMinutes(t);
      return minutes >= startMinutes + 30;
    }).toList();
  }

  Future<void> _step1_createBooking() async {
    if (_selectedDate == null || _startTime == null || _endTime == null) {
      _showError('Please select date and time');
      return;
    }

    setState(() => _isCreatingBooking = true);

    try {
      final providerId = widget.person['id'];
      final durationHours = _calculateDuration();

      // Use selected time slots for meeting location
      final meetingLocation = '${_formatTimeString(_startTime!)} - ${_formatTimeString(_endTime!)}';

      final booking = Postbookingsmodel(
        providerId: providerId,
        bookingDate: _selectedDate!,
        durationHours: durationHours,
        meetingLocation: meetingLocation,
        notes: '',
      );

      final response = await BookingService.createBooking(booking);

      if (!mounted) return;

      if (response != null && response.success && response.data != null) {
        _bookingData = response.data as BookingData?;
        await _step2_initiatePayment();
      } else {
        setState(() => _isCreatingBooking = false);
        _showError(response?.message ?? 'Failed to create booking');
      }
    } catch (e) {
      setState(() => _isCreatingBooking = false);
      _showError('Error creating booking: $e');
    }
  }

  Future<void> _step2_initiatePayment() async {
    if (_bookingData == null) {
      _showError('No booking data available');
      return;
    }

    try {
      final totalAmount = _bookingData!.totalAmount ?? 0.0;

      final paymentResult = await BookingService.initiatePayment(
        _bookingData!.id,
        totalAmount,
      );

      if (!mounted) return;

      if (paymentResult == null || !paymentResult.success || paymentResult.data == null) {
        setState(() => _isCreatingBooking = false);
        _showError(paymentResult?.message ?? 'Failed to initiate payment');
        return;
      }

      _currentPaymentData = paymentResult.data;

      if (paymentResult.data!.paymentCompleted) {
        setState(() {
          _isCreatingBooking = false;
          _bookingSuccess = true;
        });
        return;
      }

      await _step3_openCashfreePayment();

    } catch (e) {
      setState(() => _isCreatingBooking = false);
      _showError('Error initiating payment: $e');
    }
  }

  Future<void> _step3_openCashfreePayment() async {
    if (_currentPaymentData == null) {
      _showError('No payment data available');
      return;
    }

    try {
      final cfEnvironment = _currentPaymentData!.cashfreeEnv.toLowerCase() == 'production'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final cfSession = CFSessionBuilder()
          .setEnvironment(cfEnvironment)
          .setOrderId(_currentPaymentData!.cashfreeOrder.orderId)
          .setPaymentSessionId(_currentPaymentData!.cashfreeOrder.paymentSessionId)
          .build();

      final cfPaymentComponent = CFPaymentComponentBuilder()
          .setComponents([
        CFPaymentModes.CARD,
        CFPaymentModes.UPI,
        CFPaymentModes.NETBANKING,
        CFPaymentModes.WALLET,
      ])
          .build();

      final cfTheme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#6750A4")
          .setNavigationBarTextColor("#FFFFFF")
          .setButtonBackgroundColor("#6750A4")
          .setButtonTextColor("#FFFFFF")
          .setPrimaryTextColor("#000000")
          .setSecondaryTextColor("#666666")
          .build();

      final cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(cfSession)
          .setPaymentComponent(cfPaymentComponent)
          .setTheme(cfTheme)
          .build();

      final cfPaymentGatewayService = CFPaymentGatewayService();

      cfPaymentGatewayService.setCallback(
            (String orderId) {
          _step4_processPayment(orderId);
        },
            (CFErrorResponse errorResponse, String orderId) {
          _onPaymentFailure(errorResponse.getMessage() ?? 'Payment failed');
        },
      );

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);

    } on CFException catch (e) {
      _onPaymentFailure(e.message);
    } catch (e) {
      _onPaymentFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> _step4_processPayment(String orderId) async {
    if (!mounted) return;
    if (_bookingData == null || _currentPaymentData == null) {
      return;
    }

    setState(() => _isProcessingPayment = true);
    _showMessage('Processing payment...', isLoading: true);

    try {
      final result = await BookingService.processPayment(
        bookingId: _bookingData!.id,
        cfOrderId: _currentPaymentData!.cashfreeOrder.cfOrderId,
        cfTransactionId: orderId,
        walletAmountUsed: 0.0,
        paymentMethod: 'wallet_cashfree',
      );

      if (!mounted) return;

      if (result.success) {
        _paymentResult = result;

        setState(() {
          _isProcessingPayment = false;
          _isCreatingBooking = false;
          _bookingSuccess = true;
        });

        _showMessage('Payment successful!', isSuccess: true);
      } else {
        setState(() {
          _isProcessingPayment = false;
          _isCreatingBooking = false;
        });
        _showError(result.message);
      }

    } catch (e) {
      setState(() {
        _isProcessingPayment = false;
        _isCreatingBooking = false;
      });
      _showError('Error processing payment: $e');
    }
  }

  void _onPaymentFailure(String errorMessage) {
    if (!mounted) return;

    setState(() {
      _isProcessingPayment = false;
      _isCreatingBooking = false;
    });
    _currentPaymentData = null;

    _showError(errorMessage);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  void _showMessage(String message, {bool isSuccess = false, bool isLoading = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.white))),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: Duration(seconds: isLoading ? 10 : 3),
      ),
    );
  }

  double _calculateDuration() {
    if (_startTime == null || _endTime == null) return 0;

    final startMinutes = _timeToMinutes(_startTime!);
    final endMinutes = _timeToMinutes(_endTime!);

    return (endMinutes - startMinutes) / 60.0;
  }

  double _calculateAmount() {
    final duration = _calculateDuration();
    final hourlyRate = double.tryParse(widget.person['hourly_rate']?.toString() ?? '0') ?? 0;
    return duration * hourlyRate;
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return BaseScreen(
      title: 'Book Meeting',
      showBackButton: true,
      body: _bookingSuccess ? _buildSuccessSection(colors, primaryColor) : _buildBookingForm(colors, primaryColor),
    );
  }

  Widget _buildBookingForm(AppColorSet colors, Color primaryColor) {
    final providerName = widget.person['name'] ?? 'Provider';
    final hourlyRate = widget.person['hourly_rate']?.toString() ?? '0';
    final profilePicture = widget.person['profile_picture'];

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.wp(4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.wp(4)),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: profilePicture != null ? NetworkImage(profilePicture) : null,
                  child: profilePicture == null ? Icon(Icons.person, size: 30, color: colors.textSecondary) : null,
                ),
                SizedBox(width: Responsive.wp(4)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: TextStyle(
                          fontSize: Responsive.fontSize(18),
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: Responsive.hp(0.5)),
                      Text(
                        '₹$hourlyRate/hour',
                        style: TextStyle(
                          fontSize: Responsive.fontSize(16),
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: Responsive.hp(3)),

          Text(
            'Select Date',
            style: TextStyle(
              fontSize: Responsive.fontSize(16),
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: Responsive.hp(1)),

          InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: DateTime.now().add(const Duration(days: 1)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 30)),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                  _startTime = null;
                  _endTime = null;
                });
                _fetchAvailability();
              }
            },
            child: Container(
              padding: EdgeInsets.all(Responsive.wp(4)),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: primaryColor),
                  SizedBox(width: Responsive.wp(3)),
                  Text(
                    _selectedDate != null
                        ? DateFormat('EEEE, MMM dd, yyyy').format(_selectedDate!)
                        : 'Choose a date',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(15),
                      color: _selectedDate != null ? colors.textPrimary : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: Responsive.hp(3)),

          if (_selectedDate != null) ...[
            Text(
              'Select Time',
              style: TextStyle(
                fontSize: Responsive.fontSize(16),
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: Responsive.hp(1)),

            if (_isLoadingAvailability) ...[
              Container(
                padding: EdgeInsets.all(Responsive.wp(6)),
                child: Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: primaryColor),
                      SizedBox(height: Responsive.hp(2)),
                      Text(
                        'Loading available slots...',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: Responsive.fontSize(14),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]
            else if (_availabilityError != null) ...[
              Container(
                padding: EdgeInsets.all(Responsive.wp(4)),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppColors.error),
                    SizedBox(width: Responsive.wp(3)),
                    Expanded(
                      child: Text(
                        _availabilityError!,
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: Responsive.fontSize(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]
            else if (_availableStartTimes.isEmpty) ...[
                Container(
                  padding: EdgeInsets.all(Responsive.wp(4)),
                  decoration: BoxDecoration(
                    color: colors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.schedule, color: colors.textSecondary),
                      SizedBox(width: Responsive.wp(3)),
                      Expanded(
                        child: Text(
                          'No available slots for this date. Please select another date.',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: Responsive.fontSize(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]
              else ...[
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Start Time', style: TextStyle(color: colors.textSecondary, fontSize: Responsive.fontSize(13))),
                            SizedBox(height: Responsive.hp(0.5)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(3)),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _startTime,
                                  hint: Text('Select', style: TextStyle(color: colors.textSecondary)),
                                  items: _availableStartTimes.map((time) {
                                    return DropdownMenuItem<String>(
                                      value: time,
                                      child: Text(_formatTimeString(time)),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _startTime = value;
                                      if (_endTime != null && value != null) {
                                        final startMin = _timeToMinutes(value);
                                        final endMin = _timeToMinutes(_endTime!);
                                        if (endMin < startMin + 30) {
                                          _endTime = null;
                                        }
                                      }
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: Responsive.wp(4)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('End Time', style: TextStyle(color: colors.textSecondary, fontSize: Responsive.fontSize(13))),
                            SizedBox(height: Responsive.hp(0.5)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: Responsive.wp(3)),
                              decoration: BoxDecoration(
                                color: colors.card,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: colors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: _endTime,
                                  hint: Text('Select', style: TextStyle(color: colors.textSecondary)),
                                  items: _getValidEndTimes().map((time) {
                                    return DropdownMenuItem<String>(
                                      value: time,
                                      child: Text(_formatTimeString(time)),
                                    );
                                  }).toList(),
                                  onChanged: _startTime == null ? null : (value) {
                                    setState(() => _endTime = value);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
          ],

          SizedBox(height: Responsive.hp(3)),

          if (_startTime != null && _endTime != null) ...[
            Container(
              padding: EdgeInsets.all(Responsive.wp(4)),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking Summary',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(16),
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1.5)),
                  _buildSummaryRow('Duration', '${_calculateDuration().toStringAsFixed(1)} hours', colors),
                  _buildSummaryRow('Rate', '₹$hourlyRate/hour', colors),
                  Divider(color: colors.border),
                  _buildSummaryRow(
                    'Total Amount',
                    '₹${_calculateAmount().toStringAsFixed(0)}',
                    colors,
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: Responsive.hp(4)),

          SizedBox(
            width: double.infinity,
            height: Responsive.hp(6),
            child: ElevatedButton(
              onPressed: (_isCreatingBooking || _startTime == null || _endTime == null)
                  ? null
                  : _step1_createBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                disabledBackgroundColor: colors.border,
              ),
              child: _isCreatingBooking
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : Text(
                'Proceed to Payment',
                style: TextStyle(
                  fontSize: Responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, AppColorSet colors, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.hp(0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(14),
              color: colors.textSecondary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: Responsive.fontSize(14),
              color: colors.textPrimary,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessSection(AppColorSet colors, Color primaryColor) {
    final booking = _paymentResult?.data?.booking;
    final paymentDetails = _paymentResult?.data?.paymentDetails;
    final otherUser = booking?.otherUser;

    return SingleChildScrollView(
      padding: EdgeInsets.all(Responsive.wp(4)),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.wp(6)),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: Responsive.wp(20),
              color: AppColors.success,
            ),
          ),

          SizedBox(height: Responsive.hp(3)),

          Text(
            'Payment Successful!',
            style: TextStyle(
              fontSize: Responsive.fontSize(24),
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),

          SizedBox(height: Responsive.hp(1)),

          Text(
            _paymentResult?.message ?? 'Your booking has been confirmed',
            style: TextStyle(
              fontSize: Responsive.fontSize(14),
              color: colors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          SizedBox(height: Responsive.hp(4)),

          Container(
            width: double.infinity,
            padding: EdgeInsets.all(Responsive.wp(4)),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.receipt_long, color: primaryColor),
                    SizedBox(width: Responsive.wp(2)),
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: Responsive.fontSize(18),
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),

                Divider(height: Responsive.hp(3), color: colors.border),

                _buildDetailRow('Booking ID', '#${booking?.id ?? _bookingData?.id ?? '-'}', colors),
                _buildDetailRow('Status', booking?.status?.toUpperCase() ?? 'CONFIRMED', colors,
                    valueColor: AppColors.success),
                _buildDetailRow('Payment Status', booking?.paymentStatus?.toUpperCase() ?? 'PAID', colors,
                    valueColor: AppColors.success),

                Divider(height: Responsive.hp(2), color: colors.border),

                if (otherUser != null) ...[
                  _buildDetailRow('Provider', otherUser.name ?? '-', colors),
                  if (otherUser.serviceLocation != null)
                    _buildDetailRow('Location', otherUser.serviceLocation!, colors),
                ],

                if (booking?.bookingDate != null)
                  _buildDetailRow('Date', DateFormat('EEEE, MMM dd, yyyy').format(booking!.bookingDate!), colors),
                _buildDetailRow('Time', '${booking?.startTime ?? (_startTime != null ? _formatTimeString(_startTime!) : '-')} - ${booking?.endTime ?? (_endTime != null ? _formatTimeString(_endTime!) : '-')}', colors),
                _buildDetailRow('Duration', '${booking?.durationHours ?? _calculateDuration().toStringAsFixed(1)} hours', colors),

                Divider(height: Responsive.hp(2), color: colors.border),

                Text(
                  'Payment Breakdown',
                  style: TextStyle(
                    fontSize: Responsive.fontSize(14),
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(height: Responsive.hp(1)),

                _buildDetailRow('Hourly Rate', '₹${booking?.hourlyRate ?? widget.person['hourly_rate'] ?? '-'}/hr', colors),
                _buildDetailRow('Base Amount', '₹${booking?.baseAmount ?? '-'}', colors),
                _buildDetailRow('Platform Fee', '₹${booking?.platformFee ?? '-'}', colors),

                Divider(height: Responsive.hp(2), color: colors.border),

                _buildDetailRow('Total Amount', '₹${booking?.totalAmount ?? paymentDetails?.totalAmount ?? '-'}', colors,
                    isBold: true, valueColor: primaryColor),

                SizedBox(height: Responsive.hp(1)),

                Container(
                  padding: EdgeInsets.all(Responsive.wp(3)),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow('Wallet Used', '₹${booking?.walletAmountUsed ?? paymentDetails?.walletUsed ?? '0'}', colors),
                      _buildDetailRow('Cashfree Paid', '₹${booking?.cfAmountPaid ?? paymentDetails?.cashfreePaid ?? '-'}', colors),
                      _buildDetailRow('Payment Method', booking?.paymentMethod ?? paymentDetails?.paymentMethod ?? 'cashfree', colors),
                    ],
                  ),
                ),

                if (booking?.paidAt != null) ...[
                  SizedBox(height: Responsive.hp(2)),
                  _buildDetailRow('Paid At', DateFormat('MMM dd, yyyy hh:mm a').format(booking!.paidAt!), colors),
                ],

                if (booking?.providerAmount != null) ...[
                  Divider(height: Responsive.hp(2), color: colors.border),
                  Text(
                    'Provider Info',
                    style: TextStyle(
                      fontSize: Responsive.fontSize(14),
                      fontWeight: FontWeight.w600,
                      color: colors.textSecondary,
                    ),
                  ),
                  SizedBox(height: Responsive.hp(1)),
                  _buildDetailRow('Commission', '${booking?.commissionPercentage ?? '-'}%', colors),
                  _buildDetailRow('Provider Earnings', '₹${booking?.providerAmount ?? '-'}', colors),
                ],
              ],
            ),
          ),

          SizedBox(height: Responsive.hp(4)),

          SizedBox(
            width: double.infinity,
            height: Responsive.hp(6),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: Responsive.fontSize(16),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(height: Responsive.hp(2)),

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'View My Bookings',
              style: TextStyle(
                fontSize: Responsive.fontSize(14),
                color: primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, AppColorSet colors, {bool isBold = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.hp(0.5)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Responsive.fontSize(13),
              color: colors.textSecondary,
            ),
          ),
          SizedBox(width: Responsive.wp(2)),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: Responsive.fontSize(13),
                color: valueColor ?? colors.textPrimary,
                fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}