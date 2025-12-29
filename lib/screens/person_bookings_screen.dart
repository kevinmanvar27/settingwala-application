import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';

class PersonBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const PersonBookingsScreen({super.key, required this.person});

  @override
  State<PersonBookingsScreen> createState() => _PersonBookingsScreenState();
}

class _PersonBookingsScreenState extends State<PersonBookingsScreen> {
  // Sample bookings data
  final List<Map<String, dynamic>> _myBookings = [
    {
      'date': '10 Dec 2024',
      'time': '2:00 PM - 5:00 PM',
      'location': 'Coffee Shop - Central Mall',
      'status': 'Completed',
      'amount': 600,
    },
    {
      'date': '5 Dec 2024',
      'time': '6:00 PM - 9:00 PM',
      'location': 'Restaurant - City Center',
      'status': 'Completed',
      'amount': 900,
    },
    {
      'date': '28 Nov 2024',
      'time': '10:00 AM - 12:00 PM',
      'location': 'Park - Riverside',
      'status': 'Cancelled',
      'amount': 400,
    },
    {
      'date': '20 Nov 2024',
      'time': '4:00 PM - 7:00 PM',
      'location': 'Mall - Shopping Center',
      'status': 'Pending',
      'amount': 750,
    },
  ];

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Completed', 'Cancelled'];

  List<Map<String, dynamic>> get _filteredBookings {
    if (_selectedFilter == 'All') return _myBookings;
    return _myBookings.where((b) => b['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    // Theme setup
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    // Responsive setup
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
      title: 'My Bookings with ${person['name']}',
      showBackButton: true,
      body: Column(
        children: [
          // Filter Chips
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

          // Bookings List
          Expanded(
            child: _filteredBookings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.calendar_today, size: emptyIconSize, color: colors.divider),
                        SizedBox(height: isTablet ? 20 : 16),
                        Text(
                          _selectedFilter == 'All' ? 'No bookings yet' : 'No $_selectedFilter bookings',
                          style: TextStyle(fontSize: emptyTextSize, color: colors.textTertiary),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(padding),
                    itemCount: _filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = _filteredBookings[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: colors.card,
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: Border.all(color: primaryColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.1),
                              blurRadius: isTablet ? 12 : 8,
                              offset: Offset(0, isTablet ? 4 : 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, size: iconSize, color: primaryColor),
                                    SizedBox(width: isTablet ? 12 : 8),
                                    Text(
                                      booking['date'],
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: colors.textPrimary,
                                        fontSize: dateFontSize,
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isTablet ? 14 : 10,
                                    vertical: isTablet ? 6 : 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(booking['status']).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                                  ),
                                  child: Text(
                                    booking['status'],
                                    style: TextStyle(
                                      fontSize: badgeFontSize,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(booking['status']),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            Row(
                              children: [
                                Icon(Icons.access_time, size: smallIconSize, color: colors.textTertiary),
                                SizedBox(width: isTablet ? 8 : 6),
                                Text(
                                  booking['time'],
                                  style: TextStyle(color: colors.textSecondary, fontSize: infoFontSize),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 8 : 6),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: smallIconSize, color: colors.textTertiary),
                                SizedBox(width: isTablet ? 8 : 6),
                                Expanded(
                                  child: Text(
                                    booking['location'],
                                    style: TextStyle(color: colors.textSecondary, fontSize: infoFontSize),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isTablet ? 16 : 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  booking['status'] == 'Pending' ? 'Amount' : 'Amount Paid',
                                  style: TextStyle(color: colors.textTertiary, fontSize: infoFontSize),
                                ),
                                Text(
                                  '₹${booking['amount']}',
                                  style: TextStyle(
                                    fontSize: amountFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                            // Action buttons for pending bookings
                            if (booking['status'] == 'Pending') ...[
                              SizedBox(height: isTablet ? 16 : 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () => _cancelBooking(booking),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.error,
                                        side: const BorderSide(color: AppColors.error),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                                        ),
                                      ),
                                      child: Text('Cancel', style: TextStyle(fontSize: infoFontSize)),
                                    ),
                                  ),
                                  SizedBox(width: isTablet ? 12 : 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primaryColor,
                                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                                        ),
                                      ),
                                      child: Text('Pay Now', style: TextStyle(fontSize: infoFontSize)),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppColors.success;
      case 'Pending':
        return Colors.orange;
      case 'Cancelled':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }

  void _cancelBooking(Map<String, dynamic> booking) {
    final colors = context.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    final contentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final buttonBorderRadius = isDesktop ? 14.0 : isTablet ? 12.0 : 10.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        title: Text('Cancel Booking?', style: TextStyle(color: colors.textPrimary)),
        content: Text(
          'Are you sure you want to cancel this booking on ${booking['date']}?',
          style: TextStyle(color: colors.textSecondary, fontSize: contentFontSize),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                final index = _myBookings.indexOf(booking);
                if (index != -1) {
                  _myBookings[index]['status'] = 'Cancelled';
                }
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Booking cancelled', style: TextStyle(fontSize: contentFontSize)),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonBorderRadius)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }
}
