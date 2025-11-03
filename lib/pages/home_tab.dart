import 'package:flutter/material.dart';
import 'package:ready_cart/pages/cart_tab.dart';
import 'widgets/banner_slider.dart';
import 'widgets/section_title.dart';
import 'widgets/delivery_badge.dart';
import 'widgets/categories_list.dart';
import 'widgets/featured_products_grid.dart';
import 'widgets/cart_manager.dart';
import 'widgets/category_products_inline.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String? selectedCategoryId;
  final CartManager cartManager = CartManager();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
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
              constraints: const BoxConstraints(maxWidth: 1200),
              child: Column(
                children: [
                  /// 🔹 Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          const BannerSlider(),
                          const SizedBox(height: 20),

                          /// 🏷️ Categories
                          const SectionTitle(title: 'Shop by Category'),
                          const SizedBox(height: 12),
                          CategoriesList(
                            onCategorySelected: (catId) {
                              setState(() {
                                selectedCategoryId =
                                    (selectedCategoryId == catId)
                                    ? null
                                    : catId;
                              });
                            },
                            selectedId: selectedCategoryId,
                          ),

                          const SizedBox(height: 20),

                          /// 🛍 Products Section
                          if (selectedCategoryId == null) ...[
                            const SectionTitle(
                              title: 'Featured Products',
                              trailing: DeliveryBadge(),
                            ),
                            const SizedBox(height: 12),
                            const FeaturedProductsGrid(),
                          ] else ...[
                            SectionTitle(
                              title: 'Products',
                              trailing: TextButton(
                                onPressed: () {
                                  setState(() => selectedCategoryId = null);
                                },
                                child: const Text(
                                  "Clear Filter",
                                  style: TextStyle(color: Colors.cyanAccent),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CategoryProductsInline(
                              categoryId: selectedCategoryId!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  /// 🛒 Bottom Cart Summary
                  AnimatedBuilder(
                    animation: cartManager,
                    builder: (context, _) {
                      if (cartManager.cart.isEmpty)
                        return const SizedBox.shrink();

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.08),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            /// 🛒 Cart Info
                            Row(
                              children: [
                                const Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Colors.cyanAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  "${cartManager.totalItems} items",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "₹${cartManager.totalPrice.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.cyanAccent,
                                  ),
                                ),
                              ],
                            ),

                            /// 📦 View Cart Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.cyanAccent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CartTab(),
                                  ),
                                );
                              },
                              child: const Text(
                                "View Cart",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
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
