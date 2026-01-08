import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';
import '../widgets/theme_toggle.dart';
import '../Service/profile_service.dart';
import '../routes/app_routes.dart';
import '../utils/auth_helper.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//+'), '/');
    return cleaned;
  }

  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userPhotoUrl;
  bool _isLoading = true;
  bool _isValidating = true;

  @override
  void initState() {
    super.initState();
    _validateAndLoadProfile();
  }

  // Validate user first, then load profile if valid
  Future<void> _validateAndLoadProfile() async {
    final isValid = await AuthHelper.validateUserOrRedirect(context);
    
    if (!mounted) return;
    
    if (isValid) {
      setState(() {
        _isValidating = false;
      });
      _loadProfile();
    }
    // If not valid, AuthHelper already redirected to login
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await ProfileService.getProfile();
      
      if (!mounted) return;
      
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        String? avatarUrl = user.profilePictureUrl?.toString() ?? user.profilePicture?.toString();
        
        // Check for invalid/placeholder email and redirect to login
        final email = user.email;
        if (email == null || email.isEmpty || email == 'user@example.com') {
          await AuthHelper.forceLogout(context);
          return;
        }
        
        setState(() {
          _userName = user.name ?? 'User';
          _userEmail = email;
          _userPhotoUrl = _cleanImageUrl(avatarUrl);
          _isLoading = false;
        });
      } else {
        // No valid profile data - redirect to login
        await AuthHelper.forceLogout(context);
      }
    } catch (e) {
      if (!mounted) return;
      // On error, redirect to login
      await AuthHelper.forceLogout(context);
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
    
    final drawerWidth = isDesktop 
        ? 360.0 
        : isTablet 
            ? 320.0 
            : isSmallScreen 
                ? screenWidth * 0.85 
                : 304.0;
    
    // Show loading while validating user
    if (_isValidating) {
      return SizedBox(
        width: drawerWidth,
        child: Drawer(
          backgroundColor: colors.background,
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
        ),
      );
    }
    
    final nameFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final emailFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final itemTitleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 11.0 : 13.0;
    
    final avatarRadius = isDesktop ? 44.0 : isTablet ? 40.0 : isSmallScreen ? 30.0 : 36.0;
    final avatarIconSize = isDesktop ? 48.0 : isTablet ? 44.0 : isSmallScreen ? 32.0 : 40.0;
    final itemIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final iconContainerPadding = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    return SizedBox(
      width: drawerWidth,
      child: Drawer(
        backgroundColor: colors.background,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                color: colors.card,
                border: Border(
                  bottom: BorderSide(
                    color: primaryColor.withOpacity(0.3),
                    width: 1.0,
                  ),
                ),
              ),
              accountName: _isLoading
                  ? SizedBox(
                      width: 100,
                      height: nameFontSize,
                      child: LinearProgressIndicator(
                        backgroundColor: colors.card,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.3)),
                      ),
                    )
                  : Text(
                      _userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: nameFontSize,
                        color: colors.textPrimary,
                      ),
                    ),
              accountEmail: _isLoading
                  ? SizedBox(
                      width: 150,
                      height: emailFontSize,
                      child: LinearProgressIndicator(
                        backgroundColor: colors.card,
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor.withOpacity(0.3)),
                      ),
                    )
                  : Text(
                      _userEmail,
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: emailFontSize,
                      ),
                    ),
              currentAccountPicture: CircleAvatar(
                radius: avatarRadius,
                backgroundColor: colors.card,
                child: _userPhotoUrl != null && _userPhotoUrl!.isNotEmpty
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(_userPhotoUrl!),
                        radius: avatarRadius - 4,
                      )
                    : Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.person,
                          size: avatarIconSize,
                          color: primaryColor,
                        ),
                      ),
              ),
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.account_circle,
              title: 'My Profile',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () async {
                Navigator.pop(context);
                await AppRoutes.navigateTo(context, AppRoutes.profile);
                _loadProfile();
              },
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.calendar_today,
              title: 'My Bookings',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.myBookings);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.account_balance_wallet,
              title: 'Wallet',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.wallet);
              },
            ),

            _buildDrawerItem(
              context: context,
              icon: Icons.block,
              title: 'Manage Rejections',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.rejections);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.info,
              title: 'About',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.about);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.route,
              title: 'Journey',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.journey);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.contact_mail,
              title: 'Contact Us',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.contact);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.privacyPolicy);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.gavel,
              title: 'Terms of Service',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.termsOfService);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.security,
              title: 'Safety',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.safety);
              },
            ),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.money_off,
              title: 'Refund Policy',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              onTap: () {
                Navigator.pop(context);
                AppRoutes.navigateTo(context, AppRoutes.refundPolicy);
              },
            ),
            
            _buildThemeToggleItem(
              context, 
              colors, 
              primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              subtitleFontSize: subtitleFontSize,
            ),
            
            const Divider(),
            
            _buildDrawerItem(
              context: context,
              icon: Icons.logout,
              title: 'Sign Out',
              colors: colors,
              primaryColor: primaryColor,
              iconSize: itemIconSize,
              iconContainerPadding: iconContainerPadding,
              titleFontSize: itemTitleFontSize,
              isDestructive: true,
              onTap: () async {
                Navigator.pop(context);
                _showSignOutDialog(context, colors, primaryColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required AppColorSet colors,
    required Color primaryColor,
    required VoidCallback onTap,
    required double iconSize,
    required double iconContainerPadding,
    required double titleFontSize,
    bool isDestructive = false,
  }) {
    final itemColor = isDestructive ? AppColors.error : primaryColor;
    final textColor = isDestructive ? AppColors.error : colors.textPrimary;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(iconContainerPadding),
        decoration: BoxDecoration(
          color: itemColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: itemColor.withOpacity(0.3)),
        ),
        child: Icon(
          icon,
          color: itemColor,
          size: iconSize,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: titleFontSize,
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildThemeToggleItem(
    BuildContext context, 
    AppColorSet colors, 
    Color primaryColor, {
    required double iconSize,
    required double iconContainerPadding,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(iconContainerPadding),
        decoration: BoxDecoration(
          color: primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(color: primaryColor.withOpacity(0.3)),
        ),
        child: Icon(
          isDark ? Icons.dark_mode : Icons.light_mode,
          color: primaryColor,
          size: iconSize,
        ),
      ),
      title: Text(
        'Theme Mode',
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: titleFontSize,
        ),
      ),
      subtitle: Text(
        isDark ? 'Dark Mode' : 'Light Mode',
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: subtitleFontSize,
        ),
      ),
      trailing: ThemeToggle(showLabel: false),
      onTap: () => _showThemeBottomSheet(context),
    );
  }

  void _showThemeBottomSheet(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final titleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 18.0 : 20.0;
    final verticalSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: verticalSpacing),
            Text(
              'Choose Theme',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: verticalSpacing),
            ThemeToggle.segmented(),
            SizedBox(height: verticalSpacing * 1.5),
          ],
        ),
      ),
    );
  }

  void _showSignOutDialog(BuildContext context, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final contentFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final dialogRadius = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 24.0 : 30.0;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colors.card,
          title: Text(
            'Sign Out',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: titleFontSize,
            ),
          ),
          content: Text(
            'Are you sure you want to sign out?',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: contentFontSize,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: buttonFontSize,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final GoogleSignIn googleSignIn = GoogleSignIn();
                  await googleSignIn.signOut();
                  
                  await FirebaseAuth.instance.signOut();
                  
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('auth_token');
                  await prefs.remove('user_data');
                  await prefs.remove('is_new_user');
                  
                  if (context.mounted) {
                    AppRoutes.toFirstScreen(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error signing out: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.error,
              ),
              child: Text(
                'Sign Out',
                style: TextStyle(fontSize: buttonFontSize),
              ),
            ),
          ],
        );
      },
    );
  }
}
