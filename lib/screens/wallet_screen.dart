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
                              buttonFontSize: buttonLabelFontSize,
                            ),
                            SizedBox(height: sectionSpacing),
                            _buildStatsRow(
                              colors,
                              primaryColor,
                              cardRadius: smallRadius,
                              labelFontSize: walletIdFontSize,
                              valueFontSize: balanceLabelFontSize,
                              cardPadding: horizontalPadding,
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
    required double buttonFontSize,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
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
                ],
              ),
              ElevatedButton.icon(
                onPressed: _balance > 0 
                    ? () => _showWithdrawDialog(colors, primaryColor, isDark, cardRadius, cardPadding, labelFontSize, iconSize)
                    : null,
                icon: Icon(Icons.account_balance_wallet_outlined, size: iconSize * 0.8),
                label: Text(
                  'Withdraw',
                  style: TextStyle(fontSize: buttonFontSize),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? AppColors.black.withOpacity(0.3) : AppColors.white.withOpacity(0.2),
                  foregroundColor: isDark ? AppColors.black : AppColors.white,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(
                    horizontal: cardPadding * 0.6,
                    vertical: cardPadding * 0.4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(cardRadius * 0.5),
                    side: BorderSide(
                      color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.3),
                    ),
                  ),
                ),
              ),
            ],
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
              'G-Pay Accounts',
              style: TextStyle(
                fontSize: headerFontSize,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            GestureDetector(
              onTap: () => _showAddGPayAccountDialog(colors, primaryColor, isDark),
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
                      Icons.account_balance_wallet_outlined,
                      size: iconSize * 2,
                      color: colors.textTertiary,
                    ),
                    SizedBox(height: itemSpacing * 0.5),
                    Text(
                      'No G-Pay accounts added',
                      style: TextStyle(
                        fontSize: titleFontSize,
                        color: colors.textTertiary,
                      ),
                    ),
                    SizedBox(height: itemSpacing * 0.5),
                    TextButton.icon(
                      onPressed: () => _showAddGPayAccountDialog(colors, primaryColor, isDark),
                      icon: Icon(Icons.add, color: primaryColor, size: iconSize * 0.8),
                      label: Text(
                        'Add G-Pay Account',
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
                    final accountHolderName = account['account_holder_name']?.toString() ?? '';
                    final mobileNumber = account['mobile_number']?.toString() ?? '';
                    final upiId = account['upi_id']?.toString() ?? '';
                    final isPrimary = account['is_primary'] == true || account['is_primary'] == 1;
                    final isVerified = account['is_verified'] == true || account['is_verified'] == 1;
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
                          Icons.account_balance_wallet,
                          color: primaryColor,
                          size: iconSize,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              accountHolderName,
                              style: TextStyle(
                                fontSize: titleFontSize,
                                fontWeight: FontWeight.w500,
                                color: colors.textPrimary,
                              ),
                            ),
                          ),
                          if (isVerified)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: iconPadding * 0.5,
                                vertical: iconPadding * 0.25,
                              ),
                              margin: EdgeInsets.only(right: iconPadding * 0.25),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(cardRadius * 0.25),
                              ),
                              child: Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: subtitleFontSize * 0.8,
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w500,
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
                                color: AppColors.info.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(cardRadius * 0.25),
                              ),
                              child: Text(
                                'Primary',
                                style: TextStyle(
                                  fontSize: subtitleFontSize * 0.8,
                                  color: AppColors.info,
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
                            mobileNumber,
                            style: TextStyle(
                              color: colors.textSecondary,
                              fontSize: subtitleFontSize,
                            ),
                          ),
                          Text(
                            upiId,
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
                            _showEditGPayAccountDialog(
                              colors,
                              primaryColor,
                              isDark,
                              accountId: accountId,
                              accountHolderName: accountHolderName,
                              mobileNumber: mobileNumber,
                              upiId: upiId,
                              isPrimary: isPrimary,
                            );
                          } else if (value == 'delete') {
                            _showDeleteGPayAccountDialog(
                              colors,
                              primaryColor,
                              isDark,
                              accountId: accountId,
                              accountHolderName: accountHolderName,
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

  void _showAddGPayAccountDialog(AppColorSet colors, Color primaryColor, bool isDark) {
    final accountHolderNameController = TextEditingController();
    final mobileNumberController = TextEditingController();
    final upiIdController = TextEditingController();
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add G-Pay Account',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: titleFontSize,
                    ),
                  ),
                  SizedBox(height: contentPaddingV * 0.5),
                  Text(
                    'Payment Method',
                    style: TextStyle(
                      color: colors.textTertiary,
                      fontSize: labelFontSize * 0.85,
                    ),
                  ),
                  SizedBox(height: contentPaddingV * 0.25),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: contentPaddingH * 0.5,
                      vertical: contentPaddingV * 0.25,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(inputRadius * 0.5),
                    ),
                    child: Text(
                      'G-Pay',
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Holder Name *',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentPaddingV * 0.5),
                    _buildTextField(
                      controller: accountHolderNameController,
                      label: 'Enter name as per G-Pay account',
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
                    Text(
                      'G-Pay Mobile Number *',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentPaddingV * 0.5),
                    _buildTextField(
                      controller: mobileNumberController,
                      label: 'Enter 10-digit mobile number',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                      maxLength: 10,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    Text(
                      'UPI ID *',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentPaddingV * 0.5),
                    _buildTextField(
                      controller: upiIdController,
                      label: 'e.g., yourname@paytm',
                      icon: Icons.alternate_email,
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
                          if (accountHolderNameController.text.isEmpty ||
                              mobileNumberController.text.isEmpty ||
                              upiIdController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          if (mobileNumberController.text.length != 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid 10-digit mobile number'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          if (!upiIdController.text.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid UPI ID'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final result = await WalletService.addGPayAccount(
                            accountHolderName: accountHolderNameController.text,
                            mobileNumber: mobileNumberController.text,
                            upiId: upiIdController.text,
                            isPrimary: isPrimary,
                          );

                          setDialogState(() => isLoading = false);

                          if (result != null && result.success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message.isNotEmpty ? result.message : 'G-Pay account added successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to add G-Pay account'),
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
                          'Add G-Pay Account',
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

  void _showEditGPayAccountDialog(
    AppColorSet colors,
    Color primaryColor,
    bool isDark, {
    required int accountId,
    required String accountHolderName,
    required String mobileNumber,
    required String upiId,
    required bool isPrimary,
  }) {
    final accountHolderNameController = TextEditingController(text: accountHolderName);
    final mobileNumberController = TextEditingController(text: mobileNumber);
    final upiIdController = TextEditingController(text: upiId);
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
                'Edit G-Pay Account',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleFontSize,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Account Holder Name *',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentPaddingV * 0.5),
                    _buildTextField(
                      controller: accountHolderNameController,
                      label: 'Enter name as per G-Pay account',
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
                    Text(
                      'G-Pay Mobile Number *',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentPaddingV * 0.5),
                    _buildTextField(
                      controller: mobileNumberController,
                      label: 'Enter 10-digit mobile number',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      colors: colors,
                      primaryColor: primaryColor,
                      inputRadius: inputRadius,
                      labelFontSize: labelFontSize,
                      iconSize: iconSize,
                      contentPaddingH: contentPaddingH,
                      contentPaddingV: contentPaddingV,
                      maxLength: 10,
                    ),
                    SizedBox(height: contentPaddingH * 0.75),
                    Text(
                      'UPI ID *',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: labelFontSize * 0.9,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: contentPaddingV * 0.5),
                    _buildTextField(
                      controller: upiIdController,
                      label: 'e.g., yourname@paytm',
                      icon: Icons.alternate_email,
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
                          if (accountHolderNameController.text.isEmpty ||
                              mobileNumberController.text.isEmpty ||
                              upiIdController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please fill all fields'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          if (mobileNumberController.text.length != 10) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid 10-digit mobile number'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          if (!upiIdController.text.contains('@')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter a valid UPI ID'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isLoading = true);

                          final result = await WalletService.updateGPayAccount(
                            accountId: accountId,
                            accountHolderName: accountHolderNameController.text,
                            mobileNumber: mobileNumberController.text,
                            upiId: upiIdController.text,
                            isPrimary: isPrimaryValue,
                          );

                          setDialogState(() => isLoading = false);

                          if (result != null && result.success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message.isNotEmpty ? result.message : 'G-Pay account updated successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update G-Pay account'),
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

  void _showDeleteGPayAccountDialog(
    AppColorSet colors,
    Color primaryColor,
    bool isDark, {
    required int accountId,
    required String accountHolderName,
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
                'Delete G-Pay Account',
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: titleFontSize,
                ),
              ),
              content: Text(
                'Are you sure you want to delete "$accountHolderName"? This action cannot be undone.',
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

                          final result = await WalletService.deleteGPayAccount(
                            accountId: accountId,
                          );

                          setDialogState(() => isLoading = false);

                          if (result != null && result.success) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result.message.isNotEmpty ? result.message : 'G-Pay account deleted successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete G-Pay account'),
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

  void _showWithdrawDialog(
    AppColorSet colors,
    Color primaryColor,
    bool isDark,
    double dialogRadius,
    double dialogPadding,
    double labelFontSize,
    double iconSize,
  ) {
    final amountController = TextEditingController();
    final notesController = TextEditingController();
    int? selectedAccountId;
    bool isLoading = false;
    
    final verifiedAccounts = _bankAccounts.where((account) {
      return account['is_verified'] == true || account['is_verified'] == 1;
    }).toList();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: colors.card,
              title: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(iconSize * 0.4),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(dialogRadius * 0.5),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: primaryColor,
                      size: iconSize,
                    ),
                  ),
                  SizedBox(width: dialogPadding * 0.5),
                  Expanded(
                    child: Text(
                      'Withdraw to G-Pay',
                      style: TextStyle(
                        fontSize: labelFontSize * 1.3,
                        fontWeight: FontWeight.bold,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Amount *',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: dialogPadding * 0.3),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(dialogRadius * 0.5),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: labelFontSize,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter amount to withdraw',
                          hintStyle: TextStyle(
                            color: colors.textTertiary,
                            fontSize: labelFontSize,
                          ),
                          prefixIcon: Icon(
                            Icons.currency_rupee,
                            color: primaryColor,
                            size: iconSize,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: dialogPadding * 0.5,
                            vertical: dialogPadding * 0.5,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: dialogPadding * 0.2),
                    Text(
                      'Available: ₹${_balance.toStringAsFixed(2)} | Min: ₹1',
                      style: TextStyle(
                        fontSize: labelFontSize * 0.85,
                        color: colors.textTertiary,
                      ),
                    ),
                    SizedBox(height: dialogPadding * 0.6),
                    
                    Text(
                      'G-Pay Account *',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: dialogPadding * 0.3),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(dialogRadius * 0.5),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: dialogPadding * 0.5),
                      child: verifiedAccounts.isEmpty
                          ? Padding(
                              padding: EdgeInsets.symmetric(vertical: dialogPadding * 0.5),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.warning,
                                    size: iconSize,
                                  ),
                                  SizedBox(width: dialogPadding * 0.3),
                                  Expanded(
                                    child: Text(
                                      'No verified G-Pay accounts found. Please add a G-Pay account first.',
                                      style: TextStyle(
                                        fontSize: labelFontSize * 0.9,
                                        color: AppColors.warning,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                isExpanded: true,
                                value: selectedAccountId,
                                hint: Text(
                                  'Select G-Pay account',
                                  style: TextStyle(
                                    color: colors.textTertiary,
                                    fontSize: labelFontSize,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  color: primaryColor,
                                ),
                                dropdownColor: colors.card,
                                items: verifiedAccounts.map<DropdownMenuItem<int>>((account) {
                                  return DropdownMenuItem<int>(
                                    value: account['id'],
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          account['account_holder_name'] ?? 'Unknown',
                                          style: TextStyle(
                                            fontSize: labelFontSize,
                                            fontWeight: FontWeight.w500,
                                            color: colors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          account['upi_id'] ?? '',
                                          style: TextStyle(
                                            fontSize: labelFontSize * 0.85,
                                            color: colors.textTertiary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setDialogState(() {
                                    selectedAccountId = value;
                                  });
                                },
                              ),
                            ),
                    ),
                    SizedBox(height: dialogPadding * 0.6),
                    
                    Text(
                      'Notes (Optional)',
                      style: TextStyle(
                        fontSize: labelFontSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: dialogPadding * 0.3),
                    Container(
                      decoration: BoxDecoration(
                        color: colors.background,
                        borderRadius: BorderRadius.circular(dialogRadius * 0.5),
                        border: Border.all(color: primaryColor.withOpacity(0.3)),
                      ),
                      child: TextField(
                        controller: notesController,
                        maxLines: 2,
                        style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: labelFontSize,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Add any notes for this withdrawal...',
                          hintStyle: TextStyle(
                            color: colors.textTertiary,
                            fontSize: labelFontSize,
                          ),
                          prefixIcon: Padding(
                            padding: EdgeInsets.only(bottom: dialogPadding * 0.5),
                            child: Icon(
                              Icons.note_outlined,
                              color: primaryColor,
                              size: iconSize,
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: dialogPadding * 0.5,
                            vertical: dialogPadding * 0.5,
                          ),
                        ),
                      ),
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
                  onPressed: isLoading || verifiedAccounts.isEmpty
                      ? null
                      : () async {
                          final amountText = amountController.text.trim();
                          if (amountText.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please enter an amount'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          
                          final amount = double.tryParse(amountText);
                          if (amount == null || amount < 1) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Minimum withdrawal amount is ₹1'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          
                          if (amount > _balance) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Insufficient balance'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          
                          if (selectedAccountId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Please select a G-Pay account'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }
                          
                          setDialogState(() => isLoading = true);
                          
                          final result = await WalletService.withdrawToGPay(
                            amount: amount,
                            gpayAccountId: selectedAccountId!,
                            notes: notesController.text.trim().isNotEmpty 
                                ? notesController.text.trim() 
                                : null,
                          );
                          
                          setDialogState(() => isLoading = false);
                          
                          if (result != null && result['success'] == true) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result['message'] ?? 'Withdrawal request submitted successfully!'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                            _loadWalletData();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(result?['message'] ?? 'Failed to process withdrawal'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: isDark ? AppColors.black : AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(dialogRadius * 0.5),
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
                          'Submit Request',
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
    int? maxLength,
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
        maxLength: maxLength,
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
          counterText: '',
          contentPadding: EdgeInsets.symmetric(
            horizontal: contentPaddingH,
            vertical: contentPaddingV,
          ),
        ),
      ),
    );
  }
}
