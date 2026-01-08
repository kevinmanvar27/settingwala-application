import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  
  static const Color primary = Color(0xFFA055B8);
  static const Color primaryLight = Color(0xFFBF7FD1);
  static const Color primaryDark = Color(0xFF7A3D8C);
  
  static const Color secondary = Color(0xFF1AB068);
  static const Color secondaryLight = Color(0xFF4FD492);
  static const Color secondaryDark = Color(0xFF128A50);

  
  static const Color success = Color(0xFF1AB068);
  static const Color warning = Color(0xFFF5A623);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);

  
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  
  static const LightColors light = LightColors();
  
  
  static const DarkColors dark = DarkColors();
  
  static LightColors get lightColors => light;
}

// Helper methods - separate class or extension
// Utility class for color methods
class AppColorUtils {
  static AppColorSet getColorSet(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark 
        ? AppColorSet.dark() 
        : AppColorSet.light();
  }
  
  static Color getPrimaryColor(BuildContext context) {
    return AppColors.primary;
  }
}

class LightColors {
  const LightColors();

  Color get background => const Color(0xFFFFFFFF);
  Color get surface => const Color(0xFFF9F9FB);
  Color get surfaceVariant => const Color(0xFFF3F4F6);
  Color get card => const Color(0xFFFFFFFF);
  
  Color get textPrimary => const Color(0xFF1E263D);
  Color get textSecondary => const Color(0xFF868C94);
  Color get textTertiary => const Color(0xFFB0B5BD);
  Color get textDisabled => const Color(0xFFD1D5DB);
  
  Color get border => const Color(0xFFE5E7EB);
  Color get divider => const Color(0xFFF3F4F6);
  
  Color get hover => const Color(0xFFF3F4F6);
  Color get pressed => const Color(0xFFE5E7EB);
  Color get disabled => const Color(0xFFF9FAFB);
  
  Color get shadow => const Color(0x1A000000);
  Color get shadowLight => const Color(0x0D000000);
  
  Color get navBackground => const Color(0xFFFFFFFF);
  Color get navSelected => AppColors.primary;
  Color get navUnselected => const Color(0xFF9FA4B6);
  
  Color get inputBackground => const Color(0xFFF9FAFB);
  Color get inputBorder => const Color(0xFFE5E7EB);
  Color get inputFocusBorder => AppColors.primary;
  
  Color get overlay => const Color(0x80000000);
  Color get scrim => const Color(0x52000000);
}

class DarkColors {
  const DarkColors();

  Color get background => const Color(0xFF121212);
  Color get surface => const Color(0xFF1E1E1E);
  Color get surfaceVariant => const Color(0xFF2A2A2A);
  Color get card => const Color(0xFF1E1E1E);
  
  Color get textPrimary => const Color(0xFFF5F5F5);
  Color get textSecondary => const Color(0xFFB0B5BD);
  Color get textTertiary => const Color(0xFF757575);
  Color get textDisabled => const Color(0xFF525252);
  
  Color get border => const Color(0xFF3A3A3A);
  Color get divider => const Color(0xFF2A2A2A);
  
  Color get hover => const Color(0xFF2A2A2A);
  Color get pressed => const Color(0xFF3A3A3A);
  Color get disabled => const Color(0xFF1A1A1A);
  
  Color get shadow => const Color(0x40000000);
  Color get shadowLight => const Color(0x26000000);
  
  Color get navBackground => const Color(0xFF1E1E1E);
  Color get navSelected => AppColors.primaryLight;
  Color get navUnselected => const Color(0xFF757575);
  
  Color get inputBackground => const Color(0xFF2A2A2A);
  Color get inputBorder => const Color(0xFF3A3A3A);
  Color get inputFocusBorder => AppColors.primaryLight;
  
  Color get overlay => const Color(0xB3000000);
  Color get scrim => const Color(0x80000000);
}

extension AppColorsExtension on BuildContext {
  AppColorSet get colors {
    final brightness = Theme.of(this).brightness;
    return brightness == Brightness.dark 
        ? AppColorSet.dark() 
        : AppColorSet.light();
  }
}

class AppColorSet {
  final Color background;
  final Color surface;
  final Color surfaceVariant;
  final Color card;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textDisabled;
  final Color border;
  final Color divider;
  final Color hover;
  final Color pressed;
  final Color disabled;
  final Color shadow;
  final Color shadowLight;
  final Color navBackground;
  final Color navSelected;
  final Color navUnselected;
  final Color inputBackground;
  final Color inputBorder;
  final Color inputFocusBorder;
  final Color overlay;
  final Color scrim;
  final Color cardBackground;
  final Color cardBorder;

  const AppColorSet({
    required this.background,
    required this.surface,
    required this.surfaceVariant,
    required this.card,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textDisabled,
    required this.border,
    required this.divider,
    required this.hover,
    required this.pressed,
    required this.disabled,
    required this.shadow,
    required this.shadowLight,
    required this.navBackground,
    required this.navSelected,
    required this.navUnselected,
    required this.inputBackground,
    required this.inputBorder,
    required this.inputFocusBorder,
    required this.overlay,
    required this.scrim,
    required this.cardBackground,
    required this.cardBorder,
  });

  factory AppColorSet.light() {
    final colors = AppColors.light;
    return AppColorSet(
      background: colors.background,
      surface: colors.surface,
      surfaceVariant: colors.surfaceVariant,
      card: colors.card,
      textPrimary: colors.textPrimary,
      textSecondary: colors.textSecondary,
      textTertiary: colors.textTertiary,
      textDisabled: colors.textDisabled,
      border: colors.border,
      divider: colors.divider,
      hover: colors.hover,
      pressed: colors.pressed,
      disabled: colors.disabled,
      shadow: colors.shadow,
      shadowLight: colors.shadowLight,
      navBackground: colors.navBackground,
      navSelected: colors.navSelected,
      navUnselected: colors.navUnselected,
      inputBackground: colors.inputBackground,
      inputBorder: colors.inputBorder,
      inputFocusBorder: colors.inputFocusBorder,
      overlay: colors.overlay,
      scrim: colors.scrim,
      cardBackground: colors.card,
      cardBorder: colors.border,
    );
  }

  factory AppColorSet.dark() {
    final colors = AppColors.dark;
    return AppColorSet(
      background: colors.background,
      surface: colors.surface,
      surfaceVariant: colors.surfaceVariant,
      card: colors.card,
      textPrimary: colors.textPrimary,
      textSecondary: colors.textSecondary,
      textTertiary: colors.textTertiary,
      textDisabled: colors.textDisabled,
      border: colors.border,
      divider: colors.divider,
      hover: colors.hover,
      pressed: colors.pressed,
      disabled: colors.disabled,
      shadow: colors.shadow,
      shadowLight: colors.shadowLight,
      navBackground: colors.navBackground,
      navSelected: colors.navSelected,
      navUnselected: colors.navUnselected,
      inputBackground: colors.inputBackground,
      inputBorder: colors.inputBorder,
      inputFocusBorder: colors.inputFocusBorder,
      overlay: colors.overlay,
      scrim: colors.scrim,
      cardBackground: colors.card,
      cardBorder: colors.border,
    );
  }
}
