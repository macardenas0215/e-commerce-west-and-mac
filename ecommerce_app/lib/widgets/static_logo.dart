import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// StaticLogo — A non-animated logo widget that displays the SVG logo
/// Perfect for app bars and headers where motion is not desired
class StaticLogo extends StatelessWidget {
  final double height;
  final String assetPath;

  const StaticLogo({
    super.key,
    this.height = 40,
    this.assetPath = 'assets/images/app_logo.svg',
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      height: height,
      fit: BoxFit.contain,
      // Fallback for when SVG fails to load
      placeholderBuilder: (context) => Container(
        height: height,
        width: height * 2, // Approximate aspect ratio
        decoration: BoxDecoration(
          color: Color(0xFFE8DCC4).withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.chair_outlined,
          size: height * 0.5,
          color: Color(0xFF6B4423),
        ),
      ),
    );
  }
}
