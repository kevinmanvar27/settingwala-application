import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/notification_service.dart';
import '../model/GetnotificatonsModel.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  int _currentPage = 1;
  int _lastPage = 1;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadNotifications();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreNotifications();
    }
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _currentPage = 1;
    });

    try {
      final result = await NotificationService.getNotifications(page: 1);

      if (result != null && result.success) {
        setState(() {
          _notifications = result.data.notifications;
          _lastPage = result.data.pagination.lastPage;
          _isLoading = false;
        });
      } else {
        setState(() {
          _notifications = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _notifications = [];
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreNotifications() async {
    if (_isLoadingMore || _currentPage >= _lastPage) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final result = await NotificationService.getNotifications(page: nextPage);

      if (result != null && result.success) {
        setState(() {
          _notifications.addAll(result.data.notifications);
          _currentPage = nextPage;
          _isLoadingMore = false;
        });
      } else {
        setState(() => _isLoadingMore = false);
      }
    } catch (e) {
      print('Error loading more notifications: $e');
      setState(() => _isLoadingMore = false);
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hours ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'booking_request':
      case 'booking_confirmed':
      case 'booking_cancelled':
        return Icons.calendar_today;
      case 'payment':
      case 'payment_received':
      case 'payment_pending':
        return Icons.payment;
      case 'message':
      case 'chat':
        return Icons.message;
      case 'match':
      case 'new_match':
        return Icons.favorite;
      case 'reminder':
      case 'meeting_reminder':
        return Icons.alarm;
      case 'subscription':
        return Icons.card_membership;
      case 'profile':
      case 'profile_view':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type, Color primaryColor) {
    switch (type.toLowerCase()) {
      case 'booking':
      case 'booking_request':
      case 'booking_confirmed':
        return Colors.blue;
      case 'booking_cancelled':
        return Colors.red;
      case 'payment':
      case 'payment_received':
        return Colors.green;
      case 'payment_pending':
        return Colors.orange;
      case 'message':
      case 'chat':
        return Colors.purple;
      case 'match':
      case 'new_match':
        return Colors.pink;
      case 'reminder':
      case 'meeting_reminder':
        return Colors.amber;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final messageFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final timeFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final avatarRadius = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;

    return BaseScreen(
      title: 'Notifications',
      showBackButton: true,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _notifications.isEmpty
              ? _buildEmptyState(colors, primaryColor, titleFontSize)
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: primaryColor,
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(padding),
                    itemCount: _notifications.length + (_isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _notifications.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: primaryColor),
                          ),
                        );
                      }

                      final notification = _notifications[index];
                      return _buildNotificationCard(
                        notification,
                        colors,
                        primaryColor,
                        isDark,
                        titleFontSize,
                        messageFontSize,
                        timeFontSize,
                        iconSize,
                        avatarRadius,
                        padding,
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(AppColorSet colors, Color primaryColor, double fontSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications yet',
            style: TextStyle(
              fontSize: fontSize + 2,
              fontWeight: FontWeight.w600,
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll see your notifications here',
            style: TextStyle(
              fontSize: fontSize - 2,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification,
    AppColorSet colors,
    Color primaryColor,
    bool isDark,
    double titleFontSize,
    double messageFontSize,
    double timeFontSize,
    double iconSize,
    double avatarRadius,
    double padding,
  ) {
    final notificationColor = _getNotificationColor(notification.type, primaryColor);
    final isRead = notification.readAt != DateTime.now(); // Check if read
    final isBookingConfirmed = notification.type.toLowerCase() == 'booking_confirmed';
    final isBookingRequest = notification.type.toLowerCase() == 'booking_request';

    return Card(
      margin: EdgeInsets.only(bottom: padding * 0.75),
      elevation: isRead ? 1 : 3,
      color: colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isRead
            ? BorderSide.none
            : BorderSide(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: InkWell(
        onTap: () {
          // Handle notification tap - navigate to relevant screen
          _handleNotificationTap(notification);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  CircleAvatar(
                    radius: avatarRadius,
                    backgroundColor: notificationColor.withOpacity(0.15),
                    child: Icon(
                      _getNotificationIcon(notification.type),
                      color: notificationColor,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: padding),
                  
                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Message
                        Text(
                          notification.message,
                          style: TextStyle(
                            fontSize: messageFontSize,
                            color: colors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        
                        // Time and Type
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: timeFontSize + 2,
                              color: colors.textTertiary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: timeFontSize,
                                color: colors.textTertiary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: notificationColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                notification.type.replaceAll('_', ' ').toUpperCase(),
                                style: TextStyle(
                                  fontSize: timeFontSize - 1,
                                  color: notificationColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              // Action buttons for booking_confirmed
              if (isBookingConfirmed) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Update Booking Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onUpdateBooking(notification),
                        icon: Icon(Icons.edit, size: iconSize * 0.8),
                        label: Text(
                          'Update Booking',
                          style: TextStyle(fontSize: messageFontSize),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: padding * 0.75),
                    // Delete Booking Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onDeleteBooking(notification),
                        icon: Icon(Icons.delete_outline, size: iconSize * 0.8),
                        label: Text(
                          'Delete Booking',
                          style: TextStyle(fontSize: messageFontSize),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Action buttons for booking_request
              if (isBookingRequest) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    // Accept Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _onAcceptBooking(notification),
                        icon: Icon(Icons.check, size: iconSize * 0.8),
                        label: Text(
                          'Accept',
                          style: TextStyle(fontSize: messageFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.white,
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: padding * 0.5),
                    // Reject Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onRejectBooking(notification),
                        icon: Icon(Icons.close, size: iconSize * 0.8),
                        label: Text(
                          'Reject',
                          style: TextStyle(fontSize: messageFontSize),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: colors.textSecondary,
                          side: BorderSide(color: colors.textTertiary),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: padding * 0.5),
                    // Block Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onBlockUser(notification),
                        icon: Icon(Icons.block, size: iconSize * 0.8),
                        label: Text(
                          'Block',
                          style: TextStyle(fontSize: messageFontSize),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Handle Update Booking button tap
  void _onUpdateBooking(NotificationItem notification) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final bookingData = notification.data;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.edit_calendar, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'Update Booking',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Booking ID: #${bookingData.bookingId}',
              style: TextStyle(
                color: colors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Provider: ${bookingData.providerName ?? 'N/A'}',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${_formatDate(bookingData.date)}',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${bookingData.meetingLocation}',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Update functionality coming soon!',
              style: TextStyle(
                color: colors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Navigate to update booking screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Update booking feature coming soon'),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // Handle Delete Booking button tap
  void _onDeleteBooking(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.delete_forever, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Delete Booking',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete this booking?',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID: #${bookingData.bookingId}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provider: ${bookingData.providerName ?? 'N/A'}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(bookingData.date)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action cannot be undone.',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Call delete booking API
              _deleteBooking(bookingData.bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // Delete booking API call
  Future<void> _deleteBooking(int bookingId) async {
    // TODO: Implement actual API call to delete booking
    // Example: await BookingService.deleteBooking(bookingId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking #$bookingId deleted successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Refresh notifications
    _loadNotifications();
  }

  // Handle Accept Booking button tap
  void _onAcceptBooking(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Accept Booking',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to accept this booking request?',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID: #${bookingData.bookingId}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client ID: ${bookingData.clientId}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(bookingData.date)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${bookingData.durationHours} hours',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  if (bookingData.meetingLocation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${bookingData.meetingLocation}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _acceptBooking(bookingData.bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  // Accept booking API call
  Future<void> _acceptBooking(int bookingId) async {
    // TODO: Implement actual API call to accept booking
    // Example: await BookingService.acceptBooking(bookingId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking #$bookingId accepted successfully'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Refresh notifications
    _loadNotifications();
  }

  // Handle Reject Booking button tap
  void _onRejectBooking(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: colors.textSecondary),
            const SizedBox(width: 8),
            Text(
              'Reject Booking',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject this booking request?',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.textTertiary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Booking ID: #${bookingData.bookingId}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client ID: ${bookingData.clientId}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(bookingData.date)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'The client will be notified of your decision.',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _rejectBooking(bookingData.bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.textSecondary,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  // Reject booking API call
  Future<void> _rejectBooking(int bookingId) async {
    // TODO: Implement actual API call to reject booking
    // Example: await BookingService.rejectBooking(bookingId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Booking #$bookingId rejected'),
        backgroundColor: Colors.grey,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Refresh notifications
    _loadNotifications();
  }

  // Handle Block User button tap
  void _onBlockUser(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Block User',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to block this user?',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Client ID: ${bookingData.clientId}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will:',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '• Reject this booking request',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '• Prevent future booking requests',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                  Text(
                    '• Hide your profile from this user',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'This action can be undone from Settings.',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _blockUser(bookingData.clientId, bookingData.bookingId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  // Block user API call
  Future<void> _blockUser(int clientId, int bookingId) async {
    // TODO: Implement actual API call to block user
    // Example: await UserService.blockUser(clientId);
    // Also reject the booking: await BookingService.rejectBooking(bookingId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('User blocked and booking rejected'),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    
    // Refresh notifications
    _loadNotifications();
  }

  void _handleNotificationTap(NotificationItem notification) {
    // Navigate based on notification type
    switch (notification.type.toLowerCase()) {
      case 'booking':
      case 'booking_request':
      case 'booking_confirmed':
      case 'booking_cancelled':
        // Navigate to booking details
        // Navigator.push(context, MaterialPageRoute(builder: (_) => BookingDetailsScreen(id: notification.data.bookingId)));
        break;
      case 'payment':
      case 'payment_received':
      case 'payment_pending':
        // Navigate to payment screen
        break;
      default:
        // Show notification details in dialog
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationItem notification) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          notification.title,
          style: TextStyle(color: colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notification.message,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Text(
              'Received: ${_formatDate(notification.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: colors.textTertiary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: primaryColor)),
          ),
        ],
      ),
    );
  }
}
