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

import '../providers/notification_provider.dart';
// Cashfree SDK imports
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';

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
    
    // Auto-mark all notifications as read when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _autoMarkAllAsRead();
    });
  }
  
  /// Automatically mark all notifications as read when screen opens
  /// This updates both the backend and the app bar badge
  Future<void> _autoMarkAllAsRead() async {
    try {
      final response = await NotificationService.markAllAsRead();
      if (response != null && response.success && mounted) {
        // Update local state
        setState(() {
          for (var notification in _notifications) {
            notification.readAt = DateTime.now();
          }
        });
        // Update app bar badge via provider
        context.notificationNotifier.clearCount();
      }
    } catch (e) {
      // Silent fail - not critical if auto-mark fails
      debugPrint('Auto mark all as read failed: $e');
    }
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
        
        // Update app bar badge via provider
        context.notificationNotifier.clearCount();
        
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
        
        // Update app bar badge via provider
        context.notificationNotifier.clearCount();
        
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
        // Update app bar badge via provider
        context.notificationNotifier.decrementCount();
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
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
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
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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
                // Action Buttons Row - Cancel and Update
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _onCancelBooking(notification),
                        icon: Icon(Icons.cancel_outlined, size: iconSize * 0.8),
                        label: Text(
                          'Cancel',
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
                    SizedBox(width: padding * 0.5),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _onUpdateBooking(notification),
                        icon: Icon(Icons.edit_calendar, size: iconSize * 0.8),
                        label: Text(
                          'Update',
                          style: TextStyle(fontSize: messageFontSize),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: isDark ? AppColors.black : AppColors.white,
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

              // Show Start Meeting button for accepted bookings (provider accepted)
              if (isBookingAccepted) ...[
                const SizedBox(height: 12),
                // Booking Details Card for Accepted Bookings
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
      // Ensure 2-digit hour format (06:00 instead of 6:00)
      final hourString = hour.toString().padLeft(2, '0');
      slots.add('$hourString:00');
      if (hour < 23) {
        slots.add('$hourString:30');
      }
    }
    print('Generated ${slots.length} time slots: $slots');
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
    
    // Normalize time format from HH:mm:ss to HH:mm (API returns with seconds)
    String? normalizeTime(String? time) {
      if (time == null) return null;
      
      // If time has seconds (HH:mm:ss), remove them
      if (time.length == 8 && time.contains(':')) {
        return time.substring(0, 5); // "09:00:00" -> "09:00"
      }
      
      // If time is in single-digit hour format (9:00), convert to double-digit (09:00)
      if (time.length == 4 && time.contains(':')) {
        return "0$time"; // "9:00" -> "09:00"
      }
      
      // If time is in AM/PM format, convert to 24-hour
      if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
        final parts = time.toLowerCase().split(':');
        if (parts.length >= 2) {
          int hour = int.tryParse(parts[0]) ?? 0;
          String minutePart = parts[1];
          String minutes = "00";
          
          // Extract minutes from "30pm" or "30 pm"
          final minuteMatch = RegExp(r'(\d+)').firstMatch(minutePart);
          if (minuteMatch != null) {
            minutes = minuteMatch.group(1)!.padLeft(2, '0');
          }
          
          // Handle PM conversion
          if (minutePart.contains('pm') && hour < 12) {
            hour += 12;
          }
          // Handle 12 AM special case
          if (minutePart.contains('am') && hour == 12) {
            hour = 0;
          }
          
          return "${hour.toString().padLeft(2, '0')}:$minutes";
        }
      }
      
      return time;
    }
    
    // Get original times from booking data
    String? originalStartTime = normalizeTime(bookingData.startTime);
    String? originalEndTime = normalizeTime(bookingData.endTime);
    
    // Debug log
    print('Original times from API - Start: $originalStartTime, End: $originalEndTime');
    print('Available time slots: $allTimeSlots');
    
    // Initialize with original values if they exist in our time slots
    String? selectedStartTime = originalStartTime;
    String? selectedEndTime = originalEndTime;
    
    // Validate that times exist in our available slots
    if (selectedStartTime != null && !allTimeSlots.contains(selectedStartTime)) {
      print('Start time $selectedStartTime not found in available slots');
      selectedStartTime = allTimeSlots.isNotEmpty ? allTimeSlots.first : null;
    }
    
    // Only set end time if start time is valid
    if (selectedStartTime != null) {
      List<String> validEndTimes = _getValidEndTimes(selectedStartTime, allTimeSlots);
      if (selectedEndTime != null && !validEndTimes.contains(selectedEndTime)) {
        print('End time $selectedEndTime not found in valid end times');
        selectedEndTime = validEndTimes.isNotEmpty ? validEndTimes.first : null;
      }
    } else {
      selectedEndTime = null;
    }

    print('📝 Showing update dialog for booking ID: ${notification.data?.bookingId}, Date: ${selectedDate}, StartTime: ${selectedStartTime}, EndTime: ${selectedEndTime}');
    
    // Debug all time slots
    print('All time slots: $allTimeSlots');
    if (selectedStartTime != null) {
      print('Valid end times: ${_getValidEndTimes(selectedStartTime, allTimeSlots)}');
    }
    
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
                                  child: Row(
                                    children: [
                                      Text(_formatTimeForDisplay(time), style: TextStyle(color: colors.textPrimary)),
                                      const SizedBox(width: 4),
                                      Text('($time)', style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                                    ],
                                  ),
                                )).toList(),
                                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                onChanged: (value) {
                                  print('Start time changed to: $value');
                                  setDialogState(() {
                                    selectedStartTime = value;
                                    if (selectedEndTime != null && value != null) {
                                      final validEndTimes = _getValidEndTimes(value, allTimeSlots);
                                      print('Valid end times after start time change: $validEndTimes');
                                      if (!validEndTimes.contains(selectedEndTime)) {
                                        print('Current end time $selectedEndTime is no longer valid, resetting');
                                        selectedEndTime = validEndTimes.isNotEmpty ? validEndTimes.first : null;
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
                                  child: Row(
                                    children: [
                                      Text(_formatTimeForDisplay(time), style: TextStyle(color: colors.textPrimary)),
                                      const SizedBox(width: 4),
                                      Text('($time)', style: TextStyle(color: colors.textTertiary, fontSize: 12)),
                                    ],
                                  ),
                                )).toList(),
                                icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                                onChanged: selectedStartTime == null ? null : (value) {
                                  print('End time changed to: $value');
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

                Text('Notes (Optional)', style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                TextField(
                  controller: notesController,
                  maxLines: 3,
                  style: TextStyle(color: colors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Add any notes for the provider...',
                    hintStyle: TextStyle(color: colors.textTertiary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: colors.textTertiary.withOpacity(0.3)),
                    ),
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
              onPressed: () async {
                if (selectedStartTime == null || selectedEndTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Please select both start and end time'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  return;
                }

                // Close the update dialog first
                if (Navigator.canPop(dialogContext)) {
                  Navigator.pop(dialogContext);
                }
                
                // Show loading dialog with a key for easier management
                final loadingDialogKey = GlobalKey<State>();
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    key: loadingDialogKey,
                    backgroundColor: Colors.white,
                    content: Row(
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(width: 20),
                        Text('Updating booking...', style: TextStyle(color: colors.textPrimary)),
                      ],
                    ),
                  ),
                );

                try {
                  // Debug log before API call
                  print('Calling updateBookingWithPayment - ID: ${bookingData.bookingId}, Date: ${selectedDate}, Start: ${selectedStartTime}, End: ${selectedEndTime}');
                  print('Formatted date for API: ${selectedDate.toIso8601String().split('T')[0]}');
                  
                  if (selectedStartTime == null || selectedEndTime == null) {
                    if (mounted) {
                    // Find the most recent dialog and close it
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                    throw Exception('Start time or end time is null');
                  }
                  
                  // Make sure time format is correct (HH:MM format)
                  String ensureCorrectTimeFormat(String time) {
                    // If time is already in correct format (HH:MM), return it
                    if (time.length == 5 && time.contains(':')) {
                      return time;
                    }
                    // If time has seconds (HH:MM:SS), remove them
                    if (time.length == 8 && time.contains(':')) {
                      return time.substring(0, 5);
                    }
                    // If time is in single-digit hour format (9:00), convert to double-digit (09:00)
                    if (time.length == 4 && time.contains(':')) {
                      return "0$time"; // "9:00" -> "09:00"
                    }
                    // If time is in AM/PM format, convert to 24-hour
                    if (time.toLowerCase().contains('am') || time.toLowerCase().contains('pm')) {
                      final parts = time.toLowerCase().split(':');
                      if (parts.length >= 2) {
                        int hour = int.tryParse(parts[0]) ?? 0;
                        String minutePart = parts[1];
                        String minutes = "00";
                        
                        // Extract minutes from "30pm" or "30 pm"
                        final minuteMatch = RegExp(r'(\d+)').firstMatch(minutePart);
                        if (minuteMatch != null) {
                          minutes = minuteMatch.group(1)!.padLeft(2, '0');
                        }
                        
                        // Handle PM conversion
                        if (minutePart.contains('pm') && hour < 12) {
                          hour += 12;
                        }
                        // Handle 12 AM special case
                        if (minutePart.contains('am') && hour == 12) {
                          hour = 0;
                        }
                        
                        return "${hour.toString().padLeft(2, '0')}:$minutes";
                      }
                    }
                    // Default case, return as is
                    return time;
                  }
                  
                  // Format date as YYYY-MM-DD for API
                  String formattedDate = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                  print('Manually formatted date: $formattedDate');
                  
                  // Try to update booking - API will return if payment is required
                  final updateResponse = await BookingService.updateBookingWithPayment(
                    bookingData.bookingId ?? 0,
                    bookingDate: selectedDate,
                    startTime: ensureCorrectTimeFormat(selectedStartTime!),
                    endTime: ensureCorrectTimeFormat(selectedEndTime!),
                    notes: notesController.text,
                  );

                  // Debug log after API call
                  print('API Response: ${updateResponse.success}, Message: ${updateResponse.message}, Requires Payment: ${updateResponse.requiresPayment}');
                  if (updateResponse.validationErrors != null) {
                    print('Validation errors: ${updateResponse.validationErrors}');
                  }
                  
                  // Safely close the loading dialog
                  if (mounted) {
                    // Find the most recent dialog and close it
                    Navigator.of(context, rootNavigator: true).pop();
                  }

                  if (updateResponse.requiresPayment && updateResponse.paymentRequirement != null) {
                    // Show payment dialog
                    _showPaymentDialog(
                      bookingId: bookingData.bookingId ?? 0,
                      paymentRequirement: updateResponse.paymentRequirement!,
                      updateData: updateResponse.data,
                      bookingDate: selectedDate,
                      startTime: selectedStartTime,
                      endTime: selectedEndTime,
                      notes: notesController.text,
                    );
                  } else if (updateResponse.success) {
                    // Update successful without additional payment
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(child: Text('Booking updated successfully!')),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                    _loadNotifications();
                  } else {
                    // Show detailed error message
                    String errorMessage = updateResponse.message;
                    
                    // Handle validation errors better
                    if (errorMessage.contains('Validation failed')) {
                      if (updateResponse.validationErrors != null) {
                        // Extract specific validation error messages
                        final errors = updateResponse.validationErrors!;
                        print('Validation errors: $errors');
                        
                        if (errors['booking_date'] != null) {
                          errorMessage = errors['booking_date'][0];
                        } else if (errors['start_time'] != null) {
                          errorMessage = errors['start_time'][0];
                        } else if (errors['end_time'] != null) {
                          errorMessage = errors['end_time'][0];
                        } else {
                          // Generic validation error
                          errorMessage = 'Booking update failed. Please check if the selected time slot is available.';
                        }
                      } else {
                        errorMessage = 'Booking update failed. Please check if the selected time slot is available.';
                      }
                    }
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMessage),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                } catch (e) {
                  print('Error updating booking: $e');
                  // Safely close the loading dialog
                  if (mounted) {
                    // Find the most recent dialog and close it
                    Navigator.of(context, rootNavigator: true).pop();
                  }
                  
                  // Show user-friendly error message
                  String errorMessage = 'Failed to update booking';
                  if (e.toString().contains('time is null')) {
                    errorMessage = 'Please select both start and end time';
                  } else if (e.toString().contains('No host specified in URI')) {
                    errorMessage = 'Network connection error. Please check your internet connection.';
                  }
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(errorMessage),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      duration: const Duration(seconds: 4),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
              ),
              child: const Text('Update Booking'),
            ),
          ],
        ),
      ),
    );
  }



  void _onCancelBooking(NotificationItem notification) {
    // Handle cancel booking functionality
    print('Cancel Booking: ${notification.data?.bookingId}');
    final colors = context.colors;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.cancel, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Cancel Booking', style: TextStyle(color: colors.textPrimary)),
          ],
        ),
        content: Text(
          'Are you sure you want to cancel this booking? This action cannot be undone.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('No, Keep It', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              // Show loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => const Center(child: CircularProgressIndicator()),
              );
              
              try {
                final response = await BookingService.cancelBooking(notification.data?.bookingId ?? 0);
                
                if (mounted) {
          // Find the most recent dialog and close it
          Navigator.of(context, rootNavigator: true).pop();
        } // Close loading
                
                if (response != null && response.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Booking cancelled successfully'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                  // Refresh notifications
                  _loadNotifications();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(response?.message ?? 'Failed to cancel booking'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
          // Find the most recent dialog and close it
          Navigator.of(context, rootNavigator: true).pop();
        } // Close loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  void _onStartMeeting(NotificationItem notification) {
    // Handle start meeting functionality for accepted bookings
    print('Start Meeting: ${notification.data?.bookingId}');
    // TODO: Implement meeting start logic (e.g., navigate to video call screen)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Starting meeting...'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onAcceptBooking(NotificationItem notification) async {
    // Handle accept booking functionality
    print('Accept Booking: ${notification.data?.bookingId}');
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final response = await ProviderBookingService.acceptBooking(notification.data?.bookingId ?? 0);
      
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
      
      if (response != null && response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking accepted successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Refresh notifications
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to accept booking'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
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

  void _onRejectBooking(NotificationItem notification) async {
    // Handle reject booking functionality
    print('Reject Booking: ${notification.data?.bookingId}');
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final response = await ProviderBookingService.rejectBooking(notification.data?.bookingId ?? 0);
      
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
      
      if (response != null && response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking rejected'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Refresh notifications
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to reject booking'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
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

  void _onBlockUser(NotificationItem notification) async {
    // Handle block user functionality
    print('Block User for Booking: ${notification.data?.bookingId}');
    
    final colors = context.colors;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block, color: AppColors.error),
            const SizedBox(width: 8),
            Text('Block User', style: TextStyle(color: colors.textPrimary)),
          ],
        ),
        content: Text(
          'Are you sure you want to block this user? They will not be able to send you booking requests anymore.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );
    
    try {
      final response = await ProviderBookingService.blockClient(notification.data?.bookingId ?? 0);
      
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
      
      if (response != null && response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('User blocked successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        // Refresh notifications
        _loadNotifications();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?.message ?? 'Failed to block user'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
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

  void _handleNotificationTap(NotificationItem notification) {
    // Mark as read when tapped
    _markNotificationAsRead(notification);
    
    // Handle navigation based on notification type
    final type = notification.type.toLowerCase();
    
    switch (type) {
      case 'booking':
      case 'booking_request':
      case 'booking_confirmed':
      case 'booking_cancelled':
      case 'booking_accepted':
        // Navigate to booking details or my bookings screen
        // Navigator.pushNamed(context, '/my-bookings');
        break;
      case 'payment':
      case 'payment_received':
      case 'payment_pending':
        // Navigate to payment history
        // Navigator.pushNamed(context, '/payment-history');
        break;
      case 'message':
      case 'chat':
        // Navigate to chat
        // Navigator.pushNamed(context, '/chat');
        break;
      default:
        // Just mark as read, no navigation
        break;
    }
  }

  void _refreshNotifications() {
    _loadNotifications();
  }

  /// Show payment dialog for booking update with price difference
  void _showPaymentDialog({
    required int bookingId,
    required PaymentRequirement paymentRequirement,
    UpdateBookingData? updateData,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    String? notes,
  }) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    // Get amounts from updateData if available, otherwise use totalDue
    final originalAmount = updateData?.oldTotalAmount ?? 0.0;
    final newAmount = updateData?.newTotalAmount ?? (originalAmount + paymentRequirement.totalDue);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.payment, color: primaryColor),
            const SizedBox(width: 8),
            Text('Additional Payment Required', style: TextStyle(color: colors.textPrimary, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'The updated booking requires additional payment:',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildPaymentRow('Original Amount', '₹${originalAmount.toStringAsFixed(2)}', colors),
            _buildPaymentRow('New Amount', '₹${newAmount.toStringAsFixed(2)}', colors),
            const Divider(),
            _buildPaymentRow('Difference', '₹${paymentRequirement.totalDue.toStringAsFixed(2)}', colors, isBold: true, color: AppColors.error),
            const SizedBox(height: 12),
            if (paymentRequirement.walletBalance > 0) ...[
              _buildPaymentRow('Wallet Balance', '₹${paymentRequirement.walletBalance.toStringAsFixed(2)}', colors, color: AppColors.success),
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

    // Show loading dialog with a key for easier management
    final loadingDialogKey = GlobalKey<State>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        key: loadingDialogKey,
        backgroundColor: Theme.of(context).cardColor,
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text('Processing payment...', style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          ],
        ),
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

        if (mounted) {
          // Find the most recent dialog and close it
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (response != null && response.success) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Payment successful! Booking has been updated.'),
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

        if (mounted) {
          // Find the most recent dialog and close it
          Navigator.of(context, rootNavigator: true).pop();
        }

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
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      }

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

    try {
      // Get environment
      final cfEnvironment = (paymentResponse.data?.cashfreeEnv ?? 'SANDBOX').toLowerCase() == 'production'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      // Build session using CFSessionBuilder
      final cfSession = CFSessionBuilder()
          .setEnvironment(cfEnvironment)
          .setOrderId(paymentResponse.data?.cashfreeOrder?.orderId ?? '')
          .setPaymentSessionId(paymentResponse.data?.cashfreeOrder?.paymentSessionId ?? '')
          .build();

      // Set payment components using CFPaymentComponentBuilder
      final cfPaymentComponent = CFPaymentComponentBuilder()
          .setComponents([
            CFPaymentModes.CARD,
            CFPaymentModes.UPI,
            CFPaymentModes.NETBANKING,
            CFPaymentModes.WALLET,
          ])
          .build();

      // Set theme using CFThemeBuilder
      final cfTheme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor('#6366F1')
          .setNavigationBarTextColor('#FFFFFF')
          .setButtonBackgroundColor('#6366F1')
          .setButtonTextColor('#FFFFFF')
          .setPrimaryTextColor('#000000')
          .setSecondaryTextColor('#666666')
          .build();

      // Build drop checkout payment using CFDropCheckoutPaymentBuilder
      final cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(cfSession)
          .setPaymentComponent(cfPaymentComponent)
          .setTheme(cfTheme)
          .build();

      // Get payment gateway service
      final cfPaymentGatewayService = CFPaymentGatewayService();
      
      // Set callbacks
      cfPaymentGatewayService.setCallback(
        (String orderId) {
          _onCashfreePaymentSuccess(orderId, bookingId, walletAmountUsed);
        },
        (CFErrorResponse errorResponse, String orderId) {
          _onCashfreePaymentFailure(errorResponse);
        },
      );
      
      // Initiate payment
      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);
    } on CFException catch (e) {
      _onCashfreePaymentCancelled('Payment failed: ${e.message}');
    } catch (e) {
      _onCashfreePaymentCancelled('Payment failed: Something went wrong');
    }
  }

  // Handle successful payment
  void _onCashfreePaymentSuccess(String orderId, int bookingId, double walletAmountUsed) async {
    if (!mounted) return;
    
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();
    
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    
    try {
      // Process the payment with the backend
      final response = await BookingService.processDifferencePayment(
        bookingId: bookingId,
        amount: walletAmountUsed, // This is the wallet amount used
        paymentMethod: 'cashfree',
        // Use orderId parameter instead of cashfreeOrderId
        // Since the processDifferencePayment method doesn't have a cashfreeOrderId parameter
      );
      
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
      
      if (response != null && response.success) {
        // Show success message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Payment successful! Booking has been updated.'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Refresh the notifications list
        _refreshNotifications();
      } else {
        // Show error message
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Payment verification failed: ${response?.message ?? 'Unknown error'}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Find the most recent dialog and close it
        Navigator.of(context, rootNavigator: true).pop();
      } // Close loading
      
      // Show error message
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Payment processing error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // Handle payment failure
  void _onCashfreePaymentFailure(CFErrorResponse error) {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('Payment failed: ${error.getMessage() ?? 'Unknown error'}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Handle payment cancellation
  void _onCashfreePaymentCancelled(String message) {
    if (!mounted) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}