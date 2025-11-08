import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 1. ADD THIS IMPORT
import 'package:ecommerce_app/screens/admin_panel_screen.dart'; // 2. ADD THIS
import 'package:ecommerce_app/screens/profile_screen.dart'; // 3. ADD THIS
import 'package:ecommerce_app/screens/chat_screen.dart';
import 'package:ecommerce_app/widgets/product_card.dart'; // Product card widget
import 'package:ecommerce_app/widgets/notification_icon.dart';
import 'package:ecommerce_app/screens/product_detail_screen.dart';
import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/cart_screen.dart';
import 'package:ecommerce_app/screens/order_history_screen.dart'; // NEW: Order history screen
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ecommerce_app/widgets/animated_logo.dart';

// HomeScreen is now stateful so we can fetch and store the user's role
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. A state variable to hold the user's role. Default to 'user'.
  String _userRole = 'user';
  // 2. Get the current user from Firebase Auth
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  // 5. This is our new function to get data from Firestore
  Future<void> _fetchUserRole() async {
    // 6. If no one is logged in, do nothing
    if (_currentUser == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser.uid)
          .get();

      final data = doc.data();
      if (doc.exists && data != null) {
        setState(() {
          _userRole = (data['role'] ?? 'user') as String;
        });
      }
    } catch (e) {
      // Keep default 'user' role on error
      debugPrint('Error fetching user role: $e');
    }
  }

  // NOTE: Sign-out is moved to the Profile screen. Removed _signOut from HomeScreen.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedLogo(height: 60), // Enlarged and rotating icon
            const SizedBox(width: 8),
            const Text(
              'Furniture & Decor',
              style: TextStyle(fontSize: 20),
            ), // Enlarged title text, no rotation
          ],
        ),
        actions: [
          // Cart icon with badge using Consumer to listen to cart changes
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 20,
                          minHeight: 20,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Notification (bell) icon
          const NotificationIcon(),
          // Orders / Order History button
          IconButton(
            icon: const Icon(Icons.receipt_long), // A "receipt" icon
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const OrderHistoryScreen(),
                ),
              );
            },
          ),
          if (_userRole == 'admin')
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          // Replaced the Logout icon with a Profile icon that navigates to ProfileScreen
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No products found. Add some in the Admin Panel!'),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(10.0),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3 / 4,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final productDoc = products[index];
              final productData = productDoc.data() as Map<String, dynamic>;

              final name = (productData['name'] ?? '') as String;
              final imageUrl = (productData['imageUrl'] ?? '') as String;

              double price = 0.0;
              final p = productData['price'];
              if (p is int) {
                price = p.toDouble();
              } else if (p is double) {
                price = p;
              } else if (p is String) {
                price = double.tryParse(p) ?? 0.0;
              }

              return ProductCard(
                productName: name,
                price: price,
                imageUrl: imageUrl,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        productData: productData,
                        productId: productDoc.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      // 1. --- REPLACED floatingActionButton: ---
      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
              // 3. Listen to *this user's* chat document
              stream: _firestore
                  .collection('chats')
                  .doc(_currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                int unreadCount = 0;
                if (snapshot.hasData && snapshot.data!.exists) {
                  final data = snapshot.data!.data();
                  if (data != null) {
                    unreadCount =
                        (data as Map<String, dynamic>)['unreadByUserCount'] ??
                        0;
                  }
                }

                return Badge(
                  label: Text('$unreadCount'),
                  isLabelVisible: unreadCount > 0,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.support_agent),
                    label: const Text('Contact Admin'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(chatRoomId: _currentUser!.uid),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : null,
    );
  }
}
