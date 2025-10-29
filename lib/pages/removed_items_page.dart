import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RemovedItemsPage extends StatelessWidget {
  final List<Map<String, dynamic>> removedItems;
  final void Function(Map<String, dynamic>) onRestore;

  const RemovedItemsPage({
    super.key,
    required this.removedItems,
    required this.onRestore,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        title: const Text("Removed Products"),
        backgroundColor: const Color(0xFF14233A),
        foregroundColor: Colors.cyanAccent,
        elevation: 1,
      ),
      body: removedItems.isEmpty
          ? const Center(
              child: Text(
                "No removed products yet.",
                style: TextStyle(color: Colors.white70),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemCount: removedItems.length,
              itemBuilder: (context, index) {
                final item = removedItems[index];
                final product = item['product'] as Map<String, dynamic>;
                final name = product['name'] ?? 'Product';
                final img = product['imageUrl'] ?? '';
                final qty = item['qty'] ?? 1;
                final price = item['price'] ?? 0.0;

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14233A),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black38,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: CachedNetworkImage(
                          imageUrl: img,
                          height: 60,
                          width: 60,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            height: 60,
                            width: 60,
                            color: Colors.grey[800],
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Qty: $qty  •  ₹$price",
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          onRestore(item);
                          Navigator.pop(context);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.cyanAccent,
                        ),
                        child: const Text(
                          "Restore",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
