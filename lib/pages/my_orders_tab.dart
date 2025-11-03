import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MyOrdersTab extends StatelessWidget {
  const MyOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(
        child: Text(
          "⚠️ Please login to view your orders",
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      );
    }

    final orderStream = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .where('status', isEqualTo: 'Placed')
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color(0xFF14233A),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: orderStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.cyanAccent),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                '📦 No orders found',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: orders.length,
            itemBuilder: (context, i) {
              final order = orders[i].data() as Map<String, dynamic>;
              return OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderCard({required this.order, super.key});

  @override
  Widget build(BuildContext context) {
    final img = order['productImage'] ?? order['imageUrl'] ?? '';
    final name = order['productName'] ?? 'Unknown Product';
    final qty = order['quantity']?.toString() ?? '1';
    final total = order['totalPrice']?.toString() ?? '0';
    final timestamp = order['timestamp'] as Timestamp?;
    final date = timestamp != null
        ? '${timestamp.toDate().day}/${timestamp.toDate().month}/${timestamp.toDate().year}'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          // 🖼 Product Image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              bottomLeft: Radius.circular(12),
            ),
            child: img.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: img,
                    height: 110,
                    width: 110,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => Container(
                      height: 110,
                      width: 110,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, size: 40),
                    ),
                  )
                : Container(
                    height: 110,
                    width: 110,
                    color: Colors.grey[200],
                    child: const Icon(Icons.image_not_supported, size: 40),
                  ),
          ),

          // 🧾 Order Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Quantity: $qty',
                    style: const TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total: ₹$total',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Date: $date',
                    style: const TextStyle(color: Colors.black45, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Status: Placed ✅',
                    style: TextStyle(
                      color: Colors.blueGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
