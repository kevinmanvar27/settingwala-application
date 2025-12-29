import 'package:flutter/material.dart';

/// Responsive utility class for handling different screen sizes
/// Using MediaQuery to make UI responsive across all devices
class Responsive {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double safeAreaHorizontal;
  static late double safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;
  static late bool isMobile;
  static late bool isTablet;
  static late bool isDesktop;
  static late Orientation orientation;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    blockSizeHorizontal = screenWidth / 100;
    blockSizeVertical = screenHeight / 100;

    safeAreaHorizontal = _mediaQueryData.padding.left + _mediaQueryData.padding.right;
    safeAreaVertical = _mediaQueryData.padding.top + _mediaQueryData.padding.bottom;

    safeBlockHorizontal = (screenWidth - safeAreaHorizontal) / 100;
    safeBlockVertical = (screenHeight - safeAreaVertical) / 100;

    // Device type detection
    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1024;
    isDesktop = screenWidth >= 1024;
  }

  // Responsive font size
  static double fontSize(double size) {
    if (isMobile) {
      if (screenWidth < 360) {
        return size * 0.85; // Small phones
      } else if (screenWidth < 400) {
        return size * 0.9; // Medium phones
      }
      return size; // Large phones
    } else if (isTablet) {
      return size * 1.1;
    }
    return size * 1.2; // Desktop
  }

  // Responsive padding
  static double padding(double size) {
    if (isMobile) {
      if (screenWidth < 360) {
        return size * 0.7;
      } else if (screenWidth < 400) {
        return size * 0.85;
      }
      return size;
    } else if (isTablet) {
      return size * 1.2;
    }
    return size * 1.5;
  }

  // Responsive icon size
  static double iconSize(double size) {
    if (isMobile) {
      if (screenWidth < 360) {
        return size * 0.8;
      }
      return size;
    } else if (isTablet) {
      return size * 1.15;
    }
    return size * 1.3;
  }

  // Responsive width percentage
  static double wp(double percentage) {
    return screenWidth * (percentage / 100);
  }

  // Responsive height percentage
  static double hp(double percentage) {
    return screenHeight * (percentage / 100);
  }

  // Get grid cross axis count based on screen width
  static int getGridCrossAxisCount({int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

  // Get responsive horizontal padding
  static EdgeInsets horizontalPadding({double mobile = 16, double tablet = 24, double desktop = 32}) {
    double padding;
    if (isMobile) {
      padding = mobile;
    } else if (isTablet) {
      padding = tablet;
    } else {
      padding = desktop;
    }
    return EdgeInsets.symmetric(horizontal: padding);
  }

  // Get responsive all-side padding
  static EdgeInsets allPadding({double mobile = 16, double tablet = 20, double desktop = 24}) {
    double padding;
    if (isMobile) {
      if (screenWidth < 360) {
        padding = mobile * 0.75;
      } else {
        padding = mobile;
      }
    } else if (isTablet) {
      padding = tablet;
    } else {
      padding = desktop;
    }
    return EdgeInsets.all(padding);
  }

  // Responsive container width (for centered content on large screens)
  static double containerWidth() {
    if (isDesktop) {
      return screenWidth * 0.7;
    } else if (isTablet) {
      return screenWidth * 0.85;
    }
    return screenWidth;
  }

  // Responsive card height
  static double cardHeight({double mobile = 220, double tablet = 250, double desktop = 280}) {
    if (isMobile) {
      if (screenWidth < 360) {
        return mobile * 0.85;
      }
      return mobile;
    } else if (isTablet) {
      return tablet;
    }
    return desktop;
  }

  // Responsive avatar size
  static double avatarSize({double mobile = 60, double tablet = 70, double desktop = 80}) {
    if (isMobile) {
      if (screenWidth < 360) {
        return mobile * 0.8;
      }
      return mobile;
    } else if (isTablet) {
      return tablet;
    }
    return desktop;
  }

  // Responsive button height
  static double buttonHeight({double mobile = 50, double tablet = 54, double desktop = 58}) {
    if (isMobile) {
      if (screenWidth < 360) {
        return mobile * 0.9;
      }
      return mobile;
    } else if (isTablet) {
      return tablet;
    }
    return desktop;
  }

  // Get aspect ratio for cards
  static double getCardAspectRatio({double mobile = 0.75, double tablet = 0.8, double desktop = 0.85}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
}

/// Extension on BuildContext for easy access to responsive values
extension ResponsiveExtension on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  bool get isMobile => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 1024;
  bool get isDesktop => screenWidth >= 1024;
  bool get isSmallMobile => screenWidth < 360;
  
  Orientation get orientation => MediaQuery.of(this).orientation;
  bool get isPortrait => orientation == Orientation.portrait;
  bool get isLandscape => orientation == Orientation.landscape;
  
  // Responsive font
  double responsiveFont(double size) {
    if (isSmallMobile) return size * 0.85;
    if (isMobile) return size;
    if (isTablet) return size * 1.1;
    return size * 1.2;
  }
  
  // Responsive padding
  double responsivePadding(double size) {
    if (isSmallMobile) return size * 0.7;
    if (isMobile) return size;
    if (isTablet) return size * 1.2;
    return size * 1.5;
  }
  
  // Responsive icon
  double responsiveIcon(double size) {
    if (isSmallMobile) return size * 0.8;
    if (isMobile) return size;
    if (isTablet) return size * 1.15;
    return size * 1.3;
  }
}
