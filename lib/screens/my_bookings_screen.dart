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
import '../Service/user_service.dart';
import '../Service/meeting_verification_service.dart';
import '../Service/dispute_service.dart';
import '../routes/app_routes.dart';
import '../model/postbookingsmodel.dart';
import '../model/getuseravailabilitymodel.dart';

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
  bool _isCreatingBooking = false;
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

  Future<void> _createBooking(Postbookingsmodel booking) async {
    setState(() {
      _isCreatingBooking = true;
    });

    final response = await BookingService.createBooking(booking);

    setState(() {
      _isCreatingBooking = false;
    });

    if (response != null && response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
        _fetchBookings();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to create booking'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelBooking(int bookingId) async {
    final response = await BookingService.cancelBooking(bookingId);

    if (response != null && response.success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
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
  bool _shouldShowDisputeButton(BookingData booking) {
    final status = booking.status.toLowerCase();
    
    // Show for completed bookings
    if (status == 'completed') return true;
    
    // Show for cancelled bookings (user might want to dispute cancellation)
    if (status == 'cancelled') return true;
    
    // Show for confirmed bookings where meeting time has passed (no-show scenario)
    if (status == 'confirmed' && booking.bookingDate != null) {
      try {
        final bookingDateTime = DateTime.parse(booking.bookingDate!);
        final durationHoursStr = booking.durationHours ?? '1';
        final durationHours = double.tryParse(durationHoursStr) ?? 1.0;
        final meetingEndTime = bookingDateTime.add(Duration(hours: durationHours.toInt()));
        
        // If meeting end time has passed, show dispute button
        if (DateTime.now().isAfter(meetingEndTime)) {
          return true;
        }
      } catch (e) {
        // If date parsing fails, don't show button
      }
    }
    
    return false;
  }

  /// Show raise dispute dialog
  void _showRaiseDisputeDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    String selectedReason = 'service_not_provided';
    final descriptionController = TextEditingController();
    bool isSubmitting = false;

    final reasons = [
      {'value': 'service_not_provided', 'label': 'Service Not Provided (No Show)'},
      {'value': 'quality_issue', 'label': 'Quality Issue'},
      {'value': 'payment_issue', 'label': 'Payment Issue'},
      {'value': 'misconduct', 'label': 'Misconduct'},
      {'value': 'other', 'label': 'Other'},
    ];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.gavel, color: Colors.red, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Raise Dispute',
                  style: TextStyle(color: colors.textPrimary, fontSize: 18),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: 20, color: primaryColor),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking #${booking.id}',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (booking.bookingDate != null)
                              Text(
                                _formatDate(booking.bookingDate!),
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (booking.totalAmount != null)
                        Text(
                          '₹${booking.totalAmount}',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Reason dropdown
                Text(
                  'Reason for Dispute *',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: colors.textSecondary.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedReason,
                      isExpanded: true,
                      dropdownColor: colors.card,
                      style: TextStyle(color: colors.textPrimary),
                      items: reasons.map((reason) {
                        return DropdownMenuItem<String>(
                          value: reason['value'],
                          child: Text(
                            reason['label']!,
                            style: TextStyle(color: colors.textPrimary, fontSize: 14),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => selectedReason = value);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Description
                Text(
                  'Description *',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Please describe your issue in detail...',
                    hintStyle: TextStyle(color: colors.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Minimum 20 characters required',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: colors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      final description = descriptionController.text.trim();
                      if (description.length < 20) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please provide at least 20 characters in description'),
                            backgroundColor: Colors.orange,
                          ),
                        );
                        return;
                      }

                      setDialogState(() => isSubmitting = true);

                      try {
                        final response = await DisputeService.raiseDispute(
                          bookingId: booking.id,
                          reason: selectedReason,
                          description: description,
                        );

                        if (response.success) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response.message.isNotEmpty
                                  ? response.message
                                  : 'Dispute raised successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // Navigate to disputes screen
                          Navigator.pushNamed(context, AppRoutes.disputes);
                        } else {
                          setDialogState(() => isSubmitting = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(response.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        setDialogState(() => isSubmitting = false);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Submit Dispute'),
            ),
          ],
        ),
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
              Icon(Icons.verified_user, size: 16, color: primaryColor),
              const SizedBox(width: 8),
              Text(
                'Meeting Verification',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      verification.hasStartPhoto ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: verification.hasStartPhoto ? Colors.green : colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Start Photo',
                        style: TextStyle(
                          fontSize: 12,
                          color: verification.hasStartPhoto ? Colors.green : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      verification.hasEndPhoto ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 16,
                      color: verification.hasEndPhoto ? Colors.green : colors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'End Photo',
                        style: TextStyle(
                          fontSize: 12,
                          color: verification.hasEndPhoto ? Colors.green : colors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Photo thumbnails row
          if (verification.startPhotoUrl != null || verification.endPhotoUrl != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (verification.startPhotoUrl != null) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPhotoFullScreen(verification.startPhotoUrl!, 'Start Photo', colors),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImage(
                              imageUrl: verification.startPhotoUrl!,
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                height: 80,
                                color: colors.background,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: Container(
                                height: 80,
                                color: colors.background,
                                child: Center(
                                  child: Icon(Icons.broken_image, color: colors.textTertiary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Start',
                            style: TextStyle(fontSize: 10, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (verification.startPhotoUrl != null && verification.endPhotoUrl != null)
                  const SizedBox(width: 8),
                if (verification.endPhotoUrl != null) ...[
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showPhotoFullScreen(verification.endPhotoUrl!, 'End Photo', colors),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedImage(
                              imageUrl: verification.endPhotoUrl!,
                              height: 80,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              placeholder: Container(
                                height: 80,
                                color: colors.background,
                                child: const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                              errorWidget: Container(
                                height: 80,
                                color: colors.background,
                                child: Center(
                                  child: Icon(Icons.broken_image, color: colors.textTertiary),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'End',
                            style: TextStyle(fontSize: 10, color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
          if (verification.startTime != null || verification.endTime != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (verification.startTime != null) ...[
                  Icon(Icons.login, size: 14, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Started: ${_formatTime(verification.startTime!)}',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
                if (verification.startTime != null && verification.endTime != null)
                  const SizedBox(width: 16),
                if (verification.endTime != null) ...[
                  Icon(Icons.logout, size: 14, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    'Ended: ${_formatTime(verification.endTime!)}',
                    style: TextStyle(fontSize: 11, color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showPhotoFullScreen(String photoUrl, String title, AppColorSet colors) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colors.textPrimary),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.7,
              ),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                child: CachedImage(
                  imageUrl: photoUrl,
                  fit: BoxFit.contain,
                  placeholder: Container(
                    height: 300,
                    width: double.infinity,
                    color: colors.background,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: Container(
                    height: 200,
                    width: double.infinity,
                    color: colors.background,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.broken_image, size: 48, color: colors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'Failed to load image',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(String timeString) {
    try {
      final dateTime = DateTime.parse(timeString);
      final hour = dateTime.hour;
      final minute = dateTime.minute.toString().padLeft(2, '0');
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:$minute $period';
    } catch (e) {
      return timeString;
    }
  }

  Widget _buildPostPhotoPrompt(BookingData booking, AppColorSet colors, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withOpacity(0.1),
            Colors.blue.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🎉 Meeting Completed!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Share your experience with photos',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showPostPhotoDialog(booking, colors, primaryColor),
              icon: const Icon(Icons.add_photo_alternate, size: 18),
              label: const Text('📸 Post Photo to Gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPostPhotoDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.photo_library, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Post to Gallery',
                style: TextStyle(color: colors.textPrimary),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Share your meeting experience with ${booking.otherUser?.name ?? "others"}!',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tips_and_updates, color: Colors.blue, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tips for great photos:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildTipItem('📍 Include location context', colors),
                  _buildTipItem('😊 Capture memorable moments', colors),
                  _buildTipItem('🤝 Show your meeting experience', colors),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Later', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/gallery');
            },
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Go to Gallery'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, AppColorSet colors) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 4),
      child: Text(
        text,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }

  void _showStartMeetingDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    File? selectedPhoto;
    bool isUploading = false;
    bool isGettingLocation = false;
    Position? currentLocation;
    String? locationError;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.play_circle_outline, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Start Meeting',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a photo to verify meeting start with ${booking.otherUser?.name ?? "the other person"}.',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: isUploading ? null : () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setDialogState(() {
                        selectedPhoto = File(image.path);
                      });
                    }
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedPhoto != null ? Colors.green : colors.textTertiary,
                        width: selectedPhoto != null ? 2 : 1,
                      ),
                    ),
                    child: selectedPhoto != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            selectedPhoto!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setDialogState(() => selectedPhoto = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48, color: colors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Photo will be used for meeting verification. Both parties should be visible.',
                          style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                if (locationError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_off, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationError!,
                            style: TextStyle(fontSize: 12, color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (currentLocation != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location captured successfully',
                            style: TextStyle(fontSize: 12, color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (isUploading || isGettingLocation) ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: (selectedPhoto == null || isUploading || isGettingLocation)
                  ? null
                  : () async {
                setDialogState(() {
                  isGettingLocation = true;
                  locationError = null;
                });

                currentLocation = await PermissionHelper.getCurrentLocation();

                if (currentLocation == null) {
                  setDialogState(() {
                    isGettingLocation = false;
                    locationError = 'Unable to get location. Please enable GPS and try again.';
                  });
                  return;
                }

                setDialogState(() {
                  isGettingLocation = false;
                  isUploading = true;
                });

                final response = await MeetingVerificationService.uploadStartPhoto(
                  booking.id,
                  selectedPhoto!,
                  latitude: currentLocation!.latitude,
                  longitude: currentLocation!.longitude,
                );

                setDialogState(() => isUploading = false);

                if (mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: response.success ? Colors.green : Colors.red,
                    ),
                  );

                  if (response.success) {
                    // Optimistically update local state to reflect photo upload with URL
                    final photoUrl = response.data?.photoUrl;
                    _updateBookingVerificationLocally(booking.id, hasStartPhoto: true, startPhotoUrl: photoUrl);
                    // Also fetch from server to sync
                    _fetchBookings();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: (isUploading || isGettingLocation)
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(isGettingLocation ? 'Getting Location...' : 'Uploading...'),
                ],
              )
                  : const Text('Start Meeting'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndMeetingDialog(BookingData booking, AppColorSet colors, Color primaryColor) {
    File? selectedPhoto;
    bool isUploading = false;
    bool isGettingLocation = false;
    Position? currentLocation;
    String? locationError;
    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.stop_circle_outlined, color: Colors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'End Meeting',
                  style: TextStyle(color: colors.textPrimary),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Take a photo to verify meeting end with ${booking.otherUser?.name ?? "the other person"}.',
                  style: TextStyle(color: colors.textSecondary),
                ),
                const SizedBox(height: 16),

                GestureDetector(
                  onTap: isUploading ? null : () async {
                    final XFile? image = await picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1920,
                      maxHeight: 1080,
                      imageQuality: 85,
                    );
                    if (image != null) {
                      setDialogState(() => selectedPhoto = File(image.path));
                    }
                  },
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selectedPhoto != null ? Colors.orange : colors.textTertiary,
                        width: selectedPhoto != null ? 2 : 1,
                      ),
                    ),
                    child: selectedPhoto != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            selectedPhoto!,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () => setDialogState(() => selectedPhoto = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(Icons.close, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo, size: 48, color: colors.textTertiary),
                        const SizedBox(height: 8),
                        Text(
                          'Tap to add photo',
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This will mark the meeting as completed. Payment will be processed after verification.',
                          style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                if (locationError != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_off, size: 16, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            locationError!,
                            style: TextStyle(fontSize: 12, color: Colors.red[700]),
                          ),
                        ),
                      ],
                    ),
                  )
                else if (currentLocation != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Location captured successfully',
                            style: TextStyle(fontSize: 12, color: Colors.green[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: (isUploading || isGettingLocation) ? null : () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: (selectedPhoto == null || isUploading || isGettingLocation)
                  ? null
                  : () async {
                setDialogState(() {
                  isGettingLocation = true;
                  locationError = null;
                });

                currentLocation = await PermissionHelper.getCurrentLocation();

                if (currentLocation == null) {
                  setDialogState(() {
                    isGettingLocation = false;
                    locationError = 'Unable to get location. Please enable GPS and try again.';
                  });
                  return;
                }

                setDialogState(() {
                  isGettingLocation = false;
                  isUploading = true;
                });

                final response = await MeetingVerificationService.uploadEndPhoto(
                  booking.id,
                  selectedPhoto!,
                  latitude: currentLocation!.latitude,
                  longitude: currentLocation!.longitude,
                );

                setDialogState(() => isUploading = false);

                if (mounted) {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(this.context).showSnackBar(
                    SnackBar(
                      content: Text(response.message),
                      backgroundColor: response.success ? Colors.green : Colors.red,
                    ),
                  );

                  if (response.success) {
                    // Optimistically update local state to reflect photo upload with URL
                    final photoUrl = response.data?.photoUrl;
                    _updateBookingVerificationLocally(booking.id, hasStartPhoto: true, hasEndPhoto: true, endPhotoUrl: photoUrl);
                    // Also fetch from server to sync
                    _fetchBookings();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: (isUploading || isGettingLocation)
                  ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(isGettingLocation ? 'Getting Location...' : 'Uploading...'),
                ],
              )
                  : const Text('End Meeting'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCancelConfirmation(int bookingId, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Cancel Booking', style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'Are you sure you want to cancel this booking?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _cancelBooking(bookingId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateBookingDialog(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    final formKey = GlobalKey<FormState>();
    final providerIdController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = _selectedDate ?? DateTime.now();
    String? startTime;
    String? endTime;
    double durationHours = 0.5;

    bool isLoadingAvailability = false;
    Getuseravailabilitymodel? availability;
    String? availabilityError;
    List<String> availableStartTimes = [];
    List<String> availableEndTimes = [];

    String formatTimeString(String time) {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }

    int timeToMinutes(String time) {
      final parts = time.split(':');
      if (parts.length < 2) return 0;
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      return hour * 60 + minute;
    }

    List<String> generateTimeSlots(Getuseravailabilitymodel avail, DateTime date, {bool forEndTime = false}) {
      final slots = <String>[];

      if (avail.availableSlots.isNotEmpty) {
        for (final slot in avail.availableSlots) {
          final startParts = slot.start.split(':');
          final endParts = slot.end.split(':');

          if (startParts.length >= 2 && endParts.length >= 2) {
            int startHour = int.tryParse(startParts[0]) ?? 9;
            int startMinute = int.tryParse(startParts[1]) ?? 0;
            final endHour = int.tryParse(endParts[0]) ?? 17;
            final endMinute = int.tryParse(endParts[1]) ?? 0;
            
            // Round start time UP to next 30-minute interval (9:00, 9:30, 10:00, etc.)
            if (startMinute > 0 && startMinute < 30) {
              startMinute = 30;
            } else if (startMinute > 30) {
              startMinute = 0;
              startHour += 1;
            }
            
            // Round end time DOWN to previous 30-minute interval
            int adjustedEndMinute = endMinute;
            int adjustedEndHour = endHour;
            if (endMinute > 0 && endMinute < 30) {
              adjustedEndMinute = 0;
            } else if (endMinute > 30) {
              adjustedEndMinute = 30;
            }
            
            final endTotalMinutes = adjustedEndHour * 60 + adjustedEndMinute;
            int hour = startHour;
            int minute = startMinute;

            // Generate slots at exact 30-minute intervals (9:00, 9:30, 10:00, 10:30, etc.)
            while (hour * 60 + minute < endTotalMinutes) {
              final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              if (!slots.contains(timeStr)) {
                slots.add(timeStr);
              }

              minute += 30;
              if (minute >= 60) {
                hour += 1;
                minute = 0;
              }
            }

            if (forEndTime) {
              final endTimeStr = '${adjustedEndHour.toString().padLeft(2, '0')}:${adjustedEndMinute.toString().padLeft(2, '0')}';
              if (!slots.contains(endTimeStr)) {
                slots.add(endTimeStr);
              }
            }
          }
        }
      }

      slots.sort((a, b) => timeToMinutes(a).compareTo(timeToMinutes(b)));
      return slots;
    }

    List<String> filterPastTimes(List<String> slots, DateTime date) {
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

      if (!isToday) return slots;

      final currentMinutes = now.hour * 60 + now.minute;
      return slots.where((t) {
        return timeToMinutes(t) > currentMinutes;
      }).toList();
    }

    Future<void> fetchAvailability(int providerId, DateTime date, Function(void Function()) setState) async {
      setState(() {
        isLoadingAvailability = true;
        availabilityError = null;
        availability = null;
        startTime = null;
        endTime = null;
        availableStartTimes = [];
        availableEndTimes = [];
        durationHours = 0.5;
      });

      try {
        final result = await UserService.getUserAvailability(
          userId: providerId,
          date: date,
        );

        if (result != null && result.success) {
          if (result.isHoliday) {
            setState(() {
              isLoadingAvailability = false;
              availabilityError = 'Provider is not available on this day (Holiday)';
            });
          } else {
            final allStartSlots = generateTimeSlots(result, date, forEndTime: false);
            final filteredStartSlots = filterPastTimes(allStartSlots, date);
            final allEndSlots = generateTimeSlots(result, date, forEndTime: true);

            setState(() {
              availability = result;
              isLoadingAvailability = false;
              availableStartTimes = filteredStartSlots;
              availableEndTimes = allEndSlots;
              if (filteredStartSlots.isEmpty) {
                availabilityError = 'No available time slots for this date';
              }
            });
          }
        } else {
          setState(() {
            isLoadingAvailability = false;
            availabilityError = 'No availability found for this provider';
          });
        }
      } catch (e) {
        setState(() {
          isLoadingAvailability = false;
          availabilityError = 'Error loading availability: $e';
        });
      }
    }

    void updateDuration() {
      if (startTime == null || endTime == null) return;
      final startMinutes = timeToMinutes(startTime!);
      final endMinutes = timeToMinutes(endTime!);
      if (endMinutes > startMinutes) {
        durationHours = (endMinutes - startMinutes) / 60.0;
      }
    }

    List<String> getValidEndTimes() {
      if (startTime == null) return [];
      final startMinutes = timeToMinutes(startTime!);
      const minDurationMinutes = 30;
      return availableEndTimes.where((t) {
        final minutes = timeToMinutes(t);
        return minutes >= startMinutes + minDurationMinutes;
      }).toList();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) {

          return Container(
            height: MediaQuery.of(context).size.height * 0.85,
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
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
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),

                Divider(color: primaryColor.withOpacity(0.2)),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Provider ID',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: providerIdController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Enter provider ID',
                              hintStyle: TextStyle(color: colors.textSecondary),
                              filled: true,
                              fillColor: colors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.person, color: primaryColor),
                              suffixIcon: IconButton(
                                icon: Icon(Icons.search, color: primaryColor),
                                onPressed: () {
                                  final providerId = int.tryParse(providerIdController.text);
                                  if (providerId != null) {
                                    fetchAvailability(providerId, selectedDate, setModalState);
                                  }
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter provider ID';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value) {
                              final providerId = int.tryParse(value);
                              if (providerId != null) {
                                fetchAvailability(providerId, selectedDate, setModalState);
                              }
                            },
                          ),
                          const SizedBox(height: 20),

                          Text(
                            'Booking Date',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: selectedDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setModalState(() {
                                  selectedDate = picked;
                                });
                                final providerId = int.tryParse(providerIdController.text);
                                if (providerId != null) {
                                  fetchAvailability(providerId, picked, setModalState);
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: primaryColor),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                    style: TextStyle(color: colors.textPrimary),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          if (isLoadingAvailability) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Loading available slots...',
                                    style: TextStyle(color: primaryColor),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else if (availabilityError != null) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline, color: Colors.red),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      availabilityError!,
                                      style: const TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ] else if (availability != null && availableStartTimes.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Available Slots:',
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  ...availability!.availableSlots.map((slot) => Padding(
                                    padding: const EdgeInsets.only(left: 26, top: 2),
                                    child: Text(
                                      slot.display.isNotEmpty ? slot.display : '${formatTimeString(slot.start)} - ${formatTimeString(slot.end)}',
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Start Time',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: colors.background,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: startTime,
                                            hint: Text(
                                              'Select',
                                              style: TextStyle(color: colors.textSecondary),
                                            ),
                                            isExpanded: true,
                                            dropdownColor: colors.card,
                                            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                            items: availableStartTimes.map((time) {
                                              return DropdownMenuItem<String>(
                                                value: time,
                                                child: Text(
                                                  formatTimeString(time),
                                                  style: TextStyle(color: colors.textPrimary),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: (value) {
                                              setModalState(() {
                                                startTime = value;
                                                if (endTime != null && startTime != null) {
                                                  final startMin = timeToMinutes(startTime!);
                                                  final endMin = timeToMinutes(endTime!);
                                                  if (endMin < startMin + 30) {
                                                    endTime = null;
                                                  }
                                                }
                                                updateDuration();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'End Time',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: colors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12),
                                        decoration: BoxDecoration(
                                          color: colors.background,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                            value: endTime,
                                            hint: Text(
                                              'Select',
                                              style: TextStyle(color: colors.textSecondary),
                                            ),
                                            isExpanded: true,
                                            dropdownColor: colors.card,
                                            icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                            items: getValidEndTimes().map((time) {
                                              return DropdownMenuItem<String>(
                                                value: time,
                                                child: Text(
                                                  formatTimeString(time),
                                                  style: TextStyle(color: colors.textPrimary),
                                                ),
                                              );
                                            }).toList(),
                                            onChanged: startTime == null ? null : (value) {
                                              setModalState(() {
                                                endTime = value;
                                                updateDuration();
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                          ] else ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.background,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.info_outline, color: colors.textSecondary),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Enter Provider ID and press search to load available time slots',
                                      style: TextStyle(color: colors.textSecondary),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          if (startTime != null && endTime != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.timer, color: primaryColor, size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Duration: ${durationHours.toStringAsFixed(1)} hours (${formatTimeString(startTime!)} - ${formatTimeString(endTime!)})',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          Text(
                            'Notes (Optional)',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: notesController,
                            maxLines: 3,
                            style: TextStyle(color: colors.textPrimary),
                            decoration: InputDecoration(
                              hintText: 'Add any special requests or notes...',
                              hintStyle: TextStyle(color: colors.textSecondary),
                              filled: true,
                              fillColor: colors.background,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: (_isCreatingBooking || startTime == null || endTime == null)
                                  ? null
                                  : () {
                                if (formKey.currentState!.validate()) {
                                  if (startTime == null || endTime == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Please select start and end time'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  final bookingDateStr = '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
                                  final booking = Postbookingsmodel(
                                    providerId: int.parse(providerIdController.text),
                                    bookingDate: bookingDateStr,
                                    startTime: startTime!,
                                    endTime: endTime!,
                                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                                  );
                                  _createBooking(booking);
                                  Navigator.pop(context);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                disabledBackgroundColor: primaryColor.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isCreatingBooking
                                  ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : Text(
                                startTime == null || endTime == null
                                    ? 'Select Time Slots'
                                    : 'Create Booking',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCalendarSection(AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final calendarPadding = isDesktop ? 20.0 : isTablet ? 16.0 : isSmallScreen ? 10.0 : 12.0;
    final headerFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final dayFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final dateFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final cellSize = isDesktop ? 48.0 : isTablet ? 44.0 : isSmallScreen ? 32.0 : 38.0;
    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final toggleIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 18.0 : 20.0;
    final headerSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 10.0;

    final bookingDates = _getBookingDates();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: colors.card,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: calendarPadding, vertical: calendarPadding / 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_month, color: primaryColor, size: iconSize),
                    SizedBox(width: headerSpacing / 2),
                    Text(
                      'Calendar View',
                      style: TextStyle(
                        fontSize: headerFontSize,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    if (_selectedDate != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedDate = null;
                          });
                        },
                        child: Text(
                          'Clear',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: dayFontSize,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: Icon(
                        _showCalendar ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: primaryColor,
                        size: toggleIconSize,
                      ),
                      onPressed: () {
                        setState(() {
                          _showCalendar = !_showCalendar;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          AnimatedCrossFade(
            firstChild: _buildMonthCalendar(
              colors, primaryColor, isDark, bookingDates,
              cellSize, dayFontSize, dateFontSize, headerFontSize, iconSize, calendarPadding,
            ),
            secondChild: const SizedBox.shrink(),
            crossFadeState: _showCalendar ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 300),
          ),

          Divider(height: 1, color: primaryColor.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildMonthCalendar(
      AppColorSet colors,
      Color primaryColor,
      bool isDark,
      Set<DateTime> bookingDates,
      double cellSize,
      double dayFontSize,
      double dateFontSize,
      double headerFontSize,
      double iconSize,
      double padding,
      ) {
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final firstDayOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    final dayNames = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: primaryColor, size: iconSize),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                  });
                },
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _focusedMonth = DateTime.now();
                  });
                },
                child: Text(
                  '${monthNames[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  style: TextStyle(
                    fontSize: headerFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: primaryColor, size: iconSize),
                onPressed: () {
                  setState(() {
                    _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                  });
                },
              ),
            ],
          ),

          SizedBox(height: padding / 2),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: dayNames.map((day) => SizedBox(
              width: cellSize,
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: dayFontSize,
                    fontWeight: FontWeight.w600,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            )).toList(),
          ),

          SizedBox(height: padding / 2),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisExtent: cellSize,
            ),
            itemCount: 42,
            itemBuilder: (context, index) {
              final dayNumber = index - firstWeekday + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayNumber);
              final isToday = _isSameDay(date, DateTime.now());
              final isSelected = _isSameDay(date, _selectedDate);
              final hasBooking = bookingDates.any((d) => _isSameDay(d, date));

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (_isSameDay(_selectedDate, date)) {
                      _selectedDate = null;
                    } else {
                      _selectedDate = date;
                    }
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor
                        : isToday
                        ? primaryColor.withOpacity(0.2)
                        : null,
                    borderRadius: BorderRadius.circular(cellSize / 4),
                    border: isToday && !isSelected
                        ? Border.all(color: primaryColor, width: 2)
                        : null,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: dateFontSize,
                          fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? (isDark ? AppColors.black : AppColors.white)
                              : colors.textPrimary,
                        ),
                      ),
                      if (hasBooking)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isDark ? AppColors.black : AppColors.white)
                                  : primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          SizedBox(height: padding),

          if (_selectedDate != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding / 2),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.filter_list, color: primaryColor, size: iconSize * 0.7),
                  const SizedBox(width: 8),
                  Text(
                    'Showing bookings for ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      fontSize: dayFontSize,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: padding),
        ],
      ),
    );
  }
}
