import 'package:flutter/material.dart';
import 'package:ready_cart/pages/cart_tab.dart';
import 'package:ready_cart/pages/widgets/cart_manager.dart';
import 'wid/search_bar.dart';
import 'wid/category_chips.dart';
import 'wid/product_grid.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  String _searchQuery = '';
  String? _selectedCategoryId;
  final CartManager cartManager = CartManager();

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Browse Products',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
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
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),

                        /// 🔍 Search Bar
                        SearchInput(
                          onChanged: (v) =>
                              setState(() => _searchQuery = v.trim()),
                        ),

                        const SizedBox(height: 16),

                        /// 🏷 Categories
                        CategoryChips(
                          selectedId: _selectedCategoryId,
                          onCategorySelected: (id) {
                            setState(() {
                              _selectedCategoryId = id == _selectedCategoryId
                                  ? null
                                  : id;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        /// 🧃 Product Grid
                        ProductGrid(
                          searchQuery: _searchQuery,
                          categoryId: _selectedCategoryId,
                        ),

                        const SizedBox(
                          height: 100,
                        ), // gap for bottom cart summary
                      ],
                    ),
                  ),

                  /// ✅ Bottom cart summary
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: AnimatedBuilder(
                      animation: cartManager,
                      builder: (context, _) {
                        if (cartManager.cart.isEmpty) {
                          return const SizedBox.shrink();
                        }

                        return Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black26.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, -2),
                              ),
                            ],
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
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    "₹${cartManager.totalPrice.toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontWeight: FontWeight.bold,
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
                                    borderRadius: BorderRadius.circular(10),
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
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
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
