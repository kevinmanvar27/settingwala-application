import 'package:flutter/material.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentgateway/cfpaymentgatewayservice.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfsession/cfsession.dart';
import 'package:flutter_cashfree_pg_sdk/api/cftheme/cftheme.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpayment/cfdropcheckoutpayment.dart';
import 'package:flutter_cashfree_pg_sdk/api/cfpaymentcomponents/cfpaymentcomponent.dart';
import 'package:flutter_cashfree_pg_sdk/api/cferrorresponse/cferrorresponse.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfenums.dart';
import 'package:flutter_cashfree_pg_sdk/utils/cfexceptions.dart';
import '../widgets/base_screen.dart';
import '../theme/theme.dart';
import '../Service/subscription_service.dart';
import '../model/getsubscriptionmodel.dart';
import '../model/postpurchasemodel.dart';
import '../utils/responsive.dart';
import '../routes/app_routes.dart';
import '../utils/auth_helper.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  bool _isCancelling = false;
  int _selectedPlanId = -1;
  List<Plan> _subscriptionPlans = [];
  bool _hasActiveSubscription = false;
  String? _activeSubscriptionName;
  String? _subscriptionEndDate;
  bool _isValidating = true;
  
  final SubscriptionService _subscriptionService = SubscriptionService();

  PostpurchaseModelData? _currentPurchaseData;

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
      _step1_loadSubscriptionPlans();
      _checkActiveSubscription();
    }
    // If not valid, AuthHelper already redirected to login
  }

  Future<void> _checkActiveSubscription() async {
    try {
      final statusResult = await _subscriptionService.getSubscriptionStatus();
      if (!mounted) return;
      
      if (statusResult != null && statusResult.success && statusResult.data != null) {
        final subscription = statusResult.data.subscription;
        if (subscription != null && subscription.status == 'active') {
          setState(() {
            _hasActiveSubscription = true;
            _activeSubscriptionName = subscription.planName;
            _subscriptionEndDate = subscription.endDate;
          });
        }
      }
    } catch (e) {
      // Silent fail - subscription status check is optional
    }
  }

  Future<void> _step1_loadSubscriptionPlans() async {
    
    
    
    

    try {
      final result = await _subscriptionService.getSubscriptionPlans();

      if (!mounted) return;

      if (result != null && result.success) {
        setState(() {
          _subscriptionPlans = result.data.plans;
          if (_subscriptionPlans.isNotEmpty) {
            _selectedPlanId = _subscriptionPlans[0].id;
          }
          _isLoading = false;
        });
        
      } else {
        setState(() => _isLoading = false);
        _showError('Failed to load subscription plans');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      
    }
  }

  Future<void> _step2_createPurchaseOrder() async {
    if (_selectedPlanId == -1) {
      _showError('Please select a plan');
      return;
    }

    setState(() => _isProcessing = true);
    
    

    try {
      final purchaseResult = await _subscriptionService.purchaseSubscription(
        planId: _selectedPlanId,
      );

      if (purchaseResult == null || !purchaseResult.success) {
        throw Exception('Failed to create order');
      }

      _currentPurchaseData = purchaseResult.data;

      
      
      
      
      

      if (purchaseResult.data.paymentCompleted) {
        
        await _step5_confirmStatus();
        return;
      }

      await _step3_openCashfreePayment();

    } catch (e) {
      
      _showError('Failed to process payment: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<void> _step3_openCashfreePayment() async {
    if (_currentPurchaseData == null) {
      _showError('No order data available');
      return;
    }

    
    
    
    

    try {
      final cfEnvironment = _currentPurchaseData!.cashfreeEnv.toLowerCase() == 'production'
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final cfSession = CFSessionBuilder()
          .setEnvironment(cfEnvironment)
          .setOrderId(_currentPurchaseData!.cashfreeOrder.orderId)
          .setPaymentSessionId(_currentPurchaseData!.cashfreeOrder.paymentSessionId)
          .build();

      final cfPaymentComponent = CFPaymentComponentBuilder()
          .setComponents([
            CFPaymentModes.CARD,
            CFPaymentModes.UPI,
            CFPaymentModes.NETBANKING,
            CFPaymentModes.WALLET,
          ])
          .build();

      final cfTheme = CFThemeBuilder()
          .setNavigationBarBackgroundColorColor("#6750A4")
          .setNavigationBarTextColor("#FFFFFF")
          .setButtonBackgroundColor("#6750A4")
          .setButtonTextColor("#FFFFFF")
          .setPrimaryTextColor("#000000")
          .setSecondaryTextColor("#666666")
          .build();

      final cfDropCheckoutPayment = CFDropCheckoutPaymentBuilder()
          .setSession(cfSession)
          .setPaymentComponent(cfPaymentComponent)
          .setTheme(cfTheme)
          .build();

      final cfPaymentGatewayService = CFPaymentGatewayService();
      
      cfPaymentGatewayService.setCallback(
        (String orderId) {
          
          
          
          
          
          
          
          
          
          _step4_verifyPayment(orderId);
        },
        (CFErrorResponse errorResponse, String orderId) {
          
          
          
          
          
          
          
          
          _onPaymentFailure(errorResponse.getMessage() ?? 'Payment failed');
        },
      );

      cfPaymentGatewayService.doPayment(cfDropCheckoutPayment);

    } on CFException catch (e) {
      
      _onPaymentFailure(e.message);
    } catch (e) {
      
      _onPaymentFailure('Something went wrong. Please try again.');
    }
  }

  Future<void> _step4_verifyPayment(String orderId) async {
    if (!mounted) return;
    if (_currentPurchaseData == null) {
      
      return;
    }

    
    
    
    

    _showMessage('Verifying payment...', isLoading: true);

    try {
      final verifyResult = await _subscriptionService.verifyPayment(
        subscriptionId: _currentPurchaseData!.subscriptionId,
        orderId: _currentPurchaseData!.cashfreeOrder.orderId,
        cfOrderId: _currentPurchaseData!.cashfreeOrder.cfOrderId,
      );

      if (verifyResult != null && verifyResult.success) {
        
        
        
        
        await _step5_confirmStatus();
      } else {
        
        await _step5_confirmStatus();
      }

    } catch (e) {
      
      _navigateToSuccess();
    }
  }

  Future<void> _step5_confirmStatus() async {
    
    

    try {
      final statusResult = await _subscriptionService.getSubscriptionStatus();

      if (statusResult != null && statusResult.success) {
        
      } else {
        
      }

    } catch (e) {
      
    }

    _navigateToSuccess();
  }

  void _navigateToSuccess() {
    if (!mounted) return;

    _currentPurchaseData = null;

    
    
    
    

    _showMessage('Payment successful! Subscription activated.', isSuccess: true);

    AppRoutes.navigateAndReplace(context, AppRoutes.timeSpending);
  }

  void _onPaymentFailure(String errorMessage) {
    if (!mounted) return;

    setState(() => _isProcessing = false);
    _currentPurchaseData = null;
    
    _showError(errorMessage);
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }

  void _showMessage(String message, {bool isSuccess = false, bool isLoading = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isLoading) ...[
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                ),
              ),
              const SizedBox(width: 12),
            ],
            Expanded(child: Text(message, style: const TextStyle(color: AppColors.white))),
          ],
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        duration: Duration(seconds: isLoading ? 10 : 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Responsive.init(context);
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;

    // Show loading while validating user
    if (_isValidating) {
      return BaseScreen(
        title: 'Subscription Plans',
        showBackButton: true,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
        ),
      );
    }

    return BaseScreen(
      title: 'Subscription Plans',
      showBackButton: true,
      body: _isLoading
          ? _buildLoadingWidget(colors)
          : _subscriptionPlans.isEmpty
              ? _buildEmptyWidget(colors, primaryColor)
              : SingleChildScrollView(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 24 : 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose Your Plan',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 18 : isTablet ? 26 : 20,
                          fontWeight: FontWeight.bold,
                          color: colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: isTablet ? 12 : 8),
                      Text(
                        'Subscribe to access time spending features and more',
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: isSmallScreen ? 13 : isTablet ? 16 : 14,
                        ),
                      ),
                      SizedBox(height: isTablet ? 32 : 24),

                      if (isTablet)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _subscriptionPlans.map((plan) => Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: isDesktop ? 8 : 4),
                              child: _buildSubscriptionCard(
                                plan: plan,
                                isSelected: _selectedPlanId == plan.id,
                                colors: colors,
                                primaryColor: primaryColor,
                                isDark: isDark,
                              ),
                            ),
                          )).toList(),
                        )
                      else
                        ..._subscriptionPlans.map((plan) => _buildSubscriptionCard(
                          plan: plan,
                          isSelected: _selectedPlanId == plan.id,
                          colors: colors,
                          primaryColor: primaryColor,
                          isDark: isDark,
                        )),

                      SizedBox(height: isTablet ? 40 : 32),

                      _buildSubscribeButton(colors, primaryColor, isDark),

                      // Active Subscription Section
                      if (_hasActiveSubscription) ...[
                        SizedBox(height: isTablet ? 40 : 32),
                        _buildActiveSubscriptionSection(colors, primaryColor, isDark, isSmallScreen, isTablet),
                      ],

                      // Subscription History Button
                      SizedBox(height: isTablet ? 24 : 16),
                      _buildHistoryButton(colors, primaryColor, isDark, isSmallScreen, isTablet),
                    ],
                  ),
                ),
    );
  }

  Widget _buildActiveSubscriptionSection(
    AppColorSet colors,
    Color primaryColor,
    bool isDark,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : isTablet ? 35 : 30),
        border: Border.all(color: primaryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success,
                size: isSmallScreen ? 20 : isTablet ? 28 : 24,
              ),
              SizedBox(width: isTablet ? 12 : 8),
              Expanded(
                child: Text(
                  'Active Subscription',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : isTablet ? 22 : 18,
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 16 : 12),
          Text(
            _activeSubscriptionName ?? 'Premium Plan',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : isTablet ? 18 : 16,
              color: colors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_subscriptionEndDate != null) ...[
            SizedBox(height: isTablet ? 8 : 4),
            Text(
              'Expires: ${_formatDateString(_subscriptionEndDate!)}',
              style: TextStyle(
                fontSize: isSmallScreen ? 12 : isTablet ? 16 : 14,
                color: colors.textSecondary,
              ),
            ),
          ],
          SizedBox(height: isTablet ? 20 : 16),
          SizedBox(
            width: double.infinity,
            height: isSmallScreen ? 42 : isTablet ? 54 : 46,
            child: OutlinedButton.icon(
              onPressed: _isCancelling ? null : _showCancelSubscriptionDialog,
              icon: _isCancelling
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.error,
                      ),
                    )
                  : Icon(Icons.cancel_outlined, size: isSmallScreen ? 16 : 18),
              label: Text(
                _isCancelling ? 'Cancelling...' : 'Cancel Subscription',
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : isTablet ? 17 : 15,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 21 : isTablet ? 27 : 23),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryButton(
    AppColorSet colors,
    Color primaryColor,
    bool isDark,
    bool isSmallScreen,
    bool isTablet,
  ) {
    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 46 : isTablet ? 60 : 50,
      child: OutlinedButton.icon(
        onPressed: () => AppRoutes.navigateTo(context, AppRoutes.subscriptionHistory),
        icon: Icon(Icons.history, size: isSmallScreen ? 18 : isTablet ? 24 : 20),
        label: Text(
          'View Subscription History',
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : isTablet ? 18 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor.withOpacity(0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 23 : isTablet ? 30 : 25),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return _formatDate(date);
    } catch (e) {
      return dateString;
    }
  }

  Future<void> _showCancelSubscriptionDialog() async {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 28),
            const SizedBox(width: 12),
            Text(
              'Cancel Subscription',
              style: TextStyle(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to cancel your subscription?',
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '• You will lose access to premium features\n'
              '• Your subscription will remain active until the end of the billing period\n'
              '• You can resubscribe anytime',
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep Subscription',
              style: TextStyle(color: primaryColor),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancel Subscription'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _cancelSubscription();
    }
  }

  Future<void> _cancelSubscription() async {
    setState(() => _isCancelling = true);

    try {
      final response = await _subscriptionService.cancelSubscription();

      if (!mounted) return;

      if (response.success) {
        setState(() {
          _hasActiveSubscription = false;
          _activeSubscriptionName = null;
          _subscriptionEndDate = null;
        });
        _showMessage('Subscription cancelled successfully', isSuccess: true);
      } else {
        _showError(response.message ?? 'An error occurred');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to cancel subscription. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isCancelling = false);
      }
    }
  }

  Widget _buildLoadingWidget(AppColorSet colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(colors.textPrimary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading subscription plans...',
            style: TextStyle(color: colors.textSecondary, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(AppColorSet colors, Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.subscriptions_outlined, size: 64, color: colors.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No subscription plans available',
            style: TextStyle(color: colors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _step1_loadSubscriptionPlans();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionCard({
    required Plan plan,
    required bool isSelected,
    required AppColorSet colors,
    required Color primaryColor,
    required bool isDark,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    String durationText = '${plan.durationMonths} month${plan.durationMonths > 1 ? 's' : ''}';
    bool hasDiscount = plan.discountPrice != null &&
        plan.discountPrice!.isNotEmpty &&
        plan.discountPrice != 'null' &&
        plan.discountPrice != plan.originalPrice;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanId = plan.id),
      child: Container(
        margin: EdgeInsets.only(bottom: isTablet ? 0 : 16),
        padding: EdgeInsets.all(isSmallScreen ? 12 : isTablet ? 20 : 16),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : colors.card,
          borderRadius: BorderRadius.circular(isSmallScreen ? 20 : isTablet ? 35 : 30),
          border: Border.all(
            color: isSelected ? primaryColor : colors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryColor.withOpacity(0.2)
                  : colors.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : isTablet ? 22 : 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? primaryColor : colors.textPrimary,
                        ),
                      ),
                      SizedBox(height: isTablet ? 6 : 4),
                      Text(
                        plan.description,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : isTablet ? 14 : 12,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasDiscount)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : isTablet ? 12 : 8,
                      vertical: isSmallScreen ? 3 : isTablet ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Discount',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: isSmallScreen ? 8 : isTablet ? 12 : 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: isTablet ? 20 : 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasDiscount) ...[
                  Text(
                    '₹${plan.originalPrice}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 14 : isTablet ? 18 : 16,
                      color: colors.textSecondary,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : 6),
                ],
                Text(
                  '₹${hasDiscount ? plan.discountPrice : plan.amount}',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 20 : isTablet ? 30 : 24,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? primaryColor : colors.textPrimary,
                  ),
                ),
                SizedBox(width: isTablet ? 6 : 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    '/$durationText',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : isTablet ? 16 : 14,
                      color: colors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isTablet ? 16 : 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: colors.textSecondary,
                      size: isSmallScreen ? 12 : isTablet ? 18 : 14,
                    ),
                    SizedBox(width: isTablet ? 6 : 4),
                    Text(
                      durationText,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : isTablet ? 14 : 12,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Radio<int>(
                  value: plan.id,
                  groupValue: _selectedPlanId,
                  onChanged: (value) => setState(() => _selectedPlanId = value!),
                  activeColor: primaryColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    return SizedBox(
      width: double.infinity,
      height: isSmallScreen ? 46 : isTablet ? 60 : 50,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _step2_createPurchaseOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 25 : isTablet ? 35 : 30),
          ),
          elevation: 0,
          disabledBackgroundColor: colors.disabled,
        ),
        child: _isProcessing
            ? SizedBox(
                height: isSmallScreen ? 18 : isTablet ? 24 : 20,
                width: isSmallScreen ? 18 : isTablet ? 24 : 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.black : AppColors.white,
                  ),
                ),
              )
            : Text(
                'Subscribe Now',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : isTablet ? 20 : 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
