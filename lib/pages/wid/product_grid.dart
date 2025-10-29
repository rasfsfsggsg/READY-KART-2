import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ready_cart/pages/cart_tab.dart';
import 'package:ready_cart/pages/widgets/cart_manager.dart';
import 'product_tile.dart';
import '../product_details_page.dart';

class ProductGrid extends StatelessWidget {
  final String searchQuery;
  final String? categoryId;
  const ProductGrid({
    required this.searchQuery,
    required this.categoryId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cartManager = CartManager();
    final isWide = MediaQuery.of(context).size.width > 900;

    Query col = FirebaseFirestore.instance.collection('products');
    if (categoryId != null) {
      col = col.where('categoryId', isEqualTo: categoryId);
    }

    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: col.snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            }

            var docs = snap.data!.docs;

            // 🔍 Filter by search query
            if (searchQuery.isNotEmpty) {
              docs = docs.where((d) {
                final data = d.data() as Map<String, dynamic>;
                final name = (data['name'] ?? '').toString().toLowerCase();
                return name.contains(searchQuery.toLowerCase());
              }).toList();
            }

            if (docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'No matching products found',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 2, // ✅ Responsive column count
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: isWide ? 0.72 : 0.68,
                ),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final id = docs[i].id;
                  final inCart = cartManager.cart.containsKey(id);
                  final cartQty = inCart
                      ? cartManager.cart[id]!['qty'] as int
                      : 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ProductDetailsPage(product: d, productId: id),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0A0F1C), Color(0xFF14233A)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ✅ Product Image
                          Expanded(
                            flex: 6,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(12),
                              ),
                              child: Image.network(
                                d['imageUrl'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // ✅ Product Info
                          Expanded(
                            flex: 4,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['name'] ?? 'Product',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if ((d['quantity'] ?? '')
                                      .toString()
                                      .isNotEmpty)
                                    Text(
                                      d['quantity'].toString(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "₹${(d['price'] ?? 0).toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Colors.cyanAccent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      // ✅ Add/Remove Button
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.08),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                color: Colors.white,
                                              ),
                                              iconSize: 18,
                                              padding: EdgeInsets.zero,
                                              onPressed: () => cartManager
                                                  .removeFromCart(id),
                                            ),
                                            Text(
                                              "$cartQty",
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                color: Colors.white,
                                              ),
                                              iconSize: 18,
                                              padding: EdgeInsets.zero,
                                              onPressed: () =>
                                                  cartManager.addToCart(id, d),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
