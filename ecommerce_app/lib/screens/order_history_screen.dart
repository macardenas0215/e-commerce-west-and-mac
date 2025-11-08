import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app/widgets/order_card.dart'; // 1. Import our new card
import 'package:url_launcher/url_launcher.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 2. Get the current user
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      // 3. Check if the user is logged in
      body: user == null
          ? const Center(child: Text('Please log in to see your orders.'))
          // 4. If logged in, show the StreamBuilder
          : StreamBuilder<QuerySnapshot>(
              // 5. --- THIS IS THE CRITICAL NEW QUERY ---
              // NOTE: removed server-side orderBy to avoid requiring a composite
              // index. We'll filter by userId then sort the results in Dart so
              // the newest orders still appear first.
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  // 6. Filter the 'orders' collection
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),

              builder: (context, snapshot) {
                // 8. Handle loading state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // 9. Handle error state
                if (snapshot.hasError) {
                  final errMsg = snapshot.error.toString();

                  // Detect Firestore 'requires an index' message and show a helpful UI
                  if (errMsg.contains('requires an index') ||
                      errMsg.contains('failed-precondition')) {
                    // Try to extract a URL from the error message
                    final urlMatch = RegExp(r'https?://\S+').firstMatch(errMsg);
                    final createIndexUrl = urlMatch?.group(0) ?? '';

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 56,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'This query requires a Firestore composite index.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Open the Firebase Console link below to create the index for the orders collection.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            if (createIndexUrl.isNotEmpty) ...[
                              SelectableText(
                                createIndexUrl,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.blue),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.open_in_browser),
                                label: const Text('Open in Firebase Console'),
                                onPressed: () async {
                                  // Capture messenger before awaiting to avoid using
                                  // BuildContext after async operations.
                                  final messenger = ScaffoldMessenger.of(
                                    context,
                                  );
                                  try {
                                    final uri = Uri.parse(createIndexUrl);
                                    if (!await launchUrl(
                                      uri,
                                      mode: LaunchMode.externalApplication,
                                    )) {
                                      messenger.showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Could not open the link.',
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text('Error opening link: $e'),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ] else ...[
                              const Text(
                                'No creation link was found in the error message. Open the Firebase Console and create a composite index for the `orders` collection with fields: `userId` (ASC) and `createdAt` (DESC).',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }

                  // Fallback: show the raw error text
                  return Center(child: Text('Error: $errMsg'));
                }

                // 10. Handle no data (no orders)
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('You have not placed any orders yet.'),
                  );
                }

                // 11. We have data! Sort results in Dart (newest first) and show
                // the list. This avoids needing a Firestore composite index.
                final orderDocs = List.of(snapshot.data!.docs);

                orderDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;

                  final aTs = aData['createdAt'] as Timestamp?;
                  final bTs = bData['createdAt'] as Timestamp?;

                  final aMillis = aTs?.toDate().millisecondsSinceEpoch ?? 0;
                  final bMillis = bTs?.toDate().millisecondsSinceEpoch ?? 0;

                  // Descending: newer first
                  return bMillis.compareTo(aMillis);
                });

                // 12. Use ListView.builder to show the list
                return ListView.builder(
                  itemCount: orderDocs.length,
                  itemBuilder: (context, index) {
                    // 13. Get the data for a single order
                    final orderData =
                        orderDocs[index].data() as Map<String, dynamic>;

                    // 14. Return our custom OrderCard widget
                    return OrderCard(orderData: orderData);
                  },
                );
              },
            ),
    );
  }
}
