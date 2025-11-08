// This imports all the standard Material Design widgets
import 'package:flutter/material.dart';

// 1. Import the Firebase core package
import 'package:firebase_core/firebase_core.dart';
// 2. Import the auto-generated Firebase options file
import 'firebase_options.dart';

// 3. Import the native splash package
import 'package:flutter_native_splash/flutter_native_splash.dart';
// 1. Import the AuthWrapper
import 'package:ecommerce_app/screens/auth_wrapper.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart'; // 1. ADD THIS IMPORT

// --- ADD OUR NEW APP COLOR PALETTE ---
const Color kRichBlack = Color(0xFF1D1F24); // A dark, rich black
const Color kBrown = Color(0xFF8B5E3C); // Our main "coffee" brown
const Color kLightBrown = Color(0xFFD2B48C); // A lighter tan/beige
const Color kOffWhite = Color(0xFFF8F4F0); // A warm, off-white background
// --- END OF COLOR PALETTE ---

void main() async {
  // 1. Preserve the native splash until initialization completes
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // 2. Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Run the app wrapped with our CartProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );

  // 4. Remove the native splash screen once app is ready
  FlutterNativeSplash.remove();
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
        // 2. Set the main color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: kBrown, // Our new primary color
          brightness: Brightness.light,
          primary: kBrown,
          onPrimary: Colors.white,
          secondary: kLightBrown,
          background: kOffWhite, // Our new app background
        ),
        useMaterial3: true,

        // 3. Set the background color for all screens
        scaffoldBackgroundColor: kOffWhite,

        // 4. --- (FIX) APPLY THE GOOGLE FONT ---
        // This applies "Lato" to all text in the app
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),

        // 5. --- (FIX) GLOBAL BUTTON STYLE ---
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kBrown, // Use our new brown
            foregroundColor: Colors.white, // Text color
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded corners
            ),
          ),
        ),

        // 6. --- (FIX) GLOBAL TEXT FIELD STYLE ---
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          labelStyle: TextStyle(color: kBrown.withOpacity(0.8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kBrown, width: 2.0),
          ),
        ),

        // 7. --- (FIX) GLOBAL CARD STYLE ---
        cardTheme: CardThemeData(
          elevation: 1, // A softer shadow
          color: Colors.white, // Pure white cards on the off-white bg
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          // 8. This ensures the images inside the card are rounded
          clipBehavior: Clip.antiAlias,
        ),

        // 9. --- (NEW) GLOBAL APPBAR STYLE ---
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white, // Clean white AppBar
          foregroundColor: kRichBlack, // Black icons and text
          elevation: 0, // No shadow, modern look
          centerTitle: true,
        ),
      ),
      // --- END OF NEW THEME ---
      // 3. Use AuthWrapper to decide initial screen based on auth state
      home: const AuthWrapper(),
    );
  }
}
