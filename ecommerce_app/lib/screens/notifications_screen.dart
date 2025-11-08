import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/screens/notification_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // We no longer auto-mark all notifications as read when the screen opens.
  // Instead, we mark a specific notification as read when the user taps it
  // so the UI can show the bold state for a short split-second before
  // the change is committed to Firestore.
  // Cache the most recent non-empty snapshot so a brief empty-state
  // from the stream doesn't cause the whole UI to show "You have no
  // notifications." while the server updates.
  List<QueryDocumentSnapshot>? _cachedDocs;

  @override
  void initState() {
    super.initState();
    // Perform an initial one-time fetch to populate the cache immediately
    // so the UI shows notifications as soon as the user opens the screen.
    final uid = _user?.uid;
    if (uid != null) {
      _firestore
          .collection('notifications')
          .where('userId', isEqualTo: uid)
          .get()
          .then((snap) {
            if (snap.docs.isNotEmpty) {
              setState(() {
                _cachedDocs = snap.docs;
              });
            }
          })
          .catchError((e) {
            debugPrint('Initial notifications fetch failed: $e');
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final String? uid = _user?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _user == null
          ? const Center(child: Text('Please log in.'))
          : StreamBuilder<QuerySnapshot>(
              // Listen without server-side ordering to avoid briefly
              // excluding documents whose serverTimestamp hasn't resolved.
              // Include metadata changes so we get updates when local
              // pending writes (like serverTimestamp resolution) are
              // processed; this reduces transient empty/unstable states.
              stream: _firestore
                  .collection('notifications')
                  .where('userId', isEqualTo: uid)
                  .snapshots(includeMetadataChanges: true),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data?.docs ?? [];
                debugPrint(
                  'Notifications snapshot: uid=$uid count=${docs.length} cached=${_cachedDocs?.length ?? 0}',
                );

                // Update cache when we receive a non-empty set of docs.
                if (docs.isNotEmpty) {
                  _cachedDocs = docs;
                }

                // NOTE: Don't auto-mark notifications as read here. We'll mark
                // individual notifications when the user chooses to.

                // If the live stream is empty but we have cached docs,
                // display the cache to avoid a brief "no notifications"
                // flash. Otherwise display the current docs.
                final displayDocs = docs.isNotEmpty
                    ? docs
                    : (_cachedDocs ?? docs);

                if (displayDocs.isEmpty) {
                  return const Center(
                    child: Text('You have no notifications.'),
                  );
                }

                // Sort client-side by createdAt (treat null as epoch) so items
                // show immediately and in the expected order even if
                // server timestamps haven't arrived yet.
                final sortedDocs = List<QueryDocumentSnapshot>.from(
                  displayDocs,
                );
                sortedDocs.sort((a, b) {
                  final aData = a.data() as Map<String, dynamic>;
                  final bData = b.data() as Map<String, dynamic>;
                  final aLocal = aData['localCreatedAt'] as Timestamp?;
                  final bLocal = bData['localCreatedAt'] as Timestamp?;
                  final aTs = aLocal ?? (aData['createdAt'] as Timestamp?);
                  final bTs = bLocal ?? (bData['createdAt'] as Timestamp?);
                  final aMillis = aTs?.millisecondsSinceEpoch ?? 0;
                  final bMillis = bTs?.millisecondsSinceEpoch ?? 0;
                  return bMillis.compareTo(aMillis);
                });

                return ListView.builder(
                  itemCount: sortedDocs.length,
                  itemBuilder: (context, index) {
                    final data =
                        sortedDocs[index].data() as Map<String, dynamic>;
                    final timestamp = data['createdAt'] as Timestamp?;
                    final formattedDate = timestamp != null
                        ? DateFormat(
                            'MM/dd/yy hh:mm a',
                          ).format(timestamp.toDate())
                        : '';

                    final bool wasUnread = data['isRead'] == false;

                    return ListTile(
                      leading: wasUnread
                          ? const Icon(
                              Icons.circle,
                              color: Colors.deepPurple,
                              size: 12,
                            )
                          : const Icon(
                              Icons.circle_outlined,
                              color: Colors.grey,
                              size: 12,
                            ),
                      title: Text(
                        data['title'] ?? 'No Title',
                        style: TextStyle(
                          fontWeight: wasUnread
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        '${data['body'] ?? ''}\nOrder: ${data['orderId'] ?? ''}\n$formattedDate',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        // Open a detail screen for this notification. The
                        // detail screen allows the user to view order info
                        // and explicitly mark the notification as read; the
                        // notification itself remains in the list.
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => NotificationDetailScreen(
                              notificationRef: sortedDocs[index].reference,
                              notificationData: data,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
