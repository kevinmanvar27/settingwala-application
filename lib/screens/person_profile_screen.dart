import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:settingwala/utils/api_constants.dart';
import 'package:intl/intl.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../Service/profile_service.dart';
import '../Service/user_service.dart';
import '../Service/booking_service.dart';
import '../model/getprofilemodel.dart';
import '../model/postbookingsmodel.dart';
import '../routes/app_routes.dart';

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
  
  // Past bookings state
  List<BookingData> _pastBookings = [];
  bool _isLoadingPastBookings = false;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _checkCurrentUserSubscription();
    _loadPastBookings(); // Load past bookings with this person
  }

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

  // Load past bookings with this person - calls GET /bookings API
  Future<void> _loadPastBookings() async {
    final personId = widget.person['id'];
    if (personId == null) return;

    setState(() {
      _isLoadingPastBookings = true;
    });

    try {
      final response = await BookingService.getBookings();
      if (response != null && response.success == true && response.bookings.isNotEmpty) {
        // Filter bookings with this specific person
        final bookingsWithPerson = response.bookings.where((booking) {
          // Check if other_user matches the person we're viewing
          final otherUserId = booking.otherUser?.id;
          return otherUserId == personId;
        }).toList();

        // Filter for completed/confirmed bookings (past bookings)
        final pastBookings = bookingsWithPerson.where((booking) {
          final status = booking.status.toLowerCase();
          return status == 'completed' || status == 'confirmed';
        }).toList();

        // Sort by date (newest first)
        pastBookings.sort((a, b) {
          final dateA = DateTime.tryParse(a.bookingDate ?? '') ?? DateTime(1900);
          final dateB = DateTime.tryParse(b.bookingDate ?? '') ?? DateTime(1900);
          return dateB.compareTo(dateA);
        });

        setState(() {
          _pastBookings = pastBookings.take(5).toList(); // Show last 5 bookings
          _isLoadingPastBookings = false;
        });
      } else {
        setState(() {
          _isLoadingPastBookings = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingPastBookings = false;
      });
    }
  }

  Future<void> _checkCurrentUserSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedSubscription = prefs.getBool('has_active_time_spending_subscription');
      
      if (cachedSubscription != null) {
        setState(() {
        });

      }

      final profile = await ProfileService.getProfile();
      if (profile != null && profile.data?.user != null) {
        final hasSubscription = profile.data!.user!.hasActiveTimeSpendingSubscription ?? false;
        await prefs.setBool('has_active_time_spending_subscription', hasSubscription);
        setState(() {
        });
      }
    } catch (e) {
    }
  }

  void _onBookTimeTap(Map<String, dynamic> person) async {
    AppRoutes.toBookMeeting(context, person);
  }

  // Navigate to reviews screen - calls GET /users/{id}/reviews API
  void _onViewReviewsTap(Map<String, dynamic> person) {
    Navigator.pushNamed(
      context,
      AppRoutes.personReviews,
      arguments: person,
    );
  }

  // Navigate to bookings screen - calls GET /bookings API and filters by person
  void _onViewBookingsTap(Map<String, dynamic> person) {
    Navigator.pushNamed(
      context,
      AppRoutes.personBookings,
      arguments: person,
    );
  }

  // Format date of birth based on privacy settings
  String _formatDateOfBirth(dynamic dateOfBirth, bool hideDobYear) {
    if (dateOfBirth == null) return '';
    
    try {
      DateTime dob;
      if (dateOfBirth is DateTime) {
        dob = dateOfBirth;
      } else if (dateOfBirth is String && dateOfBirth.isNotEmpty) {
        dob = DateTime.parse(dateOfBirth);
      } else {
        return '';
      }
      
      // If user wants to hide year, show only month and day
      if (hideDobYear) {
        return DateFormat('MMMM d').format(dob); // e.g., "January 5"
      } else {
        return DateFormat('MMMM d, yyyy').format(dob); // e.g., "January 5, 1990"
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildProfileAvatar(Map<String, dynamic> person, double avatarRadius, double avatarIconSize) {
    String imageUrl = person['image']?.toString() ?? '';
    final gender = person['gender']?.toString() ?? 'Male';
    final isFemale = gender == 'Female';
    
    if (imageUrl.isNotEmpty) {
      imageUrl = imageUrl.replaceAll(r'\/', '/');
    }
    
    Widget defaultIcon = Icon(
      isFemale ? Icons.face_3 : Icons.face,
      size: avatarIconSize,
      color: isFemale ? Colors.pink.shade400 : Colors.blue.shade400,
    );
    
    if (imageUrl.isEmpty) {
      
      return CircleAvatar(
        radius: avatarRadius,
        backgroundColor: AppColors.white,
        child: defaultIcon,
      );
    }
    
    
    return Container(
      width: avatarRadius * 2,
      height: avatarRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      child: ClipOval(
        child: CachedImage(
          imageUrl: imageUrl,
          width: avatarRadius * 2,
          height: avatarRadius * 2,
          fit: BoxFit.cover,
          placeholder: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: isFemale ? Colors.pink.shade400 : Colors.blue.shade400,
            ),
          ),
          errorWidget: Center(child: defaultIcon),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final person = widget.person;
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

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
          Padding(
            padding: EdgeInsets.all(contentPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      person['age'] != null && person['age'] != 0 
                          ? '${person['name']}, ${person['age']}'
                          : '${person['name']}',
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isTablet ? 12 : 8),

                // Only show location row if location is not empty
                if (person['location'] != null && person['location'].toString().isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.location_on, size: iconSize, color: colors.textTertiary),
                      SizedBox(width: isTablet ? 6 : 4),
                      Expanded(
                        child: Text(
                          person['location'],
                          style: TextStyle(fontSize: infoFontSize, color: colors.textTertiary),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                ],

                // Show date of birth if user allows it
                if (person['showDateOfBirth'] == true && person['dateOfBirth'] != null) ...[
                  Row(
                    children: [
                      Icon(Icons.cake_outlined, size: iconSize, color: colors.textTertiary),
                      SizedBox(width: isTablet ? 6 : 4),
                      Text(
                        _formatDateOfBirth(person['dateOfBirth'], person['hideDobYear'] ?? false),
                        style: TextStyle(fontSize: infoFontSize, color: colors.textTertiary),
                      ),
                    ],
                  ),
                  SizedBox(height: isTablet ? 12 : 8),
                ],

                Row(
                  children: [
                    // Tappable rating section - navigates to reviews screen
                    GestureDetector(
                      onTap: () => _onViewReviewsTap(person),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 12 : 8,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
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
                            SizedBox(width: isTablet ? 4 : 2),
                            Icon(Icons.chevron_right, size: isTablet ? 16 : 12, color: colors.textTertiary),
                          ],
                        ),
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

                if (person['age'] != null && person['age'] != 0)
                  _buildDetailRow(Icons.cake, 'Age', '${person['age']}', colors, infoFontSize, iconSize),
                SizedBox(height: isTablet ? 8 : 6),

                if (person['serviceLocation'] != null && person['serviceLocation'].toString().isNotEmpty) ...[
                  _buildDetailRow(Icons.home_work, 'Service Location', person['serviceLocation'].toString(), colors, infoFontSize, iconSize),
                  SizedBox(height: isTablet ? 8 : 6),
                ],

                SizedBox(height: isTablet ? 12 : 8),

                if ((person['showInterestsHobbies'] ?? true) && (person['hobbies'] as List).isNotEmpty) ...[
                  _buildInfoSection('Interests & Hobbies', person['hobbies'], primaryColor, colors),
                  SizedBox(height: isTablet ? 16 : 12),
                ],

                if ((person['expectations'] as List).isNotEmpty) ...[
                  _buildInfoSection('Expectations', person['expectations'], Colors.orange, colors),
                  SizedBox(height: isTablet ? 20 : 16),
                ],

                if ((person['showGalleryImages'] ?? true) && (person['gallery'] as List).isNotEmpty) ...[
                  _buildGalleryPreview(person, colors, primaryColor),
                  SizedBox(height: isTablet ? 24 : 20),
                ],

                _buildActionButtons(person, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
              ],
            ),
          ),
        ],
      ),
    );
  }

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

    final bool isTimeSpendingEnabled = person['isTimeSpendingEnabled'] ?? false;
    final String hourlyRate = person['hourlyRate']?.toString() ?? '0';

    return Column(
      children: [
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

        // View Reviews Button - calls GET /users/{id}/reviews API
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _onViewReviewsTap(person),
            icon: Icon(Icons.star_rate, size: buttonIconSize, color: Colors.amber),
            label: Text(
              'View Reviews (${person['reviews'] ?? 0})',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: buttonFontSize,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
              side: BorderSide(color: Colors.amber.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
          ),
        ),
        SizedBox(height: buttonSpacing),

        // View Bookings Button - calls GET /bookings API filtered by person
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _onViewBookingsTap(person),
            icon: Icon(Icons.calendar_month, size: buttonIconSize, color: Colors.blue),
            label: Text(
              'View Bookings',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: buttonFontSize,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
              side: BorderSide(color: Colors.blue.withOpacity(0.5)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonBorderRadius),
              ),
            ),
          ),
        ),
        SizedBox(height: buttonSpacing),

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
        
        // Past Bookings Section - shows completed/confirmed bookings with this person
        SizedBox(height: buttonSpacing * 2),
        _buildPastBookingsSection(person, colors, buttonFontSize, buttonIconSize),
      ],
    );
  }

  // Build Past Bookings section showing recent bookings with this person
  Widget _buildPastBookingsSection(Map<String, dynamic> person, AppColorSet colors, double fontSize, double iconSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final titleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    final cardPadding = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;
    final spacing = isDesktop ? 12.0 : isTablet ? 10.0 : 8.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.history, size: iconSize, color: Colors.teal),
                SizedBox(width: spacing),
                Text(
                  'Past Bookings',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
            if (_pastBookings.isNotEmpty)
              TextButton(
                onPressed: () => _onViewBookingsTap(person),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: Colors.teal,
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: spacing),

        // Loading state
        if (_isLoadingPastBookings)
          Center(
            child: Padding(
              padding: EdgeInsets.all(cardPadding),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.teal,
              ),
            ),
          )
        // Empty state
        else if (_pastBookings.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(cardPadding),
            decoration: BoxDecoration(
              color: colors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.cardBorder.withOpacity(0.5)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.event_busy,
                  size: iconSize * 2,
                  color: colors.textTertiary,
                ),
                SizedBox(height: spacing),
                Text(
                  'No past bookings with this person',
                  style: TextStyle(
                    fontSize: fontSize,
                    color: colors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        // Bookings list
        else
          Column(
            children: _pastBookings.map((booking) {
              return _buildPastBookingCard(booking, colors, fontSize, cardPadding, spacing);
            }).toList(),
          ),
      ],
    );
  }

  // Build individual past booking card
  Widget _buildPastBookingCard(BookingData booking, AppColorSet colors, double fontSize, double padding, double spacing) {
    final bookingDate = booking.bookingDate ?? '';
    final status = booking.status;
    final duration = booking.durationHours ?? '0';
    final location = booking.meetingLocation ?? 'Not specified';
    final totalAmount = booking.totalAmount ?? '0';
    final paymentStatus = booking.paymentStatus ?? 'unknown';

    // Format date
    String formattedDate = bookingDate;
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      // Keep original format if parsing fails
    }

    // Status color
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'confirmed':
        statusColor = Colors.blue;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => _showBookingDetails(booking),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: spacing),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: colors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.cardBorder.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and Status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: fontSize, color: colors.textTertiary),
                    SizedBox(width: spacing / 2),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      fontSize: fontSize * 0.8,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),

            // Duration and Location
            Row(
              children: [
                Icon(Icons.access_time, size: fontSize * 0.9, color: colors.textTertiary),
                SizedBox(width: spacing / 2),
                Text(
                  '$duration hour(s)',
                  style: TextStyle(
                    fontSize: fontSize * 0.9,
                    color: colors.textSecondary,
                  ),
                ),
                SizedBox(width: spacing * 2),
                Icon(Icons.location_on, size: fontSize * 0.9, color: colors.textTertiary),
                SizedBox(width: spacing / 2),
                Expanded(
                  child: Text(
                    location,
                    style: TextStyle(
                      fontSize: fontSize * 0.9,
                      color: colors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: spacing),

            // Amount and Payment Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '₹ $totalAmount',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                Text(
                  paymentStatus.replaceAll('_', ' ').toUpperCase(),
                  style: TextStyle(
                    fontSize: fontSize * 0.8,
                    color: paymentStatus.toLowerCase() == 'paid' ? Colors.green : Colors.orange,
                  ),
                ),
              ],
            ),

            // Tap hint
            SizedBox(height: spacing / 2),
            Center(
              child: Text(
                'Tap for details',
                style: TextStyle(
                  fontSize: fontSize * 0.75,
                  color: colors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show booking details in a bottom sheet
  void _showBookingDetails(BookingData booking) async {
    final colors = AppColorUtils.getColorSet(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final fontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final padding = isDesktop ? 24.0 : isTablet ? 20.0 : 16.0;
    final spacing = isDesktop ? 16.0 : isTablet ? 14.0 : 12.0;

    // Format booking details
    final bookingDate = booking.bookingDate ?? '';
    String formattedDate = bookingDate;
    try {
      final date = DateTime.parse(bookingDate);
      formattedDate = '${date.day}/${date.month}/${date.year}';
    } catch (e) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colors.textTertiary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),

                  // Title
                  Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: titleFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: spacing * 1.5),

                  // Booking ID
                  _buildDetailItem('Booking ID', '#${booking.id}', Icons.tag, colors, fontSize, spacing),
                  
                  // Date
                  _buildDetailItem('Date', formattedDate, Icons.calendar_today, colors, fontSize, spacing),
                  
                  // Duration
                  _buildDetailItem('Duration', '${booking.durationHours ?? '0'} hour(s)', Icons.access_time, colors, fontSize, spacing),
                  
                  // Location
                  _buildDetailItem('Location', booking.meetingLocation ?? 'Not specified', Icons.location_on, colors, fontSize, spacing),
                  
                  // Status
                  _buildDetailItem('Status', booking.status.toUpperCase(), Icons.info_outline, colors, fontSize, spacing),
                  
                  // Hourly Rate
                  _buildDetailItem('Hourly Rate', '₹ ${booking.hourlyRate ?? '0'}', Icons.monetization_on, colors, fontSize, spacing),
                  
                  // Total Amount
                  _buildDetailItem('Total Amount', '₹ ${booking.totalAmount ?? '0'}', Icons.account_balance_wallet, colors, fontSize, spacing),
                  
                  // Payment Status
                  _buildDetailItem('Payment Status', (booking.paymentStatus ?? 'Unknown').replaceAll('_', ' ').toUpperCase(), Icons.payment, colors, fontSize, spacing),
                  
                  // Notes (if any)
                  if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                    SizedBox(height: spacing),
                    Text(
                      'Notes',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: spacing / 2),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(padding * 0.75),
                      decoration: BoxDecoration(
                        color: colors.cardBorder.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        booking.notes!,
                        style: TextStyle(
                          fontSize: fontSize,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],

                  SizedBox(height: spacing * 2),

                  // Close button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: padding * 0.75),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontSize: fontSize,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: spacing),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Helper widget for detail items in bottom sheet
  Widget _buildDetailItem(String label, String value, IconData icon, AppColorSet colors, double fontSize, double spacing) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: fontSize * 1.2, color: colors.textTertiary),
          SizedBox(width: spacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: fontSize * 0.85,
                    color: colors.textTertiary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, AppColorSet colors, double fontSize, double iconSize) {
    return Row(
      children: [
        Icon(icon, size: iconSize, color: colors.textTertiary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: colors.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(String title, List<dynamic> items, Color color, AppColorSet colors) {
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
                AppRoutes.toUserGallery(context, person);
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
              
              if (imageUrl.isNotEmpty) {
                imageUrl = imageUrl.replaceAll(r'\/', '/');
              }
              
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                imageUrl = ApiConstants.getStorageUrl(imageUrl);
              }
              
              return GestureDetector(
                onTap: () {
                  AppRoutes.toUserGallery(context, person);
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
                        ? CachedImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: primaryColor,
                              ),
                            ),
                            errorWidget: Center(
                              child: Icon(
                                Icons.broken_image,
                                size: iconSize,
                                color: primaryColor.withOpacity(0.5),
                              ),
                            ),
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

  Map<String, dynamic> _mapUserToPersonData(User user) {
    String getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      String cleanUrl = url.replaceAll(r'\/', '/');
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        return cleanUrl;
      }
      return ApiConstants.getStorageUrl(cleanUrl);
    }
    
    List<String> processGalleryImages(List<dynamic>? galleryData) {
      if (galleryData == null || galleryData.isEmpty) return [];
      
      List<String> processedImages = [];
      for (var item in galleryData) {
        String? imageUrl;
        
        if (item is String) {
          imageUrl = item;
        } else if (item is Map) {
          imageUrl = item['url'] ?? item['image_url'] ?? item['image'] ?? item['path'];
        }
        
        if (imageUrl != null && imageUrl.isNotEmpty) {
          if (!imageUrl.startsWith('http')) {
            imageUrl = ApiConstants.getStorageUrl(imageUrl);
          }
          processedImages.add(imageUrl);
        }
      }
      
      return processedImages;
    }
    
    String buildLocation() {
      List<String> locationParts = [];
      
      if (user.city != null && user.city.toString().isNotEmpty) {
        locationParts.add(user.city.toString());
      }
      if (user.state != null && user.state.toString().isNotEmpty) {
        locationParts.add(user.state.toString());
      }
      if (user.country != null && user.country.toString().isNotEmpty) {
        locationParts.add(user.country.toString());
      }
      
      // Return empty string if no location parts - UI will hide the row
      return locationParts.join(', ');
    }
    
    List<String> processExpectations() {
      List<String> expectations = [];
      
      if (user.expectation != null) {
        if (user.expectation is List) {
          for (var item in user.expectation) {
            if (item != null && item.toString().isNotEmpty) {
              expectations.add(item.toString());
            }
          }
        } else if (user.expectation.toString().isNotEmpty) {
          expectations.add(user.expectation.toString());
        }
      }
      
      return expectations;
    }
    
    // Helper function to clean individual interest item
    String cleanInterestItem(String item) {
      String cleaned = item.trim();
      // Remove surrounding brackets and quotes
      cleaned = cleaned.replaceAll(RegExp(r'^\[|\]$'), '');
      cleaned = cleaned.replaceAll(RegExp(r'^"|"$'), '');
      cleaned = cleaned.replaceAll(RegExp(r"^'|'$"), '');
      return cleaned.trim();
    }
    
    // Helper function to parse interests string (JSON array format)
    List<String> parseInterestsString(String str) {
      List<String> result = [];
      str = str.trim();
      
      // Check if it's a JSON array format like ["developer"] or ["item1", "item2"]
      if (str.startsWith('[') && str.endsWith(']')) {
        // Remove outer brackets
        str = str.substring(1, str.length - 1).trim();
        
        // Split by comma and clean each item
        List<String> parts = str.split(',');
        for (var part in parts) {
          String cleaned = part.trim();
          // Remove quotes
          cleaned = cleaned.replaceAll(RegExp(r'^"|"$'), '');
          cleaned = cleaned.replaceAll(RegExp(r"^'|'$"), '');
          if (cleaned.isNotEmpty) {
            result.add(cleaned);
          }
        }
      } else if (str.isNotEmpty) {
        // Not a JSON array, just add as single item
        result.add(str);
      }
      
      return result;
    }
    
    List<String> processInterests() {
      List<String> interests = [];
      
      if (user.interests != null) {
        if (user.interests is List) {
          for (var item in user.interests) {
            if (item != null && item.toString().isNotEmpty) {
              // Clean up the item - remove brackets, quotes
              String cleaned = cleanInterestItem(item.toString());
              if (cleaned.isNotEmpty) {
                interests.add(cleaned);
              }
            }
          }
        } else if (user.interests.toString().isNotEmpty) {
          // Try to parse as JSON string array first
          String interestStr = user.interests.toString();
          interests = parseInterestsString(interestStr);
        }
      }
      
      return interests;
    }

    String getBio() {
      if (user.iAm != null && user.iAm.toString().isNotEmpty) {
        return user.iAm.toString();
      }
      if (user.iWant != null && user.iWant.toString().isNotEmpty) {
        return user.iWant.toString();
      }
      return 'No bio available';
    }

    return {
      'id': user.id,
      'name': user.name ?? '',
      'email': user.email,
      'age': user.age ?? 0,
      'location': buildLocation(),
      'bio': getBio(),
      'gender': user.gender ?? 'Female',
      'isVerified': false,
      'isOnline': false,
      'isTimeSpendingEnabled': user.isTimeSpendingEnabled ?? false,
      'hourlyRate': user.hourlyRate ?? '0',
      'price': double.tryParse(user.hourlyRate?.toString() ?? '0') ?? 0,
      'rating': 4.5,
      'reviews': 0,
      'serviceLocation': user.serviceLocation,
      'hobbies': processInterests(),
      'expectations': processExpectations(),
      'image': getFullImageUrl(user.profilePictureUrl ?? user.profilePicture),
      'gallery': processGalleryImages(_userProfile?.data?.gallery),
      'showInterestsHobbies': user.showInterestsHobbies ?? true,
      'showExpectations': user.showExpectations ?? true,
      'showGalleryImages': user.showGalleryImages ?? true,
      'galleryCount': _userProfile?.data?.gallery?.length ?? 0,
      'timeSpendingServices': [],
      'timeSpendingDescription': '',
      'dateOfBirth': user.dateOfBirth,
      'showDateOfBirth': user.showDateOfBirth ?? true,
      'hideDobYear': user.hideDobYear ?? false,
    };
  }

  void _showReportDialog(Map<String, dynamic> person) {
    final colors = context.colors;

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : 18.0;
    final contentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : 14.0;

    String? selectedReason;
    final descriptionController = TextEditingController();
    bool isSubmitting = false;

    // Map display reasons to API reason values (snake_case as per API docs)
    final reportReasons = {
      'Inappropriate Behavior': 'inappropriate_behavior',
      'Spam or Scam': 'spam_or_scam',
      'Fake Profile': 'fake_profile',
      'Harassment or Bullying': 'harassment',
      'Other': 'other',
    };

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
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
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Please select a reason for reporting:',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: contentFontSize,
                  ),
                ),
                const SizedBox(height: 16),
                ...reportReasons.keys.map((reason) => RadioListTile<String>(
                  title: Text(
                    reason,
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: contentFontSize,
                    ),
                  ),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: isSubmitting ? null : (value) {
                    setDialogState(() {
                      selectedReason = value;
                    });
                  },
                  activeColor: AppColors.error,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                )),
                const SizedBox(height: 16),
                Text(
                  'Description (optional):',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: contentFontSize,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: descriptionController,
                  enabled: !isSubmitting,
                  maxLines: 3,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: contentFontSize,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Provide more details about the issue...',
                    hintStyle: TextStyle(
                      color: colors.textTertiary,
                      fontSize: contentFontSize,
                    ),
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
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: colors.textTertiary,
                  fontSize: buttonFontSize,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: (selectedReason == null || isSubmitting)
                  ? null
                  : () async {
                      setDialogState(() {
                        isSubmitting = true;
                      });

                      final userId = person['id'];
                      if (userId == null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Error: User ID not found'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Call POST /users/{id}/report API
                      final response = await UserService.reportUser(
                        userId: userId is int ? userId : int.parse(userId.toString()),
                        reason: reportReasons[selectedReason]!,
                        description: descriptionController.text.trim().isEmpty 
                            ? 'No additional details provided.'
                            : descriptionController.text.trim(),
                      );

                      if (!context.mounted) return;
                      Navigator.pop(context);

                      if (response != null && response.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response.message ?? 'Report submitted successfully'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(response?.message ?? 'Failed to submit report. Please try again.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.gray400,
                disabledForegroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isTablet ? 12 : 8),
                ),
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                      ),
                    )
                  : Text(
                      'Report',
                      style: TextStyle(fontSize: buttonFontSize),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
