import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppThemeMode {
  light,
  dark,
  system,
}

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

  static ThemeNotifier? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ThemeProvider>();
    return provider?.notifier;
  }
}

class ThemeNotifier extends ChangeNotifier {
  static const String _themeKey = 'app_theme_mode';
  
  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isInitialized = false;

  ThemeNotifier() {
    _loadThemeMode();
  }

  AppThemeMode get themeMode => _themeMode;
  
  bool get isInitialized => _isInitialized;

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

  bool get isDarkMode {
    if (_themeMode == AppThemeMode.system) {
      final brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    }
    return _themeMode == AppThemeMode.dark;
  }

  bool get isLightMode => !isDarkMode;

  Future<void> setThemeMode(AppThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    await _saveThemeMode();
  }

  Future<void> toggleTheme() async {
    final newMode = isDarkMode ? AppThemeMode.light : AppThemeMode.dark;
    await setThemeMode(newMode);
  }

  Future<void> setLightMode() async {
    await setThemeMode(AppThemeMode.light);
  }

  Future<void> setDarkMode() async {
    await setThemeMode(AppThemeMode.dark);
  }

  Future<void> setSystemMode() async {
    await setThemeMode(AppThemeMode.system);
  }

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

  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, _themeMode.name);
    } catch (e) {
      debugPrint('Error saving theme mode: $e');
    }
  }
}

extension ThemeContextExtension on BuildContext {
  ThemeNotifier get themeNotifier => ThemeProvider.of(this);
  
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  bool get isLightMode => !isDarkMode;
  
  ThemeData get theme => Theme.of(this);
  
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  TextTheme get textTheme => Theme.of(this).textTheme;
}
