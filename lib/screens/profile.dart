import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/profile_service.dart';
import '../Service/completion_status_service.dart';
import '../Service/wallet_service.dart';
import '../routes/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//+'), '/');
    return cleaned;
  }

  double _profileCompleteness = 0.0;

  double _balance = 0.0;
  double _earnings = 0.0;
  double _spending = 0.0;
  bool _isLoadingWallet = true;

  bool _isSugarPartnerEnabled = false;

  bool _isTimeSpendingEnabled = false;

  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userPhotoUrl;
  String _userLocation = 'Location not set';

  bool _isLoadingProfile = true;
  bool _isLoadingCompletion = true;

  @override
  void initState() {
    super.initState();
    _loadPrivacySettings();
    _loadProfile();
    _loadCompletionStatus();
    _loadWalletData();
  }

  Future<void> _loadWalletData() async {
    try {
      final walletData = await WalletService.getWalletOverview();

      if (walletData.success) {
        setState(() {
          _balance = walletData.balance;
          _earnings = walletData.totalEarned;
          _spending = walletData.totalWithdrawn;
          _isLoadingWallet = false;
        });
      } else {
        
        setState(() {
          _isLoadingWallet = false;
        });
      }
    } catch (e) {
      
      setState(() {
        _isLoadingWallet = false;
      });
    }
  }

  Future<void> _loadPrivacySettings() async {
    final prefs = await SharedPreferences.getInstance();

    final sugarPartnerFromPrefs = prefs.getBool('interested_in_sugar_partner') ?? false;
    final timeSpendingFromPrefs = prefs.getBool('is_time_spending_enabled') ?? false;

    setState(() {
      _isSugarPartnerEnabled = sugarPartnerFromPrefs;
      _isTimeSpendingEnabled = timeSpendingFromPrefs;
    });

    try {
      final profileData = await ProfileService.getProfile();
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;

        final apiSugarPartner = user.interestedInSugarPartner;
        final apiTimeSpending = user.isTimeSpendingEnabled;

        setState(() {
          _isSugarPartnerEnabled = (apiSugarPartner == true) || sugarPartnerFromPrefs;
          _isTimeSpendingEnabled = (apiTimeSpending == true) || timeSpendingFromPrefs;
        });

        if (apiSugarPartner == true && !sugarPartnerFromPrefs) {
          await prefs.setBool('interested_in_sugar_partner', true);
        }
        if (apiTimeSpending == true && !timeSpendingFromPrefs) {
          await prefs.setBool('is_time_spending_enabled', true);
        }
      }
    } catch (e) {
      
    }
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await ProfileService.getProfile();

      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        String? avatarUrl = user.profilePictureUrl?.toString() ?? user.profilePicture?.toString();

        setState(() {
          _userName = user.name ?? 'User';
          _userEmail = user.email ?? 'user@example.com';
          _userPhotoUrl = _cleanImageUrl(avatarUrl);

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
        final user = FirebaseAuth.instance.currentUser;
        setState(() {
          _userName = user?.displayName ?? 'User';
          _userEmail = user?.email ?? 'user@example.com';
          _userPhotoUrl = user?.photoURL;
          _isLoadingProfile = false;
        });
      }
    } catch (e) {
      
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
      
      setState(() {
        _profileCompleteness = 0.0;
        _isLoadingCompletion = false;
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoadingProfile = true;
      _isLoadingCompletion = true;
      _isLoadingWallet = true;
    });
    await Future.wait([
      _loadProfile(),
      _loadCompletionStatus(),
      _loadPrivacySettings(),
      _loadWalletData(),
    ]);
  }

  Future<void> _onTimeSpendingTap() async {
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
      Navigator.pop(context);

      if (profileData != null && profileData.success == true) {
        final user = profileData.data?.user;
        final profileCompletion = user?.profileCompletionPercentage ?? 0;
        final isTimeSpendingEnabled = user?.isTimeSpendingEnabled ?? false;

        if (!isTimeSpendingEnabled) {
          await ProfileService.updatePrivacySettings(isTimeSpendingEnabled: true);
          await _loadProfile();
          await _loadCompletionStatus();
          await _loadPrivacySettings();
        }

        if (profileCompletion >= 100) {
          if (!mounted) return;
          AppRoutes.navigateTo(context, AppRoutes.timeSpending);
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please complete your profile first ($profileCompletion% complete)'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
          AppRoutes.navigateTo(context, AppRoutes.profileSettings);
        }
      } else {
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
      Navigator.pop(context);
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
    Responsive.init(context);

    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

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
                _buildProfileHeader(colors, primaryColor, isSmallScreen, isTablet),
                SizedBox(height: sectionSpacing),

                _buildFinancialOverview(colors, primaryColor, isSmallScreen, isTablet),
                SizedBox(height: sectionSpacing),

                _buildNavigationButtons(context, colors, primaryColor, isSmallScreen, isTablet, isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet) {
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
          _isLoadingWallet
              ? Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              ),
            ),
          )
              : Row(
            children: [
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
    final titleSize = isSmallScreen ? 14.0 : (isTablet ? 22.0 : 18.0);

    final List<Map<String, dynamic>> buttons = [
      {
        'title': 'Personal Information',
        'icon': Icons.person,
        'onTap': () async {
          await AppRoutes.navigateTo(context, AppRoutes.profileSettings);
          await _refreshData();
        },
      },
      if (_isSugarPartnerEnabled)
        {
          'title': 'Sugar Partner',
          'icon': Icons.favorite,
          'color': Colors.pink,
          'onTap': () {
            AppRoutes.navigateTo(context, AppRoutes.sugarPartner);
          },
        },
      {
        'title': 'Gallery',
        'icon': Icons.photo_library,
        'onTap': () {
          AppRoutes.navigateTo(context, AppRoutes.gallery);
        },
      },
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
          AppRoutes.navigateTo(context, AppRoutes.reviews);
        },
      },
      {
        'title': 'Notifications',
        'icon': Icons.notifications,
        'onTap': () {
          AppRoutes.navigateTo(context, AppRoutes.notificationsList);
        },
      },
      {
        'title': 'Notification Settings',
        'icon': Icons.notifications_active,
        'onTap': () {
          AppRoutes.navigateTo(context, AppRoutes.notifications);
        },
      },
      {
        'title': 'Privacy Settings',
        'icon': Icons.shield_outlined,
        'onTap': () async {
          await AppRoutes.navigateTo(context, AppRoutes.privacySettings);
          await _refreshData();
        },
      },
    ];

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
