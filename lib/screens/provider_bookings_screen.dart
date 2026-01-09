import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/provider_booking_service.dart';
import '../utils/snackbar_utils.dart';

/// Provider Bookings Screen - Shows provider's bookings and booking requests
/// Tabbed interface: "My Bookings" (completed/active) + "Booking Requests" (new requests)
class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // My Bookings state
  bool _isLoadingBookings = true;
  bool _isLoadingMoreBookings = false;
  String? _bookingsError;
  List<ProviderBooking> _bookings = [];
  int _bookingsPage = 1;
  int _bookingsLastPage = 1;
  
  // Booking Requests state
  bool _isLoadingRequests = true;
  bool _isLoadingMoreRequests = false;
  String? _requestsError;
  List<ProviderBooking> _requests = [];
  int _requestsPage = 1;
  int _requestsLastPage = 1;
  
  // Action loading state
  Set<int> _processingBookings = {};
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBookings();
    _loadRequests();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBookings({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreBookings || _bookingsPage >= _bookingsLastPage) return;
      setState(() => _isLoadingMoreBookings = true);
    } else {
      setState(() {
        _isLoadingBookings = true;
        _bookingsError = null;
      });
    }
    
    try {
      final page = loadMore ? _bookingsPage + 1 : 1;
      final response = await ProviderBookingService.getProviderBookings(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _bookings.addAll(response.data);
            _bookingsPage = page;
          } else {
            _bookings = response.data;
            _bookingsPage = 1;
          }
          _bookingsLastPage = response.pagination?.lastPage ?? 1;
          _isLoadingBookings = false;
          _isLoadingMoreBookings = false;
        });
      } else {
        setState(() {
          _bookingsError = response.message;
          _isLoadingBookings = false;
          _isLoadingMoreBookings = false;
        });
      }
    } catch (e) {
      setState(() {
        _bookingsError = 'Failed to load bookings: $e';
        _isLoadingBookings = false;
        _isLoadingMoreBookings = false;
      });
    }
  }
  
  Future<void> _loadRequests({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMoreRequests || _requestsPage >= _requestsLastPage) return;
      setState(() => _isLoadingMoreRequests = true);
    } else {
      setState(() {
        _isLoadingRequests = true;
        _requestsError = null;
      });
    }
    
    try {
      final page = loadMore ? _requestsPage + 1 : 1;
      final response = await ProviderBookingService.getBookingRequests(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _requests.addAll(response.data);
            _requestsPage = page;
          } else {
            _requests = response.data;
            _requestsPage = 1;
          }
          _requestsLastPage = response.pagination?.lastPage ?? 1;
          _isLoadingRequests = false;
          _isLoadingMoreRequests = false;
        });
      } else {
        setState(() {
          _requestsError = response.message;
          _isLoadingRequests = false;
          _isLoadingMoreRequests = false;
        });
      }
    } catch (e) {
      setState(() {
        _requestsError = 'Failed to load requests: $e';
        _isLoadingRequests = false;
        _isLoadingMoreRequests = false;
      });
    }
  }
  
  Future<void> _acceptBooking(int bookingId) async {
    if (_processingBookings.contains(bookingId)) return;
    
    setState(() => _processingBookings.add(bookingId));
    
    try {
      final response = await ProviderBookingService.acceptBooking(bookingId);
      
      if (response.success) {
        SnackbarUtils.showSuccess(context, 'Booking accepted successfully');
        // Remove from requests and refresh bookings
        setState(() {
          _requests.removeWhere((r) => r.id == bookingId);
        });
        _loadBookings();
      } else {
        SnackbarUtils.showError(context, response.message);
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Failed to accept booking');
    } finally {
      setState(() => _processingBookings.remove(bookingId));
    }
  }
  
  Future<void> _rejectBooking(int bookingId) async {
    if (_processingBookings.contains(bookingId)) return;
    
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Booking'),
        content: const Text('Are you sure you want to reject this booking request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    setState(() => _processingBookings.add(bookingId));
    
    try {
      final response = await ProviderBookingService.rejectBooking(bookingId);
      
      if (response.success) {
        SnackbarUtils.showSuccess(context, 'Booking rejected');
        setState(() {
          _requests.removeWhere((r) => r.id == bookingId);
        });
      } else {
        SnackbarUtils.showError(context, response.message);
      }
    } catch (e) {
      SnackbarUtils.showError(context, 'Failed to reject booking');
    } finally {
      setState(() => _processingBookings.remove(bookingId));
    }
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }
  
  String _formatBookingDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
      case 'confirmed':
        return AppColors.success;
      case 'rejected':
      case 'cancelled':
        return AppColors.error;
      case 'completed':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
      case 'confirmed':
        return Icons.check_circle;
      case 'rejected':
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    return BaseScreen(
      title: 'Provider Bookings',
      showBackButton: true,
      body: Column(
        children: [
          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: colors.card,
              border: Border(
                bottom: BorderSide(color: colors.border.withOpacity(0.5)),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: primaryColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 8),
                      Text(isSmallScreen ? 'Bookings' : 'My Bookings'),
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.pending_actions, size: 18),
                      const SizedBox(width: 8),
                      Text(isSmallScreen ? 'Requests' : 'Requests'),
                      if (_requests.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${_requests.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // My Bookings Tab
                _buildBookingsTab(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
                // Booking Requests Tab
                _buildRequestsTab(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBookingsTab(
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    if (_isLoadingBookings) {
      return _buildLoadingState(colors, primaryColor, 'Loading bookings...');
    }
    
    if (_bookingsError != null) {
      return _buildErrorState(colors, primaryColor, _bookingsError!, () => _loadBookings());
    }
    
    if (_bookings.isEmpty) {
      return _buildEmptyState(
        colors,
        primaryColor,
        Icons.calendar_today,
        'No Bookings Yet',
        'Your accepted bookings will appear here.',
        () => _loadBookings(),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => _loadBookings(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(contentPadding),
        itemCount: _bookings.length + (_bookingsPage < _bookingsLastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _bookings.length) {
            return _buildLoadMoreButton(
              colors,
              primaryColor,
              _isLoadingMoreBookings,
              () => _loadBookings(loadMore: true),
            );
          }
          return _buildBookingCard(
            _bookings[index],
            colors,
            primaryColor,
            isSmallScreen,
            isTablet,
            isDesktop,
            isRequest: false,
          );
        },
      ),
    );
  }
  
  Widget _buildRequestsTab(
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    if (_isLoadingRequests) {
      return _buildLoadingState(colors, primaryColor, 'Loading requests...');
    }
    
    if (_requestsError != null) {
      return _buildErrorState(colors, primaryColor, _requestsError!, () => _loadRequests());
    }
    
    if (_requests.isEmpty) {
      return _buildEmptyState(
        colors,
        primaryColor,
        Icons.pending_actions,
        'No Pending Requests',
        'New booking requests from clients will appear here.',
        () => _loadRequests(),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => _loadRequests(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(contentPadding),
        itemCount: _requests.length + (_requestsPage < _requestsLastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _requests.length) {
            return _buildLoadMoreButton(
              colors,
              primaryColor,
              _isLoadingMoreRequests,
              () => _loadRequests(loadMore: true),
            );
          }
          return _buildBookingCard(
            _requests[index],
            colors,
            primaryColor,
            isSmallScreen,
            isTablet,
            isDesktop,
            isRequest: true,
          );
        },
      ),
    );
  }
  
  Widget _buildBookingCard(
    ProviderBooking booking,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
    {required bool isRequest}
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final avatarSize = isDesktop ? 56.0 : isTablet ? 52.0 : isSmallScreen ? 40.0 : 48.0;
    final titleFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 14.0 : 15.0;
    final subtitleFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    final client = booking.client;
    final statusColor = _getStatusColor(booking.status);
    final statusIcon = _getStatusIcon(booking.status);
    final isProcessing = _processingBookings.contains(booking.id);
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: colors.border.withOpacity(0.5)),
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
            Row(
              children: [
                // Client Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
                  ),
                  child: ClipOval(
                    child: client?.avatar != null
                        ? CachedImage(
                            imageUrl: client!.avatar!,
                            fit: BoxFit.cover,
                            errorWidget: _buildDefaultAvatar(colors, avatarSize),
                          )
                        : _buildDefaultAvatar(colors, avatarSize),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                
                // Client info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              client?.name ?? 'Unknown Client',
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w600,
                                color: colors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (client?.age != null) ...[
                            Text(
                              '${client!.age} years',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: colors.textSecondary,
                              ),
                            ),
                            if (client.gender != null)
                              Text(
                                ' • ${client.gender}',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: colors.textSecondary,
                                ),
                              ),
                          ],
                          if (client?.rating != null) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.star, size: subtitleFontSize, color: AppColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              client!.rating!.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (client?.totalBookings != null && client!.totalBookings! > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${client.totalBookings} previous bookings',
                          style: TextStyle(
                            fontSize: subtitleFontSize - 1,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 10,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: subtitleFontSize, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: subtitleFontSize - 1,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Booking details
            Container(
              padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              decoration: BoxDecoration(
                color: colors.background,
                borderRadius: BorderRadius.circular(cardRadius / 2),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          colors,
                          Icons.calendar_today,
                          'Date',
                          _formatBookingDate(booking.bookingDate),
                          subtitleFontSize,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          colors,
                          Icons.timer,
                          'Duration',
                          '${booking.durationHours.toStringAsFixed(1)} hrs',
                          subtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDetailItem(
                          colors,
                          Icons.currency_rupee,
                          'Amount',
                          '₹${booking.totalAmount?.toStringAsFixed(0) ?? 'N/A'}',
                          subtitleFontSize,
                          valueColor: AppColors.success,
                        ),
                      ),
                      Expanded(
                        child: _buildDetailItem(
                          colors,
                          Icons.payment,
                          'Payment',
                          booking.paymentStatus ?? 'N/A',
                          subtitleFontSize,
                        ),
                      ),
                    ],
                  ),
                  if (booking.meetingLocation != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: subtitleFontSize, color: colors.textTertiary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.meetingLocation!,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            
            // Action buttons for requests
            if (isRequest && booking.status.toLowerCase() == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing ? null : () => _rejectBooking(booking.id),
                      icon: isProcessing
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.error,
                              ),
                            )
                          : const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(color: AppColors.error),
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing ? null : () => _acceptBooking(booking.id),
                      icon: isProcessing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check, size: 18),
                      label: const Text('Accept'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 10 : 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Created at timestamp
            if (booking.createdAt != null) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.access_time, size: subtitleFontSize - 2, color: colors.textTertiary),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(booking.createdAt),
                    style: TextStyle(
                      fontSize: subtitleFontSize - 1,
                      color: colors.textTertiary,
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
  
  Widget _buildDetailItem(
    AppColorSet colors,
    IconData icon,
    String label,
    String value,
    double fontSize,
    {Color? valueColor}
  ) {
    return Row(
      children: [
        Icon(icon, size: fontSize, color: colors.textTertiary),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize - 2,
                color: colors.textTertiary,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildDefaultAvatar(AppColorSet colors, double size) {
    return Container(
      width: size,
      height: size,
      color: colors.background,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: colors.textTertiary,
      ),
    );
  }
  
  Widget _buildLoadingState(AppColorSet colors, Color primaryColor, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(AppColorSet colors, Color primaryColor, String error, VoidCallback onRetry) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(
    AppColorSet colors,
    Color primaryColor,
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onRefresh,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLoadMoreButton(
    AppColorSet colors,
    Color primaryColor,
    bool isLoading,
    VoidCallback onLoadMore,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: isLoading
            ? CircularProgressIndicator(color: primaryColor)
            : OutlinedButton.icon(
                onPressed: onLoadMore,
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                ),
              ),
      ),
    );
  }
}
