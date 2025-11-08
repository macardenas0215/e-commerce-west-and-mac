import 'dart:async'; // For StreamSubscription
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// 1. A simple class to hold the data for an item in the cart
class CartItem {
  final String id; // The unique product ID
  final String name;
  final double price;
  int quantity; // Quantity can change, so it's not final

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  // Convert a CartItem into a Map for Firestore
  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'price': price, 'quantity': quantity};
  }

  // Create a CartItem from a Map (from Firestore)
  factory CartItem.fromJson(Map<String, dynamic> json) {
    final dynamic priceVal = json['price'];
    final dynamic qtyVal = json['quantity'];

    double parsedPrice = 0.0;
    if (priceVal is int) parsedPrice = priceVal.toDouble();
    if (priceVal is double) parsedPrice = priceVal;
    if (priceVal is String) parsedPrice = double.tryParse(priceVal) ?? 0.0;

    int parsedQty = 1;
    if (qtyVal is int) parsedQty = qtyVal;
    if (qtyVal is double) parsedQty = qtyVal.toInt();
    if (qtyVal is String) parsedQty = int.tryParse(qtyVal) ?? 1;

    return CartItem(
      id: json['id'] as String,
      name: json['name'] as String,
      price: parsedPrice,
      quantity: parsedQty,
    );
  }
}

// 2. The CartProvider class "mixes in" ChangeNotifier
class CartProvider with ChangeNotifier {
  // 3. This is the private list of items. It's mutable now because
  //    we'll replace it when loading from Firestore.
  List<CartItem> _items = [];

  // 4. New properties for auth and database
  String? _userId; // Will hold the current user's ID
  StreamSubscription<User?>? _authSubscription; // To listen to auth changes

  // 5. Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 6. A public "getter" to let widgets *read* the list of items
  List<CartItem> get items => _items;

  // 7. A public "getter" to calculate the total number of items
  int get itemCount {
    // Use fold for a concise sum of quantities
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  // --- THIS IS THE GETTERS SECTION ---
  // 1. RENAME 'totalPrice' to 'subtotal' (total before tax)
  double get subtotal {
    double total = 0.0;
    for (var item in _items) {
      total += (item.price * item.quantity);
    }
    return total;
  }

  // 2. ADD this new getter for VAT (12%)
  double get vat {
    return subtotal * 0.12; // 12% of the subtotal
  }

  // 3. ADD this new getter for the FINAL total (including VAT)
  double get totalPriceWithVat {
    return subtotal + vat;
  }

  // 9. Constructor: listen to auth changes and load/save cart
  CartProvider() {
    // Listen to authentication changes
    _authSubscription = _auth.authStateChanges().listen((User? user) {
      if (user == null) {
        // User is logged out
        _userId = null;
        _items = [];
        notifyListeners();
      } else {
        // User is logged in
        _userId = user.uid;
        _fetchCart();
      }
    });
  }

  // 10. Fetches the cart from Firestore
  Future<void> _fetchCart() async {
    if (_userId == null) return;

    try {
      final doc = await _firestore.collection('userCarts').doc(_userId).get();
      if (doc.exists && doc.data()?['cartItems'] != null) {
        final List<dynamic> cartData =
            doc.data()!['cartItems'] as List<dynamic>;
        _items = cartData
            .map(
              (item) =>
                  CartItem.fromJson(Map<String, dynamic>.from(item as Map)),
            )
            .toList();
      } else {
        _items = [];
      }
    } catch (e) {
      // On error, default to empty cart
      _items = [];
    }
    notifyListeners();
  }

  // 11. Saves the current local cart to Firestore
  Future<void> _saveCart() async {
    if (_userId == null) return;

    try {
      final List<Map<String, dynamic>> cartData = _items
          .map((i) => i.toJson())
          .toList();
      await _firestore.collection('userCarts').doc(_userId).set({
        'cartItems': cartData,
      });
    } catch (e) {
      // ignore save errors for now
    }
  }

  // 12. The main logic: "Add Item to Cart"
  // Updated to accept a quantity parameter so callers can add multiple units at once.
  void addItem(String id, String name, double price, int quantity) {
    var index = _items.indexWhere((item) => item.id == id);

    if (index != -1) {
      // If the item already exists, increment its quantity by the given amount
      _items[index].quantity += quantity;
    } else {
      // Otherwise add as a new item with the specified quantity
      _items.add(
        CartItem(id: id, name: name, price: price, quantity: quantity),
      );
    }

    _saveCart();
    notifyListeners();
  }

  // 13. The "Remove Item from Cart" logic
  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    _saveCart();
    notifyListeners();
  }

  // 1. ADD THIS: Creates an order in the 'orders' collection
  Future<void> placeOrder() async {
    // 2. Check if we have a user and items
    if (_userId == null || _items.isEmpty) {
      // Don't place an order if cart is empty or user is logged out
      throw Exception('Cart is empty or user is not logged in.');
    }

    try {
      // 3. Convert our List<CartItem> to a List<Map> using toJson()
      final List<Map<String, dynamic>> cartData = _items
          .map((item) => item.toJson())
          .toList();

      // 4. --- THIS IS THE CHANGE ---
      //    Get our new calculated values
      final double sub = subtotal;
      final double v = vat;
      final double total = totalPriceWithVat;
      final int count = itemCount;

      // 5. Create a new document in the 'orders' collection (save breakdown)
      await _firestore.collection('orders').add({
        'userId': _userId,
        'items': cartData, // Our list of item maps
        'subtotal': sub, // NEW: subtotal before tax
        'vat': v, // NEW: vat amount
        'totalPrice': total, // VAT-inclusive final price (keeps schema name)
        'itemCount': count,
        'status': 'Pending', // IMPORTANT: For admin verification
        'createdAt': FieldValue.serverTimestamp(), // For sorting
      });

      // 7. Note: We DO NOT clear the cart here.
      //    We'll call clearCart() separately from the UI after this succeeds.
    } catch (e) {
      debugPrint('Error placing order: $e');
      // 8. Re-throw the error so the UI can catch it
      rethrow;
    }
  }

  // 9. ADD THIS: Clears the cart locally AND in Firestore
  Future<void> clearCart() async {
    // 10. Clear the local list
    _items = [];

    // 11. If logged in, clear the Firestore cart as well
    if (_userId != null) {
      try {
        // 12. Set the 'cartItems' field in their cart doc to an empty list
        await _firestore.collection('userCarts').doc(_userId).set({
          'cartItems': [],
        });
        debugPrint('Firestore cart cleared.');
      } catch (e) {
        debugPrint('Error clearing Firestore cart: $e');
      }
    }

    // 13. Notify all listeners (this will clear the UI)
    notifyListeners();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
