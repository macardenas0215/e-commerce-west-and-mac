import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce_app/screens/auth_wrapper.dart';

/// SplashScreen - shows the static SVG logo full-screen while the app finishes
/// initial loading. After a short, configurable delay it replaces itself with
/// the `AuthWrapper` which contains the normal app entry logic.
class SplashScreen extends StatefulWidget {
  /// How long to show the in-app splash (in milliseconds). Keep it short.
  final int durationMs;

  const SplashScreen({super.key, this.durationMs = 1200});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;
  Timer? _failsafeTimer; // Second timer in case first navigation silently fails

  @override
  void initState() {
    super.initState();
    // Start a short timer then navigate to the AuthWrapper
    _timer = Timer(Duration(milliseconds: widget.durationMs), () {
      _navigateToAuthWrapper(reason: 'primary_timer');
    });

    // Failsafe: if for any reason navigation didn't happen (rare release issues),
    // force it after 3 seconds.
    _failsafeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToAuthWrapper(reason: 'failsafe_timer');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _failsafeTimer?.cancel();
    super.dispose();
  }

  void _navigateToAuthWrapper({required String reason}) {
    if (!mounted) return;
    // Prevent duplicate navigation attempts.
    if (ModalRoute.of(context)?.isCurrent != true) return;
    debugPrint('[SplashScreen] Navigating to AuthWrapper (reason=$reason)');
    // Use post frame callback to ensure safe navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Use theme background for consistency with the app's look
    final bg = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bg,
      body: Center(
        // Constrain the logo size so it looks good on mobile & desktop
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360, maxHeight: 180),
          child: SvgPicture.asset(
            'assets/images/app_logo.svg',
            fit: BoxFit.contain,
            semanticsLabel: 'App logo',
            // A simple placeholder while the svg loads
            placeholderBuilder: (context) => Container(
              width: 200,
              height: 90,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chair_outlined,
                size: 36,
                color: const Color(0xFF6B4423),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
