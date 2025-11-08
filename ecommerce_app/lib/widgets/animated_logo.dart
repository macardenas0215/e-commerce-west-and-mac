import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// AnimatedLogo — a small reusable widget that gently bobs and scales the
/// provided SVG to give a subtle "moving" effect suitable for login/signup
/// screens.
class AnimatedLogo extends StatefulWidget {
  final double height;
  final String assetPath;
  const AnimatedLogo({
    super.key,
    this.height = 84,
    this.assetPath = 'assets/images/app_logo.svg',
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _translateAnim;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _rotateAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Bigger up/down motion
    _translateAnim = Tween<double>(
      begin: -12.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.bounceInOut));

    // More pronounced scale pulse
    _scaleAnim = Tween<double>(begin: 0.98, end: 1.05).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.15, 0.85, curve: Curves.bounceInOut),
      ),
    );

    // Full 360-degree rotation
    _rotateAnim = Tween<double>(
      begin: 0.0,
      end: 2 * 3.14159,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.bounceInOut));

    _ctrl.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _translateAnim.value),
          child: Transform.rotate(
            angle: _rotateAnim.value,
            child: Transform.scale(scale: _scaleAnim.value, child: child),
          ),
        );
      },
      child: SvgPicture.asset(
        widget.assetPath,
        height: widget.height,
        semanticsLabel: 'Furniture & Decor Store',
        fit: BoxFit.none,
        alignment: Alignment.center,
      ),
    );
  }
}
