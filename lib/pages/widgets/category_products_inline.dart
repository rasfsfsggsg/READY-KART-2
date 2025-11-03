import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ready_cart/pages/product_details_page.dart';
import 'package:ready_cart/pages/cart_tab.dart';
import 'cart_manager.dart';

class CategoryProductsInline extends StatelessWidget {
  final String categoryId;
  const CategoryProductsInline({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final cartManager = CartManager();
    final prods = FirebaseFirestore.instance
        .collection('products')
        .where('categoryId', isEqualTo: categoryId);

    final isWide = MediaQuery.of(context).size.width > 900;

    return AnimatedBuilder(
      animation: cartManager,
      builder: (context, _) {
        return StreamBuilder<QuerySnapshot>(
          stream: prods.snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(color: Colors.cyanAccent),
                ),
              );
            }

            final docs = snap.data!.docs;
            if (docs.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    "No products found in this category.",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: docs.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isWide ? 4 : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.65,
                ),
                itemBuilder: (context, i) {
                  final d = docs[i].data() as Map<String, dynamic>;
                  final id = docs[i].id;

                  final img =
                      d['imageUrl'] ??
                      ((d['imageUrls']?.isNotEmpty ?? false)
                          ? d['imageUrls'][0]
                          : '');
                  final title = d['name'] ?? '';
                  final price = d['price']?.toString() ?? '0';
                  final qty = d['quantity']?.toString() ?? '';

                  final stock =
                      int.tryParse(d['stock']?.toString() ?? '0') ?? 0;
                  final inCart = cartManager.cart.containsKey(id);
                  final cartQty = inCart
                      ? cartManager.cart[id]!['qty'] as int
                      : 0;

                  return _ProductCard(
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

class _ProductCard extends StatelessWidget {
  final String img, title, qty, price;
  final bool inCart;
  final int cartQty;
  final int availableStock;
  final VoidCallback onAddToCart;
  final VoidCallback onRemoveFromCart;
  final VoidCallback onViewCart;
  final VoidCallback onTapProduct;

  const _ProductCard({
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
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  image: img.isNotEmpty
                      ? DecorationImage(
                          image: CachedNetworkImageProvider(img),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey[900],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  const SizedBox(height: 4),
                  Text(
                    '₹$price',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.cyanAccent,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Add to Cart / Out of Stock
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
                        foregroundColor: Colors.black,
                      ),
                      onPressed: onAddToCart,
                      child: const Text("Add to Cart"),
                    )
                  else
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: onViewCart,
                            child: const Text(
                              "View Cart",
                              style: TextStyle(color: Colors.cyanAccent),
                            ),
                          ),
                        ),
                      ],
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
