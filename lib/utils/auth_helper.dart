import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // Added for debugPrint
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/profile_service.dart';
import '../Service/auth_service.dart';
import '../routes/app_routes.dart';

/// Helper class to validate user authentication and redirect to login if invalid
class AuthHelper {
  /// Check if user is valid and redirect to login if not
  /// Returns true if user is valid, false if redirected to login
  static Future<bool> validateUserOrRedirect(BuildContext context) async {
    try {
      // Check if token exists
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      // Print auth token to console for debugging
      debugPrint('====================================');
      debugPrint('AUTH TOKEN CHECK');
      debugPrint('Token: ${token ?? "NULL"}');
      debugPrint('Token Empty: ${token?.isEmpty ?? true}');
      debugPrint('====================================');
      
      if (token == null || token.isEmpty) {
        debugPrint('AUTH: No token found - redirecting to login');
        _redirectToLogin(context);
        return false;
      }
      
      // Validate user profile from API
      debugPrint('AUTH: Token exists, validating profile...');
      final profileData = await ProfileService.getProfile();
      
      if (profileData == null || profileData.data?.user == null) {
        // Profile not found - clear token and redirect to login
        debugPrint('AUTH: Profile data is null - clearing auth and redirecting');
        await _clearAuthAndRedirect(context);
        return false;
      }
      
      final user = profileData.data!.user!;
      debugPrint('AUTH: User email: ${user.email}');
      
      // Check if user has valid email (not placeholder)
      if (user.email == null || 
          user.email == 'user@example.com' || 
          user.email!.isEmpty) {
        debugPrint('AUTH: Invalid email detected - clearing auth and redirecting');
        await _clearAuthAndRedirect(context);
        return false;
      }
      
      debugPrint('AUTH: User validation successful');
      return true;
    } catch (e) {
      // On error, redirect to login for safety
      debugPrint('AUTH ERROR: $e');
      debugPrint('AUTH: Redirecting to login due to error');
      await _clearAuthAndRedirect(context);
      return false;
    }
  }
  
  /// Clear auth data and redirect to login
  static Future<void> _clearAuthAndRedirect(BuildContext context) async {
    try {
      debugPrint('AUTH: Clearing auth data...');
      await AuthService.logout();
    } catch (e) {
      debugPrint('AUTH: Logout error (ignored): $e');
    }
    
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('auth_token');
    debugPrint('AUTH: Removing token: ${oldToken ?? "NULL"}');
    await prefs.remove('auth_token');
    
    _redirectToLogin(context);
  }
  
  /// Redirect to login screen and clear navigation stack
  static void _redirectToLogin(BuildContext context) {
    debugPrint('AUTH: Redirecting to login screen...');
    if (!context.mounted) {
      debugPrint('AUTH: Context not mounted, cannot redirect');
      return;
    }
    
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.login,
      (route) => false,
    );
    debugPrint('AUTH: Navigation to login completed');
  }
  
  /// Force logout and redirect to login
  static Future<void> forceLogout(BuildContext context) async {
    debugPrint('AUTH: Force logout initiated');
    await _clearAuthAndRedirect(context);
  }
}
