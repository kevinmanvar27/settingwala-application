import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/sugar_partner_service.dart';

class SugarPartnerBlockedUsersScreen extends StatefulWidget {
  const SugarPartnerBlockedUsersScreen({super.key});

  @override
  State<SugarPartnerBlockedUsersScreen> createState() => _SugarPartnerBlockedUsersScreenState();
}

class _SugarPartnerBlockedUsersScreenState extends State<SugarPartnerBlockedUsersScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<HardRejectUser> _blockedUsers = [];
  int _currentPage = 1;
  int _lastPage = 1;
  
  // Track users being unblocked
  final Set<int> _unblockingUsers = {};
  
  @override
  void initState() {
    super.initState();
    _loadBlockedUsers();
  }
  
  Future<void> _loadBlockedUsers({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore || _currentPage >= _lastPage) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }
    
    try {
      final page = loadMore ? _currentPage + 1 : 1;
      final response = await SugarPartnerService.getHardRejects(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _blockedUsers.addAll(response.data);
            _currentPage = page;
          } else {
            _blockedUsers = response.data;
            _currentPage = 1;
          }
          _lastPage = response.pagination?.lastPage ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load blocked users: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }
  
  Future<void> _unblockUser(HardRejectUser blockedUser) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final user = blockedUser.user;
    final userName = user?.name ?? 'this user';
    
    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.person_add, color: AppColors.success),
            const SizedBox(width: 8),
            Text(
              'Unblock User',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to unblock $userName?',
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'They will be able to send you exchange requests again.',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    // Start unblocking
    setState(() => _unblockingUsers.add(blockedUser.rejectedUserId));
    
    try {
      final response = await SugarPartnerService.removeHardReject(blockedUser.rejectedUserId);
      
      if (!mounted) return;
      
      if (response.success) {
        setState(() {
          _blockedUsers.removeWhere((u) => u.rejectedUserId == blockedUser.rejectedUserId);
          _unblockingUsers.remove(blockedUser.rejectedUserId);
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('$userName has been unblocked')),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else {
        setState(() => _unblockingUsers.remove(blockedUser.rejectedUserId));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _unblockingUsers.remove(blockedUser.rejectedUserId));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
  
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        if (difference.inHours == 0) {
          return '${difference.inMinutes}m ago';
        }
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else if (difference.inDays < 30) {
        return '${(difference.inDays / 7).floor()}w ago';
      } else if (difference.inDays < 365) {
        return '${(difference.inDays / 30).floor()}mo ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    Responsive.init(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final contentPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    return BaseScreen(
      title: 'Blocked Users',
      showBackButton: true,
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            margin: EdgeInsets.all(contentPadding),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.error.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.block, color: AppColors.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Blocked Users',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'These users cannot send you sugar partner exchange requests.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // List
          Expanded(
            child: _isLoading
                ? _buildLoadingState(colors, primaryColor)
                : _errorMessage != null
                    ? _buildErrorState(colors, primaryColor)
                    : _blockedUsers.isEmpty
                        ? _buildEmptyState(colors, primaryColor)
                        : _buildBlockedUsersList(colors, primaryColor, contentPadding, isSmallScreen, isTablet, isDesktop),
          ),
        ],
      ),
    );
  }
  
  Widget _buildLoadingState(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading blocked users...',
            style: TextStyle(color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorState(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadBlockedUsers(),
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
  
  Widget _buildEmptyState(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline,
                size: 64,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Blocked Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t blocked any sugar partner users yet.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _loadBlockedUsers(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: BorderSide(color: primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBlockedUsersList(
    AppColorSet colors,
    Color primaryColor,
    double contentPadding,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadBlockedUsers(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: contentPadding),
        itemCount: _blockedUsers.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _blockedUsers.length) {
            return _buildLoadMoreButton(colors, primaryColor);
          }
          return _buildBlockedUserCard(
            _blockedUsers[index],
            colors,
            primaryColor,
            isSmallScreen,
            isTablet,
            isDesktop,
          );
        },
      ),
    );
  }
  
  Widget _buildBlockedUserCard(
    HardRejectUser blockedUser,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 14.0;
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final avatarSize = isDesktop ? 52.0 : isTablet ? 48.0 : isSmallScreen ? 40.0 : 44.0;
    final titleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final subtitleFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    final user = blockedUser.user;
    final isUnblocking = _unblockingUsers.contains(blockedUser.rejectedUserId);
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Row(
          children: [
            // Avatar with blocked indicator
            Stack(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.error.withOpacity(0.5), width: 2),
                  ),
                  child: ClipOval(
                    child: user?.profilePhoto != null
                        ? CachedImage(
                            imageUrl: user!.profilePhoto!,
                            fit: BoxFit.cover,
                            errorWidget: _buildDefaultAvatar(colors, avatarSize),
                          )
                        : _buildDefaultAvatar(colors, avatarSize),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.card, width: 2),
                    ),
                    child: Icon(
                      Icons.block,
                      size: avatarSize * 0.25,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: isSmallScreen ? 10 : 14),
            
            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user?.name ?? 'Unknown User',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (user?.isVerified == true)
                        Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: Icon(
                            Icons.verified,
                            size: titleFontSize - 2,
                            color: AppColors.primary,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (user?.age != null) ...[
                        Text(
                          '${user!.age} years',
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: colors.textSecondary,
                          ),
                        ),
                        if (user.city != null)
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textTertiary,
                            ),
                          ),
                      ],
                      if (user?.city != null)
                        Expanded(
                          child: Text(
                            user!.city!,
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.block, size: subtitleFontSize, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        'Blocked ${_formatDate(blockedUser.rejectedAt)}',
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Unblock button
            SizedBox(
              width: isSmallScreen ? 80 : 90,
              child: isUnblocking
                  ? Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.success,
                        ),
                      ),
                    )
                  : OutlinedButton(
                      onPressed: () => _unblockUser(blockedUser),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: isSmallScreen ? 6 : 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Unblock',
                        style: TextStyle(fontSize: subtitleFontSize),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDefaultAvatar(AppColorSet colors, double size) {
    return Container(
      width: size,
      height: size,
      color: colors.background,
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: colors.textTertiary,
      ),
    );
  }
  
  Widget _buildLoadMoreButton(AppColorSet colors, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator(color: primaryColor)
            : OutlinedButton.icon(
                onPressed: () => _loadBlockedUsers(loadMore: true),
                icon: const Icon(Icons.expand_more),
                label: const Text('Load More'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  side: BorderSide(color: primaryColor),
                ),
              ),
      ),
    );
  }
}
