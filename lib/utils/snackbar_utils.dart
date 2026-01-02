import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Snackbar Types for different use cases
enum SnackbarType {
  success,
  info,
  warning,
}

/// Centralized Snackbar Utility
/// 
/// Usage:
/// ```dart
/// SnackbarUtils.showSuccess(context, 'Profile updated successfully!');
/// SnackbarUtils.showInfo(context, 'Loading data...');
/// SnackbarUtils.showWarning(context, 'Please check your connection');
/// ```
class SnackbarUtils {
  // Private constructor to prevent instantiation
  SnackbarUtils._();

  /// Default duration for snackbars
  static const Duration _defaultDuration = Duration(seconds: 3);
  
  /// Short duration for quick messages
  static const Duration shortDuration = Duration(seconds: 2);
  
  /// Long duration for important messages
  static const Duration longDuration = Duration(seconds: 5);

  // ══════════════════════════════════════════════════════════════════════════
  // PUBLIC METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Show a success snackbar (green theme)
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show an info snackbar (blue/primary theme)
  static void showInfo(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.info,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show a warning snackbar (orange/amber theme)
  static void showWarning(
    BuildContext context,
    String message, {
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _showSnackbar(
      context,
      message: message,
      type: SnackbarType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Show a custom snackbar with full control
  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? icon,
  }) {
    _showSnackbar(
      context,
      message: message,
      type: type,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      customIcon: icon,
    );
  }

  /// Hide any currently showing snackbar
  static void hide(BuildContext context) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
  }

  /// Clear all snackbars from queue
  static void clearAll(BuildContext context) {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE METHODS
  // ══════════════════════════════════════════════════════════════════════════

  static void _showSnackbar(
    BuildContext context, {
    required String message,
    required SnackbarType type,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
    IconData? customIcon,
  }) {
    // Hide any existing snackbar first
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = _getSnackbarColors(type, isDark);
    final icon = customIcon ?? _getIcon(type);

    final snackBar = SnackBar(
      content: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: colors.iconBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: colors.iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Message
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: colors.textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      backgroundColor: colors.backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colors.borderColor,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: duration ?? _defaultDuration,
      elevation: 4,
      dismissDirection: DismissDirection.horizontal,
      action: actionLabel != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: colors.actionColor,
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onAction?.call();
              },
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Get icon based on snackbar type
  static IconData _getIcon(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return Icons.check_circle_rounded;
      case SnackbarType.info:
        return Icons.info_rounded;
      case SnackbarType.warning:
        return Icons.warning_rounded;
    }
  }

  /// Get colors based on type and theme
  static _SnackbarColors _getSnackbarColors(SnackbarType type, bool isDark) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarColors(
          backgroundColor: isDark 
              ? const Color(0xFF1A3D2E) 
              : const Color(0xFFE8F5E9),
          textColor: isDark 
              ? const Color(0xFF81C784) 
              : const Color(0xFF2E7D32),
          iconColor: isDark 
              ? const Color(0xFF81C784) 
              : const Color(0xFF43A047),
          iconBackground: isDark 
              ? const Color(0xFF2E7D32).withValues(alpha: 0.3) 
              : const Color(0xFF43A047).withValues(alpha: 0.15),
          borderColor: isDark 
              ? const Color(0xFF388E3C).withValues(alpha: 0.5) 
              : const Color(0xFF81C784).withValues(alpha: 0.5),
          actionColor: isDark 
              ? const Color(0xFF81C784) 
              : const Color(0xFF2E7D32),
        );
      
      case SnackbarType.info:
        final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
        return _SnackbarColors(
          backgroundColor: isDark 
              ? const Color(0xFF1A2D3D) 
              : const Color(0xFFE3F2FD),
          textColor: isDark 
              ? const Color(0xFF90CAF9) 
              : const Color(0xFF1565C0),
          iconColor: isDark 
              ? primaryColor 
              : AppColors.primary,
          iconBackground: isDark 
              ? primaryColor.withValues(alpha: 0.3) 
              : AppColors.primary.withValues(alpha: 0.15),
          borderColor: isDark 
              ? primaryColor.withValues(alpha: 0.5) 
              : AppColors.primary.withValues(alpha: 0.3),
          actionColor: isDark 
              ? primaryColor 
              : AppColors.primary,
        );
      
      case SnackbarType.warning:
        return _SnackbarColors(
          backgroundColor: isDark 
              ? const Color(0xFF3D3520) 
              : const Color(0xFFFFF8E1),
          textColor: isDark 
              ? const Color(0xFFFFD54F) 
              : const Color(0xFFF57F17),
          iconColor: isDark 
              ? const Color(0xFFFFD54F) 
              : const Color(0xFFFF8F00),
          iconBackground: isDark 
              ? const Color(0xFFFF8F00).withValues(alpha: 0.3) 
              : const Color(0xFFFF8F00).withValues(alpha: 0.15),
          borderColor: isDark 
              ? const Color(0xFFFFB300).withValues(alpha: 0.5) 
              : const Color(0xFFFFD54F).withValues(alpha: 0.5),
          actionColor: isDark 
              ? const Color(0xFFFFD54F) 
              : const Color(0xFFF57F17),
        );
    }
  }
}

/// Internal class to hold snackbar colors
class _SnackbarColors {
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final Color iconBackground;
  final Color borderColor;
  final Color actionColor;

  _SnackbarColors({
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    required this.iconBackground,
    required this.borderColor,
    required this.actionColor,
  });
}

// ══════════════════════════════════════════════════════════════════════════
// EXTENSION FOR EASY ACCESS
// ══════════════════════════════════════════════════════════════════════════

/// Extension on BuildContext for easy snackbar access
/// 
/// Usage:
/// ```dart
/// context.showSuccessSnackbar('Done!');
/// context.showInfoSnackbar('Loading...');
/// context.showWarningSnackbar('Check connection');
/// ```
extension SnackbarExtension on BuildContext {
  /// Show success snackbar
  void showSuccessSnackbar(String message, {Duration? duration}) {
    SnackbarUtils.showSuccess(this, message, duration: duration);
  }

  /// Show info snackbar
  void showInfoSnackbar(String message, {Duration? duration}) {
    SnackbarUtils.showInfo(this, message, duration: duration);
  }

  /// Show warning snackbar
  void showWarningSnackbar(String message, {Duration? duration}) {
    SnackbarUtils.showWarning(this, message, duration: duration);
  }

  /// Hide current snackbar
  void hideSnackbar() {
    SnackbarUtils.hide(this);
  }
}
