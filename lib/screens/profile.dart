import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:settingwala/screens/time_spending_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import 'profile_settings_screen.dart';
import 'gallery_screen.dart';
//import 'time_spending_screen.dart';
import 'reviews_screen.dart';
import 'notifications_screen.dart';
import 'notifications_list_screen.dart';
import 'privacy_settings_screen.dart';
import 'sugar_partner_screen.dart';
import '../Service/profile_service.dart';
import '../Service/completion_status_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Helper function to clean URL - removes escaped slashes and double slashes
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    // Fix double slashes (except after http: or https:)
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//'), '/');
    return cleaned;
  }

  // Profile completion percentage
  double _profileCompleteness = 0.0;
  
  // Financial information
  final double _balance = 5200.0;
  final double _earnings = 8500.0;
  final double _spending = 3300.0;
  
  // Sugar Partner Service enabled state
  bool _isSugarPartnerEnabled = false;
  
  // Time Spending Service enabled state
  bool _isTimeSpendingEnabled = false;
  
  // Profile data
  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userPhotoUrl;
  String _userLocation = 'Location not set';
  
  // Loading states
  bool _isLoadingProfile = true;
  bool _isLoadingCompletion = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
    _loadProfile();
    _loadCompletionStatus();
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final profileData = await ProfileService.getProfile();
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        setState(() {
          _isSugarPartnerEnabled = user.interestedInSugarPartner ?? prefs.getBool('enableSugarPartnerService') ?? false;
          _isTimeSpendingEnabled = user.isTimeSpendingEnabled ?? prefs.getBool('enableTimeSpendingService') ?? false;
        });
      } else {
        // Fallback to SharedPreferences
        setState(() {
          _isSugarPartnerEnabled = prefs.getBool('enableSugarPartnerService') ?? false;
          _isTimeSpendingEnabled = prefs.getBool('enableTimeSpendingService') ?? false;
        });
      }
    } catch (e) {
      print('Error loading privacy settings: $e');
      // Fallback to SharedPreferences on error
      setState(() {
        _isSugarPartnerEnabled = prefs.getBool('enableSugarPartnerService') ?? false;
        _isTimeSpendingEnabled = prefs.getBool('enableTimeSpendingService') ?? false;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await ProfileService.getProfile();
      
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        // Get avatar URL - try profilePictureUrl first, then profilePicture
        String? avatarUrl = user.profilePictureUrl?.toString() ?? user.profilePicture?.toString();
        
        setState(() {
          _userName = user.name ?? 'User';
          _userEmail = user.email ?? 'user@example.com';
          _userPhotoUrl = _cleanImageUrl(avatarUrl);
          
          // Build location string
          List<String> locationParts = [];
          if (user.city != null && user.city.toString().isNotEmpty) {
            locationParts.add(user.city.toString());
          }
          if (user.state != null && user.state.toString().isNotEmpty) {
            locationParts.add(user.state.toString());
          }
          _userLocation = locationParts.isNotEmpty 
              ? locationParts.join(', ') 
              : 'Location not set';
          
          _isLoadingProfile = false;
        });
      } else {
        // Fallback to Firebase user data
        final user = FirebaseAuth.instance.currentUser;
        setState(() {
          _userName = user?.displayName ?? 'User';
          _userEmail = user?.email ?? 'user@example.com';
          _userPhotoUrl = user?.photoURL;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Fallback to Firebase user data
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _userName = user?.displayName ?? 'User';
        _userEmail = user?.email ?? 'user@example.com';
        _userPhotoUrl = user?.photoURL;
        _isLoadingProfile = false;
      });
    }
  }

  Future<void> _loadCompletionStatus() async {
    try {
      final completionData = await CompletionStatusService.getCompletionStatus();
      
      if (completionData != null && completionData.data != null) {
        setState(() {
          _profileCompleteness = (completionData.data!.percentage ?? 0).toDouble();
          _isLoadingCompletion = false;
        });
      } else {
        setState(() {
          _profileCompleteness = 0.0;
          _isLoadingCompletion = false;
        });
      }
    } catch (e) {
      print('Error loading completion status: $e');
      setState(() {
        _profileCompleteness = 0.0;
        _isLoadingCompletion = false;
      });
    }
  }

  // Refresh profile data
  Future<void> _refreshData() async {
    setState(() {
      _isLoadingProfile = true;
      _isLoadingCompletion = true;
    });
    await Future.wait([
      _loadProfile(),
      _loadCompletionStatus(),
      _loadPrivacySettings(), // Also refresh privacy settings
    ]);
  }

  /// Handle Time Spending button tap
  /// Check profile completion and enable time spending by default
  Future<void> _onTimeSpendingTap() async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final profileData = await ProfileService.getProfile();
      
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (profileData != null && profileData.success == true) {
        final user = profileData.data?.user;
        final profileCompletion = user?.profileCompletionPercentage ?? 0;
        final isTimeSpendingEnabled = user?.isTimeSpendingEnabled ?? false;

        if (!isTimeSpendingEnabled) {
          await ProfileService.updatePrivacySettings(isTimeSpendingEnabled: true);
          // Refresh the profile data to reflect the updated setting
          await _loadProfile();
          await _loadCompletionStatus();
          await _loadPrivacySettings(); // Refresh privacy settings to update the local state
        }

        if (profileCompletion >= 100) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TimeSpendingScreen()),
          );
        } else {
          // Profile is not complete, show message and navigate to Edit Profile screen
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please complete your profile first ($profileCompletion% complete)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileSettingsScreen()),
          );
        }
      } else {
        // Failed to get profile
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load profile. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive
    Responsive.init(context);
    
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    // Responsive values
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final bodyPadding = isSmallScreen ? 12.0 : (isTablet ? 24.0 : 16.0);
    final sectionSpacing = isSmallScreen ? 18.0 : (isTablet ? 32.0 : 24.0);
    
    return BaseScreen(
      title: 'My Profile',
      showBackButton: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: primaryColor,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.all(bodyPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                _buildProfileHeader(colors, primaryColor, isSmallScreen, isTablet),
                SizedBox(height: sectionSpacing),
                
                // Financial Overview
                _buildFinancialOverview(colors, primaryColor, isSmallScreen, isTablet),
                SizedBox(height: sectionSpacing),
                
                // Profile Navigation Buttons
                _buildNavigationButtons(context, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet) {
    // Responsive values
    final containerPadding = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
    final avatarSize = isSmallScreen ? 60.0 : (isTablet ? 100.0 : 80.0);
    final avatarIconSize = isSmallScreen ? 30.0 : (isTablet ? 50.0 : 40.0);
    final nameFontSize = isSmallScreen ? 18.0 : (isTablet ? 28.0 : 24.0);
    final emailFontSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final locationFontSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final locationIconSize = isSmallScreen ? 12.0 : (isTablet ? 18.0 : 14.0);
    final progressLabelSize = isSmallScreen ? 12.0 : (isTablet ? 16.0 : 14.0);
    final progressHintSize = isSmallScreen ? 10.0 : (isTablet ? 14.0 : 12.0);
    final progressBarHeight = isSmallScreen ? 8.0 : (isTablet ? 14.0 : 10.0);
    final borderRadius = isSmallScreen ? 20.0 : 30.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: _isLoadingProfile
                    ? CircleAvatar(
                        radius: avatarSize / 2,
                        backgroundColor: colors.card,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        ),
                      )
                    : _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                        ? CircleAvatar(
                            radius: avatarSize / 2,
                            backgroundImage: NetworkImage(_userPhotoUrl!),
                          )
                        : CircleAvatar(
                            radius: avatarSize / 2,
                            backgroundColor: colors.card,
                            child: Icon(
                              Icons.person,
                              size: avatarIconSize,
                              color: primaryColor,
                            ),
                          ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _isLoadingProfile
                        ? Container(
                            width: 120,
                            height: nameFontSize,
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: LinearProgressIndicator(
                              backgroundColor: colors.card,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.3)),
                            ),
                          )
                        : Text(
                            _userName,
                            style: TextStyle(
                              fontSize: nameFontSize,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    _isLoadingProfile
                        ? Container(
                            width: 180,
                            height: emailFontSize,
                            decoration: BoxDecoration(
                              color: colors.card,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: LinearProgressIndicator(
                              backgroundColor: colors.card,
                              valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.3)),
                            ),
                          )
                        : Text(
                            _userEmail,
                            style: TextStyle(
                              fontSize: emailFontSize,
                              color: colors.textSecondary,
                            ),
                          ),
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: locationIconSize,
                          color: primaryColor,
                        ),
                        SizedBox(width: isSmallScreen ? 2 : 4),
                        Expanded(
                          child: Text(
                            _userLocation,
                            style: TextStyle(
                              fontSize: locationFontSize,
                              color: colors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          
          // Profile Completeness
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Profile Completeness',
                    style: TextStyle(
                      fontSize: progressLabelSize,
                      fontWeight: FontWeight.w500,
                      color: colors.textPrimary,
                    ),
                  ),
                  _isLoadingCompletion
                      ? SizedBox(
                          width: 40,
                          height: progressLabelSize,
                          child: LinearProgressIndicator(
                            backgroundColor: colors.card,
                            valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.3)),
                          ),
                        )
                      : Text(
                          '${_profileCompleteness.toInt()}%',
                          style: TextStyle(
                            fontSize: progressLabelSize,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(progressBarHeight),
                child: _isLoadingCompletion
                    ? LinearProgressIndicator(
                        backgroundColor: primaryColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.3)),
                        minHeight: progressBarHeight,
                      )
                    : LinearProgressIndicator(
                        value: _profileCompleteness / 100,
                        backgroundColor: primaryColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: progressBarHeight,
                      ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'Complete your profile to increase visibility',
                style: TextStyle(
                  fontSize: progressHintSize,
                  color: colors.textTertiary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialOverview(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet) {
    // Responsive values
    final containerPadding = isSmallScreen ? 12.0 : (isTablet ? 20.0 : 16.0);
    final titleSize = isSmallScreen ? 14.0 : (isTablet ? 22.0 : 18.0);
    final borderRadius = isSmallScreen ? 20.0 : 30.0;
    
    return Container(
      padding: EdgeInsets.all(containerPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Financial Overview',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          Row(
            children: [
              // Balance
              Expanded(
                child: _buildFinancialItem(
                  'Balance',
                  '₹${_balance.toStringAsFixed(2)}',
                  Icons.account_balance_wallet,
                  colors,
                  primaryColor,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              
              // Earnings
              Expanded(
                child: _buildFinancialItem(
                  'Earnings',
                  '₹${_earnings.toStringAsFixed(2)}',
                  Icons.trending_up,
                  colors,
                  primaryColor,
                  isSmallScreen,
                  isTablet,
                ),
              ),
              
              // Spending
              Expanded(
                child: _buildFinancialItem(
                  'Spending',
                  '₹${_spending.toStringAsFixed(2)}',
                  Icons.trending_down,
                  colors,
                  primaryColor,
                  isSmallScreen,
                  isTablet,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String title, String amount, IconData icon, AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet) {
    // Responsive values
    final iconContainerSize = isSmallScreen ? 40.0 : (isTablet ? 60.0 : 50.0);
    final iconSize = isSmallScreen ? 18.0 : (isTablet ? 30.0 : 24.0);
    final titleSize = isSmallScreen ? 11.0 : (isTablet ? 16.0 : 14.0);
    final amountSize = isSmallScreen ? 12.0 : (isTablet ? 18.0 : 16.0);
    
    return Column(
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryColor,
            size: iconSize,
          ),
        ),
        SizedBox(height: isSmallScreen ? 6 : 8),
        Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            color: colors.textSecondary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 4),
        Text(
          amount,
          style: TextStyle(
            fontSize: amountSize,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    // Responsive values
    final titleSize = isSmallScreen ? 14.0 : (isTablet ? 22.0 : 18.0);
    
    final List<Map<String, dynamic>> buttons = [
      {
        'title': 'Personal Information',
        'icon': Icons.person,
        'onTap': () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ProfileSettingsScreen(),
            ),
          );
          // Refresh data when returning
          _refreshData();
        },
      },
      // Sugar Partner button - only show if enabled in Privacy Settings
      if (_isSugarPartnerEnabled)
        {
          'title': 'Sugar Partner',
          'icon': Icons.favorite,
          'color': Colors.pink,
          'onTap': () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SugarPartnerScreen(),
              ),
            );
          },
        },
      {
        'title': 'Gallery',
        'icon': Icons.photo_library,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const GalleryScreen(),
            ),
          );
        },
      },
      // Time Spending button - only show if enabled in Privacy Settings
      if (_isTimeSpendingEnabled)
        {
          'title': 'Time Spending',
          'icon': Icons.access_time,
          'onTap': () => _onTimeSpendingTap(),
        },
      {
        'title': 'Reviews',
        'icon': Icons.star,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ReviewsScreen(),
            ),
          );
        },
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsListScreen(),
            ),
          );
        },
      },
      {
        'title': 'Notification Settings',
        'icon': Icons.notifications_active,
        'onTap': () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NotificationsScreen(),
            ),
          );
        },
      },
      {
        'title': 'Privacy Settings',
        'icon': Icons.shield_outlined,
        'onTap': () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PrivacySettingsScreen(),
            ),
          );
          // Refresh data when returning
          _refreshData();
        },
      },
    ];

    // For tablet/desktop, use grid layout
    if (isTablet) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Settings',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: isSmallScreen ? 12 : 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 3 : 2,
              childAspectRatio: isDesktop ? 3.5 : 3.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: buttons.length,
            itemBuilder: (context, index) {
              final button = buttons[index];
              return _buildNavigationButton(
                title: button['title'],
                icon: button['icon'],
                onTap: button['onTap'],
                color: button['color'],
                colors: colors,
                primaryColor: primaryColor,
                isSmallScreen: isSmallScreen,
                isTablet: isTablet,
              );
            },
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile Settings',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: isSmallScreen ? 12 : 16),
        ...buttons.map((button) => _buildNavigationButton(
          title: button['title'],
          icon: button['icon'],
          onTap: button['onTap'],
          color: button['color'],
          colors: colors,
          primaryColor: primaryColor,
          isSmallScreen: isSmallScreen,
          isTablet: isTablet,
        )),
      ],
    );
  }

  Widget _buildNavigationButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
    required AppColorSet colors,
    required Color primaryColor,
    required bool isSmallScreen,
    required bool isTablet,
  }) {
    final buttonColor = color ?? primaryColor;
    
    // Responsive values
    final iconContainerPadding = isSmallScreen ? 6.0 : (isTablet ? 10.0 : 8.0);
    final iconSize = isSmallScreen ? 20.0 : (isTablet ? 28.0 : 24.0);
    final titleSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
    final arrowSize = isSmallScreen ? 14.0 : (isTablet ? 18.0 : 16.0);
    final borderRadius = isSmallScreen ? 20.0 : 30.0;
    final contentPaddingH = isSmallScreen ? 12.0 : 16.0;
    final contentPaddingV = isSmallScreen ? 6.0 : 8.0;
    final marginBottom = isSmallScreen ? 8.0 : 12.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isTablet ? 0 : marginBottom),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: color != null ? color.withOpacity(0.3) : primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color != null ? color.withOpacity(0.1) : primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(iconContainerPadding),
          decoration: BoxDecoration(
            color: color != null ? color.withOpacity(0.1) : primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: buttonColor,
            size: iconSize,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w500,
            color: color ?? colors.textPrimary,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: buttonColor,
          size: arrowSize,
        ),
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: contentPaddingH, vertical: contentPaddingV),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}