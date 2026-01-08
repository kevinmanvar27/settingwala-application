import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/base_screen.dart';
import '../widgets/cached_image.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/dispute_service.dart';

class DisputesScreen extends StatefulWidget {
  const DisputesScreen({super.key});

  @override
  State<DisputesScreen> createState() => _DisputesScreenState();
}

class _DisputesScreenState extends State<DisputesScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  List<Dispute> _disputes = [];
  int _currentPage = 1;
  int _lastPage = 1;
  String _selectedStatus = 'all';
  
  late TabController _tabController;
  
  final List<Map<String, String>> _statusFilters = [
    {'value': 'all', 'label': 'All'},
    {'value': 'pending', 'label': 'Pending'},
    {'value': 'under_review', 'label': 'Under Review'},
    {'value': 'resolved', 'label': 'Resolved'},
    {'value': 'cancelled', 'label': 'Cancelled'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadDisputes();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final newStatus = _statusFilters[_tabController.index]['value']!;
      if (newStatus != _selectedStatus) {
        setState(() {
          _selectedStatus = newStatus;
          _currentPage = 1;
          _disputes = [];
        });
        _loadDisputes();
      }
    }
  }

  Future<void> _loadDisputes({bool loadMore = false}) async {
    if (loadMore) {
      if (_currentPage >= _lastPage || _isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final response = await DisputeService.getDisputes(
        page: loadMore ? _currentPage + 1 : 1,
        status: _selectedStatus == 'all' ? null : _selectedStatus,
      );

      if (response.success && mounted) {
        setState(() {
          if (loadMore) {
            _disputes.addAll(response.data);
            _currentPage++;
          } else {
            _disputes = response.data;
            _currentPage = 1;
          }
          _lastPage = response.pagination?.lastPage ?? 1;
          _isLoading = false;
          _isLoadingMore = false;
        });
      } else if (mounted) {
        setState(() {
          _error = response.message;
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load disputes. Please try again.';
          _isLoading = false;
          _isLoadingMore = false;
        });
      }
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
      title: 'My Disputes',
      showBackButton: true,
      body: Column(
        children: [
          _buildTabBar(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
          
          Expanded(
            child: _isLoading
                ? _buildLoadingState(colors)
                : _error != null
                    ? _buildErrorState(colors, primaryColor, isSmallScreen, isTablet, isDesktop)
                    : _disputes.isEmpty
                        ? _buildEmptyState(colors, primaryColor, isSmallScreen, isTablet, isDesktop)
                        : _buildDisputesList(colors, primaryColor, isDark, contentPadding, isSmallScreen, isTablet, isDesktop),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showRaiseDisputeDialog(colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
        backgroundColor: primaryColor,
        foregroundColor: isDark ? AppColors.black : AppColors.white,
        icon: const Icon(Icons.add),
        label: const Text('Raise Dispute'),
      ),
    );
  }

  Widget _buildTabBar(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final tabFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    
    return Container(
      color: colors.card,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: primaryColor,
        unselectedLabelColor: colors.textSecondary,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: tabFontSize,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: tabFontSize,
          fontWeight: FontWeight.normal,
        ),
        tabs: _statusFilters.map((filter) => Tab(text: filter['label'])).toList(),
      ),
    );
  }

  Widget _buildLoadingState(AppColorSet colors) {
    return Center(
      child: CircularProgressIndicator(color: colors.textPrimary),
    );
  }

  Widget _buildErrorState(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final iconSize = isDesktop ? 80.0 : isTablet ? 70.0 : isSmallScreen ? 50.0 : 60.0;
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final buttonFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: iconSize, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Something went wrong',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: titleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadDisputes,
              icon: const Icon(Icons.refresh),
              label: Text('Retry', style: TextStyle(fontSize: buttonFontSize)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final iconSize = isDesktop ? 100.0 : isTablet ? 90.0 : isSmallScreen ? 60.0 : 80.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final subtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.gavel_outlined,
              size: iconSize,
              color: colors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedStatus == 'all' ? 'No Disputes Yet' : 'No ${_statusFilters.firstWhere((f) => f['value'] == _selectedStatus)['label']} Disputes',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You haven\'t raised any disputes.\nIf you have an issue with a booking, tap the button below.',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: subtitleFontSize,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisputesList(AppColorSet colors, Color primaryColor, bool isDark, double contentPadding, bool isSmallScreen, bool isTablet, bool isDesktop) {
    return RefreshIndicator(
      onRefresh: () => _loadDisputes(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(contentPadding),
        itemCount: _disputes.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _disputes.length) {
            return _buildLoadMoreButton(colors, primaryColor, isSmallScreen, isTablet, isDesktop);
          }
          return _buildDisputeCard(_disputes[index], colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop);
        },
      ),
    );
  }

  Widget _buildLoadMoreButton(AppColorSet colors, Color primaryColor, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final buttonFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator(color: primaryColor)
            : TextButton.icon(
                onPressed: () => _loadDisputes(loadMore: true),
                icon: const Icon(Icons.expand_more),
                label: Text('Load More', style: TextStyle(fontSize: buttonFontSize)),
                style: TextButton.styleFrom(foregroundColor: primaryColor),
              ),
      ),
    );
  }

  Widget _buildDisputeCard(Dispute dispute, AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final cardRadius = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 15.0;
    final subtitleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final smallFontSize = isDesktop ? 12.0 : isTablet ? 11.0 : isSmallScreen ? 9.0 : 10.0;
    
    return Card(
      margin: EdgeInsets.only(bottom: isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0),
      color: colors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      elevation: 2,
      child: InkWell(
        onTap: () => _showDisputeDetails(dispute, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Dispute #${dispute.id}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildStatusBadge(dispute.status, colors, smallFontSize),
                ],
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              Text(
                dispute.reason,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: subtitleFontSize,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
              
              Text(
                dispute.description,
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: smallFontSize,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isSmallScreen ? 8 : 12),
              
              if (dispute.booking != null) ...[
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, size: isSmallScreen ? 16 : 20, color: colors.textSecondary),
                      SizedBox(width: isSmallScreen ? 6 : 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Booking #${dispute.booking!.bookingNumber ?? dispute.bookingId}',
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: smallFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (dispute.booking!.serviceName != null)
                              Text(
                                dispute.booking!.serviceName!,
                                style: TextStyle(
                                  color: colors.textSecondary,
                                  fontSize: smallFontSize - 1,
                                ),
                              ),
                          ],
                        ),
                      ),
                      if (dispute.booking!.amount != null)
                        Text(
                          '₹${dispute.booking!.amount!.toStringAsFixed(0)}',
                          style: TextStyle(
                            color: primaryColor,
                            fontSize: subtitleFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: isSmallScreen ? 8 : 12),
              ],
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(dispute.createdAt),
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: smallFontSize,
                    ),
                  ),
                  Row(
                    children: [
                      if (dispute.status == 'pending' || dispute.status == 'under_review')
                        TextButton.icon(
                          onPressed: () => _showCancelDisputeDialog(dispute, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
                          icon: Icon(Icons.cancel_outlined, size: isSmallScreen ? 14 : 16),
                          label: Text('Cancel', style: TextStyle(fontSize: smallFontSize)),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
                          ),
                        ),
                      TextButton.icon(
                        onPressed: () => _showDisputeDetails(dispute, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop),
                        icon: Icon(Icons.visibility_outlined, size: isSmallScreen ? 14 : 16),
                        label: Text('View', style: TextStyle(fontSize: smallFontSize)),
                        style: TextButton.styleFrom(
                          foregroundColor: primaryColor,
                          padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status, AppColorSet colors, double fontSize) {
    Color bgColor;
    Color textColor;
    String label;
    IconData icon;
    
    switch (status.toLowerCase()) {
      case 'pending':
        bgColor = AppColors.warning.withValues(alpha: 0.15);
        textColor = AppColors.warning;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case 'under_review':
        bgColor = AppColors.info.withValues(alpha: 0.15);
        textColor = AppColors.info;
        label = 'Under Review';
        icon = Icons.search;
        break;
      case 'resolved':
        bgColor = AppColors.success.withValues(alpha: 0.15);
        textColor = AppColors.success;
        label = 'Resolved';
        icon = Icons.check_circle;
        break;
      case 'cancelled':
        bgColor = colors.textSecondary.withValues(alpha: 0.15);
        textColor = colors.textSecondary;
        label = 'Cancelled';
        icon = Icons.cancel;
        break;
      case 'escalated':
        bgColor = AppColors.error.withValues(alpha: 0.15);
        textColor = AppColors.error;
        label = 'Escalated';
        icon = Icons.priority_high;
        break;
      default:
        bgColor = colors.textSecondary.withValues(alpha: 0.15);
        textColor = colors.textSecondary;
        label = status;
        icon = Icons.help_outline;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: fontSize + 2, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showDisputeDetails(Dispute dispute, AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final dialogRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 15.0 : 17.0;
    final contentFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final smallFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogRadius)),
        child: Container(
          constraints: BoxConstraints(
            maxWidth: isDesktop ? 600 : isTablet ? 500 : double.infinity,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(dialogRadius),
                    topRight: Radius.circular(dialogRadius),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.gavel, color: primaryColor, size: isSmallScreen ? 22 : 28),
                    SizedBox(width: isSmallScreen ? 10 : 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispute #${dispute.id}',
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildStatusBadge(dispute.status, colors, smallFontSize),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.close, color: colors.textSecondary),
                    ),
                  ],
                ),
              ),
              
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 14 : 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailSection('Reason', dispute.reason, colors, contentFontSize, smallFontSize),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      
                      _buildDetailSection('Description', dispute.description, colors, contentFontSize, smallFontSize),
                      SizedBox(height: isSmallScreen ? 12 : 16),
                      
                      if (dispute.resolution != null) ...[
                        _buildDetailSection('Resolution', dispute.resolution!, colors, contentFontSize, smallFontSize, isResolution: true),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                      ],
                      
                      if (dispute.booking != null) ...[
                        Text(
                          'Booking Details',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: contentFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: [
                              _buildBookingDetailRow('Booking #', dispute.booking!.bookingNumber ?? dispute.bookingId.toString(), colors, smallFontSize),
                              if (dispute.booking!.serviceName != null)
                                _buildBookingDetailRow('Service', dispute.booking!.serviceName!, colors, smallFontSize),
                              if (dispute.booking!.date != null)
                                _buildBookingDetailRow('Date', dispute.booking!.date!, colors, smallFontSize),
                              if (dispute.booking!.amount != null)
                                _buildBookingDetailRow('Amount', '₹${dispute.booking!.amount!.toStringAsFixed(0)}', colors, smallFontSize),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                      ],
                      
                      if (dispute.evidence != null && dispute.evidence!.isNotEmpty) ...[
                        Text(
                          'Evidence (${dispute.evidence!.length})',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: contentFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dispute.evidence!.length,
                            itemBuilder: (context, index) {
                              final evidence = dispute.evidence![index];
                              return Container(
                                width: 80,
                                height: 80,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: colors.background,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: colors.textSecondary.withValues(alpha: 0.3)),
                                ),
                                child: evidence.fileUrl != null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: CachedImage(
                                          imageUrl: evidence.fileUrl!,
                                          fit: BoxFit.cover,
                                          errorWidget: Icon(
                                            Icons.broken_image,
                                            color: colors.textSecondary,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.attach_file,
                                        color: colors.textSecondary,
                                      ),
                              );
                            },
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                      ],
                      
                      if (dispute.messages != null && dispute.messages!.isNotEmpty) ...[
                        Text(
                          'Messages (${dispute.messages!.length})',
                          style: TextStyle(
                            color: colors.textPrimary,
                            fontSize: contentFontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...dispute.messages!.map((msg) => _buildMessageItem(msg, colors, smallFontSize, primaryColor)),
                      ],
                      
                      const SizedBox(height: 16),
                      Divider(color: colors.textSecondary.withValues(alpha: 0.2)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Created: ${_formatDate(dispute.createdAt)}',
                            style: TextStyle(color: colors.textSecondary, fontSize: smallFontSize),
                          ),
                          if (dispute.resolvedAt != null)
                            Text(
                              'Resolved: ${_formatDate(dispute.resolvedAt)}',
                              style: TextStyle(color: AppColors.success, fontSize: smallFontSize),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              if (dispute.status == 'pending' || dispute.status == 'under_review')
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: colors.textSecondary.withValues(alpha: 0.2))),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showAddMessageDialog(dispute, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop);
                          },
                          icon: const Icon(Icons.message),
                          label: const Text('Add Message'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: primaryColor,
                            side: BorderSide(color: primaryColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _showCancelDisputeDialog(dispute, colors, primaryColor, isDark, isSmallScreen, isTablet, isDesktop);
                          },
                          icon: const Icon(Icons.cancel),
                          label: const Text('Cancel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            foregroundColor: AppColors.white,
                          ),
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

  Widget _buildDetailSection(String title, String content, AppColorSet colors, double contentFontSize, double smallFontSize, {bool isResolution = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: contentFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isResolution ? AppColors.success.withValues(alpha: 0.1) : colors.background,
            borderRadius: BorderRadius.circular(8),
            border: isResolution ? Border.all(color: AppColors.success.withValues(alpha: 0.3)) : null,
          ),
          child: Text(
            content,
            style: TextStyle(
              color: isResolution ? AppColors.success : colors.textSecondary,
              fontSize: smallFontSize,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBookingDetailRow(String label, String value, AppColorSet colors, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: colors.textSecondary, fontSize: fontSize)),
          Text(value, style: TextStyle(color: colors.textPrimary, fontSize: fontSize, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildMessageItem(DisputeMessage message, AppColorSet colors, double fontSize, Color primaryColor) {
    final isAdmin = message.isAdmin ?? false;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isAdmin ? primaryColor.withValues(alpha: 0.1) : colors.background,
        borderRadius: BorderRadius.circular(8),
        border: isAdmin ? Border.all(color: primaryColor.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    isAdmin ? Icons.support_agent : Icons.person,
                    size: fontSize + 4,
                    color: isAdmin ? primaryColor : colors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isAdmin ? 'Support' : (message.user?.name ?? 'You'),
                    style: TextStyle(
                      color: isAdmin ? primaryColor : colors.textPrimary,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Text(
                _formatDate(message.createdAt),
                style: TextStyle(color: colors.textSecondary, fontSize: fontSize - 2),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message.message,
            style: TextStyle(color: colors.textSecondary, fontSize: fontSize),
          ),
        ],
      ),
    );
  }

  void _showRaiseDisputeDialog(AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    final bookingIdController = TextEditingController();
    final reasonController = TextEditingController();
    final descriptionController = TextEditingController();
    List<File> evidenceFiles = [];
    bool isSubmitting = false;
    
    final dialogRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final titleFontSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 15.0 : 17.0;
    final contentFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: colors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(dialogRadius)),
          title: Row(
            children: [
              Icon(Icons.report_problem, color: AppColors.warning, size: isSmallScreen ? 22 : 26),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'Raise a Dispute',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleFontSize,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: bookingIdController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(color: colors.textPrimary, fontSize: contentFontSize),
                  decoration: InputDecoration(
                    labelText: 'Booking ID *',
                    labelStyle: TextStyle(color: colors.textSecondary),
                    hintText: 'Enter the booking ID',
                    hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.receipt, color: colors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: reasonController,
                  style: TextStyle(color: colors.textPrimary, fontSize: contentFontSize),
                  decoration: InputDecoration(
                    labelText: 'Reason *',
                    labelStyle: TextStyle(color: colors.textSecondary),
                    hintText: 'Brief reason for dispute',
                    hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: Icon(Icons.help_outline, color: colors.textSecondary),
                  ),
                ),
                const SizedBox(height: 16),
                
                TextField(
                  controller: descriptionController,
                  maxLines: 4,
                  style: TextStyle(color: colors.textPrimary, fontSize: contentFontSize),
                  decoration: InputDecoration(
                    labelText: 'Description *',
                    labelStyle: TextStyle(color: colors.textSecondary),
                    hintText: 'Provide detailed description of the issue...',
                    hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.5)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),
                
                Text(
                  'Evidence (Optional)',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: contentFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ...evidenceFiles.asMap().entries.map((entry) => Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(entry.value),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -8,
                          right: -8,
                          child: IconButton(
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.error,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, size: 14, color: AppColors.white),
                            ),
                            onPressed: () {
                              setDialogState(() => evidenceFiles.removeAt(entry.key));
                            },
                          ),
                        ),
                      ],
                    )),
                    InkWell(
                      onTap: () async {
                        final picker = ImagePicker();
                        final images = await picker.pickMultiImage();
                        if (images.isNotEmpty) {
                          setDialogState(() {
                            evidenceFiles.addAll(images.map((img) => File(img.path)));
                          });
                        }
                      },
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: colors.background,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: colors.textSecondary.withValues(alpha: 0.3)),
                        ),
                        child: Icon(Icons.add_photo_alternate, color: colors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: colors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: isSubmitting
                  ? null
                  : () async {
                      if (bookingIdController.text.isEmpty) {
                        _showSnackBar('Please enter booking ID', AppColors.error);
                        return;
                      }
                      if (reasonController.text.isEmpty) {
                        _showSnackBar('Please enter reason', AppColors.error);
                        return;
                      }
                      if (descriptionController.text.isEmpty) {
                        _showSnackBar('Please enter description', AppColors.error);
                        return;
                      }
                      
                      setDialogState(() => isSubmitting = true);
                      
                      final response = await DisputeService.raiseDispute(
                        bookingId: int.parse(bookingIdController.text),
                        reason: reasonController.text,
                        description: descriptionController.text,
                        evidenceFiles: evidenceFiles.isNotEmpty ? evidenceFiles : null,
                      );
                      
                      if (response.success) {
                        Navigator.pop(context);
                        _showSnackBar('Dispute raised successfully!', AppColors.success);
                        _loadDisputes();
                      } else {
                        setDialogState(() => isSubmitting = false);
                        _showSnackBar(response.message, AppColors.error);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
              ),
              child: isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                    )
                  : const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  // NOTE: Cancel dispute endpoint does NOT exist in API documentation (Section 17)
  // API only supports: GET /disputes, POST /disputes/raise, GET /disputes/{bookingId}/details
  void _showCancelDisputeDialog(Dispute dispute, AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    _showSnackBar('Cancel dispute feature is not available. Please contact support.', AppColors.warning);
  }

  // NOTE: Add message to dispute endpoint does NOT exist in API documentation (Section 17)
  // API only supports: GET /disputes, POST /disputes/raise, GET /disputes/{bookingId}/details
  void _showAddMessageDialog(Dispute dispute, AppColorSet colors, Color primaryColor, bool isDark, bool isSmallScreen, bool isTablet, bool isDesktop) {
    _showSnackBar('Add message feature is not available. Please contact support.', AppColors.warning);
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
