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
import 'time_spending_screen.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _isLoading = true;
  bool _isProcessing = false;
  int _selectedPlanId = -1;
  List<Plan> _subscriptionPlans = [];
  
  final SubscriptionService _subscriptionService = SubscriptionService();

  PostpurchaseModelData? _currentPurchaseData;

  @override
  void initState() {
    super.initState();
    _step1_loadSubscriptionPlans();
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TimeSpendingScreen()),
    );
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
                    ],
                  ),
                ),
    );
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
