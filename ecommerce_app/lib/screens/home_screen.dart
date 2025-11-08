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
import 'package:ecommerce_app/widgets/static_logo.dart';

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
      // --- MODERN APPBAR: Clean, minimal, with brand identity ---
      appBar: AppBar(
        // Subtle shadow for depth
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Static logo from SVG - no animation
            StaticLogo(height: 50),
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
                    icon: const Icon(Icons.shopping_bag_outlined), // More elegant icon
                    iconSize: 24,
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
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFFCE8B70), // Terracotta accent
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          cart.itemCount.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Notification (bell) icon - cleaner style
          const NotificationIcon(),
          // Orders / Order History button
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            iconSize: 24,
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
              icon: const Icon(Icons.dashboard_outlined),
              iconSize: 24,
              tooltip: 'Admin Panel',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AdminPanelScreen(),
                  ),
                );
              },
            ),
          // Profile icon
          IconButton(
            icon: const Icon(Icons.person_outline),
            iconSize: 24,
            tooltip: 'Profile',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          const SizedBox(width: 8), // Spacing from edge
        ],
      ),
      body: Column(
        children: [
          // --- HERO SECTION: Modern furniture showroom banner ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
            decoration: BoxDecoration(
              // Elegant gradient with furniture showroom colors
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B4423), // Walnut brown
                  Color(0xFF8B6B47), // Lighter wood tone
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              // Subtle shadow for depth
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main headline - clean and sophisticated
                Text(
                  'Timeless Design',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                // Subheadline - warm and inviting
                Text(
                  'Curated furniture for modern living',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 20),
                // Decorative element - minimalist line
                Container(
                  width: 60,
                  height: 3,
                  decoration: BoxDecoration(
                    color: Color(0xFFE8DCC4), // Warm beige
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),

          // --- CATEGORY FILTER CHIPS: Clean, minimal, interactive ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // Filter chips with modern furniture categories
                  _buildCategoryChip('All', isSelected: true),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Living Room'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Bedroom'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Dining'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Office'),
                  const SizedBox(width: 12),
                  _buildCategoryChip('Outdoor'),
                ],
              ),
            ),
          ),
          
          // --- PRODUCTS GRID: Modern, spacious, elegant layout ---
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6B4423), // Walnut brown
                      strokeWidth: 3,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Color(0xFF9E9E9E),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Something went wrong',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chair_outlined,
                          size: 64,
                          color: Color(0xFFE8DCC4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back soon for new arrivals',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs;
                
                // Filter products based on user role
                final filteredProducts = products.where((productDoc) {
                  final productData = productDoc.data() as Map<String, dynamic>;
                  final isAvailable = productData['isAvailable'] ?? true;
                  
                  // Admins see all products, users see only available ones
                  if (_userRole == 'admin') {
                    return true;
                  } else {
                    return isAvailable;
                  }
                }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: Color(0xFFE8DCC4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No available products',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2C2C2C),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // --- RESPONSIVE GRID: Adapts to screen size ---
                return LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate optimal number of columns based on width
                    int crossAxisCount = 2; // Default for mobile
                    double childAspectRatio = 0.68; // Taller cards
                    
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 4; // Large desktop
                    } else if (constraints.maxWidth > 800) {
                      crossAxisCount = 3; // Tablet/small desktop
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.all(24.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 20, // Generous spacing
                        mainAxisSpacing: 24,
                        childAspectRatio: childAspectRatio,
                      ),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final productDoc = filteredProducts[index];
                        final productData = productDoc.data() as Map<String, dynamic>;

                        final name = (productData['name'] ?? '') as String;
                        final imageUrl = (productData['imageUrl'] ?? '') as String;
                        final isAvailable = productData['isAvailable'] ?? true;

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
                          isAvailable: isAvailable,
                          isAdmin: _userRole == 'admin',
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
                );
              },
            ),
          ),
        ],
      ),
      // --- FLOATING ACTION BUTTON: Contact admin with modern styling ---
      floatingActionButton: _userRole == 'user'
          ? StreamBuilder<DocumentSnapshot>(
              // Listen to this user's chat document for unread messages
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
                  backgroundColor: Color(0xFFCE8B70), // Terracotta
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.forum_outlined),
                    label: const Text(
                      'Need Help?',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(chatRoomId: _currentUser.uid),
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

  // --- HELPER METHOD: Category filter chip builder ---
  /// Builds a modern, minimal category filter chip
  /// Used in the horizontal scrollable filter section
  Widget _buildCategoryChip(String label, {bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Color(0xFF6B4423) : Colors.white, // Walnut brown when selected
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? Color(0xFF6B4423) : Color(0xFFE8DCC4), // Beige border
          width: 1.5,
        ),
        // Subtle shadow for depth
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: Color(0xFF6B4423).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          color: isSelected ? Colors.white : Color(0xFF2C2C2C),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
