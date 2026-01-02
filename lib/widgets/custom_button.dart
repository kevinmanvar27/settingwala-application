import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CustomButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
}

enum CustomButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final CustomButtonVariant variant;
  final CustomButtonSize size;
  final IconData? icon;
  final bool iconAtEnd;
  final bool isLoading;
  final bool fullWidth;
  final double? borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = CustomButtonVariant.primary,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  });

  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  }) : variant = CustomButtonVariant.primary;

  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  }) : variant = CustomButtonVariant.secondary;

  const CustomButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  }) : variant = CustomButtonVariant.outline;

  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  }) : variant = CustomButtonVariant.text;

  const CustomButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = CustomButtonSize.medium,
    this.icon,
    this.iconAtEnd = false,
    this.isLoading = false,
    this.fullWidth = false,
    this.borderRadius,
  }) : variant = CustomButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final sizeProps = _getSizeProperties(isSmallScreen, isTablet, isDesktop);
    final radius = borderRadius ?? (isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 10.0 : 12.0);
    
    final variantColors = _getVariantColors(colors, isDark);
    
    Widget buttonContent = _buildContent(sizeProps, variantColors);
    
    if (isLoading) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: sizeProps.iconSize,
            height: sizeProps.iconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(variantColors.foreground),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: sizeProps.fontSize,
              fontWeight: FontWeight.w600,
              color: variantColors.foreground,
            ),
          ),
        ],
      );
    }
    
    Widget button;
    switch (variant) {
      case CustomButtonVariant.primary:
      case CustomButtonVariant.secondary:
      case CustomButtonVariant.danger:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: variantColors.background,
            foregroundColor: variantColors.foreground,
            disabledBackgroundColor: colors.disabled,
            disabledForegroundColor: colors.textDisabled,
            elevation: 0,
            padding: sizeProps.padding,
            minimumSize: Size(sizeProps.minWidth, sizeProps.height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: buttonContent,
        );
        break;
        
      case CustomButtonVariant.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: variantColors.foreground,
            disabledForegroundColor: colors.textDisabled,
            padding: sizeProps.padding,
            minimumSize: Size(sizeProps.minWidth, sizeProps.height),
            side: BorderSide(
              color: onPressed != null ? variantColors.border : colors.border,
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: buttonContent,
        );
        break;
        
      case CustomButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: variantColors.foreground,
            disabledForegroundColor: colors.textDisabled,
            padding: sizeProps.padding,
            minimumSize: Size(sizeProps.minWidth, sizeProps.height),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
          child: buttonContent,
        );
        break;
    }
    
    if (fullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    
    return button;
  }

  Widget _buildContent(_ButtonSizeProperties sizeProps, _ButtonColors variantColors) {
    if (icon == null) {
      return Text(
        text,
        style: TextStyle(
          fontSize: sizeProps.fontSize,
          fontWeight: FontWeight.w600,
        ),
      );
    }
    
    final iconWidget = Icon(icon, size: sizeProps.iconSize);
    final textWidget = Text(
      text,
      style: TextStyle(
        fontSize: sizeProps.fontSize,
        fontWeight: FontWeight.w600,
      ),
    );
    
    if (iconAtEnd) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          textWidget,
          SizedBox(width: sizeProps.iconSpacing),
          iconWidget,
        ],
      );
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: sizeProps.iconSpacing),
        textWidget,
      ],
    );
  }

  _ButtonSizeProperties _getSizeProperties(bool isSmallScreen, bool isTablet, bool isDesktop) {
    switch (size) {
      case CustomButtonSize.small:
        return _ButtonSizeProperties(
          height: isDesktop ? 44 : isTablet ? 40 : isSmallScreen ? 32 : 36,
          minWidth: isDesktop ? 80 : isTablet ? 72 : isSmallScreen ? 52 : 64,
          fontSize: isDesktop ? 15 : isTablet ? 14 : isSmallScreen ? 11 : 13,
          iconSize: isDesktop ? 20 : isTablet ? 18 : isSmallScreen ? 14 : 16,
          iconSpacing: isDesktop ? 10 : isTablet ? 8 : isSmallScreen ? 6 : 8,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 16 : isTablet ? 14 : isSmallScreen ? 8 : 12,
            vertical: isDesktop ? 10 : isTablet ? 9 : isSmallScreen ? 6 : 8,
          ),
        );
      case CustomButtonSize.medium:
        return _ButtonSizeProperties(
          height: isDesktop ? 56 : isTablet ? 52 : isSmallScreen ? 40 : 48,
          minWidth: isDesktop ? 104 : isTablet ? 96 : isSmallScreen ? 72 : 88,
          fontSize: isDesktop ? 18 : isTablet ? 17 : isSmallScreen ? 14 : 16,
          iconSize: isDesktop ? 24 : isTablet ? 22 : isSmallScreen ? 16 : 20,
          iconSpacing: isDesktop ? 12 : isTablet ? 10 : isSmallScreen ? 6 : 8,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 32 : isTablet ? 28 : isSmallScreen ? 16 : 24,
            vertical: isDesktop ? 18 : isTablet ? 16 : isSmallScreen ? 10 : 14,
          ),
        );
      case CustomButtonSize.large:
        return _ButtonSizeProperties(
          height: isDesktop ? 64 : isTablet ? 60 : isSmallScreen ? 48 : 56,
          minWidth: isDesktop ? 120 : isTablet ? 112 : isSmallScreen ? 84 : 100,
          fontSize: isDesktop ? 20 : isTablet ? 19 : isSmallScreen ? 16 : 18,
          iconSize: isDesktop ? 28 : isTablet ? 26 : isSmallScreen ? 20 : 24,
          iconSpacing: isDesktop ? 12 : isTablet ? 10 : isSmallScreen ? 8 : 8,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40 : isTablet ? 36 : isSmallScreen ? 24 : 32,
            vertical: isDesktop ? 20 : isTablet ? 18 : isSmallScreen ? 12 : 16,
          ),
        );
    }
  }

  _ButtonColors _getVariantColors(AppColorSet colors, bool isDark) {
    switch (variant) {
      case CustomButtonVariant.primary:
        return _ButtonColors(
          background: isDark ? AppColors.primaryLight : AppColors.primary,
          foreground: isDark ? AppColors.black : AppColors.white,
          border: isDark ? AppColors.primaryLight : AppColors.primary,
        );
      case CustomButtonVariant.secondary:
        return _ButtonColors(
          background: isDark ? AppColors.secondaryLight : AppColors.secondary,
          foreground: AppColors.white,
          border: isDark ? AppColors.secondaryLight : AppColors.secondary,
        );
      case CustomButtonVariant.outline:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isDark ? AppColors.primaryLight : AppColors.primary,
          border: isDark ? AppColors.primaryLight : AppColors.primary,
        );
      case CustomButtonVariant.text:
        return _ButtonColors(
          background: Colors.transparent,
          foreground: isDark ? AppColors.primaryLight : AppColors.primary,
          border: Colors.transparent,
        );
      case CustomButtonVariant.danger:
        return _ButtonColors(
          background: AppColors.error,
          foreground: AppColors.white,
          border: AppColors.error,
        );
    }
  }
}

class _ButtonSizeProperties {
  final double height;
  final double minWidth;
  final double fontSize;
  final double iconSize;
  final double iconSpacing;
  final EdgeInsets padding;

  const _ButtonSizeProperties({
    required this.height,
    required this.minWidth,
    required this.fontSize,
    required this.iconSize,
    required this.iconSpacing,
    required this.padding,
  });
}

class _ButtonColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _ButtonColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}
