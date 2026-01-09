import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_colors.dart';

/// Optimized cached network image widget
/// Provides automatic caching, placeholder, and error handling
class CachedImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? placeholderColor;
  final IconData placeholderIcon;
  final double? placeholderIconSize;

  const CachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.placeholderColor,
    this.placeholderIcon = Icons.person,
    this.placeholderIconSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final bgColor = placeholderColor ?? primaryColor.withOpacity(0.1);
    final iconSize = placeholderIconSize ?? (height != null ? height! * 0.4 : 40);

    // Default placeholder widget
    Widget defaultPlaceholder = Container(
      width: width,
      height: height,
      color: bgColor,
      child: Center(
        child: Icon(
          placeholderIcon,
          size: iconSize,
          color: primaryColor.withOpacity(0.5),
        ),
      ),
    );

    // Default error widget
    Widget defaultErrorWidget = Container(
      width: width,
      height: height,
      color: bgColor,
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: iconSize,
          color: primaryColor.withOpacity(0.5),
        ),
      ),
    );

    // If no valid URL, show placeholder
    if (imageUrl == null || imageUrl!.isEmpty || imageUrl == 'null') {
      return ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: placeholder ?? defaultPlaceholder,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? defaultPlaceholder,
        errorWidget: (context, url, error) => errorWidget ?? defaultErrorWidget,
        fadeInDuration: const Duration(milliseconds: 200),
        fadeOutDuration: const Duration(milliseconds: 200),
        // Fix: Check for finite values before converting to int to avoid Infinity/NaN error
        memCacheWidth: (width != null && width!.isFinite) ? (width! * 2).toInt() : null,
        memCacheHeight: (height != null && height!.isFinite) ? (height! * 2).toInt() : null,
      ),
    );
  }
}

/// Cached circular avatar for profile pictures
class CachedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Color? backgroundColor;
  final IconData placeholderIcon;

  const CachedAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 24,
    this.backgroundColor,
    this.placeholderIcon = Icons.person,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.primaryLight : AppColors.primary;
    final bgColor = backgroundColor ?? primaryColor.withOpacity(0.1);

    // If no valid URL, show placeholder avatar
    if (imageUrl == null || imageUrl!.isEmpty || imageUrl == 'null') {
      return CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Icon(
          placeholderIcon,
          size: radius,
          color: primaryColor.withOpacity(0.7),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: radius,
        backgroundImage: imageProvider,
        backgroundColor: bgColor,
      ),
      placeholder: (context, url) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: SizedBox(
          width: radius,
          height: radius,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: primaryColor.withOpacity(0.5),
          ),
        ),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        radius: radius,
        backgroundColor: bgColor,
        child: Icon(
          placeholderIcon,
          size: radius,
          color: primaryColor.withOpacity(0.7),
        ),
      ),
      memCacheWidth: (radius * 4).toInt(),
      memCacheHeight: (radius * 4).toInt(),
    );
  }
}
