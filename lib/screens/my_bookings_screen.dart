import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../utils/permission_helper.dart';
import '../Service/booking_service.dart';

import '../Service/meeting_verification_service.dart';
import '../Service/dispute_service.dart';
import '../routes/app_routes.dart';
import '../model/postbookingsmodel.dart';

import '../utils/api_constants.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;

  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _showCalendar = true;

  bool _isLoading = false;

  List<BookingData> _bookings = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();

    _fetchBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchBookings() async {
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await BookingService.getBookings();

    setState(() {
      _isLoading = false;
      if (response != null && response.success) {
        _bookings = response.bookings;
      } else {
        
        
        
        _errorMessage = response?.message ?? 'Failed to load bookings';
      }
    });
  }

  /// Optimistically update local booking verification state
  void _updateBookingVerificationLocally(int bookingId, {bool? hasStartPhoto, bool? hasEndPhoto, String? startPhotoUrl, String? endPhotoUrl}) {
    setState(() {
      final index = _bookings.indexWhere((b) => b.id == bookingId);
      if (index != -1) {
        final booking = _bookings[index];
        final currentVerification = booking.verification;
        
        // Create updated verification
        final updatedVerification = BookingVerification(
          hasStartPhoto: hasStartPhoto ?? currentVerification?.hasStartPhoto ?? false,
          hasEndPhoto: hasEndPhoto ?? currentVerification?.hasEndPhoto ?? false,
          startTime: currentVerification?.startTime,
          endTime: currentVerification?.endTime,
          startPhotoUrl: startPhotoUrl ?? currentVerification?.startPhotoUrl,
          endPhotoUrl: endPhotoUrl ?? currentVerification?.endPhotoUrl,
        );
        
        // Create a new BookingData with updated verification
        _bookings[index] = BookingData(
          id: booking.id,
          bookingDate: booking.bookingDate,
          bookingDatetime: booking.bookingDatetime,
          startTime: booking.startTime,
          endTime: booking.endTime,
          durationHours: booking.durationHours,
          actualDurationHours: booking.actualDurationHours,
          hourlyRate: booking.hourlyRate,
          baseAmount: booking.baseAmount,
          platformFee: booking.platformFee,
          totalAmount: booking.totalAmount,
          commissionPercentage: booking.commissionPercentage,
          commissionAmount: booking.commissionAmount,
          providerAmount: booking.providerAmount,
          status: booking.status,
          providerStatus: booking.providerStatus,
          paymentStatus: booking.paymentStatus,
          paymentMethod: booking.paymentMethod,
          walletAmountUsed: booking.walletAmountUsed,
          cfAmountPaid: booking.cfAmountPaid,
          paidAt: booking.paidAt,
          role: booking.role,
          otherUser: booking.otherUser,
          providerServiceLocation: booking.providerServiceLocation,
          meetingLocation: booking.meetingLocation,
          notes: booking.notes,
          cancelledAt: booking.cancelledAt,
          cancellationReason: booking.cancellationReason,
          verification: updatedVerification,
          rating: booking.rating,
          createdAt: booking.createdAt,
        );
      }
    });
  }



  Future<void> _cancelBooking(int bookingId) async {
    final response = await BookingService.cancelBooking(bookingId);

    if (response != null && response.success) {
      if (mounted) {
        // Check if there was a refund to wallet
        if (response.data?.refundInfo != null) {
          final refundInfo = response.data!.refundInfo!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Booking cancelled! ₹${refundInfo.amount.toStringAsFixed(2)} refunded to your wallet',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking cancelled successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
        _fetchBookings();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to cancel booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  DateTime? _parseBookingDate(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  String _formatDate(String dateString) {
    final date = _parseBookingDate(dateString);
    if (date == null) return dateString;

    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Set<DateTime> _getBookingDates() {
    final dates = <DateTime>{};
    for (final booking in _bookings) {
      final date = _parseBookingDate(booking.bookingDate);
      if (date != null) {
        dates.add(DateTime(date.year, date.month, date.day));
      }
    }
    return dates;
  }

  List<BookingData> _getFilteredBookings() {
    if (_selectedDate == null) return _bookings;

    return _bookings.where((booking) {
      final date = _parseBookingDate(booking.bookingDate);
      return _isSameDay(date, _selectedDate);
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return BaseScreen(
      title: 'My Bookings',
      showBackButton: true,
      body: Column(
        children: [
          _buildCalendarSection(colors, primaryColor, isDark),

          Expanded(
            child: SlideTransition(
              position: _slideAnimation,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null
                  ? _buildErrorWidget(colors, primaryColor)
                  : _buildBookingsList(colors, primaryColor, isDark),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateBookingDialog(context, colors, primaryColor, isDark),
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildErrorWidget(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: colors.textSecondary),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(color: colors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _fetchBookings,
            style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
            child: const Text('Retry', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingsList(AppColorSet colors, Color primaryColor, bool isDark) {
    final filteredBookings = _getFilteredBookings();

    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: colors.textSecondary),
            const SizedBox(height: 16),
            Text(
              _selectedDate != null
                  ? 'No bookings for this date'
                  : 'No bookings yet',
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchBookings,
      color: primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredBookings.length,
        itemBuilder: (context, index) {
          final booking = filteredBookings[index];
          return _buildBookingCard(booking, colors, primaryColor, isDark);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingData booking, AppColorSet colors, Color primaryColor, bool isDark) {
    final statusColor = _getStatusColor(booking.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking #${booking.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Date and Duration
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  _formatDate(booking.bookingDate ?? ''),
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Text(
                  '${booking.actualDurationHours?.toStringAsFixed(1) ?? booking.durationHours ?? '0'} hours',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
            
            // Start Time and End Time
            if (booking.startTime != null || booking.endTime != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.schedule, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Time: ${_formatTime(booking.startTime)} - ${_formatTime(booking.endTime)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),

            if (booking.totalAmount != null) ...[
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '₹${booking.totalAmount}',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (booking.paymentStatus != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: booking.paymentStatus == 'paid'
                            ? Colors.green.withOpacity(0.2)
                            : Colors.orange.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.paymentStatus!.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          color: booking.paymentStatus == 'paid'
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: 16, color: primaryColor),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: TextStyle(color: colors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            if (booking.status.toLowerCase() == 'pending' ||
                booking.status.toLowerCase() == 'confirmed') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _showCancelConfirmation(booking.id, colors, primaryColor),
                  child: Text(
                    'Cancel Booking',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],


            if (booking.verification != null) ...[
              const SizedBox(height: 8),
              _buildVerificationStatus(booking.verification!, colors, primaryColor),
            ],

            if (booking.status.toLowerCase() == 'confirmed' &&
                booking.paymentStatus?.toLowerCase() == 'paid' &&
                (booking.verification == null || !booking.verification!.hasStartPhoto)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showStartMeetingDialog(booking, colors, primaryColor),
                  icon: const Icon(Icons.play_circle_outline, size: 20),
                  label: const Text('Start Meeting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            if (booking.verification != null &&
                booking.verification!.hasStartPhoto &&
                !booking.verification!.hasEndPhoto) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showEndMeetingDialog(booking, colors, primaryColor),
                  icon: const Icon(Icons.stop_circle_outlined, size: 20),
                  label: const Text('End Meeting'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],

            if (booking.verification != null &&
                booking.verification!.hasStartPhoto &&
                booking.verification!.hasEndPhoto) ...[
              const SizedBox(height: 12),
              _buildPostPhotoPrompt(booking, colors, primaryColor),
            ],

            // Raise Dispute Button - Show for completed bookings or confirmed bookings where meeting time has passed
            if (_shouldShowDisputeButton(booking)) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showRaiseDisputeDialog(booking, colors, primaryColor),
                  icon: const Icon(Icons.gavel_outlined, size: 18),
                  label: const Text('Raise Dispute'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Check if dispute button should be shown
  /// Only show after meeting time is complete (both photos uploaded)
  bool _shouldShowDisputeButton(BookingData booking) {
    final status = booking.status.toLowerCase();
    
    // Show for completed bookings
    if (status == 'completed') return true;
    
    // Show for cancelled bookings (user might want to dispute cancellation)
    if (status == 'cancelled') return true;
    
    // For confirmed bookings, only show if meeting has ended (both photos uploaded)
    if (status == 'confirmed') {
      // Check if both verification photos are uploaded (meeting completed)
      if (booking.verification != null &&
          booking.verification!.hasStartPhoto &&
          booking.verification!.hasEndPhoto) {
        return true;
      }
      
      // Also check if meeting end time has passed (fallback for no-show scenario)
      if (booking.bookingDate != null && booking.endTime != null) {
        try {
          // Parse booking date and end time
          final dateStr = booking.bookingDate!;
          final endTimeStr = booking.endTime!;
          
          DateTime meetingEndDateTime;
          if (booking.bookingDatetime != null) {
            // Use booking_datetime and add duration
            final startDateTime = DateTime.parse(booking.bookingDatetime!);
            final durationHoursStr = booking.durationHours ?? '1';
            final durationHours = double.tryParse(durationHoursStr) ?? 1.0;
            meetingEndDateTime = startDateTime.add(Duration(minutes: (durationHours * 60).toInt()));
          } else {
            // Parse date (format: YYYY-MM-DD)
            final dateParts = dateStr.split('-');
            if (dateParts.length != 3) return false;
            
            // Parse end time (format: HH:MM or HH:MM:SS)
            final timeParts = endTimeStr.split(':');
            if (timeParts.length < 2) return false;
            
            meetingEndDateTime = DateTime(
              int.parse(dateParts[0]),
              int.parse(dateParts[1]),
              int.parse(dateParts[2]),
              int.parse(timeParts[0]),
              int.parse(timeParts[1]),
            );
          }
          
          // If meeting end time has passed, show dispute button
          if (DateTime.now().isAfter(meetingEndDateTime)) {
            return true;
          }
        } catch (e) {
          // If date parsing fails, don't show button
        }
      }
    }
    
    return false;
  }



  Widget _buildCalendarSection(AppColorSet colors, Color primaryColor, bool isDark) {
    final bookingDates = _getBookingDates();
    
    // Calculate dynamic height based on calendar rows
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final totalDays = lastDayOfMonth.day + firstWeekday;
    final numberOfRows = (totalDays / 7).ceil();
    final calendarGridHeight = numberOfRows * 40.0; // 40 per row
    final calendarBodyHeight = calendarGridHeight + 80; // Add space for month nav and weekday headers
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showCalendar ? (60 + calendarBodyHeight) : 60,
      child: Column(
        children: [
          // Calendar toggle header
          InkWell(
            onTap: () => setState(() => _showCalendar = !_showCalendar),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.card,
                border: Border(
                  bottom: BorderSide(color: colors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_month, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDate != null
                            ? _formatDate(_selectedDate!.toIso8601String())
                            : 'All Bookings',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_selectedDate != null) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _selectedDate = null),
                          child: Icon(Icons.close, size: 18, color: colors.textSecondary),
                        ),
                      ],
                    ],
                  ),
                  Icon(
                    _showCalendar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          
          // Calendar body
          if (_showCalendar)
            Expanded(
              child: Container(
                color: colors.card,
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: [
                    // Month navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.chevron_left, color: colors.textPrimary),
                          onPressed: () {
                            setState(() {
                              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                            });
                          },
                        ),
                        Text(
                          '${_getMonthName(_focusedMonth.month)} ${_focusedMonth.year}',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.chevron_right, color: colors.textPrimary),
                          onPressed: () {
                            setState(() {
                              _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                            });
                          },
                        ),
                      ],
                    ),
                    
                    // Weekday headers
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                          .map((day) => SizedBox(
                                width: 36,
                                child: Text(
                                  day,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: colors.textSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 8),
                    
                    // Calendar grid
                    Expanded(
                      child: _buildCalendarGrid(colors, primaryColor, bookingDates),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(AppColorSet colors, Color primaryColor, Set<DateTime> bookingDates) {
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final lastDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    
    final days = <Widget>[];
    
    // Empty cells for days before the first day of month
    for (int i = 0; i < firstWeekday; i++) {
      days.add(const SizedBox(width: 36, height: 36));
    }
    
    // Days of the month
    for (int day = 1; day <= lastDayOfMonth.day; day++) {
      final date = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      final hasBooking = bookingDates.any((d) => _isSameDay(d, date));
      final isSelected = _isSameDay(_selectedDate, date);
      final isToday = _isSameDay(DateTime.now(), date);
      
      days.add(
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedDate = isSelected ? null : date;
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isSelected
                  ? primaryColor
                  : hasBooking
                      ? primaryColor.withOpacity(0.2)
                      : null,
              borderRadius: BorderRadius.circular(18),
              border: isToday && !isSelected
                  ? Border.all(color: primaryColor, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '$day',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : isToday
                          ? primaryColor
                          : colors.textPrimary,
                  fontWeight: hasBooking || isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: days,
    );
  }

  String _getMonthName(int month) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return months[month - 1];
  }

  void _showCreateBookingDialog(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Create New Booking',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: colors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'To create a new booking, please browse available providers and select a time slot from their profile.',
                style: TextStyle(color: colors.textSecondary),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.home);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Browse Providers',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancelConfirmation(int bookingId, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancel Booking',
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep it', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationStatus(BookingVerification verification, AppColorSet colors, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user, size: 18, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Meeting Verification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildVerificationItem(
                'Start Photo',
                verification.hasStartPhoto,
                colors,
              ),
              const SizedBox(width: 16),
              _buildVerificationItem(
                'End Photo',
                verification.hasEndPhoto,
                colors,
              ),
            ],
          ),
          // Show verification photos if available
          if (verification.hasStartPhoto || verification.hasEndPhoto) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (verification.hasStartPhoto && verification.startPhotoUrl != null)
                  Expanded(
                    child: _buildVerificationPhoto(
                      'Start',
                      verification.startPhotoUrl!,
                      Colors.green,
                      colors,
                    ),
                  ),
                if (verification.hasStartPhoto && verification.hasEndPhoto)
                  const SizedBox(width: 12),
                if (verification.hasEndPhoto && verification.endPhotoUrl != null)
                  Expanded(
                    child: _buildVerificationPhoto(
                      'End',
                      verification.endPhotoUrl!,
                      Colors.orange,
                      colors,
                    ),
                  ),
              ],
            ),
          ],
          if (verification.startTime != null || verification.endTime != null) ...[
            const SizedBox(height: 8),
            Text(
              verification.startTime != null && verification.endTime != null
                  ? 'Duration: ${_calculateDuration(verification.startTime!, verification.endTime!)}'
                  : verification.startTime != null
                      ? 'Started at: ${_formatTime(verification.startTime!)}'
                      : '',
              style: TextStyle(
                fontSize: 12,
                color: colors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVerificationItem(String label, bool isComplete, AppColorSet colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 16,
          color: isComplete ? Colors.green : colors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isComplete ? Colors.green : colors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationPhoto(String label, String photoUrl, Color labelColor, AppColorSet colors) {
    // Build full URL if it's a relative path
    String fullUrl = photoUrl;
    if (!photoUrl.startsWith('http')) {
      fullUrl = '${ApiConstants.storageUrl}/$photoUrl';
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label Photo',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => _showFullScreenPhoto(fullUrl, label),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 80,
              width: double.infinity,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CachedImage(
                imageUrl: fullUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  color: colors.border,
                  child: Center(
                    child: Icon(Icons.photo, color: colors.textSecondary, size: 24),
                  ),
                ),
                errorWidget: Container(
                  color: colors.border,
                  child: Center(
                    child: Icon(Icons.broken_image, color: colors.textSecondary, size: 24),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showFullScreenPhoto(String photoUrl, String title) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$title Photo',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: CachedImage(
                imageUrl: photoUrl,
                fit: BoxFit.contain,
                placeholder: Container(
                  height: 300,
                  color: Colors.grey[800],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: Container(
                  height: 300,
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateDuration(String startTime, String endTime) {
    try {
      final start = DateTime.parse(startTime);
      final end = DateTime.parse(endTime);
      final duration = end.difference(start);
      final hours = duration.inHours;
      final minutes = duration.inMinutes % 60;
      if (hours > 0) {
        return '$hours hr ${minutes > 0 ? '$minutes min' : ''}';
      }
      return '$minutes min';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Format time string for display (handles both HH:mm and HH:mm:ss formats)
  String _formatTime(String? timeString) {
    if (timeString == null || timeString.isEmpty) {
      return 'N/A';
    }
    
    // If time has seconds (HH:mm:ss), remove them
    if (timeString.length == 8 && timeString.contains(':')) {
      timeString = timeString.substring(0, 5); // "09:00:00" -> "09:00"
    }
    
    // Convert 24-hour format to 12-hour format with AM/PM
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = parts[1];
        
        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        
        return '$hour12:$minute $period';
      }
    } catch (e) {
      // If parsing fails, return the original string
    }
    
    return timeString;
  }

  void _showStartMeetingDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.camera_alt, color: primaryColor),
            const SizedBox(width: 8),
            Text('Start Meeting', style: TextStyle(color: colors.textPrimary)),
          ],
        ),
        content: Text(
          'Take a photo to verify the start of your meeting. This helps ensure a safe and verified experience.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _captureVerificationPhoto(booking, isStart: true, colors: colors, primaryColor: primaryColor);
            },
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showEndMeetingDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.camera_alt, color: Colors.orange),
            const SizedBox(width: 8),
            Text('End Meeting', style: TextStyle(color: colors.textPrimary)),
          ],
        ),
        content: Text(
          'Take a photo to verify the end of your meeting. This will complete the verification process.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _captureVerificationPhoto(booking, isStart: false, colors: colors, primaryColor: primaryColor);
            },
            icon: const Icon(Icons.camera_alt, size: 18),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _captureVerificationPhoto(BookingData booking, {required bool isStart, required AppColorSet colors, required Color primaryColor}) async {
    // Request camera permission
    final hasPermission = await PermissionHelper.requestCameraPermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required to take verification photo'),
            backgroundColor: Colors.red,
          ),
        );
        // Show settings dialog
        await PermissionHelper.showPermissionDeniedDialog(context, permissionName: 'Camera');
      }
      return;
    }

    // Request location permission first (before camera)
    Position? position;
    try {
      final hasLocationPermission = await PermissionHelper.requestLocationPermission();
      if (hasLocationPermission) {
        position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 10),
        );
        print('📍 Location obtained: ${position.latitude}, ${position.longitude}');
      } else {
        print('📍 Location permission denied, continuing without location');
      }
    } catch (e) {
      print('📍 Location error: $e');
      // Location is optional, continue without it
    }

    // Open camera
    try {
      final picker = ImagePicker();
      print('📸 Opening camera...');
      
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 80,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (photo == null) {
        print('📸 Camera cancelled by user');
        return;
      }

      print('📸 Photo captured: ${photo.path}');

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: colors.card,
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    isStart ? 'Uploading start photo...' : 'Uploading end photo...',
                    style: TextStyle(color: colors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Upload photo with location
      final photoFile = File(photo.path);
      
      // Verify file exists
      if (!await photoFile.exists()) {
        if (mounted) Navigator.pop(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo file not found. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      print('📤 Uploading photo to API...');
      print('   Booking ID: ${booking.id}');
      print('   Latitude: ${position?.latitude}');
      print('   Longitude: ${position?.longitude}');

      final response = isStart
          ? await MeetingVerificationService.uploadStartPhoto(
              booking.id,
              photoFile,
              latitude: position?.latitude,
              longitude: position?.longitude,
            )
          : await MeetingVerificationService.uploadEndPhoto(
              booking.id,
              photoFile,
              latitude: position?.latitude,
              longitude: position?.longitude,
            );

      if (mounted) Navigator.pop(context); // Close loading dialog

      print('📤 API Response: success=${response.success}, message=${response.message}');

      if (response.success) {
        // Update local state optimistically
        if (isStart) {
          _updateBookingVerificationLocally(
            booking.id,
            hasStartPhoto: true,
            startPhotoUrl: response.data?.photoUrl,
          );
        } else {
          _updateBookingVerificationLocally(
            booking.id,
            hasEndPhoto: true,
            endPhotoUrl: response.data?.photoUrl,
          );
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isStart ? 'Meeting started successfully!' : 'Meeting ended successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
        
        // Refresh bookings to get updated data from server
        _fetchBookings();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Error in _captureVerificationPhoto: $e');
      if (mounted) {
        // Try to close loading dialog if open
        try {
          Navigator.pop(context);
        } catch (_) {}
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Widget _buildPostPhotoPrompt(BookingData booking, AppColorSet colors, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meeting Completed!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Both verification photos have been submitted.',
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showRaiseDisputeDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    final reasonController = TextEditingController();
    String? selectedCategory;
    
    final categories = [
      'No Show',
      'Service Quality',
      'Payment Issue',
      'Safety Concern',
      'Time Dispute',
      'Other',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Raise a Dispute',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: colors.textSecondary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking #${booking.id}',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Category',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    hintText: 'Select a category',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  ),
                  items: categories.map((cat) => DropdownMenuItem(
                    value: cat,
                    child: Text(cat),
                  )).toList(),
                  onChanged: (value) {
                    setModalState(() => selectedCategory = value);
                  },
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Description',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reasonController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Please describe your issue in detail...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: selectedCategory != null && reasonController.text.trim().isNotEmpty
                        ? () async {
                            Navigator.pop(context);
                            await _submitDispute(
                              booking.id,
                              selectedCategory!,
                              reasonController.text.trim(),
                              colors,
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor: Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Submit Dispute',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDispute(int bookingId, String category, String reason, AppColorSet colors) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Submitting dispute...', style: TextStyle(color: colors.textPrimary)),
          ],
        ),
      ),
    );

    try {
      final response = await DisputeService.raiseDispute(
        bookingId: bookingId,
        reason: category,
        description: reason,
      );

      if (mounted) Navigator.pop(context); // Close loading

      if (response.success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Dispute submitted successfully. Our team will review it shortly.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Failed to submit dispute'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
