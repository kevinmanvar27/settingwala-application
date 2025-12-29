import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options
enum AppThemeMode {
  light,
  dark,
  system,
}

/// Theme provider for managing app theme state
/// 
/// Usage:
/// 1. Wrap your app with ThemeProvider
/// 2. Access theme mode: ThemeProvider.of(context).themeMode
/// 3. Toggle theme: ThemeProvider.of(context).setThemeMode(AppThemeMode.dark)
class ThemeProvider extends InheritedNotifier<ThemeNotifier> {
  const ThemeProvider({
    super.key,
    required ThemeNotifier notifier,
    required super.child,
  }) : super(notifier: notifier);

  static ThemeNotifier of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    assert(provider != null, 'No ThemeProvider found in context');
    return provider!.notifier!;
  }

  /// Try to get ThemeNotifier without throwing if not found
  static ThemeNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider?.notifier;
  }
}

/// Theme state notifier
class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isInitialized = false;

  ThemeNotifier() {
    _loadThemeMode();
  }

  /// Current theme mode setting
  AppThemeMode get themeMode => _themeMode;
  
  /// Whether the theme has been loaded from storage
  bool get isInitialized => _isInitialized;

  /// Get the actual ThemeMode for MaterialApp
  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }

  /// Check if dark mode is currently active
  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }

  /// Check if light mode is currently active
  bool get isLightMode => !isDarkMode;

  /// Set theme mode and persist
  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveThemeMode();
  }

  /// Toggle between light and dark (ignores system)
  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  /// Set to light mode
  Future<void> setLightMode() async {
    await setThemeMode(AppThemeMode.light);
  }

  /// Set to dark mode
  Future<void> setDarkMode() async {
    await setThemeMode(AppThemeMode.dark);
  }

  /// Set to system mode
  Future<void> setSystemMode() async {
    await setThemeMode(AppThemeMode.system);
  }

  /// Load theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMode = prefs.getString(_themeKey);
      
      if (savedMode != null) {
        _themeMode = AppThemeMode.values.firstWhere(
          (mode) => mode.name == savedMode,
          orElse: () => AppThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
    }
    
    _isInitialized = true;
    notifyListeners();
  }

  /// Save theme mode to SharedPreferences
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.name);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}

/// Extension for easy theme access from BuildContext
extension ThemeContextExtension on BuildContext {
  /// Get the theme notifier
  ThemeNotifier get themeNotifier => ThemeProvider.of(this);
  
  /// Check if dark mode is active
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Check if light mode is active
  bool get isLightMode => !isDarkMode;
  
  /// Get current theme data
  ThemeData get theme => Theme.of(this);
  
  /// Get current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
}
