import 'package:ecommerce_app/providers/cart_provider.dart';
import 'package:ecommerce_app/screens/order_success_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. An enum to represent our different payment methods
//    This is cleaner than using strings like "gcash"
enum PaymentMethod { card, gcash, bank }

class PaymentScreen extends StatefulWidget {
  // 2. We need to know the total amount to be paid
  final double totalAmount;

  // 3. The constructor will require this amount
  const PaymentScreen({super.key, required this.totalAmount});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // 4. State variables to track selection and loading
  PaymentMethod _selectedMethod = PaymentMethod.card; // Default to card
  bool _isLoading = false;

  // The main function that simulates a payment call and then places the order
  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Mock external payment call
      await Future.delayed(const Duration(seconds: 3));

      final cartProvider = Provider.of<CartProvider>(context, listen: false);

      // Call existing provider functions
      await cartProvider.placeOrder();
      await cartProvider.clearCart();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to place order: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTotal = '₱${widget.totalAmount.toStringAsFixed(2)}';

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Payment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Total Amount:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              formattedTotal,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 24),
            const Divider(),
            Text(
              'Select Payment Method:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),

            RadioListTile<PaymentMethod>(
              title: const Text('Credit/Debit Card'),
              secondary: const Icon(Icons.credit_card),
              value: PaymentMethod.card,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),

            RadioListTile<PaymentMethod>(
              title: const Text('GCash'),
              secondary: const Icon(Icons.phone_android),
              value: PaymentMethod.gcash,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),

            RadioListTile<PaymentMethod>(
              title: const Text('Bank Transfer'),
              secondary: const Icon(Icons.account_balance),
              value: PaymentMethod.bank,
              groupValue: _selectedMethod,
              onChanged: (PaymentMethod? value) {
                setState(() {
                  _selectedMethod = value!;
                });
              },
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : Text('Pay Now ($formattedTotal)'),
            ),
          ],
        ),
      ),
    );
  }
}
