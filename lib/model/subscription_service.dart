import 'package:shared_preferences/shared_preferences.dart';

class SubscriptionService {
  static const String _hasSubscriptionKey = 'has_active_subscription';
  static const String _subscriptionExpiryKey = 'subscription_expiry_date';
  static const String _subscriptionTypeKey = 'subscription_type';

  // Check if user has an active subscription
  static Future<bool> hasActiveSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSubscription = prefs.getBool(_hasSubscriptionKey) ?? false;

    if (hasSubscription) {
      // Check if subscription has expired
      final expiryDateStr = prefs.getString(_subscriptionExpiryKey);
      if (expiryDateStr != null) {
        final expiryDate = DateTime.parse(expiryDateStr);
        return DateTime.now().isBefore(expiryDate);
      }
    }

    return false;
  }

  // Set subscription status after successful payment
  static Future<void> activateSubscription(String subscriptionType, int durationInDays) async {
    final prefs = await SharedPreferences.getInstance();

    // Set expiry date
    final expiryDate = DateTime.now().add(Duration(days: durationInDays));

    // Save subscription data
    await prefs.setBool(_hasSubscriptionKey, true);
    await prefs.setString(_subscriptionExpiryKey, expiryDate.toIso8601String());
    await prefs.setString(_subscriptionTypeKey, subscriptionType);
  }

  // Get subscription details
  static Future<Map<String, dynamic>> getSubscriptionDetails() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSubscription = prefs.getBool(_hasSubscriptionKey) ?? false;

    if (!hasSubscription) {
      return {
        'hasSubscription': false,
        'type': null,
        'expiryDate': null,
        'daysRemaining': 0,
      };
    }

    final type = prefs.getString(_subscriptionTypeKey);
    final expiryDateStr = prefs.getString(_subscriptionExpiryKey);

    if (expiryDateStr != null) {
      final expiryDate = DateTime.parse(expiryDateStr);
      final daysRemaining = expiryDate.difference(DateTime.now()).inDays;

      return {
        'hasSubscription': DateTime.now().isBefore(expiryDate),
        'type': type,
        'expiryDate': expiryDate,
        'daysRemaining': daysRemaining > 0 ? daysRemaining : 0,
      };
    }

    return {
      'hasSubscription': false,
      'type': null,
      'expiryDate': null,
      'daysRemaining': 0,
    };
  }

  // Cancel subscription
  static Future<void> cancelSubscription() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSubscriptionKey, false);
  }
}

//Api =