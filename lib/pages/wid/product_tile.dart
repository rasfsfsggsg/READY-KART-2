import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductTile extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool inCart;
  final int cartQty;
  final VoidCallback onAdd;
  final VoidCallback onRemove;
  final VoidCallback onViewCart;
  final VoidCallback onTap;

  const ProductTile({
    required this.product,
    required this.inCart,
    required this.cartQty,
    required this.onAdd,
    required this.onRemove,
    required this.onViewCart,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name'] ?? '';
    final price = product['price']?.toString() ?? '';
    final qty = product['quantity']?.toString() ?? '';
    final img = product['imageUrl'] ?? '';
    final stock = int.tryParse(product['stock']?.toString() ?? '0') ?? 0;
    final isOutOfStock = stock <= 0;

    final isWide = MediaQuery.of(context).size.width > 900;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isWide ? 250 : double.infinity,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.05),
              Colors.white.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼 Product Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
                child: img.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.image_outlined,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),

            // 🏷 Product Details
            Padding(
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
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    qty,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹$price",
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 🛒 Add / Out of Stock / View Cart Button
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
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onAdd,
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyanAccent,
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: onViewCart,
                      child: const Text(
                        "Add to Cart",
                        style: TextStyle(fontWeight: FontWeight.bold),
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
