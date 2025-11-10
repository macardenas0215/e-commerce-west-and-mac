// This imports all the standard Material Design widgets
import 'package:flutter/material.dart';

// 1. Import the Firebase core package
import 'package:firebase_core/firebase_core.dart';
// 2. Import the auto-generated Firebase options file
import 'firebase_options.dart';

// 3. Import the native splash package
// NOTE: We intentionally avoid manually preserving/removing the native splash
// via flutter_native_splash. Let the plugin auto-hide the native splash on the
// first Flutter frame to prevent rare cases where the app stays stuck on the
// splash until the app is backgrounded/foregrounded.
// 1. Import the AuthWrapper
import 'package:ecommerce_app/screens/splash_screen.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. ADD THIS IMPORT

// --- MODERN FURNITURE SHOWROOM COLOR PALETTE ---
// Inspired by brands like IKEA, West Elm, and modern Scandinavian design
const Color kCharcoalBlack = Color(0xFF2C2C2C); // Sophisticated matte black
const Color kWalnutBrown = Color(0xFF6B4423); // Rich wood brown (primary)
const Color kWarmBeige = Color(0xFFE8DCC4); // Soft beige (secondary)
const Color kOffWhite = Color(0xFFFAF8F5); // Warm off-white (background)
const Color kSoftGray = Color(0xFF9E9E9E); // Neutral gray for text
const Color kOliveGreen = Color(0xFF6B7C59); // Accent - organic feel
const Color kTerracotta = Color(0xFFCE8B70); // Accent - warmth
const Color kLightGray = Color(0xFFF5F5F5); // Card backgrounds
// --- END OF PALETTE ---

void main() async {
  // Ensure bindings are initialized before any async work
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Run the app wrapped with our CartProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. MaterialApp is the root of your app
    return MaterialApp(
      // 2. This removes the "Debug" banner
      debugShowCheckedModeBanner: false,
      title: 'eCommerce App',
      // 1. --- THIS IS THE NEW, COMPLETE THEME ---
      theme: ThemeData(
        // 2. Set the main color scheme with furniture showroom colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: kWalnutBrown, // Rich wood brown as primary
          brightness: Brightness.light,
          primary: kWalnutBrown,
          onPrimary: Colors.white,
          secondary: kOliveGreen, // Organic olive green
          onSecondary: Colors.white,
          tertiary: kTerracotta, // Warm terracotta accent
          surface: kLightGray,
          background: kOffWhite, // Warm off-white background
        ),
        useMaterial3: true,

        // 3. Set the background color for all screens
        scaffoldBackgroundColor: kOffWhite,

        // 4. --- APPLY MODERN FONT: Poppins (clean & elegant) ---
        // Poppins gives a modern, geometric, friendly feel perfect for furniture
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme).copyWith(
          headlineLarge: GoogleFonts.poppins(
            fontSize: 32,
            fontWeight: FontWeight.w600,
            color: kCharcoalBlack,
            letterSpacing: -0.5,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          headlineMedium: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: kCharcoalBlack,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          titleLarge: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kCharcoalBlack,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          titleMedium: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: kCharcoalBlack,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          bodyLarge: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: kSoftGray,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          bodyMedium: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: kSoftGray,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
        ),

        // 5. --- GLOBAL BUTTON STYLE: Rounded, elegant, high-contrast ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kWalnutBrown,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16), // More rounded for modern look
            ),
            elevation: 2, // Subtle shadow
            textStyle: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          ),
        ),

        // 6. --- GLOBAL TEXT BUTTON STYLE ---
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: kWalnutBrown,
            textStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          ),
        ),

        // 7. --- GLOBAL TEXT FIELD STYLE: Clean borders, rounded ---
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kWarmBeige),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kWarmBeige),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: kWalnutBrown, width: 2.0),
          ),
          labelStyle: GoogleFonts.poppins(
            color: kSoftGray,
            fontWeight: FontWeight.w500,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          hintStyle: GoogleFonts.poppins(
            color: kSoftGray.withOpacity(0.6),
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),

        // 8. --- GLOBAL CARD STYLE: Soft shadows, rounded corners ---
        cardTheme: CardThemeData(
          elevation: 3, // Soft, elegant shadow
          color: Colors.white,
          surfaceTintColor: Colors.white,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // Generous rounding
          ),
          clipBehavior: Clip.antiAlias,
        ),

        // 9. --- GLOBAL APPBAR STYLE: Clean, minimal, elegant ---
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: kCharcoalBlack,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: kCharcoalBlack,
            letterSpacing: 0.5,
          ).copyWith(fontFamilyFallback: ['Roboto', 'Noto Sans']),
          iconTheme: IconThemeData(color: kCharcoalBlack),
        ),

        // 10. --- FLOATING ACTION BUTTON STYLE ---
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: kWalnutBrown,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      // --- END OF NEW THEME ---
      // 3. Show an in-app splash first, then navigate to the AuthWrapper
      home: const SplashScreen(),
    );
  }
}
