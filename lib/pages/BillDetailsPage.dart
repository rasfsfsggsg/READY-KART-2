import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ready_cart/pages/widgets/cart_manager.dart';

class BillDetailsPage extends StatelessWidget {
  final CartManager cartManager;

  const BillDetailsPage({super.key, required this.cartManager});

  @override
  Widget build(BuildContext context) {
    final items = cartManager.items;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Bill Details",
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0F1C), Color(0xFF14233A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        "🛒 No items in cart",
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              alignment: isWide
                                  ? WrapAlignment.start
                                  : WrapAlignment.center,
                              children: items.map((entry) {
                                final id = entry.key;
                                final item = entry.value;
                                final product =
                                    item['product'] as Map<String, dynamic>;
                                final qty = item['qty'] as int;
                                final price = item['price'] as double;
                                final total = price * qty;

                                final name = product['name'] ?? 'Product';
                                final weight =
                                    product['quantity']?.toString() ?? '';
                                final img = product['imageUrl'] ?? '';

                                return Container(
                                  width: isWide ? 350 : double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: CachedNetworkImage(
                                          imageUrl: img,
                                          height: 70,
                                          width: 70,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, __, ___) =>
                                              Container(
                                                height: 70,
                                                width: 70,
                                                color: Colors.grey[800],
                                                child: const Icon(
                                                  Icons.image,
                                                  color: Colors.white54,
                                                ),
                                              ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              name,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            if (weight.isNotEmpty)
                                              Text(
                                                weight,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            const SizedBox(height: 4),
                                            Text(
                                              "₹${price.toStringAsFixed(2)} x $qty",
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Colors.cyanAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Text(
                                        "₹${total.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.cyanAccent,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),

                        /// 🧾 Total Summary
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Subtotal",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    "₹${cartManager.totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(
                                height: 16,
                                thickness: 0.4,
                                color: Colors.white24,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    "Total (Including Taxes)",
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    "₹${cartManager.totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.cyanAccent,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.cyanAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Proceeding to pay ₹${cartManager.totalPrice.toStringAsFixed(2)}",
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Proceed to Pay",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
