import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../utils/responsive.dart';
import '../Service/sugar_partner_service.dart';

/// Sugar Partner Payments Screen - Shows sugar partner payment history
/// Displays all payments with status, amount, and transaction details
class SugarPartnerPaymentsScreen extends StatefulWidget {
  const SugarPartnerPaymentsScreen({super.key});

  @override
  State<SugarPartnerPaymentsScreen> createState() => _SugarPartnerPaymentsScreenState();
}

class _SugarPartnerPaymentsScreenState extends State<SugarPartnerPaymentsScreen> {
  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  
  List<SugarPartnerPayment> _payments = [];
  int _currentPage = 1;
  int _lastPage = 1;
  double? _totalAmount;
  
  @override
  void initState() {
    super.initState();
    _loadPayments();
  }
  
  Future<void> _loadPayments({bool loadMore = false}) async {
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
      final response = await SugarPartnerService.getPayments(page: page);
      
      if (response.success) {
        setState(() {
          if (loadMore) {
            _payments.addAll(response.data);
            _currentPage = page;
          } else {
            _payments = response.data;
            _currentPage = 1;
            _totalAmount = response.totalAmount;
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
        _errorMessage = 'Failed to load payments: $e';
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
  
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppColors.warning;
      case 'completed':
      case 'success':
        return AppColors.success;
      case 'failed':
      case 'rejected':
        return AppColors.error;
      case 'processing':
        return AppColors.info;
      default:
        return Colors.grey;
    }
  }
  
  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'completed':
      case 'success':
        return Icons.check_circle;
      case 'failed':
      case 'rejected':
        return Icons.cancel;
      case 'processing':
        return Icons.sync;
      default:
        return Icons.help_outline;
    }
  }
  
  IconData _getPaymentMethodIcon(String? method) {
    switch (method?.toLowerCase()) {
      case 'upi':
      case 'gpay':
        return Icons.account_balance_wallet;
      case 'bank':
      case 'neft':
      case 'imps':
        return Icons.account_balance;
      case 'card':
      case 'credit':
      case 'debit':
        return Icons.credit_card;
      case 'wallet':
        return Icons.wallet;
      default:
        return Icons.payment;
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
      title: 'Payment History',
      showBackButton: true,
      body: _isLoading
          ? _buildLoadingState(colors, primaryColor)
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor)
              : _payments.isEmpty
                  ? _buildEmptyState(colors, primaryColor)
                  : _buildPaymentsList(colors, primaryColor, contentPadding, isSmallScreen, isTablet, isDesktop),
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
            'Loading payments...',
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
              onPressed: () => _loadPayments(),
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
              Icons.payment,
              size: 64,
              color: colors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Payments',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your sugar partner payment history will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => _loadPayments(),
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
  
  Widget _buildPaymentsList(
    AppColorSet colors,
    Color primaryColor,
    double contentPadding,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    return RefreshIndicator(
      onRefresh: () => _loadPayments(),
      color: primaryColor,
      child: ListView(
        padding: EdgeInsets.all(contentPadding),
        children: [
          // Total amount summary card
          if (_totalAmount != null && _totalAmount! > 0)
            _buildTotalAmountCard(colors, primaryColor, isSmallScreen, isTablet, isDesktop),
          
          // Payment list
          ...List.generate(
            _payments.length + (_currentPage < _lastPage ? 1 : 0),
            (index) {
              if (index == _payments.length) {
                return _buildLoadMoreButton(colors, primaryColor);
              }
              return _buildPaymentCard(
                _payments[index],
                colors,
                primaryColor,
                isSmallScreen,
                isTablet,
                isDesktop,
              );
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildTotalAmountCard(
    AppColorSet colors,
    Color primaryColor,
    bool isSmallScreen,
    bool isTablet,
    bool isDesktop,
  ) {
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 14.0 : 18.0;
    final cardRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final titleFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 11.0 : 12.0;
    final amountFontSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 22.0 : 26.0;
    
    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 16 : 20),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white.withOpacity(0.9), size: titleFontSize + 4),
              const SizedBox(width: 8),
              Text(
                'Total Earnings',
                style: TextStyle(
                  fontSize: titleFontSize,
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${_totalAmount!.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: amountFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'From ${_payments.length} payment${_payments.length != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: titleFontSize - 1,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPaymentCard(
    SugarPartnerPayment payment,
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
    
    final statusColor = _getStatusColor(payment.status);
    final statusIcon = _getStatusIcon(payment.status);
    final paymentMethodIcon = _getPaymentMethodIcon(payment.paymentMethod);
    
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
        onTap: () => _showPaymentDetails(payment, colors, primaryColor),
        borderRadius: BorderRadius.circular(cardRadius),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              // Payment method icon
              Container(
                width: iconSize,
                height: iconSize,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(iconSize / 4),
                ),
                child: Icon(
                  paymentMethodIcon,
                  size: iconSize * 0.5,
                  color: statusColor,
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 14),
              
              // Payment info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Exchange #${payment.exchangeId}',
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
                          '₹${payment.amount.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (payment.paymentMethod != null) ...[
                          Text(
                            payment.paymentMethod!.toUpperCase(),
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textSecondary,
                            ),
                          ),
                          Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: colors.textTertiary,
                            ),
                          ),
                        ],
                        Icon(Icons.access_time, size: subtitleFontSize, color: colors.textTertiary),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(payment.createdAt),
                          style: TextStyle(
                            fontSize: subtitleFontSize,
                            color: colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    if (payment.transactionId != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Txn: ${payment.transactionId}',
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
              
              const SizedBox(width: 8),
              
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
                      payment.status.toUpperCase(),
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
  
  Widget _buildLoadMoreButton(AppColorSet colors, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: _isLoadingMore
            ? CircularProgressIndicator(color: primaryColor)
            : OutlinedButton.icon(
                onPressed: () => _loadPayments(loadMore: true),
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
  
  void _showPaymentDetails(SugarPartnerPayment payment, AppColorSet colors, Color primaryColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final statusColor = _getStatusColor(payment.status);
        
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
                      'Payment Details',
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
                  color: AppColors.success.withOpacity(0.1),
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
                      '₹${payment.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Details
              _buildDetailRow(colors, 'Exchange ID', '#${payment.exchangeId}'),
              _buildDetailRow(colors, 'Payment ID', '#${payment.id}'),
              _buildDetailRow(colors, 'Status', payment.status.toUpperCase(), valueColor: statusColor),
              if (payment.paymentMethod != null)
                _buildDetailRow(colors, 'Payment Method', payment.paymentMethod!.toUpperCase()),
              if (payment.transactionId != null)
                _buildDetailRow(colors, 'Transaction ID', payment.transactionId!),
              _buildDetailRow(colors, 'Created', _formatFullDate(payment.createdAt)),
              if (payment.completedAt != null)
                _buildDetailRow(colors, 'Completed', _formatFullDate(payment.completedAt)),
              
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
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? colors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
