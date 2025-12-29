import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/base_screen.dart';

/// Person Reviews Screen - Shows rating summary, reviews list, and similar users
/// Extracted from PersonProfileScreen tabs for standalone navigation
class PersonReviewsScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const PersonReviewsScreen({super.key, required this.person});

  @override
  State<PersonReviewsScreen> createState() => _PersonReviewsScreenState();
}

class _PersonReviewsScreenState extends State<PersonReviewsScreen> {
  // Sample reviews data - API se replace karna baad mein
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Amit S.',
      'rating': 5,
      'date': '8 Dec 2024',
      'comment': 'Great conversation and very punctual. Highly recommended!'
    },
    {
      'name': 'Ravi K.',
      'rating': 4,
      'date': '2 Dec 2024',
      'comment': 'Pleasant company, had a wonderful time at dinner.'
    },
    {
      'name': 'Sanjay M.',
      'rating': 5,
      'date': '25 Nov 2024',
      'comment': 'Professional and friendly. Will definitely book again.'
    },
    {
      'name': 'Priya D.',
      'rating': 5,
      'date': '18 Nov 2024',
      'comment': 'Amazing experience! Very polite and engaging.'
    },
    {
      'name': 'Vikram T.',
      'rating': 4,
      'date': '10 Nov 2024',
      'comment': 'Good company for the evening event. Would recommend.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final person = widget.person;

    // Responsive values
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Person Info Header Card
            _buildPersonInfoCard(person, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
            SizedBox(height: isDesktop ? 24 : isTablet ? 20 : 16),

            // Rating Summary Card
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
                        '${person['rating']}',
                        style: TextStyle(
                          fontSize: ratingFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < (person['rating'] as double).floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: starSize,
                          );
                        }),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        '${person['reviews']} reviews',
                        style: TextStyle(color: colors.textTertiary, fontSize: reviewCountSize),
                      ),
                    ],
                  ),
                  SizedBox(width: isDesktop ? 32 : isTablet ? 28 : 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildRatingBar('5', 0.7, colors, isTablet, isDesktop),
                        _buildRatingBar('4', 0.2, colors, isTablet, isDesktop),
                        _buildRatingBar('3', 0.08, colors, isTablet, isDesktop),
                        _buildRatingBar('2', 0.02, colors, isTablet, isDesktop),
                        _buildRatingBar('1', 0.0, colors, isTablet, isDesktop),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isDesktop ? 28 : isTablet ? 24 : 20),

            // Reviews List Section
            Text(
              'Recent Reviews',
              style: TextStyle(
                fontSize: sectionTitleSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            SizedBox(height: isTablet ? 16 : 12),
            ..._reviews.map((review) => _buildReviewCard(review, colors, primaryColor)),

            SizedBox(height: isDesktop ? 32 : isTablet ? 28 : 24),
          ],
        ),
      ),
    );
  }

  /// Person info card header - shows who's reviews we're viewing
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
          // Avatar
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
          // Info
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
                      person['location'],
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
                      '${person['rating']} (${person['reviews']} reviews)',
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

  /// Rating bar for distribution display
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

  /// Individual review card
  Widget _buildReviewCard(Map<String, dynamic> review, AppColorSet colors, Color primaryColor) {
    // Responsive values
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
                    child: Text(
                      review['name'][0],
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: nameFontSize,
                      ),
                    ),
                  ),
                  SizedBox(width: isTablet ? 14 : 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                          fontSize: nameFontSize,
                        ),
                      ),
                      Text(
                        review['date'],
                        style: TextStyle(fontSize: dateFontSize, color: colors.textTertiary),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: starSize,
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            review['comment'],
            style: TextStyle(
              color: colors.textSecondary,
              height: 1.4,
              fontSize: commentFontSize,
            ),
          ),
        ],
      ),
    );
  }

  /// Similar user card for recommendations carousel
}
