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

  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Pending', 'Completed', 'Cancelled'];



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
      title: 'My Bookings with ${person['name']}',
      showBackButton: true,
      body: Column(
        children: [
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
        ],
      ),
    );
  }
}
