import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/wallet_service.dart';

/// Wallet Transactions Screen - Full transaction history with filters
/// Shows all wallet transactions with type filter and date range picker
class WalletTransactionsScreen extends StatefulWidget {
  const WalletTransactionsScreen({super.key});

  @override
  State<WalletTransactionsScreen> createState() => _WalletTransactionsScreenState();
}

class _WalletTransactionsScreenState extends State<WalletTransactionsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<WalletTransaction> _transactions = [];
  int _currentPage = 1;
  int _lastPage = 1;
  
  // Filter state
  String? _selectedType;
  DateTime? _fromDate;
  DateTime? _toDate;
  
  // Filter options
  final List<Map<String, String>> _typeOptions = [
    {'value': '', 'label': 'All Types'},
    {'value': 'credit', 'label': 'Credit'},
    {'value': 'debit', 'label': 'Debit'},
    {'value': 'refund', 'label': 'Refund'},
  ];
  
  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }
  
  Future<void> _loadTransactions({bool loadMore = false}) async {
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
      final response = await WalletService.getTransactions(
        page: page,
        type: _selectedType?.isNotEmpty == true ? _selectedType : null,
        fromDate: _fromDate != null ? _formatDateForApi(_fromDate!) : null,
        toDate: _toDate != null ? _formatDateForApi(_toDate!) : null,
      );
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _transactions.addAll(response.transactions ?? []);
            _currentPage = page;
          } else {
            _transactions = response.transactions ?? [];
            _currentPage = 1;
          }
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
      setState(() {
        _errorMessage = 'Failed to load transactions: $e';
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }
  
  String _formatDateForApi(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
  
  String _formatFullDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return 'N/A';
    try {
      final date = DateTime.parse(dateString);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
      final ampm = date.hour >= 12 ? 'PM' : 'AM';
      return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:${date.minute.toString().padLeft(2, '0')} $ampm';
    } catch (e) {
      return dateString;
    }
  }
  
  String _formatDisplayDate(DateTime? date) {
    if (date == null) return 'Select';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
  
  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return AppColors.success;
      case 'debit':
        return AppColors.error;
      case 'refund':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'credit':
        return Icons.arrow_downward;
      case 'debit':
        return Icons.arrow_upward;
      case 'refund':
        return Icons.replay;
      default:
        return Icons.swap_horiz;
    }
  }
  
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'completed':
      case 'success':
        return AppColors.success;
      case 'failed':
        return AppColors.error;
      default:
        return Colors.grey;
    }
  }
  
  Future<void> _selectFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: _toDate ?? DateTime.now(),
    );
    if (picked != null) {
      setState(() => _fromDate = picked);
      _loadTransactions();
    }
  }
  
  Future<void> _selectToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _toDate = picked);
      _loadTransactions();
    }
  }
  
  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _fromDate = null;
      _toDate = null;
    });
    _loadTransactions();
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
      title: 'Transaction History',
      showBackButton: true,
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(colors, primaryColor, isSmallScreen, isTablet, isDesktop, contentPadding),
          
          // Transactions list
          Expanded(
            child: _isLoading
                ? _buildLoadingState(colors, primaryColor)
                : _errorMessage != null
                    ? _buildErrorState(colors, primaryColor)
                    : _transactions.isEmpty
                        ? _buildEmptyState(colors, primaryColor)
                        : _buildTransactionsList(colors, primaryColor, contentPadding, isSmallScreen, isTablet, isDesktop),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSection(
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
    double contentPadding,
  ) {
    final filterFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final hasActiveFilters = _selectedType != null || _fromDate != null || _toDate != null;
    
    return Container(
      padding: EdgeInsets.all(contentPadding),
      decoration: BoxDecoration(
        color: colors.card,
        border: Border(
          bottom: BorderSide(color: colors.border.withOpacity(0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type filter dropdown
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 12),
                  decoration: BoxDecoration(
                    color: colors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: colors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedType ?? '',
                      isExpanded: true,
                      icon: Icon(Icons.keyboard_arrow_down, color: colors.textSecondary),
                      style: TextStyle(
                        fontSize: filterFontSize,
                        color: colors.textPrimary,
                      ),
                      dropdownColor: colors.card,
                      items: _typeOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option['value'],
                          child: Row(
                            children: [
                              if (option['value']!.isNotEmpty) ...[
                                Icon(
                                  _getTypeIcon(option['value']!),
                                  size: filterFontSize + 2,
                                  color: _getTypeColor(option['value']!),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Text(option['label']!),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedType = value);
                        _loadTransactions();
                      },
                    ),
                  ),
                ),
              ),
              if (hasActiveFilters) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _clearFilters,
                  icon: Icon(Icons.clear, color: colors.textSecondary, size: 20),
                  tooltip: 'Clear filters',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Date range filters
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: _selectFromDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: filterFontSize, color: colors.textTertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'From',
                                style: TextStyle(
                                  fontSize: filterFontSize - 2,
                                  color: colors.textTertiary,
                                ),
                              ),
                              Text(
                                _formatDisplayDate(_fromDate),
                                style: TextStyle(
                                  fontSize: filterFontSize,
                                  color: _fromDate != null ? colors.textPrimary : colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_fromDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => _fromDate = null);
                              _loadTransactions();
                            },
                            child: Icon(Icons.close, size: filterFontSize, color: colors.textTertiary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: _selectToDate,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 10 : 12,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                    decoration: BoxDecoration(
                      color: colors.background,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: filterFontSize, color: colors.textTertiary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'To',
                                style: TextStyle(
                                  fontSize: filterFontSize - 2,
                                  color: colors.textTertiary,
                                ),
                              ),
                              Text(
                                _formatDisplayDate(_toDate),
                                style: TextStyle(
                                  fontSize: filterFontSize,
                                  color: _toDate != null ? colors.textPrimary : colors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_toDate != null)
                          GestureDetector(
                            onTap: () {
                              setState(() => _toDate = null);
                              _loadTransactions();
                            },
                            child: Icon(Icons.close, size: filterFontSize, color: colors.textTertiary),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
            'Loading transactions...',
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
              onPressed: () => _loadTransactions(),
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
    final hasFilters = _selectedType != null || _fromDate != null || _toDate != null;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasFilters ? Icons.filter_list_off : Icons.receipt_long,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'No Matching Transactions' : 'No Transactions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'Try adjusting your filters to see more transactions.'
                  : 'Your wallet transaction history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            if (hasFilters)
              ElevatedButton.icon(
                onPressed: _clearFilters,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Filters'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                ),
              )
            else
              OutlinedButton.icon(
                onPressed: () => _loadTransactions(),
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
  
  Widget _buildTransactionsList(
    AppColorSet colors,
    Color primaryColor,
    double contentPadding,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadTransactions(),
      color: primaryColor,
      child: ListView.builder(
        padding: EdgeInsets.all(contentPadding),
        itemCount: _transactions.length + (_currentPage < _lastPage ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _transactions.length) {
            return _buildLoadMoreButton(colors, primaryColor);
          }
          return _buildTransactionCard(
            _transactions[index],
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
  
  Widget _buildTransactionCard(
    WalletTransaction transaction,
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final iconSize = isDesktop ? 48.0 : isTablet ? 44.0 : isSmallScreen ? 36.0 : 40.0;
    final titleFontSize = isDesktop ? 17.0 : isTablet ? 16.0 : isSmallScreen ? 14.0 : 15.0;
    final subtitleFontSize = isDesktop ? 13.0 : isTablet ? 12.0 : isSmallScreen ? 10.0 : 11.0;
    
    final typeColor = _getTypeColor(transaction.type);
    final typeIcon = _getTypeIcon(transaction.type);
    final statusColor = _getStatusColor(transaction.status);
    final isCredit = transaction.type.toLowerCase() == 'credit' || transaction.type.toLowerCase() == 'refund';
    
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
        onTap: () => _showTransactionDetails(transaction, colors, primaryColor),
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              // Type icon
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: typeColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  typeIcon,
                  size: iconSize * 0.5,
                  color: typeColor,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              
              // Transaction info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            transaction.description ?? transaction.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: isCredit ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            transaction.type.toUpperCase(),
                            style: TextStyle(
                              fontSize: subtitleFontSize - 1,
                              fontWeight: FontWeight.bold,
                              color: typeColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.access_time, size: subtitleFontSize, color: colors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(transaction.createdAt),
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    if (transaction.referenceId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ref: ${transaction.referenceId}',
                        style: TextStyle(
                          fontSize: subtitleFontSize - 1,
                          color: colors.textTertiary,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              
              // Status indicator
              if (transaction.status != null) ...[
                const SizedBox(width: 8),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ),
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
                onPressed: () => _loadTransactions(loadMore: true),
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
  
  void _showTransactionDetails(WalletTransaction transaction, AppColorSet colors, Color primaryColor) {
    final typeColor = _getTypeColor(transaction.type);
    final statusColor = _getStatusColor(transaction.status);
    final isCredit = transaction.type.toLowerCase() == 'credit' || transaction.type.toLowerCase() == 'refund';
    
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.receipt_long, color: primaryColor, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: colors.textSecondary),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Amount
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isCredit ? AppColors.success : AppColors.error).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Amount',
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${isCredit ? '+' : '-'}₹${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isCredit ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Details
              _buildDetailRow(colors, 'Transaction ID', '#${transaction.id}'),
              _buildDetailRow(colors, 'Type', transaction.type.toUpperCase(), valueColor: typeColor),
              if (transaction.status != null)
                _buildDetailRow(colors, 'Status', transaction.status!.toUpperCase(), valueColor: statusColor),
              if (transaction.description != null)
                _buildDetailRow(colors, 'Description', transaction.description!),
              if (transaction.referenceId != null)
                _buildDetailRow(colors, 'Reference ID', transaction.referenceId!),
              _buildDetailRow(colors, 'Date', _formatFullDate(transaction.createdAt)),
              
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildDetailRow(AppColorSet colors, String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: valueColor ?? colors.textPrimary,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
