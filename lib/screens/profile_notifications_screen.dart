import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';

class ProfileNotification {
  final String id;
  final String name;
  final String? imageUrl;
  final String message;
  final DateTime time;
  final bool isPending;

  ProfileNotification({
    required this.id,
    required this.name,
    this.imageUrl,
    required this.message,
    required this.time,
    this.isPending = true,
  });
}

class ProfileNotificationsScreen extends StatefulWidget {
  const ProfileNotificationsScreen({super.key});

  @override
  State<ProfileNotificationsScreen> createState() => _ProfileNotificationsScreenState();
}

class _ProfileNotificationsScreenState extends State<ProfileNotificationsScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Sample notifications data
  final List<ProfileNotification> _notifications = [
    ProfileNotification(
      id: '1',
      name: 'Rahul Sharma',
      message: 'Wants to connect with you',
      time: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    ProfileNotification(
      id: '2',
      name: 'Priya Patel',
      imageUrl: 'https://randomuser.me/api/portraits/women/32.jpg',
      message: 'Requested to schedule a meeting',
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    ProfileNotification(
      id: '3',
      name: 'Amit Singh',
      imageUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
      message: 'Wants to discuss project details',
      time: DateTime.now().subtract(const Duration(hours: 5)),
    ),
    ProfileNotification(
      id: '4',
      name: 'Neha Gupta',
      message: 'Sent you a connection request',
      time: DateTime.now().subtract(const Duration(days: 1)),
    ),
    ProfileNotification(
      id: '5',
      name: 'Vikram Mehta',
      imageUrl: 'https://randomuser.me/api/portraits/men/22.jpg',
      message: 'Wants to schedule a meeting',
      time: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
  
  List<ProfileNotification> _pendingNotifications = [];
  List<ProfileNotification> _approvedNotifications = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Initialize pending and approved notifications
    _pendingNotifications = _notifications.where((n) => n.isPending).toList();
    _approvedNotifications = _notifications.where((n) => !n.isPending).toList();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _approveProfile(ProfileNotification notification) {
    setState(() {
      _pendingNotifications.removeWhere((n) => n.id == notification.id);
      final updatedNotification = ProfileNotification(
        id: notification.id,
        name: notification.name,
        imageUrl: notification.imageUrl,
        message: notification.message,
        time: notification.time,
        isPending: false,
      );
      _approvedNotifications.add(updatedNotification);
    });
    
    // Navigate to chat screen
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => ChatScreen(
    //       profileName: notification.name,
    //       profileImage: notification.imageUrl,
    //       meetingTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
    //     ),
    //   ),
    // );
  }
  
  void _rejectProfile(ProfileNotification notification) {
    setState(() {
      _pendingNotifications.removeWhere((n) => n.id == notification.id);
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${notification.name} rejected'),
        backgroundColor: AppColors.error,
      ),
    );
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
    
    // Responsive padding
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive spacing
    final itemSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive border radius
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final buttonRadius = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    // Responsive typography
    final tabFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final nameFontSize = isDesktop ? 20.0 : isTablet ? 19.0 : isSmallScreen ? 16.0 : 18.0;
    final messageFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final timeFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final emptyStateFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    
    // Responsive icon sizes
    final tabIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final avatarIconSize = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 26.0 : 30.0;
    
    // Responsive avatar size
    final avatarRadius = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 26.0 : 30.0;
    
    // Max width for desktop readability
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'Profile Notifications',
      showBackButton: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    color: colors.card,
                    child: TabBar(
                      labelColor: primaryColor,
                      unselectedLabelColor: colors.textTertiary,
                      indicatorColor: primaryColor,
                      labelStyle: TextStyle(
                        fontSize: tabFontSize,
                        fontWeight: FontWeight.w600,
                      ),
                      unselectedLabelStyle: TextStyle(
                        fontSize: tabFontSize,
                        fontWeight: FontWeight.normal,
                      ),
                      tabs: [
                        Tab(
                          icon: Icon(Icons.pending_actions, size: tabIconSize),
                          text: 'Pending',
                        ),
                        Tab(
                          icon: Icon(Icons.check_circle, size: tabIconSize),
                          text: 'Approved',
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // Pending Profiles Tab
                        _pendingNotifications.isEmpty
                            ? _buildEmptyState(
                                'No pending profile requests', 
                                colors,
                                iconSize: emptyIconSize,
                                fontSize: emptyStateFontSize,
                              )
                            : _buildProfileList(
                                _pendingNotifications, 
                                colors, 
                                primaryColor, 
                                true,
                                horizontalPadding: horizontalPadding,
                                itemSpacing: itemSpacing,
                                cardRadius: cardRadius,
                                buttonRadius: buttonRadius,
                                avatarRadius: avatarRadius,
                                avatarIconSize: avatarIconSize,
                                nameFontSize: nameFontSize,
                                messageFontSize: messageFontSize,
                                timeFontSize: timeFontSize,
                                buttonFontSize: buttonFontSize,
                              ),
                        
                        // Approved Profiles Tab
                        _approvedNotifications.isEmpty
                            ? _buildEmptyState(
                                'No approved profiles yet', 
                                colors,
                                iconSize: emptyIconSize,
                                fontSize: emptyStateFontSize,
                              )
                            : _buildProfileList(
                                _approvedNotifications, 
                                colors, 
                                primaryColor, 
                                false,
                                horizontalPadding: horizontalPadding,
                                itemSpacing: itemSpacing,
                                cardRadius: cardRadius,
                                buttonRadius: buttonRadius,
                                avatarRadius: avatarRadius,
                                avatarIconSize: avatarIconSize,
                                nameFontSize: nameFontSize,
                                messageFontSize: messageFontSize,
                                timeFontSize: timeFontSize,
                                buttonFontSize: buttonFontSize,
                              ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildEmptyState(
    String message, 
    AppColorSet colors, {
    required double iconSize,
    required double fontSize,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: iconSize,
            color: colors.textTertiary,
          ),
          SizedBox(height: iconSize * 0.25),
          Text(
            message,
            style: TextStyle(
              fontSize: fontSize,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProfileList(
    List<ProfileNotification> notifications, 
    AppColorSet colors, 
    Color primaryColor, 
    bool isPending, {
    required double horizontalPadding,
    required double itemSpacing,
    required double cardRadius,
    required double buttonRadius,
    required double avatarRadius,
    required double avatarIconSize,
    required double nameFontSize,
    required double messageFontSize,
    required double timeFontSize,
    required double buttonFontSize,
  }) {
    return ListView.builder(
      padding: EdgeInsets.all(horizontalPadding),
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _buildProfileCard(
          notification, 
          colors, 
          primaryColor, 
          isPending,
          cardPadding: horizontalPadding,
          itemSpacing: itemSpacing,
          cardRadius: cardRadius,
          buttonRadius: buttonRadius,
          avatarRadius: avatarRadius,
          avatarIconSize: avatarIconSize,
          nameFontSize: nameFontSize,
          messageFontSize: messageFontSize,
          timeFontSize: timeFontSize,
          buttonFontSize: buttonFontSize,
        );
      },
    );
  }
  
  Widget _buildProfileCard(
    ProfileNotification notification, 
    AppColorSet colors, 
    Color primaryColor, 
    bool isPending, {
    required double cardPadding,
    required double itemSpacing,
    required double cardRadius,
    required double buttonRadius,
    required double avatarRadius,
    required double avatarIconSize,
    required double nameFontSize,
    required double messageFontSize,
    required double timeFontSize,
    required double buttonFontSize,
  }) {
    return Card(
      elevation: 2,
      color: colors.card,
      shadowColor: primaryColor.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(cardRadius),
      ),
      margin: EdgeInsets.only(bottom: itemSpacing),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: primaryColor.withOpacity(0.1),
                  backgroundImage: notification.imageUrl != null 
                      ? NetworkImage(notification.imageUrl!) 
                      : null,
                  child: notification.imageUrl == null
                      ? Icon(
                          Icons.person,
                          size: avatarIconSize,
                          color: primaryColor,
                        )
                      : null,
                ),
                SizedBox(width: itemSpacing),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.name,
                        style: TextStyle(
                          fontSize: nameFontSize,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: itemSpacing * 0.25),
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontSize: messageFontSize,
                          color: colors.textTertiary,
                        ),
                      ),
                      SizedBox(height: itemSpacing * 0.25),
                      Text(
                        _formatTime(notification.time),
                        style: TextStyle(
                          fontSize: timeFontSize,
                          color: colors.textTertiary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isPending) ...[
              SizedBox(height: itemSpacing),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _rejectProfile(notification),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: itemSpacing,
                        vertical: itemSpacing * 0.5,
                      ),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(fontSize: buttonFontSize),
                    ),
                  ),
                  SizedBox(width: itemSpacing * 0.75),
                  ElevatedButton(
                    onPressed: () => _approveProfile(notification),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(buttonRadius),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: itemSpacing,
                        vertical: itemSpacing * 0.5,
                      ),
                    ),
                    child: Text(
                      'Approve',
                      style: TextStyle(fontSize: buttonFontSize),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: itemSpacing),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => ChatScreen(
                    //       profileName: notification.name,
                    //       profileImage: notification.imageUrl,
                    //       meetingTime: DateTime.now().add(const Duration(days: 1, hours: 2)),
                    //     ),
                    //   ),
                    // );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: itemSpacing * 0.75,
                    ),
                  ),
                  child: Text(
                    'Open Chat',
                    style: TextStyle(fontSize: buttonFontSize),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}