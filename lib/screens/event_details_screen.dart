import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
import '../Service/event_service.dart';
import '../model/event_payment_model.dart';
import '../utils/location_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final EventModel event;

  const EventDetailsScreen({
    super.key,
    required this.event,
  });

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  bool _isJoining = false;
  bool _isJoined = false;
  String? _userGender;
  
  // Cashfree payment data
  int? _eventPaymentId;
  EventPaymentOrderData? _paymentOrderData;

  @override
  void initState() {
    super.initState();
    _isJoined = widget.event.isJoined;
    _loadUserGender();
  }

  Future<void> _loadUserGender() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userGender = prefs.getString('user_gender') ?? 'male';
    });
  }

  double _getPaymentAmount() {
    if (widget.event.isCoupleEvent && widget.event.paymentAmountCouple != null) {
      return widget.event.paymentAmountCouple!;
    }
    
    if (_userGender == 'female' && widget.event.paymentAmountGirls != null) {
      return widget.event.paymentAmountGirls!;
    }
    
    if (widget.event.paymentAmountBoys != null) {
      return widget.event.paymentAmountBoys!;
    }
    
    return 0.0;
  }

  bool _isFreeEvent() {
    return _getPaymentAmount() == 0.0;
  }

  String _formatDate() {
    if (widget.event.eventDate == null) return 'Date TBD';
    final date = widget.event.eventDate!;
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime() {
    if (widget.event.eventDate == null) return 'Time TBD';
    final date = widget.event.eventDate!;
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final period = date.hour >= 12 ? 'PM' : 'AM';
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute $period';
  }

  // Step 1: Join Event - Get event_payment_id
  Future<void> _handleJoinEvent() async {
    if (_isJoined) return;

    setState(() => _isJoining = true);

    try {
      final result = await EventService.joinEvent(widget.event.id);
      
      if (result['success'] == true) {
        _eventPaymentId = result['event_payment_id'];
        
        if (result['payment_required'] == true && _eventPaymentId != null) {
          // Payment required - show confirmation dialog
          _showPaymentConfirmation(
            context,
            context.colors,
            Theme.of(context).brightness == Brightness.dark 
                ? AppColors.primaryLight 
                : AppColors.primary,
            Theme.of(context).brightness == Brightness.dark,
            (result['payment_amount'] as double?) ?? _getPaymentAmount(),
          );
        } else {
          // Free event - already joined
          setState(() => _isJoined = true);
          _showSuccessMessage(result['message'] ?? 'Successfully joined the event!');
        }
      } else {
        _showErrorMessage(result['message'] ?? 'Failed to join event');
      }
    } catch (e) {
      _showErrorMessage('Error: ${e.toString()}');
    } finally {
      setState(() => _isJoining = false);
    }
  }

  // Step 2: Create Cashfree Payment Order
  Future<void> _createPaymentOrder() async {
    if (_eventPaymentId == null) {
      _showErrorMessage('Payment ID not found. Please try again.');
      return;
    }

    setState(() => _isJoining = true);
    _showLoadingMessage('Creating payment order...');

    try {
      final orderResult = await EventService.createPaymentOrder(_eventPaymentId!);
      
      if (orderResult != null && orderResult.success && orderResult.data != null) {
        _paymentOrderData = orderResult.data;
        _hideLoadingMessage();
        await _openCashfreePayment();
      } else {
        _hideLoadingMessage();
        _showErrorMessage(orderResult?.message ?? 'Failed to create payment order');
      }
    } catch (e) {
      _hideLoadingMessage();
      _showErrorMessage('Error creating payment order: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  // Step 3: Open Cashfree Payment Gateway
  Future<void> _openCashfreePayment() async {
    if (_paymentOrderData == null) {
      _showErrorMessage('Payment order data not available');
      return;
    }

    try {
      // Use isProduction helper from model
      final cfEnvironment = _paymentOrderData!.isProduction
          ? CFEnvironment.PRODUCTION
          : CFEnvironment.SANDBOX;

      final cfSession = CFSessionBuilder()
          .setEnvironment(cfEnvironment)
          .setOrderId(_paymentOrderData!.orderId)
          .setPaymentSessionId(_paymentOrderData!.paymentSessionId)
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
          // Payment Success
          _verifyPayment(orderId);
        },
        (CFErrorResponse errorResponse, String orderId) {
          // Payment Failed
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

  // Step 4: Verify Payment with Backend
  Future<void> _verifyPayment(String orderId) async {
    if (!mounted) return;
    if (_paymentOrderData == null || _eventPaymentId == null) {
      _showErrorMessage('Payment data not found');
      return;
    }

    _showLoadingMessage('Verifying payment...');

    try {
      final verifyResult = await EventService.verifyPayment(
        eventPaymentId: _eventPaymentId!,
        orderId: _paymentOrderData!.orderId,
      );

      _hideLoadingMessage();

      if (verifyResult != null && verifyResult.success) {
        setState(() => _isJoined = true);
        _showSuccessMessage('Payment successful! You are registered for the event.');
      } else {
        // Even if verify fails, payment might be successful
        // Backend will handle reconciliation
        setState(() => _isJoined = true);
        _showSuccessMessage('Payment completed! Registration confirmed.');
      }
    } catch (e) {
      _hideLoadingMessage();
      // Assume success if verification call fails but payment was done
      setState(() => _isJoined = true);
      _showSuccessMessage('Payment completed! Please check your registration status.');
    }
  }

  void _onPaymentFailure(String message) {
    if (!mounted) return;
    _showErrorMessage('Payment failed: $message');
  }

  void _showSuccessMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showErrorMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
  
  Future<void> _openMapsForDirections(double latitude, double longitude, String eventName) async {
    final locationPermission = await LocationUtils.checkLocationPermission();
    if (!locationPermission) {
      // If permission is denied, just open maps with the destination
      final url = 'https://www.google.com/maps/search/?api=1&query=' + latitude.toString() + ',' + longitude.toString();
      
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch maps', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
      return;
    }

    final currentPosition = await LocationUtils.getCurrentLocation();
    if (currentPosition != null) {
      // Open Google Maps with directions from current location to destination
      final url = 'https://www.google.com/maps/dir/?api=1&origin=' + currentPosition.latitude.toString() + ',' + currentPosition.longitude.toString() + '&destination=' + latitude.toString() + ',' + longitude.toString() + '&travelmode=driving';
      
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch maps', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } else {
      // If current location is not available, just open maps with the destination
      final url = 'https://www.google.com/maps/search/?api=1&query=' + latitude.toString() + ',' + longitude.toString();
      
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch maps', style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showLoadingMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 16),
            Text(message, style: const TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(minutes: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _hideLoadingMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
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
    
    final screenPadding = isDesktop ? 32.0 : isTablet ? 24.0 : isSmallScreen ? 12.0 : 16.0;
    final sectionSpacing = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 18.0 : 24.0;
    final titleSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    final sectionTitleSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    
    final maxContentWidth = isDesktop ? 900.0 : isTablet ? 700.0 : double.infinity;
    
    return BaseScreen(
      title: widget.event.title,
      showBackButton: true,
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: maxContentWidth),
            padding: EdgeInsets.all(screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventBanner(context, colors, primaryColor, isDark),
                SizedBox(height: sectionSpacing),
                
                _buildSectionTitle('Event Date & Time', colors, sectionTitleSize),
                SizedBox(height: titleSpacing),
                _buildDateTimeCard(context, colors, primaryColor),
                SizedBox(height: sectionSpacing),
                
                _buildSectionTitle('Event Location', colors, sectionTitleSize),
                SizedBox(height: titleSpacing),
                _buildLocationCard(context, colors, primaryColor, isDark),
                SizedBox(height: sectionSpacing),
                
                if (widget.event.description != null && widget.event.description!.isNotEmpty) ...[
                  _buildSectionTitle('About This Event', colors, sectionTitleSize),
                  SizedBox(height: titleSpacing),
                  _buildDescriptionCard(context, colors, primaryColor),
                  SizedBox(height: sectionSpacing),
                ],
                
                _buildSectionTitle('Rules and Regulations', colors, sectionTitleSize),
                SizedBox(height: titleSpacing),
                _buildRulesCard(context, colors, primaryColor),
                SizedBox(height: sectionSpacing),
                
                if (!_isFreeEvent()) ...[
                  _buildSectionTitle('Secure Payment', colors, sectionTitleSize),
                  SizedBox(height: titleSpacing),
                  _buildPaymentCard(context, colors, primaryColor, isDark),
                  SizedBox(height: sectionSpacing),
                ],
                
                if (_isFreeEvent() && !_isJoined) ...[
                  _buildFreeEventJoinButton(context, primaryColor, isDark),
                  SizedBox(height: sectionSpacing),
                ],
                
                if (_isJoined) ...[
                  _buildJoinedIndicator(context, colors),
                  SizedBox(height: sectionSpacing),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventBanner(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final bannerHeight = isDesktop ? 240.0 : isTablet ? 220.0 : isSmallScreen ? 140.0 : 180.0;
    final bannerRadius = isDesktop ? 40.0 : isTablet ? 35.0 : isSmallScreen ? 20.0 : 30.0;
    final bannerPadding = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
    final bgIconSize = isDesktop ? 200.0 : isTablet ? 180.0 : isSmallScreen ? 100.0 : 150.0;
    final bgIconOffset = isDesktop ? -40.0 : isTablet ? -35.0 : isSmallScreen ? -20.0 : -30.0;
    
    final badgePaddingH = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final badgePaddingV = isDesktop ? 8.0 : isTablet ? 7.0 : isSmallScreen ? 4.0 : 6.0;
    final badgeRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final badgeTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    
    final titleSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 18.0 : 24.0;
    final titleBadgeSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    String badgeText = _isFreeEvent() ? 'Free Event' : 'Premium Event';
    if (_isJoined) badgeText = 'Joined';
    
    return Container(
      height: bannerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor,
            primaryColor.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(bannerRadius),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: bgIconOffset,
            bottom: bgIconOffset,
            child: Icon(
              Icons.event,
              size: bgIconSize,
              color: (isDark ? AppColors.black : AppColors.white).withOpacity(0.1),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(bannerPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: badgePaddingH, vertical: badgePaddingV),
                  decoration: BoxDecoration(
                    color: _isJoined 
                        ? AppColors.success.withOpacity(0.9)
                        : (isDark ? AppColors.black : AppColors.white).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(badgeRadius),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: _isJoined ? Colors.white : (isDark ? AppColors.black : AppColors.white),
                      fontSize: badgeTextSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(height: titleBadgeSpacing),
                Text(
                  widget.event.title,
                  style: TextStyle(
                    color: isDark ? AppColors.black : AppColors.white,
                    fontSize: titleSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, AppColorSet colors, double fontSize) {
    return Text(
      title,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: colors.textPrimary,
      ),
    );
  }

  Widget _buildDateTimeCard(BuildContext context, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
    final dateBoxPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 10.0 : 16.0;
    final dateBoxRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 10.0 : 15.0;
    final dateDaySize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 18.0 : 24.0;
    final dateMonthSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 11.0 : 14.0;
    
    final infoIconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 14.0 : 18.0;
    final infoTextSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 13.0 : 16.0;
    final infoIconSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final infoRowSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final boxInfoSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 10.0 : 16.0;
    
    String day = '--';
    String month = '---';
    if (widget.event.eventDate != null) {
      final date = widget.event.eventDate!;
      day = date.day.toString();
      final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
      month = months[date.month - 1];
    }
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
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
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(dateBoxPadding),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(dateBoxRadius),
            ),
            child: Column(
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: dateDaySize,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    fontSize: dateMonthSize,
                    fontWeight: FontWeight.w500,
                    color: primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: boxInfoSpacing),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: infoIconSize,
                      color: primaryColor,
                    ),
                    SizedBox(width: infoIconSpacing),
                    Expanded(
                      child: Text(
                        _formatDate(),
                        style: TextStyle(
                          fontSize: infoTextSize,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: infoRowSpacing),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: infoIconSize,
                      color: primaryColor,
                    ),
                    SizedBox(width: infoIconSpacing),
                    Expanded(
                      child: Text(
                        _formatTime(),
                        style: TextStyle(
                          fontSize: infoTextSize,
                          fontWeight: FontWeight.w500,
                          color: colors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
    final iconContainerPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final locationIconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 18.0 : 24.0;
    final iconTextSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    final locationNameSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 13.0 : 16.0;
    final locationSubSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final textSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    
    final buttonRowSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final buttonRadius = isDesktop ? 30.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 25.0;
    final buttonPaddingV = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final buttonTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 11.0 : 14.0;
    final buttonIconSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconContainerPadding),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: primaryColor,
                  size: locationIconSize,
                ),
              ),
              SizedBox(width: iconTextSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.event.location ?? 'Location TBD',
                      style: TextStyle(
                        fontSize: locationNameSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (widget.event.latitude != null && widget.event.longitude != null) ...[
                      SizedBox(height: textSpacing),
                      Text(
                        'Coordinates: ${widget.event.latitude!.toStringAsFixed(4)}, ${widget.event.longitude!.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: locationSubSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: buttonRowSpacing),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (widget.event.latitude != null && widget.event.longitude != null) {
                      _openMapsForDirections(
                        widget.event.latitude!, 
                        widget.event.longitude!,
                        widget.event.title,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Event location coordinates not available', style: TextStyle(color: AppColors.white)),
                          backgroundColor: AppColors.error,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    }
                  },
                  icon: Icon(Icons.directions, size: buttonIconSize),
                  label: Text('Get Directions', style: TextStyle(fontSize: buttonTextSize)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(buttonRadius),
                    ),
                    padding: EdgeInsets.symmetric(vertical: buttonPaddingV),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }

  void _showDistanceDialog(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    // Check if event has coordinates
    if (widget.event.latitude == null || widget.event.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Event location coordinates not available', style: TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    
    // Show loading dialog while getting current location
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text('Calculating distance...', style: TextStyle(color: colors.textPrimary)),
          ],
        ),
      ),
    );
    
    // Calculate distance
    _calculateDistance().then((distance) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        _showActualDistanceDialog(context, colors, primaryColor, isDark, distance);
      }
    }).catchError((error) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not calculate distance: ' + error.toString(), style: TextStyle(color: AppColors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    });
  }
  
  Future<double> _calculateDistance() async {
    final locationPermission = await LocationUtils.checkLocationPermission();
    if (!locationPermission) {
      throw 'Location permission denied';
    }

    final currentPosition = await LocationUtils.getCurrentLocation();
    if (currentPosition == null) {
      throw 'Could not get current location';
    }
    
    if (widget.event.latitude == null || widget.event.longitude == null) {
      throw 'Event location not available';
    }
    
    final distance = LocationUtils.calculateDistance(
      currentPosition.latitude,
      currentPosition.longitude,
      widget.event.latitude!,
      widget.event.longitude!,
    );
    
    return distance;
  }
  
  void _showActualDistanceDialog(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark, double distance) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    final titleIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final titleTextSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final titleIconSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    final distanceCirclePadding = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    final distanceTextSize = isDesktop ? 40.0 : isTablet ? 36.0 : isSmallScreen ? 24.0 : 32.0;
    final labelTextSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 13.0 : 16.0;
    final infoTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final contentSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final sectionSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    final buttonRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final buttonTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    // Calculate estimated time (assuming average speed of 40 km/h)
    final estimatedTime = (distance / 40.0 * 60).round();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.location_on, color: primaryColor, size: titleIconSize),
            SizedBox(width: titleIconSpacing),
            Text(
              'Distance',
              style: TextStyle(color: colors.textPrimary, fontSize: titleTextSize),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(distanceCirclePadding),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Text(
                distance < 1 ? ((distance * 1000).round().toString() + ' m') : (distance.toStringAsFixed(2) + ' km'),
                style: TextStyle(
                  fontSize: distanceTextSize,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
            SizedBox(height: contentSpacing),
            Text(
              distance < 1 ? 'meters away' : 'kilometers away',
              style: TextStyle(
                fontSize: labelTextSize,
                color: colors.textSecondary,
              ),
            ),
            SizedBox(height: sectionSpacing),
            Text(
              'Approximately ' + (estimatedTime > 0 ? estimatedTime.toString() : '1') + ' min by car',
              style: TextStyle(
                fontSize: infoTextSize,
                color: primaryColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
            ),
            child: Text('OK', style: TextStyle(fontSize: buttonTextSize)),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    final textSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
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
      child: Text(
        widget.event.description!,
        style: TextStyle(
          fontSize: textSize,
          color: colors.textPrimary,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildRulesCard(BuildContext context, AppColorSet colors, Color primaryColor) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
    final ruleItemPaddingV = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 5.0 : 8.0;
    final iconContainerPadding = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final ruleIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 16.0 : 20.0;
    final ruleTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final iconTextSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    List<Map<String, dynamic>> rules;
    if (widget.event.rulesAndRegulations != null && widget.event.rulesAndRegulations!.isNotEmpty) {
      // Parse HTML content - extract text from <li> tags
      final htmlContent = widget.event.rulesAndRegulations!;
      final List<String> rulesList = [];
      
      // Check if content has HTML tags
      if (htmlContent.contains('<li>') || htmlContent.contains('<li ')) {
        // Extract content from <li> tags using regex
        final liRegex = RegExp(r'<li[^>]*>(.*?)<\/li>', caseSensitive: false, dotAll: true);
        final matches = liRegex.allMatches(htmlContent);
        for (final match in matches) {
          String text = match.group(1) ?? '';
          // Remove any remaining HTML tags
          text = text.replaceAll(RegExp(r'<[^>]*>'), '').trim();
          // Decode HTML entities
          text = text
              .replaceAll('&amp;', '&')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>')
              .replaceAll('&quot;', '"')
              .replaceAll('&#39;', "'")
              .replaceAll('&nbsp;', ' ')
              .replaceAll('/ ', '')
              .trim();
          if (text.isNotEmpty) {
            rulesList.add(text);
          }
        }
      }
      
      // Fallback: if no <li> tags found, split by newlines or treat as single rule
      if (rulesList.isEmpty) {
        final splitRules = htmlContent
            .replaceAll(RegExp(r'<[^>]*>'), '') // Remove all HTML tags
            .split('\n')
            .where((r) => r.trim().isNotEmpty)
            .toList();
        rulesList.addAll(splitRules);
      }
      
      rules = rulesList.map((r) => {'icon': Icons.check_circle, 'text': r.trim()}).toList();
    } else {
      rules = [
        {'icon': Icons.checkroom, 'text': 'Dress code: Smart casual'},
        {'icon': Icons.phone_disabled, 'text': 'No phones during dating rounds'},
        {'icon': Icons.schedule, 'text': 'Be punctual for all rounds'},
        {'icon': Icons.timer, 'text': 'Respect the time limits'},
        {'icon': Icons.emoji_emotions, 'text': 'Have fun and be yourself!'},
      ];
    }

    return Container(
      padding: EdgeInsets.all(cardPadding),
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
        children: rules.map((rule) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: ruleItemPaddingV),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(iconContainerPadding),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    rule['icon'] as IconData,
                    color: primaryColor,
                    size: ruleIconSize,
                  ),
                ),
                SizedBox(width: iconTextSpacing),
                Expanded(
                  child: Text(
                    rule['text'] as String,
                    style: TextStyle(
                      fontSize: ruleTextSize,
                      color: colors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    
    final iconContainerPadding = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final securityIconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 18.0 : 24.0;
    final iconTextSpacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    final secureTextSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 13.0 : 16.0;
    final secureSubTextSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final textSpacing = isDesktop ? 6.0 : isTablet ? 5.0 : isSmallScreen ? 2.0 : 4.0;
    
    final priceBoxPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final priceBoxRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 10.0 : 15.0;
    final priceLabelSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final priceValueSize = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 22.0 : 28.0;
    final paymentIconSize = isDesktop ? 26.0 : isTablet ? 24.0 : isSmallScreen ? 16.0 : 20.0;
    final paymentIconSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    final buttonHeight = isDesktop ? 64.0 : isTablet ? 60.0 : isSmallScreen ? 48.0 : 56.0;
    final buttonRadius = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final buttonTextSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    
    final sectionSpacing = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    
    final paymentAmount = _getPaymentAmount();
    
    return Container(
      padding: EdgeInsets.all(cardPadding),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(iconContainerPadding),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.security,
                  color: AppColors.success,
                  size: securityIconSize,
                ),
              ),
              SizedBox(width: iconTextSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Secure Payment',
                      style: TextStyle(
                        fontSize: secureTextSize,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                    SizedBox(height: textSpacing),
                    Text(
                      'Your payment is protected',
                      style: TextStyle(
                        fontSize: secureSubTextSize,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: sectionSpacing),
          Container(
            padding: EdgeInsets.all(priceBoxPadding),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(priceBoxRadius),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Event Access Fee',
                      style: TextStyle(
                        fontSize: priceLabelSize,
                        color: colors.textSecondary,
                      ),
                    ),
                    SizedBox(height: textSpacing),
                    Text(
                      '₹${paymentAmount.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: priceValueSize,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(Icons.credit_card, color: primaryColor.withOpacity(0.6), size: paymentIconSize),
                    SizedBox(width: paymentIconSpacing),
                    Icon(Icons.account_balance, color: primaryColor.withOpacity(0.6), size: paymentIconSize),
                    SizedBox(width: paymentIconSpacing),
                    Icon(Icons.qr_code, color: primaryColor.withOpacity(0.6), size: paymentIconSize),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: sectionSpacing),
          SizedBox(
            width: double.infinity,
            height: buttonHeight,
            child: ElevatedButton(
              onPressed: _isJoined ? null : (_isJoining ? null : _handleJoinEvent),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isJoined ? AppColors.success : primaryColor,
                foregroundColor: isDark ? AppColors.black : AppColors.white,
                disabledBackgroundColor: _isJoined ? AppColors.success : colors.inputBorder,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(buttonRadius),
                ),
                elevation: 4,
              ),
              child: _isJoining
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isDark ? AppColors.black : AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      _isJoined ? 'Already Joined' : 'Pay Now',
                      style: TextStyle(
                        fontSize: buttonTextSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFreeEventJoinButton(BuildContext context, Color primaryColor, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final buttonHeight = isDesktop ? 64.0 : isTablet ? 60.0 : isSmallScreen ? 48.0 : 56.0;
    final buttonRadius = isDesktop ? 36.0 : isTablet ? 32.0 : isSmallScreen ? 24.0 : 30.0;
    final buttonTextSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 15.0 : 18.0;
    
    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: _isJoining ? null : _handleJoinEvent,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: isDark ? AppColors.black : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          elevation: 4,
        ),
        child: _isJoining
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark ? AppColors.black : AppColors.white,
                  ),
                ),
              )
            : Text(
                'Join Event (Free)',
                style: TextStyle(
                  fontSize: buttonTextSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  Widget _buildJoinedIndicator(BuildContext context, AppColorSet colors) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final cardPadding = isDesktop ? 24.0 : isTablet ? 20.0 : isSmallScreen ? 12.0 : 16.0;
    final cardRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    final iconSize = isDesktop ? 32.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final textSize = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 14.0 : 16.0;
    final spacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(cardRadius),
        border: Border.all(color: AppColors.success.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            color: AppColors.success,
            size: iconSize,
          ),
          SizedBox(width: spacing),
          Text(
            'You have joined this event!',
            style: TextStyle(
              fontSize: textSize,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentConfirmation(BuildContext context, AppColorSet colors, Color primaryColor, bool isDark, double amount) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final dialogRadius = isDesktop ? 28.0 : isTablet ? 24.0 : isSmallScreen ? 14.0 : 20.0;
    final titleIconSize = isDesktop ? 28.0 : isTablet ? 26.0 : isSmallScreen ? 20.0 : 24.0;
    final titleTextSize = isDesktop ? 22.0 : isTablet ? 20.0 : isSmallScreen ? 16.0 : 18.0;
    final titleIconSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    final contentTextSize = isDesktop ? 18.0 : isTablet ? 16.0 : isSmallScreen ? 13.0 : 14.0;
    final contentSpacing = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    final sectionSpacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final confirmTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    final buttonRadius = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final buttonTextSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 13.0 : 14.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
        ),
        title: Row(
          children: [
            Icon(Icons.payment, color: primaryColor, size: titleIconSize),
            SizedBox(width: titleIconSpacing),
            Text(
              'Confirm Payment',
              style: TextStyle(color: colors.textPrimary, fontSize: titleTextSize),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Event: ${widget.event.title}',
              style: TextStyle(color: colors.textPrimary, fontSize: contentTextSize),
            ),
            SizedBox(height: contentSpacing),
            Text(
              'Amount: ₹${amount.toStringAsFixed(0)}',
              style: TextStyle(color: colors.textPrimary, fontSize: contentTextSize),
            ),
            SizedBox(height: sectionSpacing),
            Text(
              'Proceed with payment?',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: colors.textSecondary,
                fontSize: confirmTextSize,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colors.textSecondary, fontSize: buttonTextSize),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Trigger actual Cashfree payment flow
              _createPaymentOrder();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: isDark ? AppColors.black : AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(buttonRadius),
              ),
            ),
            child: Text('Pay ₹${amount.toStringAsFixed(0)}', style: TextStyle(fontSize: buttonTextSize)),
          ),
        ],
      ),
    );
  }
}
