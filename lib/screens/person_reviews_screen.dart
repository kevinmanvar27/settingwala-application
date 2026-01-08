import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/base_screen.dart';
import '../Service/user_service.dart';

class PersonReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const PersonReviewsScreen({super.key, required this.person});

  @override
  State<PersonReviewsScreen> createState() => _PersonReviewsScreenState();
}

class _PersonReviewsScreenState extends State<PersonReviewsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<UserReviewItem> _reviews = [];
  double _averageRating = 0.0;
  int _totalReviews = 0;
  
  int _currentPage = 1;
  int _lastPage = 1;
  bool _isLoadingMore = false;
  
  Map<int, int> _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }
  
  Future<void> _loadReviews({bool loadMore = false}) async {
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
      final userId = widget.person['id'];
      
      if (userId == null) {
        setState(() {
          _averageRating = (widget.person['rating'] ?? 0.0).toDouble();
          _totalReviews = widget.person['reviews'] ?? 0;
          _isLoading = false;
        });
        return;
      }
      
      // FIX: Using UserService.getUserReviews() instead of removed ReviewService.getReviews()
      // API endpoint: GET /users/{id}/reviews (Section 5.4)
      final response = await UserService.getUserReviews(userId: userId, page: page);
      
      if (response != null && response.success) {
        setState(() {
          if (loadMore) {
            _reviews.addAll(response.reviews);
          } else {
            _reviews = response.reviews;
            _ratingDistribution = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
            for (var review in _reviews) {
              final rating = review.rating.toInt().clamp(1, 5);
              _ratingDistribution[rating] = (_ratingDistribution[rating] ?? 0) + 1;
            }
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
          _averageRating = (widget.person['rating'] ?? 0.0).toDouble();
          _totalReviews = widget.person['reviews'] ?? 0;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load reviews. Please try again.';
        _isLoading = false;
        _isLoadingMore = false;
        _averageRating = (widget.person['rating'] ?? 0.0).toDouble();
        _totalReviews = widget.person['reviews'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final person = widget.person;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final borderRadius = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final ratingFontSize = isDesktop ? 52.0 : isTablet ? 46.0 : isSmallScreen ? 32.0 : 40.0;
    final starSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 14.0 : 18.0;
    final reviewCountSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final sectionTitleSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;

    return BaseScreen(
      title: 'Reviews - ${person['name']}',
      showBackButton: true,
      body: _isLoading
          ? _buildLoadingState(colors, primaryColor)
          : RefreshIndicator(
              onRefresh: () => _loadReviews(),
              color: primaryColor,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPersonInfoCard(person, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
                    SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),

                    Container(
                      padding: EdgeInsets.all(cardPadding),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(borderRadius),
                        border: Border.all(color: Colors.amber.shade200),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                _averageRating.toStringAsFixed(1),
                                style: TextStyle(
                                  fontSize: ratingFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber.shade800,
                                ),
                              ),
                              Row(
                                children: List.generate(5, (index) {
                                  final fullStars = _averageRating.floor();
                                  final hasHalfStar = (_averageRating - fullStars) >= 0.5;
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
                                    size: starSize,
                                  );
                                }),
                              ),
                              SizedBox(height: isTablet ? 6 : 4),
                              Text(
                                '$_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'}',
                                style: TextStyle(color: colors.textTertiary, fontSize: reviewCountSize),
                              ),
                            ],
                          ),
                          SizedBox(width: isDesktop ? 32 : isTablet ? 28 : 24),
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingBar('5', _getRatingPercentage(5), colors, isTablet, isDesktop),
                                _buildRatingBar('4', _getRatingPercentage(4), colors, isTablet, isDesktop),
                                _buildRatingBar('3', _getRatingPercentage(3), colors, isTablet, isDesktop),
                                _buildRatingBar('2', _getRatingPercentage(2), colors, isTablet, isDesktop),
                                _buildRatingBar('1', _getRatingPercentage(1), colors, isTablet, isDesktop),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isDesktop ? 28 : isTablet ? 24 : 20),

                    Text(
                      'Recent Reviews',
                      style: TextStyle(
                        fontSize: sectionTitleSize,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: isTablet ? 16 : 12),
                    
                    if (_errorMessage != null && _reviews.isEmpty)
                      _buildErrorState(colors, primaryColor, reviewCountSize)
                    else if (_reviews.isEmpty)
                      _buildEmptyState(colors, primaryColor, sectionTitleSize, reviewCountSize)
                    else
                      ..._reviews.map((review) => _buildReviewCard(review, colors, primaryColor)),
                    
                    if (_currentPage < _lastPage && _reviews.isNotEmpty)
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: padding),
                          child: _isLoadingMore
                              ? CircularProgressIndicator(color: primaryColor)
                              : TextButton(
                                  onPressed: () => _loadReviews(loadMore: true),
                                  child: Text(
                                    'Load More Reviews',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: reviewCountSize,
                                    ),
                                  ),
                                ),
                        ),
                      ),

                    SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),
                  ],
                ),
              ),
            ),
    );
  }
  
  double _getRatingPercentage(int rating) {
    if (_totalReviews == 0) return 0.0;
    return (_ratingDistribution[rating] ?? 0) / _totalReviews;
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
  
  Widget _buildEmptyState(AppColorSet colors, Color primaryColor, double titleSize, double subtitleSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
              'No reviews yet',
              style: TextStyle(
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This user hasn\'t received any reviews yet',
              style: TextStyle(
                fontSize: subtitleSize,
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonInfoCard(
    Map<String, dynamic> person,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 16.0 : 14.0;
    final borderRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final avatarRadius = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 22.0 : 24.0;
    final nameFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final infoFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final iconSize = isDesktop ? 18.0 : isTablet ? 16.0 : 14.0;

    final isFemale = person['gender'] == 'Female';

    return Container(
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.divider),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: avatarRadius,
            backgroundColor: primaryColor.withOpacity(0.2),
            backgroundImage: person['image'] != null && person['image'].toString().isNotEmpty
                ? NetworkImage(person['image'])
                : null,
            onBackgroundImageError: person['image'] != null && person['image'].toString().isNotEmpty
                ? (exception, stackTrace) {}
                : null,
            child: person['image'] == null || person['image'].toString().isEmpty
                ? Icon(
                    isFemale ? Icons.face_3 : Icons.face,
                    size: avatarRadius,
                    color: primaryColor,
                  )
                : null,
          ),
          SizedBox(width: isTablet ? 16 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${person['name']}, ${person['age']}',
                  style: TextStyle(
                    fontSize: nameFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: isTablet ? 6 : 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: iconSize, color: colors.textTertiary),
                    SizedBox(width: 4),
                    Text(
                      person['location'] ?? '',
                      style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 4 : 2),
                Row(
                  children: [
                    Icon(Icons.star, size: iconSize, color: Colors.amber),
                    SizedBox(width: 4),
                    Text(
                      '${_averageRating.toStringAsFixed(1)} ($_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'})',
                      style: TextStyle(fontSize: infoFontSize, color: colors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double value, AppColorSet colors, bool isTablet, bool isDesktop) {
    final labelSize = isDesktop ? 14.0 : isTablet ? 13.0 : 12.0;
    final barHeight = isDesktop ? 8.0 : isTablet ? 7.0 : 6.0;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: isTablet ? 3 : 2),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: labelSize, color: colors.textTertiary)),
          SizedBox(width: isTablet ? 12 : 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(isTablet ? 6 : 4),
              child: LinearProgressIndicator(
                value: value,
                backgroundColor: colors.divider,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: barHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(UserReviewItem review, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final borderRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final avatarRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 18.0;
    final nameFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final dateFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : 11.0;
    final commentFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final starSize = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    
    // FIX: Updated to use UserReviewItem model from UserService.getUserReviews()
    final reviewerName = review.reviewer?.name ?? 'Anonymous';
    final reviewerPhoto = review.reviewer?.profilePicture;
    final rating = review.rating.toInt();
    final comment = review.review ?? '';
    final date = _formatDateFromDateTime(review.createdAt);

    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 16 : 12),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: colors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                              fontSize: nameFontSize,
                            ),
                          )
                        : null,
                  ),
                  SizedBox(width: isTablet ? 14 : 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerName,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          fontSize: nameFontSize,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(fontSize: dateFontSize, color: colors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: starSize,
                  );
                }),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            SizedBox(height: isTablet ? 16 : 12),
            Text(
              comment,
              style: TextStyle(
                color: colors.textSecondary,
                height: 1.4,
                fontSize: commentFontSize,
              ),
            ),
          ],
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
