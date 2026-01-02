import 'package:flutter/material.dart';

class ThemedLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final BoxFit fit;

  const ThemedLogo({
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Image.asset(
      isDark ? 'assets/Settingwala_white.png' : 'assets/Settingwala_black.png',
      width: width,
      height: height,
      fit: fit,
    );
  }
}
