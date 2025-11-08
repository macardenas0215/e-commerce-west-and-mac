import 'signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// flutter_svg is used by the AnimatedLogo widget (imported below)
import 'package:ecommerce_app/widgets/animated_logo.dart';

// 1. Create a StatefulWidget
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

// 2. This is the State class
class _LoginScreenState extends State<LoginScreen> {
  // 3. Create a GlobalKey for the Form
  final _formKey = GlobalKey<FormState>();

  // 4. Create TextEditingControllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Loading state
  bool _isLoading = false;

  // 3. Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 5. Clean up controllers when the widget is removed
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Login function
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    // Capture ScaffoldMessenger before awaiting to avoid using BuildContext across async gaps
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // AuthWrapper will react to changes and navigate
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      }

      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. A Scaffold provides the basic screen structure
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      // 2. SingleChildScrollView prevents the keyboard from
      //    causing a "pixel overflow" error
      body: SingleChildScrollView(
        child: Padding(
          // 3. Add padding around the form
          padding: const EdgeInsets.all(16.0),
          // 4. The Form widget acts as a container for our fields
          child: Form(
            key: _formKey, // 5. Assign our key to the Form
            // 6. A Column arranges its children vertically
            child: Column(
              // 7. Center the contents of the column
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // The Form Fields will go here
                const SizedBox(height: 8),
                // Animated logo (subtle movement)
                Center(child: AnimatedLogo(height: 84)),
                const SizedBox(height: 12),

                // Email field
                // Wrapped in a Card so the form feels distinct and has a gentle rounded area
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!value.contains('@')) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                  ),
                  onPressed: _login,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Login'),
                ),

                const SizedBox(height: 10),

                // Navigate to Sign Up (replace so AuthWrapper can handle navigation after signup)
                TextButton(
                  onPressed: () {
                    // Use push so that SignUp can pop back to Login after
                    // successful sign-up. Using pushReplacement caused the
                    // route stack to be replaced which led to a blank page
                    // when SignUp called pop().
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SignUpScreen(),
                      ),
                    );
                  },
                  child: const Text("Don't have an account? Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
