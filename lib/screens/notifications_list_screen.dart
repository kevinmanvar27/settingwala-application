import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../Service/notification_service.dart';
import '../Service/provider_booking_service.dart';
import '../Service/booking_service.dart';
import '../model/GetnotificatonsModel.dart';
import '../model/booking_payment_model.dart';
import '../providers/chat_icon_provider.dart';

class NotificationsListScreen extends StatefulWidget {
  const NotificationsListScreen({super.key});

  @override
  State<NotificationsListScreen> createState() => _NotificationsListScreenState();
}

class _NotificationsListScreenState extends State<NotificationsListScreen> {
  List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _isMarkingAllRead = false;
  bool _isClearingAll = false;
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
      setState(() => _isLoadingMore = false);
    }
  }

  // Mark all notifications as read
  Future<void> _markAllAsRead() async {
    if (_isMarkingAllRead) return;
    
    setState(() => _isMarkingAllRead = true);
    
    try {
      final response = await NotificationService.markAllAsRead();
      
      if (!mounted) return;
      
      if (response != null && response.success) {
        // Update all notifications to mark them as read
        setState(() {
          for (var notification in _notifications) {
            notification.readAt = DateTime.now();
          }
          _isMarkingAllRead = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications marked as read'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        setState(() => _isMarkingAllRead = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to mark notifications as read'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isMarkingAllRead = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Clear all notifications
  Future<void> _clearAllNotifications() async {
    // Show confirmation dialog first
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final colors = context.colors;
        return AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.delete_sweep, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Clear All Notifications', style: TextStyle(color: colors.textPrimary)),
            ],
          ),
          content: Text(
            'Are you sure you want to clear all notifications? This action cannot be undone.',
            style: TextStyle(color: colors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
    
    if (confirmed != true) return;
    
    setState(() => _isClearingAll = true);
    
    try {
      final response = await NotificationService.clearAll();
      
      if (!mounted) return;
      
      if (response != null && response.success) {
        setState(() {
          _notifications.clear();
          _isClearingAll = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications cleared'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        setState(() => _isClearingAll = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to clear notifications'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isClearingAll = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  // Mark individual notification as read
  Future<void> _markNotificationAsRead(NotificationItem notification) async {
    if (notification.readAt != null) return; // Already read
    
    try {
      final response = await NotificationService.markAsRead(notification.id);
      
      if (!mounted) return;
      
      if (response != null && response.success) {
        setState(() {
          notification.readAt = DateTime.now();
        });
      }
    } catch (e) {
      // Silent fail for individual mark as read
    }
  }

  // Delete individual notification
  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      final response = await NotificationService.deleteNotification(notification.id);
      
      if (!mounted) return;
      
      if (response != null && response.success) {
        setState(() {
          _notifications.remove(notification);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                // Reload notifications to restore
                _loadNotifications();
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to delete notification'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
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
      actions: [
        // Mark All as Read button
        if (_notifications.isNotEmpty && !_isMarkingAllRead)
          IconButton(
            icon: Icon(Icons.done_all, color: primaryColor, size: iconSize),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
        if (_isMarkingAllRead)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2),
            ),
          ),
        // Clear All button
        if (_notifications.isNotEmpty && !_isClearingAll)
          IconButton(
            icon: Icon(Icons.delete_sweep, color: AppColors.error, size: iconSize),
            tooltip: 'Clear all notifications',
            onPressed: _clearAllNotifications,
          ),
        if (_isClearingAll)
          Padding(
            padding: const EdgeInsets.all(12),
            child: SizedBox(
              width: iconSize,
              height: iconSize,
              child: CircularProgressIndicator(color: AppColors.error, strokeWidth: 2),
            ),
          ),
      ],
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
            // Wrap with Dismissible for swipe actions
            return Dismissible(
              key: Key('notification_${notification.id}'),
              // Swipe left to delete
              direction: DismissDirection.horizontal,
              background: Container(
                margin: EdgeInsets.only(bottom: padding * 0.75),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Icon(Icons.done, color: Colors.white, size: iconSize),
                    const SizedBox(width: 8),
                    Text(
                      'Mark as Read',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: messageFontSize),
                    ),
                  ],
                ),
              ),
              secondaryBackground: Container(
                margin: EdgeInsets.only(bottom: padding * 0.75),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Delete',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: messageFontSize),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.delete, color: Colors.white, size: iconSize),
                  ],
                ),
              ),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  // Swipe right - Mark as read
                  await _markNotificationAsRead(notification);
                  return false; // Don't dismiss, just mark as read
                } else {
                  // Swipe left - Delete
                  return true;
                }
              },
              onDismissed: (direction) {
                if (direction == DismissDirection.endToStart) {
                  _deleteNotification(notification);
                }
              },
              child: _buildNotificationCard(
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
              ),
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
    final isRead = notification.readAt != null;
    final notificationType = notification.type.toLowerCase();
    final isBookingRequest = notificationType == 'booking_request';
    final status = notification.data?.status?.toLowerCase();
    final providerStatus = notification.data?.providerStatus?.toLowerCase();
    
    // booking_confirmed: Show Cancel + Update buttons (booking created, waiting for provider)
    // Also check for variations like booking_created, bookingconfirmed, etc.
    // Check if booking is confirmed - either notification type is 'booking_confirmed' or status is 'confirmed'
    final isBookingConfirmed = notificationType.contains('booking_confirmed') || status?.toLowerCase() == 'confirmed';
    
    // DEBUG: Print notification type and status to see what's coming
    print('🔔 NOTIFICATION DEBUG: Type="$notificationType", Status="$status", ProviderStatus="$providerStatus", BookingId=${notification.data?.bookingId}, isBookingConfirmed=$isBookingConfirmed, DataStatus="${notification.data?.status}"');
    
    // Additional debug info for the notification data
    print('📋 NOTIFICATION DATA: ID=${notification.id}, Title="${notification.title}", Message="${notification.message}", Date=${notification.data?.date}, StartTime=${notification.data?.startTime}, EndTime=${notification.data?.endTime}, PaymentStatus=${notification.data?.paymentStatus}');
    
    // booking_accepted: Show Start button (provider accepted the booking)
    final isBookingAccepted = notificationType == 'booking_accepted' || 
        providerStatus == 'accepted' || 
        status == 'accepted';
    
    // Show Accept/Reject buttons only when:
    // 1. status is 'pending' AND providerStatus is null/empty (initial request, provider hasn't acted yet)
    // 2. OR when it's a booking_request with null status and providerStatus (fresh notification)
    // Note: When providerStatus is 'accepted', 'rejected', or 'blocked' - don't show buttons
    final hasProviderActed = providerStatus == 'accepted' || 
        providerStatus == 'rejected' || 
        providerStatus == 'blocked' ||
        providerStatus == 'pending';
    final isPendingBooking = !hasProviderActed && (
        (status == 'pending' && (providerStatus == null || providerStatus.isEmpty)) ||
        (isBookingRequest && status == null && providerStatus == null)
    );
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

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),

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

              if (isBookingConfirmed) ...[
                const SizedBox(height: 12),
                // Booking Details Card
                Container(
                  padding: EdgeInsets.all(padding * 0.75),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.textTertiary.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking ID and Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking #${notification.data?.bookingId ?? 0}',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (notification.data?.status ?? 'CONFIRMED').toUpperCase(),
                              style: TextStyle(
                                fontSize: timeFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.5),
                      // Provider Name
                      if (notification.data?.providerName != null && notification.data!.providerName!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: iconSize * 0.7, color: colors.textSecondary),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                notification.data!.providerName!,
                                style: TextStyle(
                                  fontSize: messageFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: padding * 0.3),
                      ],
                      // Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: iconSize * 0.7, color: colors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            _formatDate(notification.data?.date),
                            style: TextStyle(fontSize: messageFontSize, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.3),
                      // Time (Start - End) or Duration
                      Row(
                        children: [
                          Icon(Icons.access_time, size: iconSize * 0.7, color: colors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            (notification.data?.startTime != null && notification.data?.endTime != null)
                                ? '${notification.data?.startTime} - ${notification.data?.endTime}'
                                : '${notification.data?.durationHours ?? 0} hours',
                            style: TextStyle(fontSize: messageFontSize, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.3),
                      // Meeting Location
                      if (notification.data?.meetingLocation != null && notification.data!.meetingLocation!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: iconSize * 0.7, color: colors.textSecondary),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                notification.data!.meetingLocation!,
                                style: TextStyle(fontSize: messageFontSize, color: colors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: padding * 0.3),
                      ],
                      // Amount and Payment Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.currency_rupee, size: iconSize * 0.7, color: colors.textSecondary),
                              SizedBox(width: 6),
                              Text(
                                '₹${notification.data?.amount ?? '0'}',
                                style: TextStyle(
                                  fontSize: messageFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (notification.data?.paymentStatus?.toLowerCase() == 'paid')
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (notification.data?.paymentStatus ?? 'PENDING').toUpperCase(),
                              style: TextStyle(
                                fontSize: timeFontSize,
                                fontWeight: FontWeight.w600,
                                color: (notification.data?.paymentStatus?.toLowerCase() == 'paid')
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: padding * 0.75),
                // Action Buttons Row - Cancel and Update (for booking_confirmed)
                Row(
                  children: [
                    // Cancel Booking Button - Only show for confirmed bookings
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onCancelBooking(notification),
                        icon: Icon(Icons.cancel_outlined, size: iconSize * 0.7),
                        label: Text(
                          'Cancel',
                          style: TextStyle(fontSize: messageFontSize * 0.9),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: padding * 0.5),
                    // Update Booking Button - Only show for confirmed bookings
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onUpdateBooking(notification),
                        icon: Icon(Icons.edit_outlined, size: iconSize * 0.7),
                        label: Text(
                          'Update',
                          style: TextStyle(fontSize: messageFontSize * 0.9),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: primaryColor,
                          side: BorderSide(color: primaryColor),
                          padding: EdgeInsets.symmetric(vertical: padding * 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // booking_accepted: Show Start Meeting button
              if (isBookingAccepted && !isBookingConfirmed) ...[
                const SizedBox(height: 12),
                // Booking Details Card for Accepted Booking
                Container(
                  padding: EdgeInsets.all(padding * 0.75),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Booking ID and Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking #${notification.data?.bookingId ?? 0}',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'ACCEPTED',
                              style: TextStyle(
                                fontSize: timeFontSize,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.5),
                      // Provider Name
                      if (notification.data?.providerName != null && notification.data!.providerName!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.person_outline, size: iconSize * 0.7, color: colors.textSecondary),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                notification.data!.providerName!,
                                style: TextStyle(
                                  fontSize: messageFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: padding * 0.3),
                      ],
                      // Date
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: iconSize * 0.7, color: colors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            _formatDate(notification.data?.date),
                            style: TextStyle(fontSize: messageFontSize, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.3),
                      // Time (Start - End) or Duration
                      Row(
                        children: [
                          Icon(Icons.access_time, size: iconSize * 0.7, color: colors.textSecondary),
                          SizedBox(width: 6),
                          Text(
                            (notification.data?.startTime != null && notification.data?.endTime != null)
                                ? '${notification.data?.startTime} - ${notification.data?.endTime}'
                                : '${notification.data?.durationHours ?? 0} hours',
                            style: TextStyle(fontSize: messageFontSize, color: colors.textSecondary),
                          ),
                        ],
                      ),
                      SizedBox(height: padding * 0.3),
                      // Meeting Location
                      if (notification.data?.meetingLocation != null && notification.data!.meetingLocation!.isNotEmpty) ...[
                        Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: iconSize * 0.7, color: colors.textSecondary),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                notification.data!.meetingLocation!,
                                style: TextStyle(fontSize: messageFontSize, color: colors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: padding * 0.3),
                      ],
                      // Amount and Payment Status Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.currency_rupee, size: iconSize * 0.7, color: colors.textSecondary),
                              SizedBox(width: 6),
                              Text(
                                '₹${notification.data?.amount ?? '0'}',
                                style: TextStyle(
                                  fontSize: messageFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: colors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: (notification.data?.paymentStatus?.toLowerCase() == 'paid')
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              (notification.data?.paymentStatus ?? 'PENDING').toUpperCase(),
                              style: TextStyle(
                                fontSize: timeFontSize,
                                fontWeight: FontWeight.w600,
                                color: (notification.data?.paymentStatus?.toLowerCase() == 'paid')
                                    ? AppColors.success
                                    : AppColors.warning,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: padding * 0.75),
                // Start Meeting Button - Full width, enabled only when payment is paid
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (notification.data?.paymentStatus?.toLowerCase() == 'paid')
                        ? () => _onStartMeeting(notification)
                        : null,
                    icon: Icon(Icons.play_circle_outline, size: iconSize * 0.8),
                    label: Text(
                      'Start Meeting',
                      style: TextStyle(fontSize: messageFontSize),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: colors.textTertiary.withOpacity(0.3),
                      disabledForegroundColor: colors.textTertiary,
                      padding: EdgeInsets.symmetric(vertical: padding * 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                // Show message if payment is pending
                if (notification.data?.paymentStatus?.toLowerCase() != 'paid') ...[
                  SizedBox(height: padding * 0.5),
                  Text(
                    'Complete payment to start the meeting',
                    style: TextStyle(
                      fontSize: timeFontSize,
                      color: AppColors.warning,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],

              if (isBookingRequest && isPendingBooking) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
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
              if (isBookingRequest && !isPendingBooking) ...[
                const SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: padding, vertical: padding * 0.5),
                  decoration: BoxDecoration(
                    color: notification.data?.status?.toLowerCase() == 'accepted' 
                        ? AppColors.success.withOpacity(0.1)
                        : notification.data?.status?.toLowerCase() == 'rejected'
                            ? AppColors.error.withOpacity(0.1)
                            : colors.textTertiary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        notification.data?.status?.toLowerCase() == 'accepted' 
                            ? Icons.check_circle
                            : notification.data?.status?.toLowerCase() == 'rejected'
                                ? Icons.cancel
                                : Icons.info,
                        size: iconSize * 0.8,
                        color: notification.data?.status?.toLowerCase() == 'accepted' 
                            ? AppColors.success
                            : notification.data?.status?.toLowerCase() == 'rejected'
                                ? AppColors.error
                                : colors.textTertiary,
                      ),
                      SizedBox(width: padding * 0.3),
                      Text(
                        'Status: ${notification.data?.status?.toUpperCase() ?? 'UNKNOWN'}',
                        style: TextStyle(
                          fontSize: messageFontSize,
                          fontWeight: FontWeight.w600,
                          color: notification.data?.status?.toLowerCase() == 'accepted' 
                              ? AppColors.success
                              : notification.data?.status?.toLowerCase() == 'rejected'
                                  ? AppColors.error
                                  : colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<String> _generateTimeSlots() {
    final slots = <String>[];
    for (int hour = 6; hour <= 23; hour++) {
      slots.add('${hour.toString().padLeft(2, '0')}:00');
      if (hour < 23) {
        slots.add('${hour.toString().padLeft(2, '0')}:30');
      }
    }
    return slots;
  }

  List<String> _getValidEndTimes(String? startTime, List<String> allSlots) {
    if (startTime == null) return [];
    final startIndex = allSlots.indexOf(startTime);
    if (startIndex == -1) return [];
    return allSlots.sublist(startIndex + 1);
  }

  String _formatTimeForDisplay(String time) {
    final parts = time.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$displayHour:$minute $period';
  }

  void _onUpdateBooking(NotificationItem notification) {
    // Handle update booking functionality for confirmed bookings
    print('📝 Update Booking called for ID: ${notification.data?.bookingId}, Status: ${notification.data?.status}');
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final bookingData = notification.data;
    if (bookingData == null) return;

    final notesController = TextEditingController(text: bookingData.notes);
    DateTime selectedDate = bookingData.date ?? DateTime.now();
    
    final allTimeSlots = _generateTimeSlots();
    
    String? selectedStartTime = bookingData.startTime;
    String? selectedEndTime = bookingData.endTime;
    
    if (selectedStartTime != null && !allTimeSlots.contains(selectedStartTime)) {
      selectedStartTime = null;
    }
    if (selectedEndTime != null && !allTimeSlots.contains(selectedEndTime)) {
      selectedEndTime = null;
    }

    print('📝 Showing update dialog for booking ID: ${notification.data?.bookingId}, Date: ${selectedDate}, StartTime: ${selectedStartTime}, EndTime: ${selectedEndTime}');
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.edit_calendar, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Update Booking #${bookingData.bookingId ?? 0}',
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person, color: primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Provider: ${bookingData.providerName ?? 'N/A'}',
                          style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Text('Booking Date', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate.isAfter(DateTime.now()) ? selectedDate : DateTime.now().add(const Duration(days: 1)),
                      firstDate: DateTime.now().add(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setDialogState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.textTertiary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, color: primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                          style: TextStyle(color: colors.textPrimary),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Start Time', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.textTertiary.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedStartTime,
                                isExpanded: true,
                                dropdownColor: colors.card,
                                hint: Text('Select', style: TextStyle(color: colors.textTertiary)),
                                items: allTimeSlots.map((time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(_formatTimeForDisplay(time), style: TextStyle(color: colors.textPrimary)),
                                )).toList(),
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedStartTime = value;
                                    if (selectedEndTime != null && value != null) {
                                      final validEndTimes = _getValidEndTimes(value, allTimeSlots);
                                      if (!validEndTimes.contains(selectedEndTime)) {
                                        selectedEndTime = null;
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
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('End Time', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: colors.textTertiary.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: selectedEndTime,
                                isExpanded: true,
                                dropdownColor: colors.card,
                                hint: Text('Select', style: TextStyle(color: colors.textTertiary)),
                                items: _getValidEndTimes(selectedStartTime, allTimeSlots).map((time) => DropdownMenuItem(
                                  value: time,
                                  child: Text(_formatTimeForDisplay(time), style: TextStyle(color: colors.textPrimary)),
                                )).toList(),
                                onChanged: selectedStartTime == null ? null : (value) {
                                  setDialogState(() => selectedEndTime = value);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Text('Notes (optional)', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  style: TextStyle(color: colors.textPrimary),
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Add any notes...',
                    hintStyle: TextStyle(color: colors.textTertiary),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.textTertiary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
            ),
            ElevatedButton(
              onPressed: (selectedStartTime == null || selectedEndTime == null) ? null : () {
                Navigator.pop(dialogContext);
                if (bookingData.bookingId != null) {
                  _updateBooking(
                    bookingData.bookingId!,
                    bookingDate: selectedDate,
                    startTime: selectedStartTime,
                    endTime: selectedEndTime,
                    notes: notesController.text.isNotEmpty ? notesController.text : null,
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
              ),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateBooking(
      int bookingId, {
        DateTime? bookingDate,
        String? startTime,
        String? endTime,
        String? notes,
      }) async {
    // Update booking functionality for confirmed bookings
    print('🔄 API Update Booking called for ID: $bookingId, Date: $bookingDate, Start: $startTime, End: $endTime');
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Use new updateBookingWithPayment method that handles payment differences
      final response = await BookingService.updateBookingWithPayment(
        bookingId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );

      if (mounted) Navigator.pop(context);

      // Check if payment is required (duration increased)
      if (response.requiresPayment && response.paymentRequirement != null) {
        // Show payment dialog
        _showPaymentRequirementDialog(
          bookingId: bookingId,
          paymentRequirement: response.paymentRequirement!,
          bookingDate: bookingDate,
          startTime: startTime,
          endTime: endTime,
          notes: notes,
        );
        return;
      }

      // Check if refund was processed (duration decreased)
      if (response.success && response.data?.refundInfo != null) {
        final refundInfo = response.data!.refundInfo!;
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Booking updated! ₹${refundInfo.amount.toStringAsFixed(2)} refunded to your wallet',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 4),
          ),
        );
        if (mounted) _loadNotifications();
        return;
      }

      // Normal success/failure handling
      String messageToShow;
      if (response.message.isNotEmpty) {
        messageToShow = response.message;
      } else if (response.success) {
        messageToShow = 'Booking updated successfully';
      } else {
        messageToShow = 'Failed to update booking';
      }

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(messageToShow),
          backgroundColor: response.success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );

      if (response.success && mounted) {
        _loadNotifications();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Show payment requirement dialog when booking update requires extra payment
  void _showPaymentRequirementDialog({
    required int bookingId,
    required PaymentRequirement paymentRequirement,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    String? notes,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: primaryColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Additional Payment Required',
                style: TextStyle(color: colors.textPrimary, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Extending booking time requires additional payment.',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildPaymentRow('Extra Amount Due', '₹${paymentRequirement.totalDue.toStringAsFixed(2)}', colors, isBold: true),
                  const Divider(height: 16),
                  _buildPaymentRow('Your Wallet Balance', '₹${paymentRequirement.walletBalance.toStringAsFixed(2)}', colors),
                  if (paymentRequirement.walletAmountToUse > 0) ...[
                    const SizedBox(height: 8),
                    _buildPaymentRow('From Wallet', '-₹${paymentRequirement.walletAmountToUse.toStringAsFixed(2)}', colors, color: AppColors.success),
                  ],
                  if (paymentRequirement.cashfreeAmountDue > 0) ...[
                    const SizedBox(height: 8),
                    _buildPaymentRow('Pay via Cashfree', '₹${paymentRequirement.cashfreeAmountDue.toStringAsFixed(2)}', colors, color: AppColors.warning),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (paymentRequirement.canPayFromWallet)
              Text(
                '✓ Full amount can be paid from wallet',
                style: TextStyle(color: AppColors.success, fontSize: 12),
              )
            else
              Text(
                '⚠ Insufficient wallet balance. Remaining amount will be charged via Cashfree.',
                style: TextStyle(color: AppColors.warning, fontSize: 12),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _processUpdatePayment(
                bookingId: bookingId,
                paymentRequirement: paymentRequirement,
                bookingDate: bookingDate,
                startTime: startTime,
                endTime: endTime,
                notes: notes,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
            ),
            child: Text(paymentRequirement.canPayFromWallet ? 'Pay from Wallet' : 'Proceed to Pay'),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentRow(String label, String value, dynamic colors, {bool isBold = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textSecondary,
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color ?? colors.textPrimary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Process payment for booking update
  Future<void> _processUpdatePayment({
    required int bookingId,
    required PaymentRequirement paymentRequirement,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    String? notes,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      if (paymentRequirement.canPayFromWallet) {
        // Pay fully from wallet
        final response = await BookingService.processDifferencePayment(
          bookingId: bookingId,
          amount: paymentRequirement.totalDue,
          paymentMethod: 'wallet',
        );

        if (mounted) Navigator.pop(context);

        if (response != null && response.success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Booking updated! ₹${paymentRequirement.totalDue.toStringAsFixed(2)} deducted from wallet'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 4),
            ),
          );
          if (mounted) _loadNotifications();
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(response?.message?.isNotEmpty == true ? response!.message : 'Payment failed'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Need to use Cashfree for remaining amount
        final paymentResponse = await BookingService.initiateUpdatePayment(
          bookingId,
          paymentRequirement.cashfreeAmountDue,
          preferredPaymentMethod: 'cashfree',
        );

        if (mounted) Navigator.pop(context);

        if (paymentResponse != null && paymentResponse.success) {
          // Navigate to Cashfree payment or handle payment session
          _handleCashfreePayment(
            bookingId: bookingId,
            paymentResponse: paymentResponse,
            walletAmountUsed: paymentRequirement.walletAmountToUse,
          );
        } else {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(paymentResponse?.message ?? 'Failed to initiate payment'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Handle Cashfree payment flow for booking update
  void _handleCashfreePayment({
    required int bookingId,
    required BookingPaymentModel paymentResponse,
    required double walletAmountUsed,
  }) {
    // TODO: Integrate with Cashfree SDK
    // This should open Cashfree payment gateway
    // After successful payment, call BookingService.processDifferencePayment with Cashfree details
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: const Text('Redirecting to payment gateway...'),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );

    // For now, show a placeholder message
    // In production, integrate with Cashfree SDK here
    // Example:
    // CashfreePayment.startPayment(
    //   orderId: paymentResponse.orderId,
    //   sessionId: paymentResponse.sessionId,
    //   onSuccess: (result) => _onCashfreePaymentSuccess(bookingId, result, walletAmountUsed),
    //   onFailure: (error) => _onCashfreePaymentFailure(error),
    // );
  }

  void _onDeleteBooking(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;
    if (bookingData == null) return;

    // Debug print for this method
    print('🔍 Method called with notification ID: ${notification.id}, Type: ${notification.type}');
    
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
                    'Booking ID: #${bookingData.bookingId ?? 0}',
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
              if (bookingData.bookingId != null) _deleteBooking(bookingData.bookingId!);
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

  Future<void> _deleteBooking(int bookingId) async {
    // Cancel/delete booking functionality for confirmed bookings
    print('🗑️ API Cancel Booking called for ID: $bookingId');
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Use new cancelBookingWithRefund method that returns refund info
      final response = await BookingService.cancelBookingWithRefund(bookingId, reason: 'Cancelled by user');

      if (mounted) Navigator.pop(context);

      if (response.success) {
        // Check if refund was processed
        final refundInfo = response.data?.refundInfo;
        
        if (refundInfo != null && refundInfo.amount > 0) {
          // Show refund success message
          scaffoldMessenger.showSnackBar(
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
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 4),
            ),
          );
        } else {
          // No refund (maybe booking wasn't paid yet)
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text(response.message.isNotEmpty ? response.message : 'Booking cancelled successfully'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 3),
            ),
          );
        }

        if (mounted) _loadNotifications();
      } else {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Failed to cancel booking'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onCancelBooking(NotificationItem notification) {
    // Handle cancel booking functionality for confirmed bookings
    final colors = context.colors;
    final bookingData = notification.data;
    if (bookingData == null) return;
    
    // Debug print for cancel booking
    print('❌ Cancel Booking called for ID: ${notification.data?.bookingId}, Status: ${notification.data?.status}');
    print('📅 Booking details: Date=${bookingData.date}, Start=${bookingData.startTime}, End=${bookingData.endTime}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            const SizedBox(width: 8),
            Text(
              'Cancel Booking',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel this booking?',
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
                    'Booking ID: #${bookingData.bookingId ?? 0}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(bookingData.date)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Amount: ₹${bookingData.amount ?? '0'}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            if (bookingData.paymentStatus?.toLowerCase() == 'paid') ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: AppColors.success, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amount will be refunded to your wallet',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('No, Keep It', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (bookingData.bookingId != null) _deleteBooking(bookingData.bookingId!);
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

  void _onStartMeeting(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;
    if (bookingData == null) return;

    // Debug print for this method
    print('🔍 Method called with notification ID: ${notification.id}, Type: ${notification.type}');
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.play_circle, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Start Meeting',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you ready to start this meeting?',
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
                    'Booking ID: #${bookingData.bookingId ?? 0}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(bookingData.date)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${bookingData.durationHours ?? 0} hours',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  if (bookingData.meetingLocation != null && bookingData.meetingLocation!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${bookingData.meetingLocation ?? ''}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You will need to take a photo to verify the meeting has started.',
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
            child: Text('Not Yet', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (bookingData.bookingId != null) _startMeeting(bookingData.bookingId!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Start Meeting'),
          ),
        ],
      ),
    );
  }

  Future<void> _startMeeting(int bookingId) async {
    // Navigate to my_bookings_screen where the actual meeting start functionality exists
    // Or show a message to go to My Bookings
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            const Expanded(
              child: Text('Please go to My Bookings to start the meeting with photo verification'),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Go',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to My Bookings
            Navigator.of(context).pushNamed('/my-bookings');
          },
        ),
      ),
    );
  }

  void _onAcceptBooking(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;
    if (bookingData == null) return;

    // Debug print for this method
    print('🔍 Method called with notification ID: ${notification.id}, Type: ${notification.type}');
    
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
                    'Booking ID: #${bookingData.bookingId ?? 0}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Client ID: ${bookingData.clientId ?? 0}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Date: ${_formatDate(bookingData.date)}',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Duration: ${bookingData.durationHours ?? 0} hours',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                  if (bookingData.meetingLocation != null && bookingData.meetingLocation!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Location: ${bookingData.meetingLocation ?? ''}',
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
              if (bookingData.bookingId != null) _acceptBooking(bookingData.bookingId!);
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

  Future<void> _acceptBooking(int bookingId) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ProviderBookingService.acceptBooking(bookingId);

      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: response.success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );

        if (response.success) {
          _loadNotifications();
          // Optimistically show chat icon immediately
          ChatIconProvider.maybeOf(context)?.setChatIconVisibility(true);
          // Then refresh in background to get accurate chat count
          ChatIconProvider.maybeOf(context)?.refresh();
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error accepting booking: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _onRejectBooking(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;
    if (bookingData == null) return;
    final reasonController = TextEditingController();

    // Debug print for this method
    print('🔍 Method called with notification ID: ${notification.id}, Type: ${notification.type}');
    
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
        content: SingleChildScrollView(
          child: Column(
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
                      'Booking ID: #${bookingData.bookingId ?? 0}',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Client ID: ${bookingData.clientId ?? 0}',
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
              const SizedBox(height: 16),
              Text(
                'Reason for rejection (optional)',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Enter reason for rejecting this booking...',
                  hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
                  filled: true,
                  fillColor: colors.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.inputBorder),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.inputBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: colors.textSecondary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                style: TextStyle(color: colors.textPrimary, fontSize: 14),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              final reason = reasonController.text.trim();
              if (bookingData.bookingId != null) _rejectBooking(bookingData.bookingId!, reason: reason.isNotEmpty ? reason : null);
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

  Future<void> _rejectBooking(int bookingId, {String? reason}) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ProviderBookingService.rejectBooking(bookingId, reason: reason);

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.success ? Colors.grey : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      if (response.success) {
        _loadNotifications();
      }
    }
  }

  void _onBlockUser(NotificationItem notification) {
    final colors = context.colors;
    final bookingData = notification.data;
    if (bookingData == null) return;

    // Debug print for this method
    print('🔍 Block User called - Notification ID: ${notification.id}, Type: ${notification.type}');
    print('🔍 Booking Data - bookingId: ${bookingData.bookingId}, clientId: ${bookingData.clientId}');
    
    // TextEditingController for reason input
    final reasonController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
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
            content: SingleChildScrollView(
              child: Column(
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
                  
                  // Reason input field - Required by API
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: 'Reason for blocking *',
                      hintText: 'e.g., Inappropriate behavior, No-show, etc.',
                      labelStyle: TextStyle(color: colors.textSecondary),
                      hintStyle: TextStyle(color: colors.textTertiary, fontSize: 12),
                      filled: true,
                      fillColor: colors.card,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.error),
                      ),
                      counterStyle: TextStyle(color: colors.textTertiary),
                    ),
                    style: TextStyle(color: colors.textPrimary),
                    onChanged: (_) => setDialogState(() {}),
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
            ),
            actions: [
              TextButton(
                onPressed: () {
                  reasonController.dispose();
                  Navigator.pop(dialogContext);
                },
                child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
              ),
              ElevatedButton(
                onPressed: reasonController.text.trim().isEmpty
                    ? null
                    : () {
                        final reason = reasonController.text.trim();
                        reasonController.dispose();
                        Navigator.pop(dialogContext);
                        if (bookingData.bookingId != null) {
                          _blockUser(bookingData.bookingId!, reason);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.gray400,
                  disabledForegroundColor: AppColors.white,
                ),
                child: const Text('Block'),
              ),
            ],
          );
        },
      ),
    );
  }

  // Block user API call - POST /provider/booking/{id}/block with reason
  Future<void> _blockUser(int bookingId, String reason) async {
    print('🔍 Calling blockClient API - bookingId: $bookingId, reason: $reason');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await ProviderBookingService.blockClient(bookingId, reason: reason);

    print('🔍 Block API Response - success: ${response.success}, message: ${response.message}');

    if (mounted) {
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: response.success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      if (response.success) {
        _loadNotifications();
      }
    }
  }

  void _handleNotificationTap(NotificationItem notification) {
    switch (notification.type.toLowerCase()) {
      case 'booking':
      case 'booking_request':
      case 'booking_confirmed':
      case 'booking_cancelled':
        break;
      case 'payment':
      case 'payment_received':
      case 'payment_pending':
        break;
      default:
        _showNotificationDetails(notification);
    }
  }

  void _showNotificationDetails(NotificationItem notification) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    print('📝 Showing notification details for ID: ${notification.id}, Type: ${notification.type}');
    
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
