import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../Service/profile_service.dart';
import '../model/getprofilemodel.dart';
import 'book_meeting_screen.dart';
import 'person_bookings_screen.dart';
import 'person_reviews_screen.dart';
import 'user_gallery_screen.dart';
import 'subscription_screen.dart';

class PersonProfileScreen extends StatefulWidget {
  final Map<String, dynamic> person;

  const PersonProfileScreen({super.key, required this.person});

  @override
  State<PersonProfileScreen> createState() => _PersonProfileScreenState();
}

class _PersonProfileScreenState extends State<PersonProfileScreen> {
  GetProfileModel? _userProfile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkCurrentUserSubscription();
  }

  // Fetch the specific user's profile from API
  Future<void> _fetchUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = widget.person['id'] as int;
      final profile = await ProfileService.getUserProfile(userId);
      
      if (profile != null && profile.success == true && profile.data?.user != null) {
        setState(() {
          _userProfile = profile;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load user profile';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Check if current user has active time spending subscription
  Future<void> _checkCurrentUserSubscription() async {
    try {
      // First check from SharedPreferences (cached)
      final prefs = await SharedPreferences.getInstance();
      final cachedSubscription = prefs.getBool('has_active_time_spending_subscription');
      
      if (cachedSubscription != null) {
        setState(() {
          //_hasActiveSubscription = cachedSubscription;
        });
      }

      // Then fetch fresh data from API
      final profile = await ProfileService.getProfile();
      if (profile != null && profile.data?.user != null) {
        final hasSubscription = profile.data!.user!.hasActiveTimeSpendingSubscription ?? false;
        await prefs.setBool('has_active_time_spending_subscription', hasSubscription);
        setState(() {
          //_hasActiveSubscription = hasSubscription;
        });
      }
    } catch (e) {
      print('Error checking subscription: $e');
    }
  }

  // Handle Book Time button tap - navigate directly to booking screen
  void _onBookTimeTap(Map<String, dynamic> person) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookMeetingScreen(person: person),
      ),
    );
  }

  // Show dialog when subscription is required
  void _showSubscriptionRequiredDialog() {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium, color: Colors.amber, size: 28),
            const SizedBox(width: 12),
            Text(
              'Subscription Required',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'You need an active subscription to book time with other users. Would you like to purchase a subscription?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionScreen(),
                ),
              ).then((_) {
                // Refresh subscription status after returning
                _checkCurrentUserSubscription();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Buy Subscription'),
          ),
        ],
      ),
    );
  }

  // Build profile avatar with proper error handling for network images
  Widget _buildProfileAvatar(Map<String, dynamic> person, double avatarRadius, double avatarIconSize) {
    String imageUrl = person['image']?.toString() ?? '';
    final gender = person['gender']?.toString() ?? 'Male';
    final isFemale = gender == 'Female';
    
    // Clean the URL by removing escaped slashes
    if (imageUrl.isNotEmpty) {
      imageUrl = imageUrl.replaceAll(r'\/', '/');
    }
    
    // Default icon when no image
    Widget defaultIcon = Icon(
      isFemale ? Icons.face_3 : Icons.face,
      size: avatarIconSize,
      color: isFemale ? Colors.pink.shade400 : Colors.blue.shade400,
    );
    
    // If no image URL, show default icon
    if (imageUrl.isEmpty) {
      print('Profile Avatar: No image URL provided');
      return CircleAvatar(
        radius: avatarRadius,
        backgroundColor: AppColors.white,
        child: defaultIcon,
      );
    }
    
    print('Profile Avatar: Loading image from: $imageUrl');
    
    // Use Image.network with proper error handling instead of backgroundImage
    return Container(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      child: ClipOval(
        child: Image.network(
          imageUrl,
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
                color: isFemale ? Colors.pink.shade400 : Colors.blue.shade400,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Profile Avatar Error: Failed to load image');
            print('Error: $error');
            print('URL was: $imageUrl');
            return Center(child: defaultIcon);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    // Theme setup
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    // Responsive setup
    Responsive.init(context);

    return BaseScreen(
      title: 'Profile Details',
      showBackButton: true,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48, color: Colors.red),
                      SizedBox(height: 16),
                      Text(_errorMessage!, style: TextStyle(color: colors.textSecondary)),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchUserProfile,
                        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                        child: Text('Retry', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  child: _buildProfileHeader(_userProfile?.data?.user != null ? _mapUserToPersonData(_userProfile!.data!.user!) : person, colors, primaryColor, isDark),
                ),
    );
  }

  Widget _buildProfileHeader(Map<String, dynamic> person, AppColorSet colors, Color primaryColor, bool isDark) {
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final containerMargin = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final headerHeight = isDesktop ? 180.0 : isTablet ? 150.0 : isSmallScreen ? 100.0 : 120.0;
    final avatarRadius = isDesktop ? 60.0 : isTablet ? 50.0 : isSmallScreen ? 32.0 : 40.0;
    final avatarIconSize = isDesktop ? 70.0 : isTablet ? 60.0 : isSmallScreen ? 40.0 : 50.0;
    final borderRadius = isDesktop ? 20.0 : isTablet ? 18.0 : 16.0;
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;

    // Font sizes
    final nameFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 18.0;
    final infoFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final badgeFontSize = isDesktop ? 14.0 : isTablet ? 12.0 : isSmallScreen ? 9.0 : 10.0;
    final iconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final smallIconSize = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;

    return Container(
      margin: EdgeInsets.all(containerMargin),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: isTablet ? 12 : 8,
            offset: Offset(0, isTablet ? 6 : 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Image Section
          Stack(
            children: [
              Container(
                height: headerHeight,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: person['gender'] == 'Female'
                        ? [Colors.pink.shade200, Colors.pink.shade400]
                        : [Colors.blue.shade200, Colors.blue.shade400],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(borderRadius),
                    topRight: Radius.circular(borderRadius),
                  ),
                ),
                child: Center(
                  child: _buildProfileAvatar(person, avatarRadius, avatarIconSize),
                ),
              ),
              // Gender Badge
              Positioned(
                top: isTablet ? 12 : 8,
                left: isTablet ? 12 : 8,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 12 : 8,
                    vertical: isTablet ? 6 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: person['gender'] == 'Female' ? Colors.pink.shade100 : Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(isTablet ? 16 : 12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        person['gender'] == 'Female' ? Icons.female : Icons.male,
                        size: smallIconSize,
                        color: person['gender'] == 'Female' ? Colors.pink.shade600 : Colors.blue.shade600,
                      ),
                      SizedBox(width: isTablet ? 4 : 2),
                      Text(
                        person['gender'],
                        style: TextStyle(
                          fontSize: badgeFontSize,
                          fontWeight: FontWeight.bold,
                          color: person['gender'] == 'Female' ? Colors.pink.shade600 : Colors.blue.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Online Badge
              if (person['isOnline'] == true)
                Positioned(
                  top: isTablet ? 12 : 8,
                  right: isTablet ? 12 : 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isTablet ? 10 : 6,
                      vertical: isTablet ? 5 : 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(isTablet ? 14 : 10),
                    ),
                    child: Text(
                      'Online',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isDesktop ? 12.0 : isTablet ? 11.0 : isSmallScreen ? 8.0 : 9.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          // Info Section
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name & Age
                Row(
                  children: [
                    Text(
                      '${person['name']}, ${person['age']}',
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 12 : 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: iconSize, color: colors.textTertiary),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      person['location'],
                      style: TextStyle(fontSize: infoFontSize, color: colors.textTertiary),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 6 : 4),

                // Age
                Row(
                  children: [
                    Icon(Icons.cake, size: iconSize, color: colors.textTertiary),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      'Age: ${person['age']} years',
                      style: TextStyle(fontSize: infoFontSize, color: colors.textTertiary),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 16 : 12),

                // Rating & Price
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.star, size: isTablet ? 18 : 14, color: Colors.amber),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            '${person['rating']}',
                            style: TextStyle(
                              fontSize: isDesktop ? 14.0 : isTablet ? 13.0 : 12.0,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          SizedBox(width: isTablet ? 6 : 4),
                          Text(
                            '(${person['reviews']})',
                            style: TextStyle(
                              fontSize: isDesktop ? 14.0 : isTablet ? 13.0 : 12.0,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isTablet ? 12 : 8),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 12 : 8,
                        vertical: isTablet ? 6 : 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                        border: Border.all(color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.currency_rupee, size: isTablet ? 18 : 14, color: AppColors.success),
                          Text(
                            '${person['price']}/hr',
                            style: TextStyle(
                              fontSize: isDesktop ? 14.0 : isTablet ? 13.0 : 12.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: isTablet ? 20 : 16),

                // Interests & Hobbies - Only show if user has enabled it in privacy settings
                if (person['showInterestsHobbies'] ?? true) ...[
                  _buildInfoSection('Interests & Hobbies', person['hobbies'], primaryColor, colors),
                  SizedBox(height: isTablet ? 16 : 12),
                ],

                // Expectations - Only show if user has enabled it in privacy settings
                if (person['showExpectations'] ?? true) ...[
                  _buildInfoSection('Expectations', person['expectations'], Colors.orange, colors),
                  SizedBox(height: isTablet ? 20 : 16),
                ],

                // Gallery Preview - Only show if user has enabled it in privacy settings
                if (person['showGalleryImages'] ?? true) ...[
                  _buildGalleryPreview(person, colors, primaryColor),
                  SizedBox(height: isTablet ? 24 : 20),
                ],

                // 3 Action Buttons - Vertically stacked
                _buildActionButtons(person, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Action Buttons - Book Time (if enabled), My Bookings, Reviews
  Widget _buildActionButtons(
    Map<String, dynamic> person,
    AppColorSet colors,
    Color primaryColor,
    bool isDark,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final buttonIconSize = isTablet ? 22.0 : 18.0;
    final buttonPadding = isTablet ? 16.0 : 12.0;
    final buttonBorderRadius = isTablet ? 16.0 : 12.0;
    final buttonSpacing = isTablet ? 12.0 : 10.0;

    // Check if user has time spending enabled
    final bool isTimeSpendingEnabled = person['isTimeSpendingEnabled'] ?? false;
    final String hourlyRate = person['hourlyRate']?.toString() ?? '0';

    return Column(
      children: [
        // Book Time Button - Only show if time spending is enabled
        if (isTimeSpendingEnabled) ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                _onBookTimeTap(person);
              },
              icon: Icon(Icons.access_time_filled, size: buttonIconSize),
              label: Text(
                'Book Time  •  ₹$hourlyRate/hr',
                style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                padding: EdgeInsets.symmetric(vertical: buttonPadding),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonBorderRadius),
                ),
              ),
            ),
          ),
          SizedBox(height: buttonSpacing),
        ],

        // My Bookings & Reviews Buttons - Row
        Row(
          children: [
            // My Bookings Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonBookingsScreen(person: person),
                    ),
                  );
                },
                icon: Icon(Icons.history, size: buttonIconSize, color: primaryColor),
                label: Text(
                  'My Bookings',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    color: primaryColor,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  side: BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
              ),
            ),
            SizedBox(width: buttonSpacing),

            // Reviews Button
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PersonReviewsScreen(person: person),
                    ),
                  );
                },
                icon: Icon(Icons.star_outline, size: buttonIconSize, color: Colors.amber.shade700),
                label: Text(
                  'Reviews',
                  style: TextStyle(
                    fontSize: buttonFontSize,
                    color: Colors.amber.shade700,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: buttonPadding),
                  side: BorderSide(color: Colors.amber.shade700),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(buttonBorderRadius),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: buttonSpacing),

        // Report Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showReportDialog(person),
            icon: Icon(Icons.flag, size: buttonIconSize, color: AppColors.error),
            label: Text(
              'Report User',
              style: TextStyle(
                color: AppColors.error,
                fontSize: buttonFontSize,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<dynamic> items, Color color, AppColorSet colors) {
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final titleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    final chipFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final chipPaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final chipPaddingV = isDesktop ? 8.0 : isTablet ? 7.0 : 6.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: isTablet ? 12 : 8),
        Wrap(
          spacing: isTablet ? 12 : 8,
          runSpacing: isTablet ? 12 : 8,
          children: items.map<Widget>((item) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: chipPaddingH, vertical: chipPaddingV),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(isTablet ? 24 : 20),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Text(
                item,
                style: TextStyle(
                  fontSize: chipFontSize,
                  color: color.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGalleryPreview(Map<String, dynamic> person, AppColorSet colors, Color primaryColor) {
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final titleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    final galleryHeight = isDesktop ? 140.0 : isTablet ? 120.0 : isSmallScreen ? 70.0 : 90.0;
    final galleryItemWidth = isDesktop ? 140.0 : isTablet ? 120.0 : isSmallScreen ? 70.0 : 90.0;
    final borderRadius = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final iconSize = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 24.0 : 30.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gallery',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserGalleryScreen(person: person),
                  ),
                );
              },
              child: Text(
                'View All',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: isDesktop ? 14.0 : isTablet ? 13.0 : 12.0,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: isTablet ? 12 : 8),
        SizedBox(
          height: galleryHeight,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: (person['gallery'] as List).length,
            itemBuilder: (context, index) {
              final galleryList = person['gallery'] as List;
              String imageUrl = galleryList[index]?.toString() ?? '';
              
              // Clean the URL by removing escaped slashes
              if (imageUrl.isNotEmpty) {
                imageUrl = imageUrl.replaceAll(r'\/', '/');
              }
              
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => UserGalleryScreen(person: person),
                    ),
                  );
                },
                child: Container(
                  width: galleryItemWidth,
                  margin: EdgeInsets.only(right: isTablet ? 12 : 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(color: primaryColor.withOpacity(0.3)),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(borderRadius),
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.broken_image,
                                  size: iconSize,
                                  color: primaryColor.withOpacity(0.5),
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
                                  strokeWidth: 2,
                                  color: primaryColor,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image,
                              size: iconSize,
                              color: primaryColor.withOpacity(0.5),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Helper method to convert User model to person map format
  Map<String, dynamic> _mapUserToPersonData(User user) {
    // Parse interests and expectations from the user model
    List<String> interestsList = [];
    List<String> expectationsList = [];
    
    // Parse interests - can be a string or list
    if (user.interests != null) {
      if (user.interests is String) {
        final interestsStr = user.interests.toString();
        if (interestsStr.isNotEmpty) {
          // Try to parse as JSON if it looks like an array
          if (interestsStr.startsWith('[') && interestsStr.endsWith(']')) {
            try {
              final parsed = jsonDecode(interestsStr);
              if (parsed is List) {
                interestsList = parsed.cast<String>();
              }
            } catch (e) {
              // If JSON parsing fails, treat as comma-separated string
              interestsList = interestsStr.split(',').map((e) => e.trim()).toList();
            }
          } else {
            // Comma-separated string
            interestsList = interestsStr.split(',').map((e) => e.trim()).toList();
          }
        }
      } else if (user.interests is List) {
        interestsList = List<String>.from(user.interests);
      }
    }
    
    // Parse expectations - assuming it's stored in expectation field
    if (user.expectation != null) {
      if (user.expectation is String) {
        final expectationStr = user.expectation.toString();
        if (expectationStr.isNotEmpty) {
          // Try to parse as JSON if it looks like an array
          if (expectationStr.startsWith('[') && expectationStr.endsWith(']')) {
            try {
              final parsed = jsonDecode(expectationStr);
              if (parsed is List) {
                expectationsList = parsed.cast<String>();
              }
            } catch (e) {
              // If JSON parsing fails, treat as comma-separated string
              expectationsList = expectationStr.split(',').map((e) => e.trim()).toList();
            }
          } else {
            // Comma-separated string
            expectationsList = expectationStr.split(',').map((e) => e.trim()).toList();
          }
        }
      } else if (user.expectation is List) {
        expectationsList = List<String>.from(user.expectation);
      }
    }
    
    // Helper to get full image URL - handles various URL formats
    String getFullImageUrl(dynamic url) {
      if (url == null) return '';
      String urlStr = url.toString().trim();
      if (urlStr.isEmpty) return '';
      
      // Remove escaped slashes (e.g., https:\/\/ -> https://)
      urlStr = urlStr.replaceAll(r'\/', '/');
      
      // Already a full URL
      if (urlStr.startsWith('http://') || urlStr.startsWith('https://')) {
        return urlStr;
      }
      
      // Relative path - add base URL (without /api/v1)
      const baseImageUrl = 'https://settingwala.com';
      if (urlStr.startsWith('/')) {
        return '$baseImageUrl$urlStr';
      }
      return '$baseImageUrl/$urlStr';
    }
    
    // Get the best available profile image URL
    // Priority: profilePictureUrl > profilePicture
    String profileImageUrl = '';
    
    // Debug: Print raw values from API
    print('=== DEBUG: Profile Image URL Construction ===');
    print('Raw profilePictureUrl: ${user.profilePictureUrl}');
    print('Raw profilePictureUrl type: ${user.profilePictureUrl?.runtimeType}');
    print('Raw profilePicture: ${user.profilePicture}');
    print('Raw profilePicture type: ${user.profilePicture?.runtimeType}');
    
    if (user.profilePictureUrl != null && user.profilePictureUrl.toString().trim().isNotEmpty) {
      profileImageUrl = getFullImageUrl(user.profilePictureUrl);
      print('Using profilePictureUrl: $profileImageUrl');
    } else if (user.profilePicture != null && user.profilePicture.toString().trim().isNotEmpty) {
      profileImageUrl = getFullImageUrl(user.profilePicture);
      print('Using profilePicture: $profileImageUrl');
    } else {
      print('No profile image available');
    }
    
    print('Final profileImageUrl: $profileImageUrl');
    print('============================================');
    
    return {
      'id': user.id,
      'name': user.name ?? 'Unknown',
      'age': (user.age ?? 0).toInt(),
      'location': '${user.city ?? ''}, ${user.state ?? ''}'.trim(),
      'bio': 'No bio available', // bio is not available in getprofilemodel User
      'gender': user.gender ?? 'Unknown',
      'price': 0, // price is not available in getprofilemodel User
      'rating': 4.5,
      'reviews': 0,
      'isOnline': false, // isOnline is not available in getprofilemodel User
      'hobbies': interestsList, // Use the parsed interests
      'expectations': expectationsList, // Use the parsed expectations
      'gallery': _userProfile?.data?.gallery != null 
          ? (_userProfile!.data!.gallery as List).map((e) => getFullImageUrl(e.toString())).toList() 
          : [],
      'image': profileImageUrl,
      'isVerified': false, // isVerified is not available in getprofilemodel User
      'galleryCount': 0, // galleryCount is not available in getprofilemodel User
      // Time Spending fields
      'isTimeSpendingEnabled': user.isTimeSpendingEnabled,
      'hourlyRate': user.hourlyRate?.toString() ?? '0',
      'timeSpendingServices': null, // timeSpendingServices is not available in getprofilemodel User
      'timeSpendingDescription': null, // timeSpendingDescription is not available in getprofilemodel User
      // Additional profile fields
      'showInterestsHobbies': user.showInterestsHobbies,
      'showExpectations': user.showExpectations,
    };
  }

  void _showReportDialog(Map<String, dynamic> person) {
    final colors = context.colors;

    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : 18.0;
    final contentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isTablet ? 20 : 16),
        ),
        title: Text(
          'Report ${person['name']}',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: titleFontSize,
          ),
        ),
        content: Text(
          'Are you sure you want to report this user? This action will be reviewed by our team.',
          style: TextStyle(
            color: colors.textSecondary,
            fontSize: contentFontSize,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: colors.textTertiary,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Report submitted for ${person['name']}'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
              ),
            ),
            child: Text(
              'Report',
              style: TextStyle(fontSize: buttonFontSize),
            ),
          ),
        ],
      ),
    );
  }
}