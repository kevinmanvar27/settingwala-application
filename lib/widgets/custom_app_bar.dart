import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/notifications_list_screen.dart';
import '../theme/app_colors.dart';
import '../screens/chat_list_screen.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    this.title = '',
    this.showBackButton = false,
    this.actions,
  });

  String? get _userPhotoUrl {
    final user = FirebaseAuth.instance.currentUser;
    return user?.photoURL;
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
    
    // Responsive sizes
    final logoSize = isDesktop ? 72.0 : isTablet ? 68.0 : isSmallScreen ? 52.0 : 62.0;
    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 22.0 : 24.0;
    final avatarRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final avatarIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final endPadding = isDesktop ? 16.0 : isTablet ? 12.0 : isSmallScreen ? 4.0 : 8.0;

    return AppBar(
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor, size: iconSize),
              onPressed: () => Navigator.of(context).pop(),
            )
          : null,
      backgroundColor: colors.card,
      elevation: 0,
      centerTitle: false,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: primaryColor.withOpacity(0.2),
        ),
      ),
      title: Container(
        padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
        child: Image.asset(
          'assets/settingwala_logo.png',
          height: logoSize,
          width: logoSize,
        ),
      ),
      actions: actions ?? [
        // Chat Button
        IconButton(
          icon: Icon(Icons.chat, color: primaryColor, size: iconSize),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ChatListScreen()),
            );
          },
        ),
        // Notification Button
        IconButton(
          icon: Icon(Icons.notifications, color: primaryColor, size: iconSize),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationsListScreen()),
            );
          },
        ),
        // Settings Button
        IconButton(
          icon: _userPhotoUrl != null
              ? CircleAvatar(
                  backgroundImage: NetworkImage(_userPhotoUrl!),
                  radius: avatarRadius,
                )
              : CircleAvatar(
                  backgroundColor: colors.card,
                  radius: avatarRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: primaryColor.withOpacity(0.1)),
                    ),
                    child: Icon(
                      Icons.person,
                      size: avatarIconSize,
                      color: primaryColor,
                    ),
                  ),
                ),
          onPressed: () {
            scaffoldKey.currentState?.openEndDrawer();
          },
        ),
        SizedBox(width: endPadding),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}