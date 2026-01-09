import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_colors.dart';
import '../providers/chat_icon_provider.dart';
import '../providers/notification_provider.dart';
import '../routes/app_routes.dart';
import 'themed_logo.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String title;
  final bool showBackButton;
  final List<Widget>? actions;
  final bool? showChatIcon; // Nullable - when null, uses provider

  const CustomAppBar({
    super.key,
    required this.scaffoldKey,
    this.title = '',
    this.showBackButton = false,
    this.actions,
    this.showChatIcon,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String? get _userPhotoUrl {
    final user = FirebaseAuth.instance.currentUser;
    return user?.photoURL;
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
    
    final logoSize = isDesktop ? 72.0 : isTablet ? 68.0 : isSmallScreen ? 52.0 : 62.0;
    final iconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 22.0 : 24.0;
    final avatarRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final avatarIconSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final endPadding = isDesktop ? 16.0 : isTablet ? 12.0 : isSmallScreen ? 4.0 : 8.0;

    // Get chat icon notifier and listen to changes
    final chatNotifier = ChatIconProvider.maybeOf(context);
    
    // Determine chat icon visibility: use explicit value if provided, otherwise use provider
    final shouldShowChatIcon = showChatIcon ?? (chatNotifier?.showChatIcon ?? false);

    // Get notification count from provider (auto-updates when count changes)
    final unreadNotificationCount = context.unreadNotificationCount;

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
      title: GestureDetector(
        onTap: () {
          // Navigate to MainNavigationScreen when logo is tapped
          AppRoutes.navigateAndClearStack(context, AppRoutes.mainNavigation);
        },
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
          child: ThemedLogo(
            height: logoSize,
            width: logoSize,
          ),
        ),
      ),
      actions: actions ?? [
        // Only show chat icon if shouldShowChatIcon is true
        if (shouldShowChatIcon)
          IconButton(
            icon: Icon(Icons.chat, color: primaryColor, size: iconSize),
            onPressed: () {
              // Use named route for chat list
              AppRoutes.navigateTo(context, AppRoutes.chatList);
            },
          ),
        // Notification icon with unread count badge
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications, color: primaryColor, size: iconSize),
              onPressed: () async {
                // Navigate to notifications - count will auto-update via provider
                await AppRoutes.navigateTo(context, AppRoutes.notificationsList);
              },
            ),
            if (unreadNotificationCount > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    unreadNotificationCount > 99 ? '99+' : unreadNotificationCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
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
}
