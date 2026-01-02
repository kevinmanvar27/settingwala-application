import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum CustomCardVariant {
  elevated,
  outlined,
  filled,
}

class CustomCard extends StatelessWidget {
  final Widget child;
  final CustomCardVariant variant;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? elevation;
  final bool hasShadow;

  const CustomCard({
    super.key,
    required this.child,
    this.variant = CustomCardVariant.outlined,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.hasShadow = false,
  });

  const CustomCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 4,
  })  : variant = CustomCardVariant.elevated,
        hasShadow = true;

  const CustomCard.outlined({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 0,
  })  : variant = CustomCardVariant.outlined,
        hasShadow = false;

  const CustomCard.filled({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.elevation = 0,
  })  : variant = CustomCardVariant.filled,
        hasShadow = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final defaultRadius = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final defaultPadding = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    
    final radius = borderRadius ?? defaultRadius;
    
    final cardColors = _getCardColors(colors);
    
    Widget cardContent = Container(
      padding: padding ?? EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: cardColors.background,
        borderRadius: BorderRadius.circular(radius),
        border: cardColors.showBorder
            ? Border.all(color: cardColors.border, width: 1)
            : null,
        boxShadow: hasShadow || variant == CustomCardVariant.elevated
            ? [
                BoxShadow(
                  color: colors.shadow,
                  blurRadius: elevation ?? 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: child,
    );
    
    if (onTap != null) {
      cardContent = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: cardContent,
        ),
      );
    }
    
    if (margin != null) {
      cardContent = Padding(
        padding: margin!,
        child: cardContent,
      );
    }
    
    return cardContent;
  }

  _CardColors _getCardColors(AppColorSet colors) {
    switch (variant) {
      case CustomCardVariant.elevated:
        return _CardColors(
          background: backgroundColor ?? colors.card,
          border: borderColor ?? colors.border,
          showBorder: false,
        );
      case CustomCardVariant.outlined:
        return _CardColors(
          background: backgroundColor ?? colors.card,
          border: borderColor ?? colors.border,
          showBorder: true,
        );
      case CustomCardVariant.filled:
        return _CardColors(
          background: backgroundColor ?? colors.surface,
          border: borderColor ?? colors.border,
          showBorder: false,
        );
    }
  }
}

class _CardColors {
  final Color background;
  final Color border;
  final bool showBorder;

  const _CardColors({
    required this.background,
    required this.border,
    required this.showBorder,
  });
}

class SettingsCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  final Widget? child;

  const SettingsCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.iconColor,
    this.textColor,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final titleFontSize = isDesktop ? 18.0 : isTablet ? 17.0 : isSmallScreen ? 14.0 : 16.0;
    final subtitleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    
    final iconContainerSize = isDesktop ? 44.0 : isTablet ? 40.0 : isSmallScreen ? 32.0 : 36.0;
    final iconSize = isDesktop ? 24.0 : isTablet ? 22.0 : isSmallScreen ? 16.0 : 20.0;
    final spacing = isDesktop ? 20.0 : isTablet ? 18.0 : isSmallScreen ? 12.0 : 16.0;
    final marginBottom = isDesktop ? 12.0 : isTablet ? 10.0 : isSmallScreen ? 6.0 : 8.0;
    
    return CustomCard.outlined(
      margin: EdgeInsets.only(bottom: marginBottom),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: iconContainerSize,
                  height: iconContainerSize,
                  decoration: BoxDecoration(
                    color: (iconColor ?? primaryColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? primaryColor,
                    size: iconSize,
                  ),
                ),
                SizedBox(width: spacing),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: titleFontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? colors.textPrimary,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: spacing * 0.25),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: subtitleFontSize,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          if (child != null) ...[
            SizedBox(height: spacing),
            child!,
          ],
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final VoidCallback? onTap;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    final isTablet = screenWidth >= 600;
    final isDesktop = screenWidth >= 1024;
    
    final iconContainerSize = isDesktop ? 60.0 : isTablet ? 56.0 : isSmallScreen ? 40.0 : 50.0;
    final iconSize = isDesktop ? 30.0 : isTablet ? 28.0 : isSmallScreen ? 20.0 : 24.0;
    final titleFontSize = isDesktop ? 16.0 : isTablet ? 15.0 : isSmallScreen ? 12.0 : 14.0;
    final descFontSize = isDesktop ? 14.0 : isTablet ? 13.0 : isSmallScreen ? 10.0 : 12.0;
    final spacing = isDesktop ? 16.0 : isTablet ? 14.0 : isSmallScreen ? 8.0 : 12.0;
    
    return CustomCard.outlined(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: iconContainerSize,
            height: iconContainerSize,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: iconSize,
            ),
          ),
          SizedBox(height: spacing),
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            SizedBox(height: spacing * 0.33),
            Text(
              description!,
              style: TextStyle(
                fontSize: descFontSize,
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}
