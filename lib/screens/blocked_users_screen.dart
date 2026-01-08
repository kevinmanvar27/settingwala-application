import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/app_colors.dart';
import '../Service/message_service.dart';

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  List<BlockedUser> _blockedUsers = [];
  bool _isLoading = true;
  String? _errorMessage;

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
    
    _loadBlockedUsers();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadBlockedUsers() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await MessageService.getBlockedUsers();
      
      if (mounted) {
        setState(() {
          _isLoading = false;
          if (response != null && response.success) {
            _blockedUsers = response.blockedUsers;
            _animationController.forward();
          } else {
            _errorMessage = response?.message ?? 'Failed to load blocked users';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error loading blocked users: $e';
        });
      }
    }
  }

  Future<void> _unblockUser(BlockedUser user) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await MessageService.unblockUser(user.id);

      if (mounted) {
        Navigator.of(context).pop(); // Close loading

        if (response != null && response.success) {
          setState(() {
            _blockedUsers.removeWhere((u) => u.id == user.id);
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name ?? 'User'} has been unblocked'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?.message ?? 'Failed to unblock user'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error unblocking user: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showUnblockDialog(BlockedUser user, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_add_alt_1, color: primaryColor),
            const SizedBox(width: 8),
            Text(
              'Unblock User',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to unblock ${user.name ?? 'this user'}? They will be able to send you messages again.',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: colors.textTertiary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _unblockUser(user);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
  }

  String _formatBlockedDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Blocked ${difference.inMinutes} min ago';
      }
      return 'Blocked ${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Blocked yesterday';
    } else if (difference.inDays < 7) {
      return 'Blocked ${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return 'Blocked ${weeks}w ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return 'Blocked ${months}mo ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorUtils.getColorSet(context);
    final primaryColor = AppColorUtils.getPrimaryColor(context);
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive sizing
    final listPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final cardMarginBottom = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final avatarRadius = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 22.0 : 26.0;
    final avatarIconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 22.0 : 26.0;
    final nameTextSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final dateTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final avatarSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final emptyIconSize = isDesktop ? 80.0 : isTablet ? 72.0 : isSmallScreen ? 56.0 : 64.0;
    final emptyTitleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final emptySubtitleSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final emptySpacingSmall = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final emptySpacingMedium = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    return BaseScreen(
      title: 'Blocked Users',
      showBackButton: true,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor, emptyIconSize, emptyTitleSize, emptySubtitleSize, emptySpacingSmall, emptySpacingMedium)
              : RefreshIndicator(
                  onRefresh: _loadBlockedUsers,
                  color: primaryColor,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _blockedUsers.isEmpty
                        ? _buildEmptyState(
                            colors,
                            iconSize: emptyIconSize,
                            titleSize: emptyTitleSize,
                            subtitleSize: emptySubtitleSize,
                            spacingSmall: emptySpacingSmall,
                            spacingMedium: emptySpacingMedium,
                          )
                        : ListView.builder(
                            padding: EdgeInsets.all(listPadding),
                            itemCount: _blockedUsers.length,
                            itemBuilder: (context, index) {
                              return _buildBlockedUserCard(
                                _blockedUsers[index], 
                                colors, 
                                primaryColor,
                                cardRadius: cardRadius,
                                cardMarginBottom: cardMarginBottom,
                                cardPadding: cardPadding,
                                avatarRadius: avatarRadius,
                                avatarIconSize: avatarIconSize,
                                nameTextSize: nameTextSize,
                                dateTextSize: dateTextSize,
                                avatarSpacing: avatarSpacing,
                              );
                            },
                          ),
                  ),
                ),
    );
  }

  Widget _buildEmptyState(
    AppColorSet colors, {
    required double iconSize,
    required double titleSize,
    required double subtitleSize,
    required double spacingSmall,
    required double spacingMedium,
  }) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(spacingMedium * 2),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off_outlined,
                size: iconSize,
                color: colors.textTertiary,
              ),
              SizedBox(height: spacingMedium),
              Text(
                'No Blocked Users',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: spacingSmall),
              Text(
                'Users you block will appear here',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: subtitleSize,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(
    AppColorSet colors,
    Color primaryColor,
    double iconSize,
    double titleSize,
    double subtitleSize,
    double spacingSmall,
    double spacingMedium,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(spacingMedium * 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: iconSize,
              color: AppColors.error,
            ),
            SizedBox(height: spacingMedium),
            Text(
              'Something went wrong',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: titleSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: spacingSmall),
            Text(
              _errorMessage ?? 'Failed to load blocked users',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: subtitleSize,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: spacingMedium),
            ElevatedButton(
              onPressed: _loadBlockedUsers,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedUserCard(
    BlockedUser user,
    AppColorSet colors,
    Color primaryColor, {
    required double cardRadius,
    required double cardMarginBottom,
    required double cardPadding,
    required double avatarRadius,
    required double avatarIconSize,
    required double nameTextSize,
    required double dateTextSize,
    required double avatarSpacing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: cardMarginBottom),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(cardRadius),
          onTap: () => _showUnblockDialog(user, colors, primaryColor),
          child: Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: avatarRadius,
                  backgroundColor: colors.border,
                  backgroundImage: user.profilePhoto != null
                      ? NetworkImage(user.profilePhoto!)
                      : null,
                  child: user.profilePhoto == null
                      ? Icon(
                          Icons.person,
                          size: avatarIconSize,
                          color: colors.textTertiary,
                        )
                      : null,
                ),
                SizedBox(width: avatarSpacing),
                
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name ?? 'Unknown User',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: nameTextSize,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatBlockedDate(user.blockedAt),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: dateTextSize,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Unblock button
                TextButton.icon(
                  onPressed: () => _showUnblockDialog(user, colors, primaryColor),
                  icon: Icon(
                    Icons.person_add_alt_1,
                    size: avatarIconSize * 0.7,
                    color: primaryColor,
                  ),
                  label: Text(
                    'Unblock',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
