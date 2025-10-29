import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ready_cart/pages/product_details_page.dart';
import 'package:ready_cart/pages/widgets/cart_manager.dart';
import 'package:ready_cart/pages/cart_tab.dart';

class SimilarProductsInline extends StatelessWidget {
  final String categoryId;
  final String currentProductId;

  const SimilarProductsInline({
    super.key,
    required this.categoryId,
    required this.currentProductId,
  });

  @override
  Widget build(BuildContext context) {
    final cartManager = CartManager();

    final prodsQuery = FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: categoryId);

    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: prodsQuery.snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Colors.cyanAccent),
                ),
              );
            }

            final docs = snap.data!.docs
                .where((doc) => doc.id != currentProductId)
                .toList();

            if (docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "No similar products available.",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final width = MediaQuery.of(context).size.width;
            int crossCount = 2;
            if (width > 900)
              crossCount = 4;
            else if (width > 600)
              crossCount = 3;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 8 / 10, // consistent visual height
                ),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final id = docs[i].id;
                  final img =
                      d['imageUrl'] ??
                      (d['imageUrls'] != null && d['imageUrls'].isNotEmpty
                          ? d['imageUrls'][0]
                          : '');
                  final title = d['name'] ?? '';
                  final price = d['price']?.toString() ?? '0';
                  final qty = d['quantity']?.toString() ?? '';
                  final stock =
                      int.tryParse(d['stock']?.toString() ?? '0') ?? 0;
                  final isOutOfStock = stock <= 0;
                  final inCart = cartManager.cart.containsKey(id);

                  return _ModernProductCard(
                    img: img,
                    title: title,
                    qty: qty,
                    price: price,
                    inCart: inCart,
                    availableStock: stock,
                    onAddToCart: () => cartManager.addToCart(id, d),
                    onViewCart: () => _viewCart(context),
                    onTapProduct: () => Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(product: d, productId: id),
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

  void _viewCart(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartTab()));
  }
}

class _ModernProductCard extends StatelessWidget {
  final String img, title, qty, price;
  final bool inCart;
  final int availableStock;
  final VoidCallback onAddToCart;
  final VoidCallback onViewCart;
  final VoidCallback onTapProduct;

  const _ModernProductCard({
    required this.img,
    required this.title,
    required this.qty,
    required this.price,
    required this.inCart,
    required this.availableStock,
    required this.onAddToCart,
    required this.onViewCart,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = availableStock <= 0;

    return GestureDetector(
      onTap: onTapProduct,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF14233A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Square Image Box (8:6 ratio)
            AspectRatio(
              aspectRatio: 8 / 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: img.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        placeholder: (context, _) => Container(
                          color: Colors.black12,
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.cyanAccent,
                            ),
                          ),
                        ),
                        errorWidget: (context, _, __) => const Icon(
                          Icons.broken_image,
                          color: Colors.white30,
                        ),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white30),
                      ),
              ),
            ),

            // 📋 Product Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      qty,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹$price',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.cyanAccent,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 🛒 Add / View / Out of Stock
                    if (isOutOfStock)
                      Container(
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.redAccent),
                        ),
                        child: const Text(
                          "Out of Stock",
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else if (!inCart)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyanAccent,
                          foregroundColor: Colors.black,
                          minimumSize: const Size(double.infinity, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: onAddToCart,
                        child: const Text(
                          "Add to Cart",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      )
                    else
                      TextButton(
                        onPressed: onViewCart,
                        child: const Text(
                          "View Cart",
                          style: TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
