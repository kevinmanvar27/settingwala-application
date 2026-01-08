import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/subscription_service.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  const SubscriptionHistoryScreen({super.key});

  @override
  State<SubscriptionHistoryScreen> createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  List<SubscriptionHistoryItem> _subscriptions = [];
  
  int _currentPage = 1;
  int _lastPage = 1;
  
  final SubscriptionService _subscriptionService = SubscriptionService();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSubscriptionHistory();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadSubscriptionHistory({bool loadMore = false}) async {
    if (loadMore) {
      if (_currentPage >= _lastPage || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final page = loadMore ? _currentPage + 1 : 1;
      final response = await _subscriptionService.getSubscriptionHistory(page: page);

      if (!mounted) return;

      if (response.success) {
        setState(() {
          if (loadMore) {
            _subscriptions.addAll(response.subscriptions ?? []);
          } else {
            _subscriptions = response.subscriptions ?? [];
          }
          _currentPage = response.currentPage;
          _lastPage = response.lastPage;
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
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load subscription history. Please try again.';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _loadMore() async {
    await _loadSubscriptionHistory(loadMore: true);
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
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final itemSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final cardRadius = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 16.0;
    
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 14.0 : 15.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final priceFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 16.0 : 17.0;
    
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;

    return BaseScreen(
      title: 'Subscription History',
      showBackButton: true,
      body: _isLoading
          ? _buildLoadingState(colors, primaryColor)
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor)
              : _subscriptions.isEmpty
                  ? _buildEmptyState(colors, primaryColor)
                  : RefreshIndicator(
                      onRefresh: () => _loadSubscriptionHistory(),
                      color: primaryColor,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: maxContentWidth),
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.symmetric(
                              horizontal: horizontalPadding,
                              vertical: verticalPadding,
                            ),
                            itemCount: _subscriptions.length + (_isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == _subscriptions.length) {
                                return Padding(
                                  padding: EdgeInsets.all(itemSpacing),
                                  child: Center(
                                    child: CircularProgressIndicator(color: primaryColor),
                                  ),
                                );
                              }
                              
                              final subscription = _subscriptions[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: itemSpacing),
                                child: _buildSubscriptionCard(
                                  subscription: subscription,
                                  colors: colors,
                                  primaryColor: primaryColor,
                                  isDark: isDark,
                                  cardRadius: cardRadius,
                                  titleFontSize: titleFontSize,
                                  subtitleFontSize: subtitleFontSize,
                                  priceFontSize: priceFontSize,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
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
            'Loading subscription history...',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadSubscriptionHistory(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
              color: colors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Subscription History',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your subscription history will appear here once you subscribe to a plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required SubscriptionHistoryItem subscription,
    required AppColorSet colors,
    required Color primaryColor,
    required bool isDark,
    required double cardRadius,
    required double titleFontSize,
    required double subtitleFontSize,
    required double priceFontSize,
  }) {
    final statusColor = _getStatusColor(subscription.status);
    final statusIcon = _getStatusIcon(subscription.status);

    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black26 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(cardRadius),
                topRight: Radius.circular(cardRadius),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusIcon, color: statusColor, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      _capitalizeFirst(subscription.status ?? 'Unknown'),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                        fontSize: subtitleFontSize,
                      ),
                    ),
                  ],
                ),
                Text(
                  '₹${subscription.amount ?? '0'}',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: priceFontSize,
                  ),
                ),
              ],
            ),
          ),
          
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subscription.planName ?? 'Subscription Plan',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: titleFontSize,
                  ),
                ),
                const SizedBox(height: 12),
                
                // Date info
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.calendar_today_outlined,
                        label: 'Start Date',
                        value: _formatDate(subscription.startDate),
                        colors: colors,
                        primaryColor: primaryColor,
                        subtitleFontSize: subtitleFontSize,
                      ),
                    ),
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.event_outlined,
                        label: 'End Date',
                        value: _formatDate(subscription.endDate),
                        colors: colors,
                        primaryColor: primaryColor,
                        subtitleFontSize: subtitleFontSize,
                      ),
                    ),
                  ],
                ),
                
                if (subscription.transactionId != null) ...[
                  const SizedBox(height: 12),
                  Divider(color: colors.divider, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        size: 14,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Transaction ID: ',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: subtitleFontSize - 1,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          subscription.transactionId!,
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: subtitleFontSize - 1,
                            fontFamily: 'monospace',
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required AppColorSet colors,
    required Color primaryColor,
    required double subtitleFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: primaryColor),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: subtitleFontSize - 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: subtitleFontSize,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return AppColors.success;
      case 'expired':
        return AppColors.error;
      case 'cancelled':
        return AppColors.warning;
      case 'pending':
        return AppColors.info;
      default:
        return AppColors.gray500;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return Icons.check_circle;
      case 'expired':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      case 'pending':
        return Icons.hourglass_empty;
      default:
        return Icons.help_outline;
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
