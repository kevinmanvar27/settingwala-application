import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/user_service.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<UserReviewItem> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;
  int? _currentUserId;
  
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  
  @override
  void initState() {
    super.initState();
    _loadCurrentUserAndReviews();
  }
  
  Future<void> _loadCurrentUserAndReviews() async {
    // Get current user ID from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_data');
    
    if (userJson != null) {
      try {
        final userData = jsonDecode(userJson);
        _currentUserId = userData['id'];
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to load user data. Please login again.';
          _isLoading = false;
        });
        return;
      }
    }
    
    if (_currentUserId == null) {
      setState(() {
        _errorMessage = 'User not found. Please login again.';
        _isLoading = false;
      });
      return;
    }
    
    await _loadReviews();
  }
  
  Future<void> _loadReviews({bool loadMore = false}) async {
    if (_currentUserId == null) return;
    
    if (loadMore) {
      if (_currentPage >= _lastPage || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final page = loadMore ? _currentPage + 1 : 1;
      // FIX: Using UserService.getUserReviews() instead of removed ReviewService.getReceivedReviews()
      // API endpoint: GET /users/{id}/reviews (Section 5.4)
      final response = await UserService.getUserReviews(
        userId: _currentUserId!,
        page: page,
      );
      
      if (response != null && response.success) {
        setState(() {
          if (loadMore) {
            _reviews.addAll(response.reviews);
          } else {
            _reviews = response.reviews;
          }
          _averageRating = response.averageRating;
          _totalReviews = response.totalReviews;
          _currentPage = response.pagination.currentPage;
          _lastPage = response.pagination.lastPage;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load reviews';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reviews. Please try again.';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    final sectionSpacing = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final itemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final cardRadius = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 24.0 : 30.0;
    
    final sectionHeaderFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final ratingScoreFontSize = isDesktop ? 56.0 : isTablet ? 52.0 : isSmallScreen ? 40.0 : 48.0;
    final ratingLabelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final categoryLabelFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final categoryRatingFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final reviewNameFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final reviewDateFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final reviewCommentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final emptyStateFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final buttonLabelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    final starIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final smallStarIconSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final replyIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    
    final avatarRadius = isDesktop ? 30.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    
    final ratingBadgePaddingH = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final ratingBadgePaddingV = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
    final ratingBadgeRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'My Reviews',
      showBackButton: true,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: _isLoading
              ? _buildLoadingState(colors, primaryColor)
              : _errorMessage != null
                  ? _buildErrorState(colors, primaryColor, emptyStateFontSize)
                  : RefreshIndicator(
                      onRefresh: () => _loadReviews(),
                      color: primaryColor,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildReviewSummary(
                              colors, 
                              primaryColor,
                              cardRadius: cardRadius,
                              cardPadding: horizontalPadding,
                              scoreFontSize: ratingScoreFontSize,
                              labelFontSize: ratingLabelFontSize,
                              categoryLabelFontSize: categoryLabelFontSize,
                              categoryRatingFontSize: categoryRatingFontSize,
                              starIconSize: starIconSize,
                              smallStarIconSize: smallStarIconSize,
                              itemSpacing: itemSpacing,
                            ),
                            SizedBox(height: sectionSpacing),
                            Text(
                              'Recent Reviews',
                              style: TextStyle(
                                fontSize: sectionHeaderFontSize,
                                fontWeight: FontWeight.bold,
                                color: colors.textPrimary,
                              ),
                            ),
                            SizedBox(height: itemSpacing),
                            if (_reviews.isEmpty)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.all(sectionSpacing),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.rate_review_outlined,
                                        size: 64,
                                        color: colors.textTertiary,
                                      ),
                                      SizedBox(height: itemSpacing),
                                      Text(
                                        'No reviews yet',
                                        style: TextStyle(
                                          fontSize: sectionHeaderFontSize,
                                          fontWeight: FontWeight.w600,
                                          color: colors.textSecondary,
                                        ),
                                      ),
                                      SizedBox(height: itemSpacing * 0.5),
                                      Text(
                                        'Complete bookings to receive reviews from clients',
                                        style: TextStyle(
                                          fontSize: emptyStateFontSize,
                                          color: colors.textTertiary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              ..._reviews.map((review) => Padding(
                                padding: EdgeInsets.only(bottom: itemSpacing),
                                child: _buildReviewItem(
                                  review: review,
                                  colors: colors,
                                  primaryColor: primaryColor,
                                  cardRadius: cardRadius,
                                  cardPadding: horizontalPadding,
                                  avatarRadius: avatarRadius,
                                  nameFontSize: reviewNameFontSize,
                                  dateFontSize: reviewDateFontSize,
                                  commentFontSize: reviewCommentFontSize,
                                  buttonLabelFontSize: buttonLabelFontSize,
                                  smallStarIconSize: smallStarIconSize,
                                  replyIconSize: replyIconSize,
                                  ratingBadgePaddingH: ratingBadgePaddingH,
                                  ratingBadgePaddingV: ratingBadgePaddingV,
                                  ratingBadgeRadius: ratingBadgeRadius,
                                  itemSpacing: itemSpacing,
                                ),
                              )),
                            if (_currentPage < _lastPage)
                              Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: itemSpacing),
                                  child: _isLoadingMore
                                      ? CircularProgressIndicator(color: primaryColor)
                                      : TextButton(
                                          onPressed: () => _loadReviews(loadMore: true),
                                          child: Text(
                                            'Load More Reviews',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: buttonLabelFontSize,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
        ),
      ),
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
            'Loading reviews...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(AppColorSet colors, Color primaryColor, double fontSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              style: TextStyle(
                fontSize: fontSize,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadReviews(),
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

  Widget _buildReviewSummary(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double scoreFontSize,
    required double labelFontSize,
    required double categoryLabelFontSize,
    required double categoryRatingFontSize,
    required double starIconSize,
    required double smallStarIconSize,
    required double itemSpacing,
  }) {
    final fullStars = _averageRating.floor();
    final hasHalfStar = (_averageRating - fullStars) >= 0.5;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _averageRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: scoreFontSize,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              SizedBox(width: itemSpacing),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      IconData icon;
                      if (index < fullStars) {
                        icon = Icons.star;
                      } else if (index == fullStars && hasHalfStar) {
                        icon = Icons.star_half;
                      } else {
                        icon = Icons.star_border;
                      }
                      return Icon(
                        icon,
                        color: Colors.amber,
                        size: starIconSize,
                      );
                    }),
                  ),
                  SizedBox(height: itemSpacing * 0.25),
                  Text(
                    'Based on $_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'}',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildReviewItem({
    required UserReviewItem review,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double cardPadding,
    required double avatarRadius,
    required double nameFontSize,
    required double dateFontSize,
    required double commentFontSize,
    required double buttonLabelFontSize,
    required double smallStarIconSize,
    required double replyIconSize,
    required double ratingBadgePaddingH,
    required double ratingBadgePaddingV,
    required double ratingBadgeRadius,
    required double itemSpacing,
  }) {
    // FIX: Updated to use UserReviewItem model from UserService.getUserReviews()
    final reviewerName = review.reviewer?.name ?? 'Anonymous';
    final reviewerPhoto = review.reviewer?.profilePicture;
    final rating = review.rating;
    final comment = review.review ?? '';
    final date = _formatDateFromDateTime(review.createdAt);
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: avatarRadius,
                backgroundColor: primaryColor.withOpacity(0.2),
                backgroundImage: reviewerPhoto != null && reviewerPhoto.isNotEmpty
                    ? NetworkImage(reviewerPhoto)
                    : null,
                child: reviewerPhoto == null || reviewerPhoto.isEmpty
                    ? Text(
                        reviewerName.isNotEmpty ? reviewerName[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: avatarRadius * 0.8,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: itemSpacing * 0.75),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: nameFontSize,
                        color: colors.textPrimary,
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: dateFontSize,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ratingBadgePaddingH, 
                  vertical: ratingBadgePaddingV,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(ratingBadgeRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: smallStarIconSize,
                    ),
                    SizedBox(width: smallStarIconSize * 0.25),
                    Text(
                      rating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: commentFontSize,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: itemSpacing * 0.75),
            Text(
              comment,
              style: TextStyle(
                fontSize: commentFontSize,
                color: colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: itemSpacing * 0.75),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Reply feature coming soon'),
                      backgroundColor: primaryColor,
                    ),
                  );
                },
                icon: Icon(
                  Icons.reply,
                  color: primaryColor,
                  size: replyIconSize,
                ),
                label: Text(
                  'Reply',
                  style: TextStyle(
                    fontSize: buttonLabelFontSize,
                    color: primaryColor,
                  ),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    horizontal: itemSpacing * 0.75, 
                    vertical: itemSpacing * 0.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ratingBadgeRadius),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // FIX: Updated to handle DateTime directly from UserReviewItem
  String _formatDateFromDateTime(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
