import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive spacing
    final sectionSpacing = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final itemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive border radius
    final cardRadius = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 24.0 : 30.0;
    
    // Responsive typography
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
    
    // Responsive icon sizes
    final starIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final smallStarIconSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final replyIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    
    // Responsive avatar size
    final avatarRadius = isDesktop ? 30.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    
    // Responsive rating badge
    final ratingBadgePaddingH = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final ratingBadgePaddingV = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 3.0 : 4.0;
    final ratingBadgeRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    
    // Max width for desktop readability
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'My Reviews',
      showBackButton: true,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: SingleChildScrollView(
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
                _buildReviewItem(
                  name: 'Priya Sharma',
                  date: '10 Dec 2025',
                  rating: 4.5,
                  comment: 'John was very professional and helpful. He provided excellent service and was always on time. Would definitely recommend him for anyone looking for reliable assistance.',
                  profileImage: 'https://randomuser.me/api/portraits/women/44.jpg',
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
                SizedBox(height: itemSpacing),
                Center(
                  child: Text(
                    'More reviews coming soon...',
                    style: TextStyle(
                      fontSize: emptyStateFontSize,
                      color: colors.textTertiary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
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
                '4.5',
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
                      return Icon(
                        index < 4 ? Icons.star : Icons.star_half,
                        color: Colors.amber,
                        size: starIconSize,
                      );
                    }),
                  ),
                  SizedBox(height: itemSpacing * 0.25),
                  Text(
                    'Based on 1 review',
                    style: TextStyle(
                      fontSize: labelFontSize,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: itemSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildRatingCategory(
                label: 'Reliability', 
                rating: 5.0, 
                colors: colors,
                labelFontSize: categoryLabelFontSize,
                ratingFontSize: categoryRatingFontSize,
                starIconSize: smallStarIconSize,
              ),
              _buildRatingCategory(
                label: 'Communication', 
                rating: 4.0, 
                colors: colors,
                labelFontSize: categoryLabelFontSize,
                ratingFontSize: categoryRatingFontSize,
                starIconSize: smallStarIconSize,
              ),
              _buildRatingCategory(
                label: 'Service', 
                rating: 4.5, 
                colors: colors,
                labelFontSize: categoryLabelFontSize,
                ratingFontSize: categoryRatingFontSize,
                starIconSize: smallStarIconSize,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingCategory({
    required String label, 
    required double rating, 
    required AppColorSet colors,
    required double labelFontSize,
    required double ratingFontSize,
    required double starIconSize,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: labelFontSize,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: starIconSize * 0.25),
        Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: starIconSize,
            ),
            SizedBox(width: starIconSize * 0.25),
            Text(
              rating.toString(),
              style: TextStyle(
                fontSize: ratingFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildReviewItem({
    required String name,
    required String date,
    required double rating,
    required String comment,
    required String profileImage,
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
                backgroundImage: NetworkImage(profileImage),
              ),
              SizedBox(width: itemSpacing * 0.75),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
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
                      rating.toString(),
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
          SizedBox(height: itemSpacing * 0.75),
          Text(
            comment,
            style: TextStyle(
              fontSize: commentFontSize,
              color: colors.textSecondary,
            ),
          ),
          SizedBox(height: itemSpacing * 0.75),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {},
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
}