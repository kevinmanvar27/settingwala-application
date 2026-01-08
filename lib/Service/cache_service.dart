import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Centralized cache service for API data caching
/// Improves app performance by reducing API calls
class CacheService {
  static const String _cachePrefix = 'cache_';
  static const String _cacheTimePrefix = 'cache_time_';
  
  // Default cache durations (in minutes)
  static const int defaultCacheDuration = 5; // 5 minutes
  static const int usersCacheDuration = 3; // 3 minutes for users list
  static const int eventsCacheDuration = 5; // 5 minutes for events
  static const int profileCacheDuration = 10; // 10 minutes for profile data
  static const int notificationsCacheDuration = 1; // 1 minute for notifications
  
  /// Save data to cache with expiration time
  static Future<void> saveToCache({
    required String key,
    required dynamic data,
    int? durationMinutes,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cacheTimeKey = '$_cacheTimePrefix$key';
      
      // Store data as JSON string
      final jsonData = jsonEncode(data);
      await prefs.setString(cacheKey, jsonData);
      
      // Store cache timestamp
      final expirationTime = DateTime.now()
          .add(Duration(minutes: durationMinutes ?? defaultCacheDuration))
          .millisecondsSinceEpoch;
      await prefs.setInt(cacheTimeKey, expirationTime);
    } catch (e) {
      // Silent fail - caching is optional
    }
  }
  
  /// Get data from cache if not expired
  static Future<dynamic> getFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '$_cachePrefix$key';
      final cacheTimeKey = '$_cacheTimePrefix$key';
      
      // Check if cache exists
      final cachedData = prefs.getString(cacheKey);
      final cacheTime = prefs.getInt(cacheTimeKey);
      
      if (cachedData == null || cacheTime == null) {
        return null;
      }
      
      // Check if cache is expired
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now > cacheTime) {
        // Cache expired, remove it
        await removeFromCache(key);
        return null;
      }
      
      // Return cached data
      return jsonDecode(cachedData);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if cache exists and is valid
  static Future<bool> isCacheValid(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheTimeKey = '$_cacheTimePrefix$key';
      
      final cacheTime = prefs.getInt(cacheTimeKey);
      if (cacheTime == null) return false;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      return now <= cacheTime;
    } catch (e) {
      return false;
    }
  }
  
  /// Remove specific cache entry
  static Future<void> removeFromCache(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cacheTimePrefix$key');
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix) || key.startsWith(_cacheTimePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  /// Clear expired cache entries only
  static Future<void> clearExpiredCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().toList();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      for (final key in keys) {
        if (key.startsWith(_cacheTimePrefix)) {
          final cacheTime = prefs.getInt(key);
          if (cacheTime != null && now > cacheTime) {
            final dataKey = key.replaceFirst(_cacheTimePrefix, _cachePrefix);
            await prefs.remove(key);
            await prefs.remove(dataKey);
          }
        }
      }
    } catch (e) {
      // Silent fail
    }
  }
  
  // Predefined cache keys for consistency
  static const String usersListKey = 'users_list';
  static const String eventsListKey = 'events_list';
  static const String eventDetailsKey = 'event_details'; // Used with suffix: event_details_<id>
  static const String userProfileKey = 'user_profile';
  static const String userDetailsKey = 'user_details'; // Used with suffix: user_details_<id>
  static const String notificationsKey = 'notifications';
  static const String chatsListKey = 'chats_list';
  static const String bookingsListKey = 'bookings_list';
}
