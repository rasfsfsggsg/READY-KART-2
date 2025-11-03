import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ready_cart/pages/BillDetailsPage.dart';
import 'package:ready_cart/pages/widgets/cart_manager.dart';
import 'package:ready_cart/pages/removed_items_page.dart';

class CartTab extends StatefulWidget {
  const CartTab({super.key});

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  final cartManager = CartManager();
  final List<Map<String, dynamic>> removedItems = [];
  bool _removedPopupVisible = false;

  @override
  void initState() {
    super.initState();
    cartManager.addListener(_update);
  }

  @override
  void dispose() {
    cartManager.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  void _showRemovedPopup() {
    setState(() => _removedPopupVisible = true);
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _removedPopupVisible = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = cartManager.items;
    final isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'My Cart',
          style: TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                  items.isEmpty
                      ? const Center(
                          child: Text(
                            "🛒 Your Cart is Empty",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
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
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.white24,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
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
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.white,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (weight.isNotEmpty)
                                                  Text(
                                                    weight,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.white70,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.white
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.white24,
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
                                                      onPressed: () {
                                                        if (qty <= 1) {
                                                          cartManager
                                                              .removeFromCart(
                                                                id,
                                                              );
                                                          setState(() {
                                                            removedItems.add({
                                                              'key': id,
                                                              'product':
                                                                  product,
                                                              'qty': qty,
                                                              'price': price,
                                                            });
                                                          });
                                                          _showRemovedPopup();
                                                        } else {
                                                          cartManager
                                                              .removeFromCart(
                                                                id,
                                                              );
                                                        }
                                                      },
                                                    ),
                                                    Text(
                                                      "$qty",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
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
                                                          cartManager.addToCart(
                                                            id,
                                                            product,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "₹${total.toStringAsFixed(0)}",
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.cyanAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),

                            /// ✅ Bottom Summary Bar
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
                                      Text(
                                        "Total: ₹${cartManager.totalPrice.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => BillDetailsPage(
                                                cartManager: cartManager,
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          "View Detailed Bill",
                                          style: TextStyle(
                                            color: Colors.cyanAccent,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                      ),
                                      onPressed: () {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                  /// 🧾 Removed Popup
                  if (_removedPopupVisible)
                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, -2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.remove_shopping_cart_outlined,
                                  color: Colors.redAccent,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "Product removed",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () async {
                                setState(() => _removedPopupVisible = false);
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => RemovedItemsPage(
                                      removedItems: removedItems,
                                      onRestore: (item) {
                                        final id = item['key'];
                                        final product = item['product'];
                                        cartManager.addToCart(id, product);
                                        setState(
                                          () => removedItems.remove(item),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text("✅ Product restored"),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "View Removed",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.cyan,
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
          ),
        ),
      ),
    );
  }
}
