import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/sugar_partner_service.dart';

class SugarPartnerExchangesScreen extends StatefulWidget {
  const SugarPartnerExchangesScreen({super.key});

  @override
  State<SugarPartnerExchangesScreen> createState() => _SugarPartnerExchangesScreenState();
}

class _SugarPartnerExchangesScreenState extends State<SugarPartnerExchangesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<SugarPartnerExchange> _exchanges = [];
  int _currentPage = 1;
  int _lastPage = 1;
  int _pendingCount = 0;
  
  late TabController _tabController;
  String _currentFilter = 'all';
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadExchanges();
    _loadPendingCount();
  }
  
  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }
  
  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    
    final filters = ['all', 'pending', 'accepted', 'rejected'];
    final newFilter = filters[_tabController.index];
    
    if (newFilter != _currentFilter) {
      setState(() {
        _currentFilter = newFilter;
        _currentPage = 1;
        _exchanges = [];
      });
      _loadExchanges();
    }
  }
  
  Future<void> _loadExchanges({bool loadMore = false}) async {
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
      final response = await SugarPartnerService.getExchanges(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _exchanges.addAll(_filterExchanges(response.data));
            _currentPage = page;
          } else {
            _exchanges = _filterExchanges(response.data);
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
        _errorMessage = 'Failed to load exchanges: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }
  
  List<SugarPartnerExchange> _filterExchanges(List<SugarPartnerExchange> exchanges) {
    if (_currentFilter == 'all') return exchanges;
    return exchanges.where((e) => e.status == _currentFilter).toList();
  }
  
  Future<void> _loadPendingCount() async {
    try {
      final response = await SugarPartnerService.getPendingCount();
      if (response.success) {
        setState(() => _pendingCount = response.count);
      }
    } catch (e) {
      
    }
  }
  
  Future<void> _respondToExchange(SugarPartnerExchange exchange, String action) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              action == 'accept' ? Icons.check_circle : Icons.cancel,
              color: action == 'accept' ? AppColors.success : AppColors.error,
            ),
            const SizedBox(width: 8),
            Text(
              action == 'accept' ? 'Accept Exchange' : 'Reject Exchange',
              style: TextStyle(color: colors.textPrimary),
            ),
          ],
        ),
        content: Text(
          action == 'accept'
              ? 'Are you sure you want to accept this exchange request?'
              : 'Are you sure you want to reject this exchange request?',
          style: TextStyle(color: colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: action == 'accept' ? AppColors.success : AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: Text(action == 'accept' ? 'Accept' : 'Reject'),
          ),
        ],
      ),
    );
    
    if (confirmed != true) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: primaryColor),
              const SizedBox(height: 16),
              Text('Processing...', style: TextStyle(color: colors.textPrimary)),
            ],
          ),
        ),
      ),
    );
    
    try {
      final response = await SugarPartnerService.respondToExchange(
        exchange.id,
        action: action,
      );
      
      Navigator.pop(context);
      
      if (response.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message.isNotEmpty ? response.message : 'Exchange ${action}ed successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadExchanges();
        _loadPendingCount();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
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
      title: 'Sugar Partner Exchanges',
      showBackButton: true,
      body: Column(
        children: [
          Container(
            color: colors.card,
            child: TabBar(
              controller: _tabController,
              labelColor: primaryColor,
              unselectedLabelColor: colors.textSecondary,
              indicatorColor: primaryColor,
              tabs: [
                const Tab(text: 'All'),
                Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Pending'),
                      if (_pendingCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$_pendingCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Tab(text: 'Accepted'),
                const Tab(text: 'Rejected'),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? _buildLoadingState(colors, primaryColor)
                : _errorMessage != null
                    ? _buildErrorState(colors, primaryColor)
                    : _exchanges.isEmpty
                        ? _buildEmptyState(colors, primaryColor)
                        : _buildExchangesList(colors, primaryColor, contentPadding, isSmallScreen, isTablet, isDesktop),
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
            'Loading exchanges...',
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
              onPressed: () => _loadExchanges(),
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
              Icons.swap_horiz,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Exchanges',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentFilter == 'all'
                  ? 'You don\'t have any sugar partner exchanges yet.'
                  : 'No ${_currentFilter} exchanges found.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _loadExchanges(),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
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
  
  Widget _buildExchangesList(AppColorSet colors, Color primaryColor, double padding, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: () => _loadExchanges(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(padding),
        itemCount: _exchanges.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _exchanges.length) {
            return _buildLoadMoreButton(colors, primaryColor);
          }
          return _buildExchangeCard(
            _exchanges[index],
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
  
  Widget _buildExchangeCard(
    SugarPartnerExchange exchange,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final avatarSize = isDesktop ? 60.0 : isTablet ? 56.0 : isSmallScreen ? 44.0 : 50.0;
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    
    final otherUser = exchange.initiator ?? exchange.receiver;
    final statusColor = _getStatusColor(exchange.status);
    final statusIcon = _getStatusIcon(exchange.status);
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: ClipOval(
                    child: otherUser?.profilePhoto != null
                        ? Image.network(
                            otherUser!.profilePhoto!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(colors, avatarSize),
                          )
                        : _buildDefaultAvatar(colors, avatarSize),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 10 : 14),
                
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
                                fontWeight: FontWeight.bold,
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
                                size: titleFontSize,
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
                    ],
                  ),
                ),
                
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
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
                          fontSize: subtitleFontSize - 2,
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
          
          if (exchange.message != null && exchange.message!.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: cardPadding, vertical: cardPadding / 2),
              decoration: BoxDecoration(
                color: colors.background,
              ),
              child: Text(
                '"${exchange.message}"',
                style: TextStyle(
                  fontSize: subtitleFontSize,
                  fontStyle: FontStyle.italic,
                  color: colors.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          
          Padding(
            padding: EdgeInsets.all(cardPadding),
            child: Row(
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
                  const SizedBox(width: 16),
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
                
                const Spacer(),
                
                if (exchange.status == 'pending') ...[
                  TextButton.icon(
                    onPressed: () => _respondToExchange(exchange, 'reject'),
                    icon: Icon(Icons.close, size: subtitleFontSize + 2),
                    label: Text('Reject', style: TextStyle(fontSize: subtitleFontSize)),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.error,
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _respondToExchange(exchange, 'accept'),
                    icon: Icon(Icons.check, size: subtitleFontSize + 2),
                    label: Text('Accept', style: TextStyle(fontSize: subtitleFontSize)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 12),
                    ),
                  ),
                ],
                
                if (exchange.status != 'pending')
                  TextButton.icon(
                    onPressed: () => _viewExchangeDetails(exchange),
                    icon: Icon(Icons.visibility, size: subtitleFontSize + 2),
                    label: Text('Details', style: TextStyle(fontSize: subtitleFontSize)),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
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
            : ElevatedButton(
                onPressed: () => _loadExchanges(loadMore: true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Load More'),
              ),
      ),
    );
  }
  
  void _viewExchangeDetails(SugarPartnerExchange exchange) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
    
    try {
      final response = await SugarPartnerService.getExchangeDetails(exchange.id);
      Navigator.pop(context);
      
      if (response.success && response.data != null) {
        _showExchangeDetailsDialog(response.data!, colors, primaryColor);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _showExchangeDetailsDialog(SugarPartnerExchange exchange, AppColorSet colors, Color primaryColor) {
    final otherUser = exchange.initiator ?? exchange.receiver;
    final statusColor = _getStatusColor(exchange.status);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: primaryColor),
            const SizedBox(width: 8),
            const Text('Exchange Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (otherUser != null) ...[
                _buildDetailRow('Name', otherUser.name ?? 'Unknown', colors),
                if (otherUser.age != null)
                  _buildDetailRow('Age', '${otherUser.age} years', colors),
                if (otherUser.city != null)
                  _buildDetailRow('City', otherUser.city!, colors),
                if (otherUser.gender != null)
                  _buildDetailRow('Gender', otherUser.gender!, colors),
                if (otherUser.rating != null)
                  _buildDetailRow('Rating', '${otherUser.rating!.toStringAsFixed(1)} ★', colors),
              ],
              const Divider(height: 24),
              
              _buildDetailRow('Status', exchange.status.toUpperCase(), colors, valueColor: statusColor),
              if (exchange.exchangeType != null)
                _buildDetailRow('Type', exchange.exchangeType!, colors),
              if (exchange.amount != null)
                _buildDetailRow('Amount', '₹${exchange.amount!.toStringAsFixed(0)}', colors),
              if (exchange.message != null && exchange.message!.isNotEmpty)
                _buildDetailRow('Message', exchange.message!, colors),
              if (exchange.createdAt != null)
                _buildDetailRow('Created', _formatDate(exchange.createdAt), colors),
              if (exchange.expiresAt != null)
                _buildDetailRow('Expires', _formatDate(exchange.expiresAt), colors),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.textSecondary)),
          ),
          if (exchange.status == 'accepted' && exchange.profilesViewed != true)
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _viewProfiles(exchange);
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Profiles'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, AppColorSet colors, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? colors.textPrimary,
                fontWeight: valueColor != null ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  void _viewProfiles(SugarPartnerExchange exchange) async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: CircularProgressIndicator(color: primaryColor),
      ),
    );
    
    try {
      final response = await SugarPartnerService.viewProfiles(exchange.id);
      Navigator.pop(context);
      
      if (response.success) {
        if (response.profiles.isNotEmpty) {
          _showProfilesDialog(response.profiles, colors, primaryColor);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No profiles available'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
      } else if (response.requiresPayment) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: colors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(Icons.payment, color: AppColors.warning),
                const SizedBox(width: 8),
                const Text('Payment Required'),
              ],
            ),
            content: Text(
              response.paymentAmount != null
                  ? 'Payment of ₹${response.paymentAmount!.toStringAsFixed(0)} is required to view profiles.'
                  : 'Payment is required to view profiles.',
              style: TextStyle(color: colors.textSecondary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment feature coming soon'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Pay Now'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
  
  void _showProfilesDialog(List<SugarPartnerUser> profiles, AppColorSet colors, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.people, color: primaryColor),
            const SizedBox(width: 8),
            Text('Profiles (${profiles.length})'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final user = profiles[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: user.profilePhoto != null
                      ? NetworkImage(user.profilePhoto!)
                      : null,
                  child: user.profilePhoto == null
                      ? Icon(Icons.person, color: colors.textTertiary)
                      : null,
                ),
                title: Row(
                  children: [
                    Text(user.name ?? 'Unknown'),
                    if (user.isVerified == true)
                      Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: Icon(Icons.verified, size: 16, color: AppColors.primary),
                      ),
                  ],
                ),
                subtitle: Text(
                  [
                    if (user.age != null) '${user.age} years',
                    if (user.city != null) user.city,
                  ].join(' • '),
                ),
                trailing: user.rating != null
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star, size: 16, color: AppColors.warning),
                          const SizedBox(width: 2),
                          Text(user.rating!.toStringAsFixed(1)),
                        ],
                      )
                    : null,
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: colors.textSecondary)),
          ),
        ],
      ),
    );
  }
}
