import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:settingwala/firstscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screens/profile.dart';
import '../screens/my_bookings_screen.dart';
import '../screens/wallet_screen.dart';
import '../screens/rejections_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/theme_toggle.dart';
import '../Service/profile_service.dart';

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  // Helper function to clean URL - removes escaped slashes and double slashes
  String? _cleanImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return null;
    String cleaned = url.replaceAll('\\/', '/');
    // Fix double slashes (except after http: or https:)
    cleaned = cleaned.replaceAll(RegExp(r'(?<!:)//'), '/');
    return cleaned;
  }

  // Profile data
  String _userName = 'User';
  String _userEmail = 'user@example.com';
  String? _userPhotoUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profileData = await ProfileService.getProfile();
      
      // Check if widget is still mounted before calling setState
      if (!mounted) return;
      
      if (profileData != null && profileData.data?.user != null) {
        final user = profileData.data!.user!;
        // Get avatar URL - try profilePictureUrl first, then profilePicture
        String? avatarUrl = user.profilePictureUrl?.toString() ?? user.profilePicture?.toString();
        
        setState(() {
          _userName = user.name ?? 'User';
          _userEmail = user.email ?? 'user@example.com';
          _userPhotoUrl = _cleanImageUrl(avatarUrl);
          _isLoading = false;
        });
      } else {
        // Fallback to Firebase user data
        final user = FirebaseAuth.instance.currentUser;
        setState(() {
          _userName = user?.displayName ?? 'User';
          _userEmail = user?.email ?? 'user@example.com';
          _userPhotoUrl = user?.photoURL;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      // Check if widget is still mounted before calling setState
      if (!mounted) return;
      // Fallback to Firebase user data
      final user = FirebaseAuth.instance.currentUser;
      setState(() {
        _userName = user?.displayName ?? 'User';
        _userEmail = user?.email ?? 'user@example.com';
        _userPhotoUrl = user?.photoURL;
        _isLoading = false;
      });
    }
  }

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
    
    // Responsive drawer width
    final drawerWidth = isDesktop 
        ? 360.0 
        : isTablet 
            ? 320.0 
            : isSmallScreen 
                ? screenWidth * 0.85 
                : 304.0;
    
    // Responsive typography
    final nameFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final emailFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final itemTitleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 11.0 : 13.0;
    
    // Responsive sizes
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
            // Drawer Header with User Info
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
            
            // My Profile
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
                // Refresh profile data when returning from ProfileScreen
                _loadProfile();
              },
            ),

            // My Bookings
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyBookingsScreen(),
                  ),
                );
              },
            ),
            
            // Wallet
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WalletScreen(),
                  ),
                );
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RejectionsScreen(),
                  ),
                );
              },
            ),
            
            // Theme Toggle
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
            
            // Sign Out
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
                  // Sign out from Google
                  final GoogleSignIn googleSignIn = GoogleSignIn();
                  await googleSignIn.signOut();
                  
                  // Sign out from Firebase
                  await FirebaseAuth.instance.signOut();
                  
                  // Clear SharedPreferences
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('auth_token');
                  await prefs.remove('user_data');
                  await prefs.remove('is_new_user');
                  
                  // Navigate to login screen
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => Firstscreen()),
                      (route) => false,
                    );
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