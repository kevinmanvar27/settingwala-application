import 'package:flutter/material.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/wallet_service.dart';
import '../model/getwalletmodel.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  // Wallet data from API
  GetwalletModel? _walletData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadWalletData();
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
      print('Error loading wallet: $e');
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
    return _walletData?.data.bankAccounts ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    // Responsive breakpoints
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    // Responsive padding
    final horizontalPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final verticalPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    // Responsive spacing
    final sectionSpacing = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    
    // Responsive border radius
    final cardRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final smallRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    
    // Responsive typography
    final balanceLabelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final balanceAmountFontSize = isDesktop ? 44.0 : isTablet ? 40.0 : isSmallScreen ? 28.0 : 36.0;
    final walletIdFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final sectionHeaderFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    final buttonLabelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final transactionTitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final transactionDateFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final transactionAmountFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    // Responsive icon sizes
    final walletIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final actionIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final transactionIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    
    // Responsive action button padding
    final actionButtonPaddingV = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final actionIconPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0;
    final transactionIconPadding = isDesktop ? 10.0 : isTablet ? 9.0 : isSmallScreen ? 6.0 : 8.0;
    
    // Max width for desktop readability
    final maxContentWidth = isDesktop ? 800.0 : double.infinity;
    
    return BaseScreen(
      title: 'Wallet',
      showBackButton: true,
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: primaryColor),
            )
          : _errorMessage != null
              ? _buildErrorState(colors, primaryColor, sectionHeaderFontSize, balanceLabelFontSize)
              : RefreshIndicator(
                  onRefresh: _loadWalletData,
                  color: primaryColor,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxContentWidth),
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: horizontalPadding,
                          vertical: verticalPadding,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBalanceCard(
                              colors, 
                              primaryColor, 
                              isDark,
                              cardRadius: cardRadius,
                              cardPadding: sectionSpacing,
                              labelFontSize: balanceLabelFontSize,
                              amountFontSize: balanceAmountFontSize,
                              walletIdFontSize: walletIdFontSize,
                              iconSize: walletIconSize,
                            ),
                            SizedBox(height: sectionSpacing),
                            // Stats Row
                            _buildStatsRow(
                              colors,
                              primaryColor,
                              cardRadius: smallRadius,
                              labelFontSize: walletIdFontSize,
                              valueFontSize: balanceLabelFontSize,
                              cardPadding: horizontalPadding,
                            ),
                            SizedBox(height: sectionSpacing),
                            _buildActionButtons(
                              colors, 
                              primaryColor, 
                              isDark,
                              cardRadius: smallRadius,
                              buttonPaddingV: actionButtonPaddingV,
                              iconPadding: actionIconPadding,
                              iconSize: actionIconSize,
                              labelFontSize: buttonLabelFontSize,
                              buttonSpacing: horizontalPadding,
                            ),
                            SizedBox(height: sectionSpacing),
                            _buildBankAccountsSection(
                              colors,
                              primaryColor,
                              isDark,
                              cardRadius: smallRadius,
                              cardPadding: horizontalPadding,
                              headerFontSize: sectionHeaderFontSize,
                              titleFontSize: transactionTitleFontSize,
                              subtitleFontSize: transactionDateFontSize,
                              iconSize: transactionIconSize,
                              iconPadding: transactionIconPadding,
                              itemSpacing: horizontalPadding,
                            ),
                            SizedBox(height: sectionSpacing),
                            _buildTransactionHistory(
                              colors, 
                              primaryColor,
                              cardRadius: smallRadius,
                              cardPadding: horizontalPadding,
                              headerFontSize: sectionHeaderFontSize,
                              titleFontSize: transactionTitleFontSize,
                              dateFontSize: transactionDateFontSize,
                              amountFontSize: transactionAmountFontSize,
                              iconSize: transactionIconSize,
                              iconPadding: transactionIconPadding,
                              itemSpacing: horizontalPadding,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorState(
    AppColorSet colors,
    Color primaryColor,
    double titleSize,
    double subtitleSize,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: colors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Something went wrong',
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please try again',
            style: TextStyle(
              fontSize: subtitleSize,
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadWalletData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(
    AppColorSet colors,
    Color primaryColor, {
    required double cardRadius,
    required double labelFontSize,
    required double valueFontSize,
    required double cardPadding,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            label: 'Pending',
            value: '₹${_walletData?.data.pendingBalance ?? 0}',
            icon: Icons.pending_actions,
            colors: colors,
            primaryColor: Colors.orange,
            cardRadius: cardRadius,
            labelFontSize: labelFontSize,
            valueFontSize: valueFontSize,
            cardPadding: cardPadding,
          ),
        ),
        SizedBox(width: cardPadding * 0.5),
        Expanded(
          child: _buildStatCard(
            label: 'Earned',
            value: '₹${_walletData?.data.totalEarned ?? '0'}',
            icon: Icons.trending_up,
            colors: colors,
            primaryColor: AppColors.success,
            cardRadius: cardRadius,
            labelFontSize: labelFontSize,
            valueFontSize: valueFontSize,
            cardPadding: cardPadding,
          ),
        ),
        SizedBox(width: cardPadding * 0.5),
        Expanded(
          child: _buildStatCard(
            label: 'Withdrawn',
            value: '₹${_walletData?.data.totalWithdrawn ?? '0'}',
            icon: Icons.account_balance,
            colors: colors,
            primaryColor: AppColors.info,
            cardRadius: cardRadius,
            labelFontSize: labelFontSize,
            valueFontSize: valueFontSize,
            cardPadding: cardPadding,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required AppColorSet colors,
    required Color primaryColor,
    required double cardRadius,
    required double labelFontSize,
    required double valueFontSize,
    required double cardPadding,
  }) {
    return Container(
      padding: EdgeInsets.all(cardPadding * 0.75),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: primaryColor, size: valueFontSize * 1.5),
          SizedBox(height: cardPadding * 0.25),
          Text(
            value,
            style: TextStyle(
              fontSize: valueFontSize,
              fontWeight: FontWeight.bold,
              color: colors.textPrimary,
            ),
          ),
          SizedBox(height: cardPadding * 0.1),
          Text(
            label,
            style: TextStyle(
              fontSize: labelFontSize,
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(
    AppColorSet colors, 
    Color primaryColor, 
    bool isDark, {
    required double cardRadius,
    required double cardPadding,
    required double labelFontSize,
    required double amountFontSize,
    required double walletIdFontSize,
    required double iconSize,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [primaryColor.withOpacity(0.8), primaryColor.withOpacity(0.6)]
              : [primaryColor, primaryColor.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(cardRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Available Balance',
            style: TextStyle(
              color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.9),
              fontSize: labelFontSize,
            ),
          ),
          SizedBox(height: cardPadding * 0.33),
          Text(
            '₹${_balance.toStringAsFixed(2)}',
            style: TextStyle(
              color: isDark ? AppColors.black : AppColors.white,
              fontSize: amountFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: cardPadding * 0.67),
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.9),
                size: iconSize,
              ),
              SizedBox(width: iconSize * 0.4),
              Text(
                'SettingWala Wallet',
                style: TextStyle(
                  color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.9),
                  fontSize: walletIdFontSize,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    AppColorSet colors, 
    Color primaryColor, 
    bool isDark, {
    required double cardRadius,
    required double buttonPaddingV,
    required double iconPadding,
    required double iconSize,
    required double labelFontSize,
    required double buttonSpacing,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildActionButton(
            icon: Icons.add,
            label: 'Add Money',
            onTap: () => _showAddMoneyDialog(colors, primaryColor, isDark),
            colors: colors,
            primaryColor: primaryColor,
            isDark: isDark,
            cardRadius: cardRadius,
            buttonPaddingV: buttonPaddingV,
            iconPadding: iconPadding,
            iconSize: iconSize,
            labelFontSize: labelFontSize,
          ),
        ),
        SizedBox(width: buttonSpacing),
        Expanded(
          child: _buildActionButton(
            icon: Icons.send,
            label: 'Withdraw',
            onTap: () => _showWithdrawDialog(colors, primaryColor, isDark),
            colors: colors,
            primaryColor: primaryColor,
            isDark: isDark,
            cardRadius: cardRadius,
            buttonPaddingV: buttonPaddingV,
            iconPadding: iconPadding,
            iconSize: iconSize,
            labelFontSize: labelFontSize,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required AppColorSet colors,
    required Color primaryColor,
    required bool isDark,
    required double cardRadius,
    required double buttonPaddingV,
    required double iconPadding,
    required double iconSize,
    required double labelFontSize,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
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
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: primaryColor,
                size: iconSize,
              ),
            ),
            SizedBox(height: iconPadding * 0.67),
            Text(
              label,
              style: TextStyle(
                fontSize: labelFontSize,
                color: colors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory(
    AppColorSet colors, 
    Color primaryColor, {
    required double cardRadius,
    required double cardPadding,
    required double headerFontSize,
    required double titleFontSize,
    required double dateFontSize,
    required double amountFontSize,
    required double iconSize,
    required double iconPadding,
    required double itemSpacing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction History',
          style: TextStyle(
            fontSize: headerFontSize,
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        SizedBox(height: itemSpacing),
        _transactions.isEmpty
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(cardPadding * 2),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: iconSize * 2,
                      color: colors.textTertiary,
                    ),
                    SizedBox(height: itemSpacing * 0.5),
                    Text(
                      'No transactions yet',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
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
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: colors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    final type = transaction['type']?.toString().toLowerCase() ?? '';
                    final isCredit = type == 'credit';
                    final description = transaction['description']?.toString() ?? '';
                    final amount = double.tryParse(transaction['amount']?.toString() ?? '0') ?? 0.0;
                    final createdAt = transaction['created_at']?.toString() ?? '';
                    
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: cardPadding,
                        vertical: cardPadding * 0.25,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: isCredit 
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? AppColors.success : AppColors.error,
                          size: iconSize,
                        ),
                      ),
                      title: Text(
                        description,
                        style: TextStyle(
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                      subtitle: Text(
                        _formatDateString(createdAt),
                        style: TextStyle(
                          color: colors.textTertiary,
                          fontSize: dateFontSize,
                        ),
                      ),
                      trailing: Text(
                        '${isCredit ? '+' : '-'}₹${amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: amountFontSize,
                          color: isCredit ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  String _formatDateString(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  void _showAddMoneyDialog(AppColorSet colors, Color primaryColor, bool isDark) {
    final TextEditingController amountController = TextEditingController();
    
    // Responsive values for dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final inputRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final chipFontSize = isDesktop ? 15.0 : isTablet ? 14.0 : isSmallScreen ? 12.0 : 13.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final contentPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final contentPaddingV = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.card,
          title: Text(
            'Add Money', 
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: titleFontSize,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(inputRadius),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: labelFontSize,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                      color: colors.textSecondary,
                      fontSize: labelFontSize,
                    ),
                    prefixIcon: Icon(
                      Icons.currency_rupee, 
                      color: primaryColor,
                      size: iconSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: contentPaddingH, 
                      vertical: contentPaddingV,
                    ),
                  ),
                ),
              ),
              SizedBox(height: contentPaddingH),
              Wrap(
                spacing: contentPaddingH * 0.5,
                children: [500, 1000, 2000, 5000].map((amount) {
                  return GestureDetector(
                    onTap: () {
                      amountController.text = amount.toString();
                    },
                    child: Chip(
                      label: Text(
                        '₹$amount',
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: chipFontSize,
                        ),
                      ),
                      backgroundColor: primaryColor.withOpacity(0.1),
                      side: BorderSide(color: primaryColor.withOpacity(0.3)),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel', 
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: labelFontSize,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Money added successfully!', 
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: labelFontSize,
                      ),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(inputRadius * 0.67),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dialogRadius),
                ),
              ),
              child: Text(
                'Add',
                style: TextStyle(fontSize: labelFontSize),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
        );
      },
    );
  }

  void _showWithdrawDialog(AppColorSet colors, Color primaryColor, bool isDark) {
    final TextEditingController amountController = TextEditingController();
    
    // Responsive values for dialog
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final inputRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    final infoRadius = isDesktop ? 12.0 : isTablet ? 11.0 : isSmallScreen ? 8.0 : 10.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final infoFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 18.0 : 20.0;
    final contentPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final contentPaddingV = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colors.card,
          title: Text(
            'Withdraw', 
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: titleFontSize,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(contentPaddingV),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(infoRadius),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline, 
                      color: primaryColor, 
                      size: iconSize,
                    ),
                    SizedBox(width: contentPaddingV * 0.67),
                    Expanded(
                      child: Text(
                        'Available balance: ₹${_balance.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: infoFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: contentPaddingH),
              Container(
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(inputRadius),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontSize: labelFontSize,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(
                      color: colors.textSecondary,
                      fontSize: labelFontSize,
                    ),
                    prefixIcon: Icon(
                      Icons.currency_rupee, 
                      color: primaryColor,
                      size: iconSize,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: contentPaddingH, 
                      vertical: contentPaddingV,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel', 
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: labelFontSize,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Withdrawal request submitted!', 
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: labelFontSize,
                      ),
                    ),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(infoRadius),
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(dialogRadius),
                ),
              ),
              child: Text(
                'Withdraw',
                style: TextStyle(fontSize: labelFontSize),
              ),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(dialogRadius),
          ),
        );
      },
    );
  }

  // Bank Accounts Section
  Widget _buildBankAccountsSection(
    AppColorSet colors,
    Color primaryColor,
    bool isDark, {
    required double cardRadius,
    required double cardPadding,
    required double headerFontSize,
    required double titleFontSize,
    required double subtitleFontSize,
    required double iconSize,
    required double iconPadding,
    required double itemSpacing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bank Accounts',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddBankAccountDialog(colors, primaryColor, isDark),
              child: Container(
                padding: EdgeInsets.all(iconPadding),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.add,
                  color: primaryColor,
                  size: iconSize,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: itemSpacing),
        _bankAccounts.isEmpty
            ? Container(
                width: double.infinity,
                padding: EdgeInsets.all(cardPadding * 2),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(cardRadius),
                  border: Border.all(color: primaryColor.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: iconSize * 2,
                      color: colors.textTertiary,
                    ),
                    SizedBox(height: itemSpacing * 0.5),
                    Text(
                      'No bank accounts added',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: colors.textTertiary,
                      ),
                    ),
                    SizedBox(height: itemSpacing * 0.5),
                    TextButton.icon(
                      onPressed: () => _showAddBankAccountDialog(colors, primaryColor, isDark),
                      icon: Icon(Icons.add, color: primaryColor, size: iconSize * 0.8),
                      label: Text(
                        'Add Bank Account',
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: subtitleFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
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
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _bankAccounts.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: colors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final account = _bankAccounts[index];
                    final bankName = account['bank_name']?.toString() ?? '';
                    final accountNumber = account['account_number']?.toString() ?? '';
                    final accountHolderName = account['account_holder_name']?.toString() ?? '';
                    final ifscCode = account['ifsc_code']?.toString() ?? '';
                    final isPrimary = account['is_primary'] == true || account['is_primary'] == 1;
                    final accountId = account['id'] ?? 0;

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: cardPadding,
                        vertical: cardPadding * 0.25,
                      ),
                      leading: Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.account_balance,
                          color: primaryColor,
                          size: iconSize,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              bankName,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          if (isPrimary)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: iconPadding * 0.5,
                                vertical: iconPadding * 0.25,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(cardRadius * 0.25),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: subtitleFontSize * 0.8,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: iconPadding * 0.25),
                          Text(
                            '****${accountNumber.length > 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber}',
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: subtitleFontSize,
                            ),
                          ),
                          Text(
                            accountHolderName,
                            style: TextStyle(
                              color: colors.textTertiary,
                              fontSize: subtitleFontSize * 0.9,
                            ),
                          ),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_vert,
                          color: colors.textSecondary,
                          size: iconSize,
                        ),
                        color: colors.card,
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showEditBankAccountDialog(
                              colors,
                              primaryColor,
                              isDark,
                              accountId: accountId,
                              bankName: bankName,
                              accountNumber: accountNumber,
                              accountHolderName: accountHolderName,
                              ifscCode: ifscCode,
                              isPrimary: isPrimary,
                            );
                          } else if (value == 'delete') {
                            _showDeleteBankAccountDialog(
                              colors,
                              primaryColor,
                              isDark,
                              accountId: accountId,
                              bankName: bankName,
                            );
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: primaryColor, size: iconSize * 0.8),
                                SizedBox(width: iconPadding),
                                Text(
                                  'Edit',
                                  style: TextStyle(
                                    color: colors.textPrimary,
                                    fontSize: titleFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: AppColors.error, size: iconSize * 0.8),
                                SizedBox(width: iconPadding),
                                Text(
                                  'Delete',
                                  style: TextStyle(
                                    color: AppColors.error,
                                    fontSize: titleFontSize,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
      ],
    );
  }

  // Add Bank Account Dialog
  void _showAddBankAccountDialog(AppColorSet colors, Color primaryColor, bool isDark) {
    final bankNameController = TextEditingController();
    final accountNumberController = TextEditingController();
    final accountHolderNameController = TextEditingController();
    final ifscCodeController = TextEditingController();
    bool isPrimary = false;
    bool isLoading = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final inputRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final contentPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final contentPaddingV = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              title: Text(
                'Add Bank Account',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleFontSize,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: bankNameController,
                      label: 'Bank Name',
                      icon: Icons.account_balance,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    _buildTextField(
                      controller: accountNumberController,
                      label: 'Account Number',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    _buildTextField(
                      controller: accountHolderNameController,
                      label: 'Account Holder Name',
                      icon: Icons.person,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    _buildTextField(
                      controller: ifscCodeController,
                      label: 'IFSC Code',
                      icon: Icons.code,
                      textCapitalization: TextCapitalization.characters,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    Row(
                      children: [
                        Checkbox(
                          value: isPrimary,
                          onChanged: (value) {
                            setDialogState(() {
                              isPrimary = value ?? false;
                            });
                          },
                          activeColor: primaryColor,
                        ),
                        Text(
                          'Set as primary account',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: labelFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: labelFontSize,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (bankNameController.text.isEmpty ||
                              accountNumberController.text.isEmpty ||
                              accountHolderNameController.text.isEmpty ||
                              ifscCodeController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final result = await WalletService.addBankAccount(
                            bankName: bankNameController.text,
                            accountNumber: accountNumberController.text,
                            accountHolderName: accountHolderNameController.text,
                            ifscCode: ifscCodeController.text,
                            isPrimary: isPrimary,
                          );

                          setDialogState(() => isLoading = false);

                          if (result != null && result.success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message.isNotEmpty ? result.message : 'Bank account added successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add bank account'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? AppColors.black : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dialogRadius),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? AppColors.black : AppColors.white,
                          ),
                        )
                      : Text(
                          'Add',
                          style: TextStyle(fontSize: labelFontSize),
                        ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
            );
          },
        );
      },
    );
  }

  // Edit Bank Account Dialog
  void _showEditBankAccountDialog(
    AppColorSet colors,
    Color primaryColor,
    bool isDark, {
    required int accountId,
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String ifscCode,
    required bool isPrimary,
  }) {
    final bankNameController = TextEditingController(text: bankName);
    final accountNumberController = TextEditingController(text: accountNumber);
    final accountHolderNameController = TextEditingController(text: accountHolderName);
    final ifscCodeController = TextEditingController(text: ifscCode);
    bool isPrimaryValue = isPrimary;
    bool isLoading = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final inputRadius = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 12.0 : 15.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;
    final contentPaddingH = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final contentPaddingV = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              title: Text(
                'Edit Bank Account',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleFontSize,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTextField(
                      controller: bankNameController,
                      label: 'Bank Name',
                      icon: Icons.account_balance,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    _buildTextField(
                      controller: accountNumberController,
                      label: 'Account Number',
                      icon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    _buildTextField(
                      controller: accountHolderNameController,
                      label: 'Account Holder Name',
                      icon: Icons.person,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    _buildTextField(
                      controller: ifscCodeController,
                      label: 'IFSC Code',
                      icon: Icons.code,
                      textCapitalization: TextCapitalization.characters,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    Row(
                      children: [
                        Checkbox(
                          value: isPrimaryValue,
                          onChanged: (value) {
                            setDialogState(() {
                              isPrimaryValue = value ?? false;
                            });
                          },
                          activeColor: primaryColor,
                        ),
                        Text(
                          'Set as primary account',
                          style: TextStyle(
                            color: colors.textSecondary,
                            fontSize: labelFontSize,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: labelFontSize,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          if (bankNameController.text.isEmpty ||
                              accountNumberController.text.isEmpty ||
                              accountHolderNameController.text.isEmpty ||
                              ifscCodeController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final result = await WalletService.updateBankAccount(
                            accountId: accountId,
                            bankName: bankNameController.text,
                            accountNumber: accountNumberController.text,
                            accountHolderName: accountHolderNameController.text,
                            ifscCode: ifscCodeController.text,
                            isPrimary: isPrimaryValue,
                          );

                          setDialogState(() => isLoading = false);

                          if (result != null && result.success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message.isNotEmpty ? result.message : 'Bank account updated successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update bank account'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? AppColors.black : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dialogRadius),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: isDark ? AppColors.black : AppColors.white,
                          ),
                        )
                      : Text(
                          'Update',
                          style: TextStyle(fontSize: labelFontSize),
                        ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
            );
          },
        );
      },
    );
  }

  // Delete Bank Account Dialog
  void _showDeleteBankAccountDialog(
    AppColorSet colors,
    Color primaryColor,
    bool isDark, {
    required int accountId,
    required String bankName,
  }) {
    bool isLoading = false;

    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    final dialogRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final titleFontSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final labelFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    final iconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 20.0 : 22.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              title: Text(
                'Delete Bank Account',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleFontSize,
                ),
              ),
              content: Text(
                'Are you sure you want to delete "$bankName"? This action cannot be undone.',
                style: TextStyle(
                  color: colors.textSecondary,
                  fontSize: labelFontSize,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: colors.textSecondary,
                      fontSize: labelFontSize,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setDialogState(() => isLoading = true);

                          final result = await WalletService.deleteBankAccount(
                            accountId: accountId,
                          );

                          setDialogState(() => isLoading = false);

                          if (result != null && result.success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message.isNotEmpty ? result.message : 'Bank account deleted successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete bank account'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dialogRadius),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: iconSize,
                          height: iconSize,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.white,
                          ),
                        )
                      : Text(
                          'Delete',
                          style: TextStyle(fontSize: labelFontSize),
                        ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(dialogRadius),
              ),
            );
          },
        );
      },
    );
  }

  // Reusable TextField Widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required AppColorSet colors,
    required Color primaryColor,
    required double inputRadius,
    required double labelFontSize,
    required double iconSize,
    required double contentPaddingH,
    required double contentPaddingV,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(inputRadius),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: labelFontSize,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: colors.textSecondary,
            fontSize: labelFontSize,
          ),
          prefixIcon: Icon(
            icon,
            color: primaryColor,
            size: iconSize,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: contentPaddingH,
            vertical: contentPaddingV,
          ),
        ),
      ),
    );
  }
}