import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/booking_service.dart';
import '../Service/user_service.dart';
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
  
  // Calendar state
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDate;
  bool _showCalendar = true;

  // Loading and data state
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
    
    // Fetch bookings on init
    _fetchBookings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fetch bookings from API
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

  // Create a new booking
  Future<void> _createBooking(Postbookingsmodel booking) async {
    setState(() {
      _isCreatingBooking = true;
    });

    final response = await BookingService.createBooking(booking);

    setState(() {
      _isCreatingBooking = false;
    });

    if (response != null && response.success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Close the dialog
        _fetchBookings(); // Refresh the list
      }
    } else {
      // Show error message
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

  // Cancel a booking
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
        _fetchBookings(); // Refresh the list
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

  // Helper: Parse booking date string to DateTime
  DateTime? _parseBookingDate(String? dateString) {
    if (dateString == null) return null;
    try {
      // Format: "2023-10-15" (API format)
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  // Helper: Format date for display
  String _formatDate(String dateString) {
    final date = _parseBookingDate(dateString);
    if (date == null) return dateString;
    
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // Helper: Check if two dates are the same day
  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Get all booking dates for calendar highlighting
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

  // Get filtered bookings based on selected date
  List<BookingData> _getFilteredBookings() {
    if (_selectedDate == null) return _bookings;
    
    return _bookings.where((booking) {
      final date = _parseBookingDate(booking.bookingDate);
      return _isSameDay(date, _selectedDate);
    }).toList();
  }

  // Get status color
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
          // Calendar Section
          _buildCalendarSection(colors, primaryColor, isDark),

          // Bookings list
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

  // Error widget
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

  // Bookings list widget
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

  // Booking card widget
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
            // Header row with ID and status
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
            
            // Date and duration
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
                  '${booking.durationHours.toStringAsFixed(1)} hours',
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Amount
            if (booking.totalAmount != null) ...[
              Row(
                children: [
                  Icon(Icons.currency_rupee, size: 16, color: primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    '₹${booking.totalAmount!.toStringAsFixed(0)}',
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
            
            // Notes
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
            
            // Cancel button for pending bookings
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
          ],
        ),
      ),
    );
  }

  // Show cancel confirmation dialog
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

  // Show create booking dialog
  void _showCreateBookingDialog(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    final formKey = GlobalKey<FormState>();
    final providerIdController = TextEditingController();
    final notesController = TextEditingController();
    DateTime selectedDate = _selectedDate ?? DateTime.now();
    String? startTime;  // Using String for proper dropdown comparison
    String? endTime;    // Using String for proper dropdown comparison
    double durationHours = 0.5;
    
    // Availability state
    bool isLoadingAvailability = false;
    Getuseravailabilitymodel? availability;
    String? availabilityError;
    List<String> availableStartTimes = [];  // String list for dropdown
    List<String> availableEndTimes = [];    // String list for dropdown

    // Convert time string "HH:MM" to display format "H:MM AM/PM"
    String formatTimeString(String time) {
      final parts = time.split(':');
      if (parts.length < 2) return time;
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }

    // Convert time string "HH:MM" to total minutes for comparison
    int timeToMinutes(String time) {
      final parts = time.split(':');
      if (parts.length < 2) return 0;
      int hour = int.tryParse(parts[0]) ?? 0;
      int minute = int.tryParse(parts[1]) ?? 0;
      return hour * 60 + minute;
    }

    // Generate 30-minute interval time slots from available_slots array
    List<String> generateTimeSlots(Getuseravailabilitymodel avail, DateTime date, {bool forEndTime = false}) {
      final slots = <String>[];
      
      // Use available_slots from API (actual available times after excluding booked slots)
      if (avail.availableSlots.isNotEmpty) {
        for (final slot in avail.availableSlots) {
          final startParts = slot.start.split(':');
          final endParts = slot.end.split(':');
          
          if (startParts.length >= 2 && endParts.length >= 2) {
            int hour = int.tryParse(startParts[0]) ?? 9;
            int minute = int.tryParse(startParts[1]) ?? 0;
            final endHour = int.tryParse(endParts[0]) ?? 17;
            final endMinute = int.tryParse(endParts[1]) ?? 0;
            final endTotalMinutes = endHour * 60 + endMinute;
            
            // Generate all 30-minute slots within this available slot
            while (hour * 60 + minute < endTotalMinutes) {
              final timeStr = '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
              if (!slots.contains(timeStr)) {
                slots.add(timeStr);
              }
              
              // Add 30 minutes
              minute += 30;
              if (minute >= 60) {
                hour += 1;
                minute = 0;
              }
            }
            
            // For end time, also add the final end time
            if (forEndTime) {
              final endTimeStr = '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
              if (!slots.contains(endTimeStr)) {
                slots.add(endTimeStr);
              }
            }
          }
        }
      }
      
      // Sort slots by time
      slots.sort((a, b) => timeToMinutes(a).compareTo(timeToMinutes(b)));
      return slots;
    }
    
    // Filter slots to only show times after current time (for today)
    List<String> filterPastTimes(List<String> slots, DateTime date) {
      final now = DateTime.now();
      final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
      
      if (!isToday) return slots;
      
      final currentMinutes = now.hour * 60 + now.minute;
      return slots.where((t) {
        return timeToMinutes(t) > currentMinutes;
      }).toList();
    }

    // Fetch availability for provider and date
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
            // Generate all slots for start time (9:00, 9:30, 10:00, etc.)
            final allStartSlots = generateTimeSlots(result, date, forEndTime: false);
            // Filter out past times for today
            final filteredStartSlots = filterPastTimes(allStartSlots, date);
            // Generate end time slots (includes final end time like 17:00)
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

    // Calculate duration when times change
    void updateDuration() {
      if (startTime == null || endTime == null) return;
      final startMinutes = timeToMinutes(startTime!);
      final endMinutes = timeToMinutes(endTime!);
      if (endMinutes > startMinutes) {
        durationHours = (endMinutes - startMinutes) / 60.0;
      }
    }

    // Get end times that are at least 30 minutes after start time (minimum duration)
    List<String> getValidEndTimes() {
      if (startTime == null) return [];
      final startMinutes = timeToMinutes(startTime!);
      // Minimum 30 minutes duration required
      const minDurationMinutes = 30;
      // Filter end times to only show times at least 30 min after selected start time
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
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                
                // Header
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
                
                // Form
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Provider ID
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
                          
                          // Date picker
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
                                // Fetch availability if provider ID is entered
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
                          
                          // Availability loading/error state
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
                            // Available slots info from API
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
                            
                            // Time dropdowns
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
                                                // Reset end time if it's before or equal to start time + 30 min
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
                            // Prompt to enter provider ID
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
                          
                          // Duration display (only show when times are selected)
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
                          
                          // Notes
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
                          
                          // Submit button
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
                                        final booking = Postbookingsmodel(
                                          providerId: int.parse(providerIdController.text),
                                          bookingDate: selectedDate,
                                          durationHours: durationHours,
                                          notes: notesController.text,
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

  // Calendar Section Widget
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

  // Month Calendar Grid Widget
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