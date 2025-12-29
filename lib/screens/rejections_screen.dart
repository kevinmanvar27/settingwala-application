import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';

class RejectionsScreen extends StatefulWidget {
  const RejectionsScreen({super.key});

  @override
  State<RejectionsScreen> createState() => _RejectionsScreenState();
}

class _RejectionsScreenState extends State<RejectionsScreen> {
  // Sample rejected users data
  final List<Map<String, dynamic>> _rejectedUsers = [
    {
      'name': 'Priya Sharma',
      'age': 28,
      'location': 'Mumbai',
      'image': null,
      'rejectedDate': '2 days ago',
    },
    {
      'name': 'Rahul Patel',
      'age': 32,
      'location': 'Delhi',
      'image': null,
      'rejectedDate': '5 days ago',
    },
    {
      'name': 'Anjali Singh',
      'age': 26,
      'location': 'Bangalore',
      'image': null,
      'rejectedDate': '1 week ago',
    },
    {
      'name': 'Vikram Mehta',
      'age': 30,
      'location': 'Ahmedabad',
      'image': null,
      'rejectedDate': '2 weeks ago',
    },
    {
      'name': 'Neha Gupta',
      'age': 27,
      'location': 'Pune',
      'image': null,
      'rejectedDate': '3 weeks ago',
    },
  ];

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
    final itemSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    // Responsive border radius
    final headerRadius = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 24.0 : 30.0;
    final cardRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    
    // Responsive typography
    final headerTitleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final headerSubtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final nameFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final infoFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final rejectedDateFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 9.0 : 11.0;
    final avatarInitialFontSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final emptyTitleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 17.0 : 20.0;
    final emptySubtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    // Responsive icon sizes
    final headerIconSize = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 26.0 : 32.0;
    final headerIconPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final infoIconSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final actionIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 22.0 : 24.0;
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final emptyIconPadding = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    
    // Responsive avatar size
    final avatarSize = isDesktop ? 72.0 : isTablet ? 68.0 : isSmallScreen ? 50.0 : 60.0;
    final avatarBorderWidth = isDesktop ? 3.0 : isTablet ? 2.5 : isSmallScreen ? 1.5 : 2.0;
    
    // Max width for desktop readability
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'Manage Rejections',
      showBackButton: true,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
              // Header
              _buildHeader(
                colors, 
                primaryColor,
                headerRadius: headerRadius,
                headerPadding: horizontalPadding,
                iconSize: headerIconSize,
                iconPadding: headerIconPadding,
                titleFontSize: headerTitleFontSize,
                subtitleFontSize: headerSubtitleFontSize,
              ),
              
              // Rejected Users List
              Expanded(
                child: _rejectedUsers.isEmpty
                    ? _buildEmptyState(
                        colors, 
                        primaryColor,
                        iconSize: emptyIconSize,
                        iconPadding: emptyIconPadding,
                        titleFontSize: emptyTitleFontSize,
                        subtitleFontSize: emptySubtitleFontSize,
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(horizontalPadding),
                        itemCount: _rejectedUsers.length,
                        itemBuilder: (context, index) {
                          return _buildRejectedUserCard(
                            _rejectedUsers[index], 
                            index, 
                            colors, 
                            primaryColor, 
                            isDark,
                            cardRadius: cardRadius,
                            cardPadding: itemSpacing,
                            avatarSize: avatarSize,
                            avatarBorderWidth: avatarBorderWidth,
                            avatarInitialFontSize: avatarInitialFontSize,
                            nameFontSize: nameFontSize,
                            infoFontSize: infoFontSize,
                            rejectedDateFontSize: rejectedDateFontSize,
                            infoIconSize: infoIconSize,
                            actionIconSize: actionIconSize,
                            itemSpacing: itemSpacing,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    AppColorSet colors, 
    Color primaryColor, {
    required double headerRadius,
    required double headerPadding,
    required double iconSize,
    required double iconPadding,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return Container(
      margin: EdgeInsets.all(headerPadding),
      padding: EdgeInsets.all(headerPadding),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(headerRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_off,
              color: AppColors.error,
              size: iconSize,
            ),
          ),
          SizedBox(width: headerPadding),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Manage Your Rejections',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: headerPadding * 0.25),
                Text(
                  '${_rejectedUsers.length} users rejected',
                  style: TextStyle(
                    fontSize: subtitleFontSize,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    AppColorSet colors, 
    Color primaryColor, {
    required double iconSize,
    required double iconPadding,
    required double titleFontSize,
    required double subtitleFontSize,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_outline,
              color: primaryColor,
              size: iconSize,
            ),
          ),
          SizedBox(height: iconPadding),
          Text(
            'No Rejected Users',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: iconPadding * 0.33),
          Text(
            'You haven\'t rejected anyone yet',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedUserCard(
    Map<String, dynamic> user, 
    int index, 
    AppColorSet colors, 
    Color primaryColor, 
    bool isDark, {
    required double cardRadius,
    required double cardPadding,
    required double avatarSize,
    required double avatarBorderWidth,
    required double avatarInitialFontSize,
    required double nameFontSize,
    required double infoFontSize,
    required double rejectedDateFontSize,
    required double infoIconSize,
    required double actionIconSize,
    required double itemSpacing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: itemSpacing),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            // User Avatar
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: avatarBorderWidth,
                ),
              ),
              child: user['image'] != null
                  ? CircleAvatar(
                      radius: avatarSize / 2 - avatarBorderWidth,
                      backgroundImage: NetworkImage(user['image']),
                    )
                  : CircleAvatar(
                      radius: avatarSize / 2 - avatarBorderWidth,
                      backgroundColor: primaryColor.withOpacity(0.1),
                      child: Text(
                        user['name'][0],
                        style: TextStyle(
                          fontSize: avatarInitialFontSize,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: cardPadding),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'],
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: cardPadding * 0.33),
                  Row(
                    children: [
                      Icon(
                        Icons.cake,
                        size: infoIconSize,
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: infoIconSize * 0.25),
                      Text(
                        '${user['age']} years',
                        style: TextStyle(
                          fontSize: infoFontSize,
                          color: colors.textSecondary,
                        ),
                      ),
                      SizedBox(width: cardPadding),
                      Icon(
                        Icons.location_on,
                        size: infoIconSize,
                        color: colors.textSecondary,
                      ),
                      SizedBox(width: infoIconSize * 0.25),
                      Text(
                        user['location'],
                        style: TextStyle(
                          fontSize: infoFontSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: cardPadding * 0.33),
                  Text(
                    'Rejected ${user['rejectedDate']}',
                    style: TextStyle(
                      fontSize: rejectedDateFontSize,
                      color: AppColors.error,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Buttons
            Column(
              children: [
                // Undo Button
                IconButton(
                  onPressed: () => _undoRejection(index, colors, primaryColor, isDark),
                  icon: Icon(
                    Icons.undo,
                    color: primaryColor,
                    size: actionIconSize,
                  ),
                  tooltip: 'Undo Rejection',
                ),
                // Delete Button
                IconButton(
                  onPressed: () => _deleteRejection(index, colors, primaryColor, isDark),
                  icon: Icon(
                    Icons.delete_outline,
                    color: AppColors.error,
                    size: actionIconSize,
                  ),
                  tooltip: 'Remove from list',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _undoRejection(int index, AppColorSet colors, Color primaryColor, bool isDark) {
    // Responsive values for dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final contentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        title: Text(
          'Undo Rejection',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: titleFontSize,
          ),
        ),
        content: Text(
          'Are you sure you want to undo the rejection of ${_rejectedUsers[index]['name']}?',
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
                color: colors.textSecondary,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _rejectedUsers.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Rejection undone successfully!', 
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: contentFontSize,
                    ),
                  ),
                  backgroundColor: primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(dialogRadius * 0.5),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
            ),
            child: Text(
              'Undo',
              style: TextStyle(fontSize: buttonFontSize),
            ),
          ),
        ],
      ),
    );
  }

  void _deleteRejection(int index, AppColorSet colors, Color primaryColor, bool isDark) {
    // Responsive values for dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final contentFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        title: Text(
          'Remove from List',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: titleFontSize,
          ),
        ),
        content: Text(
          'Remove ${_rejectedUsers[index]['name']} from your rejection list?',
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
                color: colors.textSecondary,
                fontSize: buttonFontSize,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _rejectedUsers.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Removed from rejection list', 
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: contentFontSize,
                    ),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(dialogRadius * 0.5),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
            ),
            child: Text(
              'Remove',
              style: TextStyle(fontSize: buttonFontSize),
            ),
          ),
        ],
      ),
    );
  }
}
