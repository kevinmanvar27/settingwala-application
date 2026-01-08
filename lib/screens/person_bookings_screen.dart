import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../Service/booking_service.dart';
import '../model/postbookingsmodel.dart';

class PersonBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const PersonBookingsScreen({super.key, required this.person});

  @override
  State<PersonBookingsScreen> createState() => _PersonBookingsScreenState();
}

class _PersonBookingsScreenState extends State<PersonBookingsScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Confirmed', 'Completed', 'Cancelled'];
  
  bool _isLoading = true;
  String? _errorMessage;
  List<BookingData> _allBookings = [];
  List<BookingData> _filteredBookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  // Call GET /bookings API and filter by person id
  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await BookingService.getBookings();
      
      if (response != null && response.success) {
        final personId = widget.person['id'];
        
        // Filter bookings where other_user.id matches this person's id
        _allBookings = response.bookings.where((booking) {
          return booking.otherUser?.id == personId;
        }).toList();
        
        // Sort by date (newest first)
        _allBookings.sort((a, b) {
          final dateA = a.bookingDate ?? a.bookingDatetime ?? '';
          final dateB = b.bookingDate ?? b.bookingDatetime ?? '';
          return dateB.compareTo(dateA);
        });
        
        _applyFilter();
      } else {
        setState(() {
          _errorMessage = response?.message ?? 'Failed to load bookings';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilter() {
    setState(() {
      if (_selectedFilter == 'All') {
        _filteredBookings = List.from(_allBookings);
      } else {
        _filteredBookings = _allBookings.where((booking) {
          return booking.status.toLowerCase() == _selectedFilter.toLowerCase();
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final borderRadius = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 70.0 : 60.0;
    final emptyTextSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;
    final dateFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final infoFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final badgeFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    final amountFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : 16.0;
    final iconSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final smallIconSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;
    final filterFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;

    return BaseScreen(
      title: 'Bookings with ${person['name'] ?? 'User'}',
      showBackButton: true,
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: isTablet ? 12 : 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: EdgeInsets.only(right: isTablet ? 12 : 8),
                    child: FilterChip(
                      label: Text(
                        filter,
                        style: TextStyle(
                          fontSize: filterFontSize,
                          color: isSelected ? (isDark ? AppColors.black : AppColors.white) : colors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() => _selectedFilter = filter);
                        _applyFilter();
                      },
                      backgroundColor: colors.card,
                      selectedColor: primaryColor,
                      checkmarkColor: isDark ? AppColors.black : AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
                        side: BorderSide(color: isSelected ? primaryColor : colors.divider),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Content
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                : _errorMessage != null
                    ? _buildErrorState(colors, emptyIconSize, emptyTextSize, primaryColor)
                    : _filteredBookings.isEmpty
                        ? _buildEmptyState(colors, emptyIconSize, emptyTextSize)
                        : RefreshIndicator(
                            onRefresh: _loadBookings,
                            color: primaryColor,
                            child: ListView.builder(
                              padding: EdgeInsets.all(padding),
                              itemCount: _filteredBookings.length,
                              itemBuilder: (context, index) {
                                final booking = _filteredBookings[index];
                                return _buildBookingCard(
                                  booking,
                                  colors,
                                  isDark,
                                  primaryColor,
                                  cardPadding,
                                  borderRadius,
                                  dateFontSize,
                                  infoFontSize,
                                  badgeFontSize,
                                  amountFontSize,
                                  iconSize,
                                  smallIconSize,
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic colors, double iconSize, double textSize, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: iconSize, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(color: colors.textSecondary, fontSize: textSize),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(dynamic colors, double iconSize, double textSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: iconSize, color: colors.textTertiary),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'All'
                ? 'No bookings with ${widget.person['name'] ?? 'this user'}'
                : 'No $_selectedFilter bookings',
            style: TextStyle(color: colors.textSecondary, fontSize: textSize),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(
    BookingData booking,
    dynamic colors,
    bool isDark,
    Color primaryColor,
    double cardPadding,
    double borderRadius,
    double dateFontSize,
    double infoFontSize,
    double badgeFontSize,
    double amountFontSize,
    double iconSize,
    double smallIconSize,
  ) {
    final statusColor = _getStatusColor(booking.status);
    final formattedDate = _formatBookingDate(booking.bookingDate ?? booking.bookingDatetime);
    final formattedTime = _formatBookingTime(booking.startTime, booking.endTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: smallIconSize, color: primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: badgeFontSize,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            Divider(color: colors.divider, height: 1),
            const SizedBox(height: 12),

            // Time
            if (formattedTime.isNotEmpty)
              Row(
                children: [
                  Icon(Icons.access_time, size: smallIconSize, color: colors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                  ),
                ],
              ),

            // Duration
            if (booking.durationHours != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.timelapse, size: smallIconSize, color: colors.textTertiary),
                  const SizedBox(width: 8),
                  Text(
                    '${booking.durationHours} hour(s)',
                    style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                  ),
                ],
              ),
            ],

            // Location
            if (booking.meetingLocation != null && booking.meetingLocation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: smallIconSize, color: colors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.meetingLocation!,
                      style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Notes
            if (booking.notes != null && booking.notes!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.note, size: smallIconSize, color: colors.textTertiary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      booking.notes!,
                      style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // Amount
            if (booking.totalAmount != null) ...[
              const SizedBox(height: 12),
              Divider(color: colors.divider, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                  ),
                  Text(
                    '₹${booking.totalAmount}',
                    style: TextStyle(
                      fontSize: amountFontSize,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ],
              ),
            ],

            // Payment Status
            if (booking.paymentStatus != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Payment',
                    style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPaymentStatusColor(booking.paymentStatus!).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.paymentStatus!.toUpperCase(),
                      style: TextStyle(
                        fontSize: badgeFontSize - 1,
                        fontWeight: FontWeight.w600,
                        color: _getPaymentStatusColor(booking.paymentStatus!),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatBookingDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  String _formatBookingTime(String? startTime, String? endTime) {
    if (startTime == null || startTime.isEmpty) return '';
    String result = startTime;
    if (endTime != null && endTime.isNotEmpty) {
      result += ' - $endTime';
    }
    return result;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return AppColors.success;
      case 'confirmed':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppColors.success;
      case 'pending':
        return Colors.orange;
      case 'refunded':
        return Colors.blue;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
}
