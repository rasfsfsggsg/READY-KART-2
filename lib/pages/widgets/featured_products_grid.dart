import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ready_cart/pages/product_details_page.dart';
import 'package:ready_cart/pages/cart_tab.dart';
import 'cart_manager.dart';

class FeaturedProductsGrid extends StatelessWidget {
  const FeaturedProductsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final cartManager = CartManager();

    final prods = FirebaseFirestore.instance
        .collection('products')
        .where('isFeatured', isEqualTo: true);

    final isWide = MediaQuery.of(context).size.width > 900;

    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: prods.snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.cyanAccent),
              );
            }

            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return const Center(
                child: Text(
                  "No featured products found",
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: isWide ? WrapAlignment.start : WrapAlignment.center,
                children: docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  final id = doc.id;
                  final img = d['imageUrl'] ?? '';
                  final title = d['name'] ?? '';
                  final price = d['price']?.toString() ?? '0';
                  final qty = d['quantity']?.toString() ?? '';
                  final stock =
                      int.tryParse(d['stock']?.toString() ?? '0') ?? 0;
                  final isOutOfStock = stock <= 0;

                  final inCart = cartManager.cart.containsKey(id);
                  final cartQty = inCart
                      ? cartManager.cart[id]!['qty'] as int
                      : 0;

                  return _ProductCard(
                    width: isWide ? 280 : double.infinity,
                    img: img,
                    title: title,
                    qty: qty,
                    price: price,
                    inCart: inCart,
                    cartQty: cartQty,
                    availableStock: stock,
                    onAddToCart: () => cartManager.addToCart(id, d),
                    onRemoveFromCart: () => cartManager.removeFromCart(id),
                    onViewCart: () => _viewCart(context),
                    onTapProduct: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductDetailsPage(product: d, productId: id),
                      ),
                    ),
                  );
                }).toList(),
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

class _ProductCard extends StatelessWidget {
  final double width;
  final String img, title, qty, price;
  final bool inCart;
  final int cartQty;
  final int availableStock;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final VoidCallback onViewCart;
  final VoidCallback onTapProduct;

  const _ProductCard({
    required this.width,
    required this.img,
    required this.title,
    required this.qty,
    required this.price,
    required this.inCart,
    required this.cartQty,
    required this.availableStock,
    required this.onAddToCart,
    required this.onRemoveFromCart,
    required this.onViewCart,
    required this.onTapProduct,
  });

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = availableStock <= 0;

    return GestureDetector(
      onTap: onTapProduct,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: img.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: img,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Container(
                        height: 160,
                        color: Colors.grey[800],
                        child: const Icon(Icons.image, color: Colors.white54),
                      ),
                    )
                  : Container(height: 160, color: Colors.grey[800]),
            ),

            // Product Details
            Padding(
              padding: const EdgeInsets.all(12),
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
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    qty,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹$price',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Add to Cart / Out of Stock / View Cart
                  if (isOutOfStock)
                    Container(
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
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
                        minimumSize: const Size(double.infinity, 36),
                      ),
                      onPressed: onAddToCart,
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(color: Colors.black),
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
          ],
        ),
      ),
    );
  }
}
