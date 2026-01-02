import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../utils/responsive.dart';
import '../Service/profile_service.dart';
import '../model/getprofilemodel.dart';
import 'book_meeting_screen.dart';
import 'user_gallery_screen.dart';
import 'my_bookings_screen.dart';

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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookMeetingScreen(person: person),
      ),
    );
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
            
            
            
            return Center(child: defaultIcon);
          },
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

                _buildDetailRow(Icons.cake, 'Age', '${person['age']} years', colors, infoFontSize, iconSize),
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

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyBookingsScreen()),
              );
            },
            icon: Icon(Icons.calendar_month, size: buttonIconSize),
            label: Text(
              'My Bookings',
              style: TextStyle(fontSize: buttonFontSize, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: AppColors.white,
              padding: EdgeInsets.symmetric(vertical: buttonPadding),
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
      ],
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
              
              if (imageUrl.isNotEmpty) {
                imageUrl = imageUrl.replaceAll(r'\/', '/');
              }
              
              if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                imageUrl = 'https://settingwala.com/storage/$imageUrl';
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

  Map<String, dynamic> _mapUserToPersonData(User user) {
    String getFullImageUrl(String? url) {
      if (url == null || url.isEmpty) return '';
      String cleanUrl = url.replaceAll(r'\/', '/');
      if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
        return cleanUrl;
      }
      return 'https://settingwala.com/storage/$cleanUrl';
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
            imageUrl = 'https://settingwala.com/storage/$imageUrl';
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
      
      return locationParts.isEmpty ? 'Location not specified' : locationParts.join(', ');
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
    
    List<String> processInterests() {
      List<String> interests = [];
      
      if (user.interests != null) {
        if (user.interests is List) {
          for (var item in user.interests) {
            if (item != null && item.toString().isNotEmpty) {
              interests.add(item.toString());
            }
          }
        } else if (user.interests.toString().isNotEmpty) {
          interests.add(user.interests.toString());
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
      'age': user.age?.toString() != null ? int.tryParse(user.age.toString()) ?? 0 : 0,
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
