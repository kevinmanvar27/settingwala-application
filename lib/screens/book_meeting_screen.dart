
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
import '../model/booking_payment_details_model.dart';
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

  BookingPaymentDetails? _paymentDetails;
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

  String _formatBookingDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEEE, MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
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

        int firstSlotMinutes = startTotalMinutes;
        if (isToday) {
          int next30MinuteSlot = ((currentMinutes + 29) ~/ 30) * 30;
          if (next30MinuteSlot >= startTotalMinutes && next30MinuteSlot < endTotalMinutes) {
            firstSlotMinutes = next30MinuteSlot;
          } else if (next30MinuteSlot < startTotalMinutes) {
            firstSlotMinutes = startTotalMinutes;
          } else {
            continue;
          }
        }

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

      final bookingDateStr = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';

      final booking = Postbookingsmodel(
        providerId: providerId,
        bookingDate: bookingDateStr,
        startTime: _startTime!,
        endTime: _endTime!,
        meetingLocation: null,
        notes: null,
      );

      final response = await BookingService.createBooking(booking);

      if (!mounted) return;

      if (response != null && response.success && response.data?.booking != null) {
        _bookingData = response.data!.booking;
        await _step2_getPaymentDetails();
      } else {
        setState(() => _isCreatingBooking = false);
        _showError(response?.message ?? 'Failed to create booking');
      }
    } catch (e) {
      setState(() => _isCreatingBooking = false);
      _showError('Error creating booking: $e');
    }
  }

  Future<void> _step2_getPaymentDetails() async {
    if (_bookingData == null) {
      _showError('No booking data available');
      return;
    }

    try {
      final paymentResult = await BookingService.getBookingPaymentDetails(_bookingData!.id);

      if (!mounted) return;

      if (paymentResult == null || !paymentResult.success || paymentResult.data == null) {
        setState(() => _isCreatingBooking = false);
        _showError(paymentResult?.message ?? 'Failed to get payment details');
        return;
      }

      _paymentDetails = paymentResult.data;
      
      final paymentRequired = _paymentDetails!.paymentRequired ?? true;
      
      
      
      
      
      
      

      if (!paymentRequired) {
        
        await _processWalletOnlyPayment();
        return;
      }

      if (_paymentDetails!.cashfreeOrder != null) {
        
        await _step3_openCashfreePayment();
      } else {
        setState(() => _isCreatingBooking = false);
        _showError('Payment order not created. Please try again.');
      }

    } catch (e) {
      setState(() => _isCreatingBooking = false);
      _showError('Error getting payment details: $e');
    }
  }
  
  Future<void> _processWalletOnlyPayment() async {
    try {
      final result = await BookingService.processPayment(
        bookingId: _bookingData!.id,
        cfOrderId: null,
        cfTransactionId: null,
        walletAmountUsed: _paymentDetails!.walletUsage ?? _paymentDetails!.totalAmount ?? 0.0,
        paymentMethod: 'wallet',
      );

      if (!mounted) return;

      if (result.success) {
        _paymentResult = result;
        setState(() {
          _isCreatingBooking = false;
          _bookingSuccess = true;
        });
        _showMessage('Payment successful via wallet!', isSuccess: true);
      } else {
        setState(() => _isCreatingBooking = false);
        _showError(result.message);
      }
    } catch (e) {
      setState(() => _isCreatingBooking = false);
      _showError('Error processing wallet payment: $e');
    }
  }

  Future<void> _step3_openCashfreePayment() async {
    if (_paymentDetails == null) {
      _showError('No payment data available');
      return;
    }
    
    if (_paymentDetails!.cashfreeOrder == null) {
      _showError('Payment order not created. Please try again.');
      setState(() => _isCreatingBooking = false);
      return;
    }

    try {
      final cfEnvironment = (_paymentDetails!.cashfreeEnv ?? 'SANDBOX').toLowerCase() == 'production'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final cfSession = CFSessionBuilder()
          .setEnvironment(cfEnvironment)
          .setOrderId(_paymentDetails!.cashfreeOrder!.orderId ?? '')
          .setPaymentSessionId(_paymentDetails!.cashfreeOrder!.paymentSessionId ?? '')
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
    if (_bookingData == null || _paymentDetails == null) {
      return;
    }

    setState(() => _isCreatingBooking = true);
    _showMessage('Processing payment...', isLoading: true);

    try {
      final walletUsed = _paymentDetails!.walletUsage ?? 0.0;
      
      final paymentMethod = walletUsed > 0 ? 'wallet_cashfree' : 'cashfree';
      
      final result = await BookingService.processPayment(
        bookingId: _bookingData!.id,
        cfOrderId: _paymentDetails!.cashfreeOrder?.cfOrderId ?? '',
        cfTransactionId: orderId,
        walletAmountUsed: walletUsed,
        paymentMethod: paymentMethod,
      );

      if (!mounted) return;

      if (result.success) {
        _paymentResult = result;

        setState(() {
          _isCreatingBooking = false;
          _bookingSuccess = true;
        });

        _showMessage('Payment successful!', isSuccess: true);
      } else {
        setState(() {
          _isCreatingBooking = false;
        });
        _showError(result.message);
      }

    } catch (e) {
      setState(() {
        _isCreatingBooking = false;
      });
      _showError('Error processing payment: $e');
    }
  }

  void _onPaymentFailure(String errorMessage) {
    if (!mounted) return;

    setState(() {
      _isCreatingBooking = false;
    });
    _paymentDetails = null;

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
                  _buildDetailRow('Date', _formatBookingDate(booking!.bookingDate!), colors),
                _buildDetailRow('Time', '${booking?.startTime ?? (_startTime != null ? _formatTimeString(_startTime!) : '-')} - ${booking?.endTime ?? (_endTime != null ? _formatTimeString(_endTime!) : '-')}', colors),
                _buildDetailRow('Duration', '${booking?.actualDurationHours?.toStringAsFixed(1) ?? booking?.durationHours ?? _calculateDuration()} hours', colors),

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
