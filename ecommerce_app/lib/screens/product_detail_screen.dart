import 'package:flutter/material.dart';
import 'package:ecommerce_app/providers/cart_provider.dart'; // provider
import 'package:provider/provider.dart';

// 1. This is a new StatelessWidget
class ProductDetailScreen extends StatefulWidget {
  // We will pass in the product's data (the map)
  final Map<String, dynamic> productData;
  // We'll also pass the unique product ID (critical for 'Add to Cart' later)
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productData,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // quantity state
  int _quantity = 1;

  void _incrementQuantity() {
    setState(() {
      _quantity++;
    });
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract data from the widget's map for easier use
    final String name = (widget.productData['name'] ?? '') as String;
    final String description =
        (widget.productData['description'] ?? '') as String;
    final String imageUrl = (widget.productData['imageUrl'] ?? '') as String;

    double price = 0.0;
    final p = widget.productData['price'];
    if (p is int) {
      price = p.toDouble();
    } else if (p is double) {
      price = p;
    } else if (p is String) {
      price = double.tryParse(p) ?? 0.0;
    }

    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              imageUrl,
              height: 300,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const SizedBox(
                  height: 300,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const SizedBox(
                  height: 300,
                  child: Center(child: Icon(Icons.broken_image, size: 100)),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    '₱${price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Divider(thickness: 1),
                  const SizedBox(height: 16),

                  Text(
                    'About this item',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 30),

                  // Quantity selector row
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filledTonal(
                        icon: const Icon(Icons.remove),
                        onPressed: _decrementQuantity,
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      IconButton.filled(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    onPressed: () {
                      final cart = Provider.of<CartProvider>(
                        context,
                        listen: false,
                      );
                      // Pass the selected quantity to the cart
                      cart.addItem(widget.productId, name, price, _quantity);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added $_quantity x $name to cart!'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
