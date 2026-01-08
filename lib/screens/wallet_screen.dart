import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/wallet_service.dart';
import '../model/getwalletmodel.dart';
import '../utils/auth_helper.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  GetwalletModel? _walletData;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isValidating = true;

  @override
  void initState() {
    super.initState();
    _validateAndLoadData();
  }

  // Validate user first, then load data if valid
  Future<void> _validateAndLoadData() async {
    final isValid = await AuthHelper.validateUserOrRedirect(context);
    
    if (!mounted) return;
    
    if (isValid) {
      setState(() {
        _isValidating = false;
      });
      _loadWalletData();
    }
    // If not valid, AuthHelper already redirected to login
  }

  Future<void> _loadWalletData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await WalletService.getWallet();

      if (result != null && result.success) {
        setState(() {
          _walletData = result;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load wallet data';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Something went wrong';
      });
    }
  }

  double get _balance {
    if (_walletData == null) return 0.0;
    return double.tryParse(_walletData!.data.balance) ?? 0.0;
  }

  List<dynamic> get _transactions {
    return _walletData?.data.recentTransactions ?? [];
  }

  List<dynamic> get _bankAccounts {
    return _walletData?.data.gpayAccounts ?? [];
  }

  // 🔥 New getters for wallet statistics
  double get _totalEarned {
    if (_walletData == null) return 0.0;
    return double.tryParse(_walletData!.data.totalEarned) ?? 0.0;
  }

  double get _totalWithdrawn {
    if (_walletData == null) return 0.0;
    return double.tryParse(_walletData!.data.totalWithdrawn) ?? 0.0;
  }

  double get _pendingBalance {
    if (_walletData == null) return 0.0;
    return (_walletData!.data.pendingBalance).toDouble();
  }

  List<dynamic> get _pendingWithdrawals {
    return _walletData?.data.pendingWithdrawals ?? [];
  }

  // 📅 Format date helper
  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final diff = now.difference(date);
      
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    // Show loading while validating user
    if (_isValidating) {
      return BaseScreen(
        title: 'Wallet',
        showBackButton: true,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final cardRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final smallRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    
    final balanceLabelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final balanceAmountFontSize = isDesktop ? 44.0 : isTablet ? 40.0 : isSmallScreen ? 28.0 : 36.0;
    final walletIdFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final sectionHeaderFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final buttonLabelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final transactionTitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final transactionDateFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final transactionAmountFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    final walletIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final transactionIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final transactionIconPadding = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'Wallet',
      showBackButton: true,
      body: RefreshIndicator(
        onRefresh: _loadWalletData,
        color: primaryColor,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: colors.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadWalletData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Center(
                      child: Container(
                        constraints: BoxConstraints(maxWidth: maxContentWidth),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Balance Card
                            _buildBalanceCard(
                              colors,
                              primaryColor,
                              cardRadius,
                              balanceLabelFontSize,
                              balanceAmountFontSize,
                              walletIdFontSize,
                              walletIconSize,
                            ),
                            SizedBox(height: sectionSpacing),
                            
                            // 📊 Statistics Section - Total Earned & Withdrawn
                            _buildStatisticsSection(
                              colors,
                              primaryColor,
                              smallRadius,
                              transactionTitleFontSize,
                              transactionAmountFontSize,
                            ),
                            SizedBox(height: sectionSpacing),
                            
                            // Quick Actions
                            _buildQuickActions(
                              colors,
                              primaryColor,
                              smallRadius,
                              buttonLabelFontSize,
                            ),
                            SizedBox(height: sectionSpacing),
                            
                            // 🔄 Pending Withdrawals (if any)
                            if (_pendingWithdrawals.isNotEmpty) ...[
                              _buildPendingWithdrawalsSection(
                                colors,
                                primaryColor,
                                smallRadius,
                                sectionHeaderFontSize,
                                transactionTitleFontSize,
                                transactionDateFontSize,
                                transactionAmountFontSize,
                              ),
                              SizedBox(height: sectionSpacing),
                            ],
                            
                            // Recent Transactions
                            _buildTransactionsSection(
                              colors,
                              primaryColor,
                              smallRadius,
                              sectionHeaderFontSize,
                              transactionTitleFontSize,
                              transactionDateFontSize,
                              transactionAmountFontSize,
                              transactionIconSize,
                              transactionIconPadding,
                            ),
                            SizedBox(height: sectionSpacing),
                            
                            // Payment Methods
                            _buildPaymentMethodsSection(
                              colors,
                              primaryColor,
                              smallRadius,
                              sectionHeaderFontSize,
                              transactionTitleFontSize,
                              transactionDateFontSize,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  Widget _buildBalanceCard(
    AppColorSet colors,
    Color primaryColor,
    double cardRadius,
    double labelFontSize,
    double amountFontSize,
    double idFontSize,
    double iconSize,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
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
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.account_balance_wallet, color: Colors.white, size: iconSize),
              const SizedBox(width: 8),
              Text(
                'Available Balance',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: labelFontSize,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '₹${_balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: amountFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 💰 Balance breakdown row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Pending Balance
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.schedule,
                          color: Colors.amber[100],
                          size: iconSize - 4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pending',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: idFontSize - 2,
                            ),
                          ),
                          Text(
                            '₹${_pendingBalance.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: idFontSize + 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Divider
                Container(
                  width: 1,
                  height: 35,
                  color: Colors.white.withOpacity(0.3),
                ),
                // Total (Available + Pending)
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: idFontSize - 2,
                            ),
                          ),
                          Text(
                            '₹${(_balance + _pendingBalance).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: idFontSize + 2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: Colors.white,
                          size: iconSize - 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double fontSize,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            colors,
            primaryColor,
            radius,
            fontSize,
            Icons.add,
            'Add Money',
            () {
              // TODO: Implement add money
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionButton(
            colors,
            primaryColor,
            radius,
            fontSize,
            Icons.send,
            'Withdraw',
            () {
              // TODO: Implement withdraw
            },
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double fontSize,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: primaryColor.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: primaryColor, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 📊 Statistics Section - Shows Total Earned & Total Withdrawn
  Widget _buildStatisticsSection(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double titleFontSize,
    double amountFontSize,
  ) {
    return Row(
      children: [
        // Total Earned Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Total Earned',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: titleFontSize - 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_totalEarned.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: amountFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Total Withdrawn Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: Colors.orange,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Withdrawn',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: titleFontSize - 2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '₹${_totalWithdrawn.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.orange,
                    fontSize: amountFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔄 Pending Withdrawals Section
  Widget _buildPendingWithdrawalsSection(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double headerFontSize,
    double titleFontSize,
    double dateFontSize,
    double amountFontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.schedule, color: Colors.amber, size: 20),
            const SizedBox(width: 8),
            Text(
              'Pending Withdrawals',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...(_pendingWithdrawals.map((withdrawal) {
          final amount = withdrawal['amount']?.toString() ?? '0';
          final status = withdrawal['status']?.toString() ?? 'pending';
          final createdAt = withdrawal['created_at']?.toString() ?? '';
          final bankName = withdrawal['bank_name']?.toString() ?? 'Bank Account';
          final accountNumber = withdrawal['account_number']?.toString() ?? '';
          
          // Status color mapping
          Color statusColor;
          IconData statusIcon;
          switch (status.toLowerCase()) {
            case 'processing':
              statusColor = Colors.blue;
              statusIcon = Icons.sync;
              break;
            case 'completed':
              statusColor = Colors.green;
              statusIcon = Icons.check_circle;
              break;
            case 'failed':
              statusColor = Colors.red;
              statusIcon = Icons.error;
              break;
            default: // pending
              statusColor = Colors.amber;
              statusIcon = Icons.schedule;
          }
          
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: statusColor.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bankName,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (accountNumber.isNotEmpty)
                        Text(
                          '****${accountNumber.length > 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber}',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: dateFontSize,
                          ),
                        ),
                      Text(
                        _formatDate(createdAt),
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: dateFontSize,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹$amount',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: amountFontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: dateFontSize - 2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList()),
      ],
    );
  }

  Widget _buildTransactionsSection(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double headerFontSize,
    double titleFontSize,
    double dateFontSize,
    double amountFontSize,
    double iconSize,
    double iconPadding,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with "View All" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Transactions',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_transactions.length > 5)
              TextButton(
                onPressed: () {
                  // 🔄 Show all transactions in bottom sheet
                  _showAllTransactions(colors, primaryColor, radius, titleFontSize, dateFontSize, amountFontSize, iconSize, iconPadding);
                },
                child: Text(
                  'View All',
                  style: TextStyle(color: primaryColor),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (_transactions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 48,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: titleFontSize,
                  ),
                ),
              ],
            ),
          )
        else
          ...(_transactions.take(5).map((transaction) {
            return _buildTransactionCard(
              transaction,
              colors,
              primaryColor,
              radius,
              titleFontSize,
              dateFontSize,
              amountFontSize,
              iconSize,
              iconPadding,
            );
          }).toList()),
      ],
    );
  }

  // 💳 Build individual transaction card with enhanced details
  Widget _buildTransactionCard(
    dynamic transaction,
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double titleFontSize,
    double dateFontSize,
    double amountFontSize,
    double iconSize,
    double iconPadding,
  ) {
    final type = transaction['type']?.toString() ?? 'Transaction';
    final amount = transaction['amount']?.toString() ?? '0';
    final date = transaction['created_at']?.toString() ?? '';
    final transactionType = transaction['transaction_type']?.toString() ?? '';
    final description = transaction['description']?.toString() ?? '';
    final status = transaction['status']?.toString() ?? 'completed';
    final referenceId = transaction['reference_id']?.toString() ?? '';
    final bookingId = transaction['booking_id']?.toString() ?? '';
    
    final isCredit = transactionType == 'credit' || 
                     description.toLowerCase().contains('refund') || 
                     description.toLowerCase().contains('returned') ||
                     description.toLowerCase().contains('earning');
    
    // 🎨 Get icon based on transaction type
    IconData getTransactionIcon() {
      final typeLower = type.toLowerCase();
      if (typeLower.contains('booking') || typeLower.contains('earning')) {
        return Icons.work_outline;
      } else if (typeLower.contains('withdrawal') || typeLower.contains('withdraw')) {
        return Icons.account_balance;
      } else if (typeLower.contains('refund')) {
        return Icons.replay;
      } else if (typeLower.contains('bonus') || typeLower.contains('reward')) {
        return Icons.card_giftcard;
      } else if (isCredit) {
        return Icons.arrow_downward;
      } else {
        return Icons.arrow_upward;
      }
    }
    
    // 🏷️ Status color
    Color getStatusColor() {
      switch (status.toLowerCase()) {
        case 'completed':
        case 'success':
          return Colors.green;
        case 'pending':
          return Colors.amber;
        case 'failed':
          return Colors.red;
        case 'processing':
          return Colors.blue;
        default:
          return Colors.grey;
      }
    }
    
    // 📝 Display title - use description if available, else type
    final displayTitle = description.isNotEmpty ? description : type;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(iconPadding),
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : Colors.red).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getTransactionIcon(),
              color: isCredit ? Colors.green : Colors.red,
              size: iconSize,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayTitle,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: titleFontSize,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _formatDate(date),
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: dateFontSize,
                      ),
                    ),
                    if (bookingId.isNotEmpty || referenceId.isNotEmpty) ...[
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: dateFontSize,
                        ),
                      ),
                      Text(
                        bookingId.isNotEmpty ? '#$bookingId' : '#$referenceId',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: dateFontSize,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}₹$amount',
                style: TextStyle(
                  color: isCredit ? Colors.green : Colors.red,
                  fontSize: amountFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (status.toLowerCase() != 'completed') ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: getStatusColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: getStatusColor(),
                      fontSize: dateFontSize - 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 📋 Show all transactions in bottom sheet
  void _showAllTransactions(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double titleFontSize,
    double dateFontSize,
    double amountFontSize,
    double iconSize,
    double iconPadding,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Handle bar
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.textSecondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Transactions',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Icon(Icons.close, color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Transactions list
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(
                        _transactions[index],
                        colors,
                        primaryColor,
                        radius,
                        titleFontSize,
                        dateFontSize,
                        amountFontSize,
                        iconSize,
                        iconPadding,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentMethodsSection(
    AppColorSet colors,
    Color primaryColor,
    double radius,
    double headerFontSize,
    double titleFontSize,
    double subtitleFontSize,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Methods',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // TODO: Add payment method
              },
              icon: Icon(Icons.add, color: primaryColor, size: 18),
              label: Text(
                'Add',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_bankAccounts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: colors.card,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: primaryColor.withOpacity(0.2)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.account_balance,
                  size: 48,
                  color: colors.textSecondary,
                ),
                const SizedBox(height: 12),
                Text(
                  'No payment methods added',
                  style: TextStyle(
                    color: colors.textSecondary,
                    fontSize: titleFontSize,
                  ),
                ),
              ],
            ),
          )
        else
          ...(_bankAccounts.map((account) {
            final name = account['account_holder_name'] ?? 'Account';
            final upiId = account['upi_id'] ?? '';
            final isPrimary = account['is_primary'] == true;
            
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: isPrimary ? primaryColor : primaryColor.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: primaryColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                color: colors.textPrimary,
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (isPrimary) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Primary',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        Text(
                          upiId,
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: subtitleFontSize,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: colors.textSecondary,
                  ),
                ],
              ),
            );
          }).toList()),
      ],
    );
  }
}
