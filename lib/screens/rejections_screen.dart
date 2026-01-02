import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/blocked_users_service.dart';
import '../model/blocked_users_model.dart';
import 'package:intl/intl.dart';

class RejectionsScreen extends StatefulWidget {
  const RejectionsScreen({super.key});

  @override
  State<RejectionsScreen> createState() => _RejectionsScreenState();
}

class _RejectionsScreenState extends State<RejectionsScreen> {
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await BlockedUsersService.getBlockedUsers();
      if (result != null && result.success) {
        setState(() {
          _blockedUsers = result.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _blockedUsers = [];
          _isLoading = false;
          _errorMessage = result?.message ?? 'Failed to load blocked users';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading blocked users: $e';
      });
    }
  }

  String _formatBlockedDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
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
    
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    
    final itemSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    
    final headerRadius = isDesktop ? 36.0 : isTablet ? 34.0 : isSmallScreen ? 24.0 : 30.0;
    final cardRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    
    final headerTitleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final headerSubtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final nameFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final emailFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final infoFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final reasonFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 9.0 : 11.0;
    final avatarInitialFontSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final emptyTitleFontSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 17.0 : 20.0;
    final emptySubtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final buttonFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    
    final headerIconSize = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 26.0 : 32.0;
    final headerIconPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final infoIconSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 52.0 : 64.0;
    final emptyIconPadding = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    
    final avatarSize = isDesktop ? 72.0 : isTablet ? 68.0 : isSmallScreen ? 50.0 : 60.0;
    final avatarBorderWidth = isDesktop ? 3.0 : isTablet ? 2.5 : isSmallScreen ? 1.5 : 2.0;
    
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'Blocked Users',
      showBackButton: true,
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: Column(
            children: [
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
              
              Expanded(
                child: _isLoading
                    ? _buildLoadingState(primaryColor)
                    : _errorMessage != null
                        ? _buildErrorState(colors, primaryColor, emptyTitleFontSize, emptySubtitleFontSize)
                        : _blockedUsers.isEmpty
                            ? _buildEmptyState(
                                colors, 
                                primaryColor,
                                iconSize: emptyIconSize,
                                iconPadding: emptyIconPadding,
                                titleFontSize: emptyTitleFontSize,
                                subtitleFontSize: emptySubtitleFontSize,
                              )
                            : RefreshIndicator(
                                onRefresh: _loadBlockedUsers,
                                color: primaryColor,
                                child: ListView.builder(
                                  padding: EdgeInsets.all(horizontalPadding),
                                  itemCount: _blockedUsers.length,
                                  itemBuilder: (context, index) {
                                    return _buildBlockedUserCard(
                                      _blockedUsers[index], 
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
                                      emailFontSize: emailFontSize,
                                      infoFontSize: infoFontSize,
                                      reasonFontSize: reasonFontSize,
                                      infoIconSize: infoIconSize,
                                      buttonFontSize: buttonFontSize,
                                      itemSpacing: itemSpacing,
                                    );
                                  },
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(Color primaryColor) {
    return Center(
      child: CircularProgressIndicator(
        color: primaryColor,
      ),
    );
  }

  Widget _buildErrorState(AppColorSet colors, Color primaryColor, double titleFontSize, double subtitleFontSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              style: TextStyle(
                fontSize: subtitleFontSize,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadBlockedUsers,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
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
              Icons.block,
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
                  'Blocked Users',
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
                SizedBox(height: headerPadding * 0.25),
                Text(
                  _isLoading 
                      ? 'Loading...' 
                      : '${_blockedUsers.length} user${_blockedUsers.length != 1 ? 's' : ''} blocked',
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
            'No Blocked Users',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: iconPadding * 0.33),
          Text(
            'You haven\'t blocked anyone yet',
            style: TextStyle(
              fontSize: subtitleFontSize,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedUserCard(
    BlockedUser user, 
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
    required double emailFontSize,
    required double infoFontSize,
    required double reasonFontSize,
    required double infoIconSize,
    required double buttonFontSize,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.error.withOpacity(0.3),
                  width: avatarBorderWidth,
                ),
              ),
              child: user.profilePicture != null && user.profilePicture!.isNotEmpty
                  ? CircleAvatar(
                      radius: avatarSize / 2 - avatarBorderWidth,
                      backgroundImage: NetworkImage(user.profilePicture!),
                    )
                  : CircleAvatar(
                      radius: avatarSize / 2 - avatarBorderWidth,
                      backgroundColor: AppColors.error.withOpacity(0.1),
                      child: Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: avatarInitialFontSize,
                          fontWeight: FontWeight.bold,
                          color: AppColors.error,
                        ),
                      ),
                    ),
            ),
            SizedBox(width: cardPadding),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: TextStyle(
                      fontSize: nameFontSize,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  SizedBox(height: cardPadding * 0.25),
                  
                  if (user.email != null && user.email!.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: infoIconSize,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: infoIconSize * 0.35),
                        Expanded(
                          child: Text(
                            user.email!,
                            style: TextStyle(
                              fontSize: emailFontSize,
                              color: colors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: cardPadding * 0.4),
                  
                  Row(
                    children: [
                      Icon(
                        Icons.block,
                        size: infoIconSize,
                        color: AppColors.error,
                      ),
                      SizedBox(width: infoIconSize * 0.35),
                      Text(
                        'Blocked On: ',
                        style: TextStyle(
                          fontSize: infoFontSize,
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        _formatBlockedDate(user.blockedOn),
                        style: TextStyle(
                          fontSize: infoFontSize,
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: cardPadding * 0.25),
                  
                  if (user.timeAgo.isNotEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: infoIconSize,
                          color: colors.textSecondary,
                        ),
                        SizedBox(width: infoIconSize * 0.35),
                        Text(
                          user.timeAgo,
                          style: TextStyle(
                            fontSize: infoFontSize,
                            color: colors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: cardPadding * 0.4),
                  
                  if (user.reason != null && user.reason!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: cardPadding * 0.75,
                        vertical: cardPadding * 0.4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(cardRadius * 0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: infoIconSize,
                            color: AppColors.error,
                          ),
                          SizedBox(width: infoIconSize * 0.35),
                          Flexible(
                            child: Text(
                              user.reason!,
                              style: TextStyle(
                                fontSize: reasonFontSize,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: cardPadding * 0.75),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _unblockUser(user, colors, primaryColor, isDark),
                      icon: Icon(Icons.lock_open, size: infoIconSize + 2),
                      label: Text(
                        'Unblock User',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: isDark ? AppColors.black : AppColors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: cardPadding,
                          vertical: cardPadding * 0.75,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(cardRadius * 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _unblockUser(BlockedUser user, AppColorSet colors, Color primaryColor, bool isDark) {
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
          'Unblock User',
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: titleFontSize,
          ),
        ),
        content: Text(
          'Are you sure you want to unblock ${user.name}?',
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
            onPressed: () async {
              Navigator.pop(context);
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => Center(
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              );
              
              final result = await BlockedUsersService.unblockUser(user.id);
              
              if (mounted) Navigator.pop(context);
              
              if (result != null && (result['success'] == true || result['status'] == true)) {
                setState(() {
                  _blockedUsers.removeWhere((u) => u.id == user.id);
                });
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        '${user.name} has been unblocked', 
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
                }
              } else {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        result?['message'] ?? 'Failed to unblock user', 
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
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
            ),
            child: Text(
              'Unblock',
              style: TextStyle(fontSize: buttonFontSize),
            ),
          ),
        ],
      ),
    );
  }
}
