import 'package:flutter/material.dart';

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

    isMobile = screenWidth < 600;
    isTablet = screenWidth >= 600 && screenWidth < 1024;
    isDesktop = screenWidth >= 1024;
  }

  static double fontSize(double size) {
    if (isMobile) {
      if (screenWidth < 360) {
        return size * 0.85;
      } else if (screenWidth < 400) {
        return size * 0.9;
      }
      return size;
    } else if (isTablet) {
      return size * 1.1;
    }
    return size * 1.2;
  }

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

  static double wp(double percentage) {
    return screenWidth * (percentage / 100);
  }

  static double hp(double percentage) {
    return screenHeight * (percentage / 100);
  }

  static int getGridCrossAxisCount({int mobile = 2, int tablet = 3, int desktop = 4}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }

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

  static double containerWidth() {
    if (isDesktop) {
      return screenWidth * 0.7;
    } else if (isTablet) {
      return screenWidth * 0.85;
    }
    return screenWidth;
  }

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

  static double getCardAspectRatio({double mobile = 0.75, double tablet = 0.8, double desktop = 0.85}) {
    if (isMobile) return mobile;
    if (isTablet) return tablet;
    return desktop;
  }
}

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
  
  double responsiveFont(double size) {
    if (isSmallMobile) return size * 0.85;
    if (isMobile) return size;
    if (isTablet) return size * 1.1;
    return size * 1.2;
  }
  
  double responsivePadding(double size) {
    if (isSmallMobile) return size * 0.7;
    if (isMobile) return size;
    if (isTablet) return size * 1.2;
    return size * 1.5;
  }
  
  double responsiveIcon(double size) {
    if (isSmallMobile) return size * 0.8;
    if (isMobile) return size;
    if (isTablet) return size * 1.15;
    return size * 1.3;
  }
}
