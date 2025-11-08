import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // We'll use this for dates again

class AdminOrderScreen extends StatefulWidget {
  const AdminOrderScreen({super.key});

  @override
  State<AdminOrderScreen> createState() => _AdminOrderScreenState();
}

class _AdminOrderScreenState extends State<AdminOrderScreen> {
  // 1. Get an instance of Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 2. This is the function that updates the status in Firestore
  Future<void> _updateOrderStatus(
    String orderId,
    String newStatus,
    String userId,
  ) async {
    try {
      // 3. Find the document and update the 'status' field
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
      // Create a notification for the user
      try {
        await _firestore.collection('notifications').add({
          'userId': userId,
          'title': 'Order Status Updated',
          'body': 'Your order ($orderId) has been updated to "$newStatus".',
          'orderId': orderId,
          // Server timestamp for canonical ordering on the server
          'createdAt': FieldValue.serverTimestamp(),
          // Local timestamp to allow immediate client-side ordering
          'localCreatedAt': Timestamp.fromDate(DateTime.now()),
          'isRead': false,
        });
      } catch (e) {
        // Non-fatal: log the error
        debugPrint('Failed to create notification: $e');
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Order status updated!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    }
  }

  // 4. This function shows the update dialog
  void _showStatusDialog(String orderId, String currentStatus, String userId) {
    showDialog(
      context: context,
      builder: (context) {
        // 5. A list of all possible statuses
        const statuses = [
          'Pending',
          'Processing',
          'Shipped',
          'Delivered',
          'Cancelled',
        ];

        return AlertDialog(
          title: const Text('Update Order Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min, // Make the dialog small
            children: statuses.map((status) {
              // 6. Create a button for each status
              return ListTile(
                title: Text(status),
                // 7. Show a checkmark next to the current status
                trailing: currentStatus == status
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  // 8. When tapped:
                  _updateOrderStatus(
                    orderId,
                    status,
                    userId,
                  ); // Call update and pass userId
                  Navigator.of(context).pop(); // Close the dialog
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      // 1. Use a StreamBuilder to get all orders
      body: StreamBuilder<QuerySnapshot>(
        // 2. This is our query
        stream: _firestore
            .collection('orders')
            .orderBy('createdAt', descending: true) // Newest first
            .snapshots(),

        builder: (context, snapshot) {
          // 3. Handle all states: loading, error, empty
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders found.'));
          }

          // 4. We have the orders!
          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final orderData = order.data() as Map<String, dynamic>;

              // 5. Format the date (same as OrderCard)
              String formattedDate = 'Unknown';
              if (orderData['createdAt'] != null &&
                  orderData['createdAt'] is Timestamp) {
                final Timestamp timestamp = orderData['createdAt'];
                formattedDate = DateFormat(
                  'MM/dd/yyyy hh:mm a',
                ).format(timestamp.toDate());
              }

              // 6. Get the current status
              final String status = (orderData['status'] ?? 'Unknown')
                  .toString();

              // Safely extract total price
              double total = 0.0;
              if (orderData['totalPrice'] is num) {
                total = (orderData['totalPrice'] as num).toDouble();
              }

              // 7. Build a Card for each order
              return Card(
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    'Order ID: ${order.id}', // Show the doc ID
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  subtitle: Text(
                    'User: ${orderData['userId'] ?? 'Unknown'}\n'
                    'Total: ₱${total.toStringAsFixed(2)} | Date: $formattedDate',
                  ),
                  isThreeLine: true,

                  // 8. Show the status with a colored chip
                  trailing: Chip(
                    label: Text(
                      status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    backgroundColor: status == 'Pending'
                        ? Colors.orange
                        : status == 'Processing'
                        ? Colors.blue
                        : status == 'Shipped'
                        ? Colors.deepPurple
                        : status == 'Delivered'
                        ? Colors.green
                        : Colors.red,
                  ),

                  // 9. On tap, show our update dialog
                  onTap: () {
                    final String? userId = orderData['userId'] as String?;
                    if (userId == null || userId.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Cannot send notification: missing userId',
                          ),
                        ),
                      );
                      return;
                    }
                    _showStatusDialog(order.id, status, userId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
