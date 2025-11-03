import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ready_cart/pages/cart_tab.dart';
import 'package:ready_cart/pages/widgets/cart_manager.dart';
import 'package:ready_cart/pages/widgets/similar_products_inline.dart';

class ProductDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? product;
  final String productId;

  const ProductDetailsPage({super.key, this.product, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  final cartManager = CartManager();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Map<String, dynamic>? product;
  List<String> imageUrls = [];
  int _currentImageIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    cartManager.addListener(_update);
    _loadProductData();
  }

  @override
  void dispose() {
    cartManager.removeListener(_update);
    _autoSlideTimer?.cancel();
    super.dispose();
  }

  void _update() => setState(() {});

  Future<void> _loadProductData() async {
    try {
      final String id = widget.productId.isNotEmpty
          ? widget.productId
          : widget.product?['id'] ?? '';
      if (id.isEmpty) {
        setState(() => product = widget.product);
        return;
      }
      final doc = await _db.collection('products').doc(id).get();
      if (doc.exists) {
        setState(() {
          product = {...doc.data()!, 'id': id};
          imageUrls = List<String>.from(product?['imageUrls'] ?? []);
        });
      } else {
        setState(() {
          product = widget.product;
          imageUrls = List<String>.from(widget.product?['imageUrls'] ?? []);
        });
      }
      _startAutoSlider();
    } catch (e) {
      setState(() => product = widget.product);
    }
  }

  void _startAutoSlider() {
    _autoSlideTimer?.cancel();
    if (imageUrls.isEmpty) return;
    _autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % imageUrls.length;
        });
      }
    });
  }

  void _onImageTap(TapUpDetails details, double width) {
    if (imageUrls.isEmpty) return;
    final dx = details.localPosition.dx;
    setState(() {
      if (dx < width / 2) {
        _currentImageIndex =
            (_currentImageIndex - 1 + imageUrls.length) % imageUrls.length;
      } else {
        _currentImageIndex = (_currentImageIndex + 1) % imageUrls.length;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0A0F1C),
        body: Center(
          child: CircularProgressIndicator(color: Colors.cyanAccent),
        ),
      );
    }

    final id = product?['id'] ?? '';
    final title = product?['name'] ?? '';
    final price = double.tryParse(product?['price']?.toString() ?? '0') ?? 0.0;
    final qty = product?['quantity']?.toString() ?? '';
    final stock = int.tryParse(product?['stock']?.toString() ?? '0') ?? 0;
    final isOutOfStock = stock <= 0;
    final inCart = cartManager.cart.containsKey(id);

    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.cyanAccent),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // 🖼 Product Box
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildImageSection(context)),
                                Expanded(
                                  child: _buildDetailsSection(
                                    id,
                                    title,
                                    price,
                                    qty,
                                    isOutOfStock,
                                    inCart,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                _buildImageSection(context),
                                _buildDetailsSection(
                                  id,
                                  title,
                                  price,
                                  qty,
                                  isOutOfStock,
                                  inCart,
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 30),

                    // 🔄 Similar Products
                    if (product?['categoryId'] != null)
                      SimilarProductsInline(
                        categoryId: product!['categoryId'],
                        currentProductId: id,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),

      // 🧾 Bottom Cart Summary
      bottomNavigationBar: AnimatedBuilder(
        animation: cartManager,
        builder: (context, _) {
          if (cartManager.cart.isEmpty) return const SizedBox.shrink();
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              border: const Border(top: BorderSide(color: Colors.white24)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.cyanAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${cartManager.totalItems} items",
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "₹${cartManager.totalPrice.toStringAsFixed(2)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyanAccent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartTab()),
                    );
                  },
                  child: const Text("View Cart"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 🖼 Image Section (Square Box Style)
  Widget _buildImageSection(BuildContext context) {
    return GestureDetector(
      onTapUp: (d) => _onImageTap(d, MediaQuery.of(context).size.width),
      child: AspectRatio(
        aspectRatio: 8 / 6, // square-like ratio for clarity
        child: Container(
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.grey[900],
            border: Border.all(color: Colors.white10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              if (imageUrls.isNotEmpty)
                CachedNetworkImage(
                  imageUrl: imageUrls[_currentImageIndex],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                )
              else
                const Icon(Icons.image, color: Colors.white30, size: 60),
              if (imageUrls.length > 1)
                Positioned(
                  bottom: 8,
                  child: Row(
                    children: List.generate(
                      imageUrls.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _currentImageIndex == index ? 10 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentImageIndex == index
                              ? Colors.cyanAccent
                              : Colors.white24,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 🧾 Details Section
  Widget _buildDetailsSection(
    String id,
    String title,
    double price,
    String qty,
    bool isOutOfStock,
    bool inCart,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(qty, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Text(
            "₹${price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
            ),
          ),
          const SizedBox(height: 20),

          // 🛒 Cart Button
          if (isOutOfStock)
            Container(
              alignment: Alignment.center,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
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
          else
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyanAccent,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(
                inCart ? "View Cart" : "Add to Cart",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                if (!inCart) {
                  cartManager.addToCart(id, {...product!, 'id': id});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("✅ Added to cart successfully!"),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartTab()),
                  );
                }
              },
            ),

          const SizedBox(height: 24),

          // 📝 Description
          const Text(
            "Description",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product?['description'] ?? 'No description available.',
            style: const TextStyle(color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }
}
