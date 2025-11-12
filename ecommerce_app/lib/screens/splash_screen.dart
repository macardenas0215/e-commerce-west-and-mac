import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
  bool _showAuth = false; // When true, render AuthWrapper in-place

  @override
  void initState() {
    super.initState();
    // Start a short timer then navigate to the AuthWrapper
    _timer = Timer(Duration(milliseconds: widget.durationMs), () {
      _showAuthWrapper(reason: 'primary_timer');
    });

    // Failsafe: if for any reason navigation didn't happen (rare release issues),
    // force it after 3 seconds.
    _failsafeTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _showAuthWrapper(reason: 'failsafe_timer');
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _failsafeTimer?.cancel();
    super.dispose();
  }



  void _showAuthWrapper({required String reason}) {
    if (!mounted) return;
    if (_showAuth) return; // already showing
    debugPrint('[SplashScreen] Showing AuthWrapper in-place (reason=$reason)');
    // Update state to render the AuthWrapper directly as the home widget.
    setState(() {
      _showAuth = true;
    });

    // Ensure web repaints immediately
    SchedulerBinding.instance.scheduleFrame();
  }

  @override
  Widget build(BuildContext context) {
    if (_showAuth) {
      // Render AuthWrapper directly to avoid route push timing issues on web.
      return const AuthWrapper();
    }
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
