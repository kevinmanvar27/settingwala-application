import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/review_service.dart';
import '../routes/app_routes.dart';

/// Pending Reviews Screen - Shows bookings awaiting user reviews
/// User can see all completed bookings where they haven't submitted a review yet
class PendingReviewsScreen extends StatefulWidget {
  const PendingReviewsScreen({super.key});

  @override
  State<PendingReviewsScreen> createState() => _PendingReviewsScreenState();
}

class _PendingReviewsScreenState extends State<PendingReviewsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<PendingReviewBooking> _pendingReviews = [];
  int _currentPage = 1;
  int _lastPage = 1;
  
  @override
  void initState() {
    super.initState();
    _loadPendingReviews();
  }
  
  Future<void> _loadPendingReviews({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || _currentPage >= _lastPage) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final page = loadMore ? _currentPage + 1 : 1;
      final response = await ReviewService.getPendingReviews(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _pendingReviews.addAll(response.data);
            _currentPage = page;
          } else {
            _pendingReviews = response.data;
            _currentPage = 1;
          }
          _lastPage = response.pagination?.lastPage ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load pending reviews: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
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
  
  String _formatDuration(int? duration) {
    if (duration == null) return '';
    if (duration == 1) return '1 hour';
    return '$duration hours';
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
    
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    return BaseScreen(
      title: 'Pending Reviews',
      showBackButton: true,
      body: _isLoading
          ? _buildLoadingState(colors, primaryColor)
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor)
              : _pendingReviews.isEmpty
                  ? _buildEmptyState(colors, primaryColor)
                  : _buildReviewsList(colors, primaryColor, contentPadding, isSmallScreen, isTablet, isDesktop),
    );
  }
  
  Widget _buildLoadingState(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading pending reviews...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(AppColorSet colors, Color primaryColor) {
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
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadPendingReviews(),
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
  
  Widget _buildEmptyState(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Pending Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have reviewed all your completed bookings. Great job!',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _loadPendingReviews(),
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
  
  Widget _buildReviewsList(
    AppColorSet colors,
    Color primaryColor,
    double contentPadding,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadPendingReviews(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(contentPadding),
        itemCount: _pendingReviews.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _pendingReviews.length) {
            return _buildLoadMoreButton(colors, primaryColor);
          }
          return _buildReviewCard(
            _pendingReviews[index],
            colors,
            primaryColor,
            isSmallScreen,
            isTablet,
            isDesktop,
          );
        },
      ),
    );
  }
  
  Widget _buildReviewCard(
    PendingReviewBooking booking,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final avatarSize = isDesktop ? 56.0 : isTablet ? 52.0 : isSmallScreen ? 40.0 : 48.0;
    final titleFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 14.0 : 15.0;
    final subtitleFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    // Get the other user (provider or client depending on role)
    final otherUser = booking.provider ?? booking.client;
    
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
                // Avatar
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: primaryColor.withOpacity(0.5), width: 2),
                  ),
                  child: ClipOval(
                    child: otherUser?.profilePhoto != null
                        ? CachedImage(
                            imageUrl: otherUser!.profilePhoto!,
                            fit: BoxFit.cover,
                            errorWidget: _buildDefaultAvatar(colors, avatarSize),
                          )
                        : _buildDefaultAvatar(colors, avatarSize),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        otherUser?.name ?? 'Unknown User',
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.calendar_today, size: subtitleFontSize, color: colors.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            booking.bookingDate ?? 'N/A',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textSecondary,
                            ),
                          ),
                          if (booking.bookingTime != null) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: colors.textTertiary,
                              ),
                            ),
                            Icon(Icons.access_time, size: subtitleFontSize, color: colors.textTertiary),
                            const SizedBox(width: 2),
                            Text(
                              booking.bookingTime!,
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: colors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (booking.duration != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, size: subtitleFontSize, color: colors.textTertiary),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(booking.duration),
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: colors.textSecondary,
                              ),
                            ),
                            if (booking.completedAt != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.check_circle, size: subtitleFontSize, color: AppColors.success),
                              const SizedBox(width: 2),
                              Text(
                                'Completed ${_formatDate(booking.completedAt)}',
                                style: TextStyle(
                                  fontSize: subtitleFontSize,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Review Now button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _navigateToReview(booking),
                icon: const Icon(Icons.star_outline, size: 20),
                label: const Text('Write Review'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    vertical: isSmallScreen ? 10 : 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius / 2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
  
  Widget _buildLoadMoreButton(AppColorSet colors, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator(color: primaryColor)
            : OutlinedButton.icon(
                onPressed: () => _loadPendingReviews(loadMore: true),
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
  
  void _navigateToReview(PendingReviewBooking booking) {
    // Navigate to my bookings screen where user can submit review
    // The booking details will show the review option
    Navigator.pushNamed(context, AppRoutes.myBookings);
  }
}
