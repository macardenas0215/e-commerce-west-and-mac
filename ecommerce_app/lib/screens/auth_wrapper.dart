import 'package:ecommerce_app/screens/home_screen.dart';
import 'package:ecommerce_app/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

/// AuthWrapper listens to Firebase auth state and returns Home or Login screen.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Helpful debug output during development
        debugPrint(
          'AuthWrapper snapshot: connection=${snapshot.connectionState}, hasData=${snapshot.hasData}, hasError=${snapshot.hasError}, data=${snapshot.data}',
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Auth error: ${snapshot.error}')),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // Wrap authenticated area with a smooth red border so it's visible
          return _AuthenticatedBorder(child: const HomeScreen());
        }

        return const LoginScreen();
      },
    );
  }
}

/// A small wrapper that adds a smooth animated red border around the
/// authenticated part of the app. This makes it visually obvious when a
/// user/admin has entered the authenticated area.
class _AuthenticatedBorder extends StatelessWidget {
  final Widget child;
  const _AuthenticatedBorder({required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.redAccent, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.redAccent.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
    );
  }
}
