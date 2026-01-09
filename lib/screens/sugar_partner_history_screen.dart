import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/sugar_partner_service.dart';

class SugarPartnerHistoryScreen extends StatefulWidget {
  const SugarPartnerHistoryScreen({super.key});

  @override
  State<SugarPartnerHistoryScreen> createState() => _SugarPartnerHistoryScreenState();
}

class _SugarPartnerHistoryScreenState extends State<SugarPartnerHistoryScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<SugarPartnerExchange> _history = [];
  int _currentPage = 1;
  int _lastPage = 1;
  
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }
  
  Future<void> _loadHistory({bool loadMore = false}) async {
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
      final response = await SugarPartnerService.getHistory(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _history.addAll(response.data);
            _currentPage = page;
          } else {
            _history = response.data;
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
        _errorMessage = 'Failed to load history: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
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
  
  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.warning;
      case 'accepted':
        return AppColors.success;
      case 'rejected':
        return AppColors.error;
      case 'expired':
        return Colors.grey;
      case 'completed':
        return AppColors.primary;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'expired':
        return Icons.timer_off;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.help_outline;
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
      title: 'Exchange History',
      showBackButton: true,
      body: _isLoading
          ? _buildLoadingState(colors, primaryColor)
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor)
              : _history.isEmpty
                  ? _buildEmptyState(colors, primaryColor)
                  : _buildHistoryList(colors, primaryColor, contentPadding, isSmallScreen, isTablet, isDesktop),
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
            'Loading history...',
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
              onPressed: () => _loadHistory(),
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
            Icon(
              Icons.history,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your past sugar partner exchanges will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _loadHistory(),
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
  
  Widget _buildHistoryList(
    AppColorSet colors,
    Color primaryColor,
    double contentPadding,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadHistory(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(contentPadding),
        itemCount: _history.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _history.length) {
            return _buildLoadMoreButton(colors, primaryColor);
          }
          return _buildHistoryCard(
            _history[index],
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
  
  Widget _buildHistoryCard(
    SugarPartnerExchange exchange,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final avatarSize = isDesktop ? 56.0 : isTablet ? 52.0 : isSmallScreen ? 40.0 : 48.0;
    final titleFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 14.0 : 15.0;
    final subtitleFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    final otherUser = exchange.initiator ?? exchange.receiver;
    final statusColor = _getStatusColor(exchange.status);
    final statusIcon = _getStatusIcon(exchange.status);
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: colors.border.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showExchangeDetails(exchange, colors, primaryColor),
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              // Avatar
              Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: statusColor.withOpacity(0.5), width: 2),
                ),
                child: ClipOval(
                  child: otherUser?.profilePhoto != null
                      ? CachedImage(
                          imageUrl: otherUser!.profilePhoto!,
                          fit: BoxFit.cover,
                          errorWidget: _buildDefaultAvatar(colors, avatarSize),
                        )
                      : _buildDefaultAvatar(colors, avatarSize),
                ),
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
                            otherUser?.name ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (otherUser?.isVerified == true)
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
                        if (otherUser?.age != null) ...[
                          Text(
                            '${otherUser!.age} years',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textSecondary,
                            ),
                          ),
                          if (otherUser.city != null)
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: subtitleFontSize,
                                color: colors.textTertiary,
                              ),
                            ),
                        ],
                        if (otherUser?.city != null)
                          Expanded(
                            child: Text(
                              otherUser!.city!,
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
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: subtitleFontSize, color: colors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(exchange.createdAt),
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: colors.textTertiary,
                          ),
                        ),
                        if (exchange.amount != null) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.currency_rupee, size: subtitleFontSize, color: AppColors.success),
                          Text(
                            '${exchange.amount!.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 8 : 10,
                  vertical: isSmallScreen ? 4 : 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, size: subtitleFontSize, color: statusColor),
                    const SizedBox(width: 4),
                    Text(
                      exchange.status.toUpperCase(),
                      style: TextStyle(
                        fontSize: subtitleFontSize - 1,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
                onPressed: () => _loadHistory(loadMore: true),
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
  
  void _showExchangeDetails(SugarPartnerExchange exchange, AppColorSet colors, Color primaryColor) {
    final otherUser = exchange.initiator ?? exchange.receiver;
    final statusColor = _getStatusColor(exchange.status);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.textTertiary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: ClipOval(
                    child: otherUser?.profilePhoto != null
                        ? CachedImage(
                            imageUrl: otherUser!.profilePhoto!,
                            fit: BoxFit.cover,
                            errorWidget: _buildDefaultAvatar(colors, 60),
                          )
                        : _buildDefaultAvatar(colors, 60),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            otherUser?.name ?? 'Unknown User',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                          ),
                          if (otherUser?.isVerified == true)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.verified, size: 18, color: AppColors.primary),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          if (otherUser?.age != null) '${otherUser!.age} years',
                          if (otherUser?.city != null) otherUser!.city,
                        ].join(' • '),
                        style: TextStyle(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            
            // Details
            _buildDetailRow('Status', exchange.status.toUpperCase(), statusColor, colors),
            if (exchange.exchangeType != null)
              _buildDetailRow('Type', exchange.exchangeType!, primaryColor, colors),
            if (exchange.amount != null)
              _buildDetailRow('Amount', '₹${exchange.amount!.toStringAsFixed(2)}', AppColors.success, colors),
            _buildDetailRow('Date', _formatDate(exchange.createdAt), colors.textSecondary, colors),
            
            if (exchange.message != null && exchange.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Message',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.background,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  exchange.message!,
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 24),
            
            // Close button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, Color valueColor, AppColorSet colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
