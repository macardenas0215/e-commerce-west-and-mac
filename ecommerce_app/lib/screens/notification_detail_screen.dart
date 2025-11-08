import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationDetailScreen extends StatefulWidget {
  final DocumentReference notificationRef;
  final Map<String, dynamic> notificationData;

  const NotificationDetailScreen({
    super.key,
    required this.notificationRef,
    required this.notificationData,
  });

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _orderData;
  bool _isRead = false;

  @override
  void initState() {
    super.initState();
    final data = widget.notificationData;
    _isRead = data['isRead'] == true;

    final orderId = data['orderId'] as String?;
    if (orderId != null && orderId.isNotEmpty) {
      _loadOrder(orderId);
    }
  }

  Future<void> _loadOrder(String orderId) async {
    try {
      final snap = await _firestore.collection('orders').doc(orderId).get();
      if (snap.exists) {
        setState(() {
          _orderData = snap.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      debugPrint('Failed to load order: $e');
    }
  }

  Future<void> _setRead(bool read) async {
    try {
      await widget.notificationRef.update({'isRead': read});
      setState(() {
        _isRead = read;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(read ? 'Marked as read' : 'Marked as unread')),
        );
      }
    } catch (e) {
      debugPrint('Failed to update read status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update read status')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.notificationData;
    final Timestamp? ts = data['createdAt'] as Timestamp?;
    final created = ts != null
        ? DateFormat('MM/dd/yy hh:mm a').format(ts.toDate())
        : '';

    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    data['title'] ?? 'No Title',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: _isRead ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isRead ? Icons.mark_email_read : Icons.mark_email_unread,
                  color: _isRead ? Colors.grey : Colors.deepPurple,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(data['body'] ?? ''),
            const SizedBox(height: 12),
            Text(
              created,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            if (_orderData != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Order Details',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('Order ID: ${widget.notificationData['orderId']}'),
              Text('Status: ${_orderData!['status'] ?? 'Unknown'}'),
              Text('Total: ₱${(_orderData!['totalPrice'] ?? 0).toString()}'),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _setRead(true),
                    child: const Text('Mark as read'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _setRead(false),
                    child: const Text('Mark as unread'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
