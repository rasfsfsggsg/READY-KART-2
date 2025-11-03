import 'package:flutter/material.dart';

class CartManager extends ChangeNotifier {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final Map<String, Map<String, dynamic>> cart = {};

  void addToCart(String id, Map<String, dynamic> product) {
    final price = double.tryParse(product['price'].toString()) ?? 0.0;
    if (cart.containsKey(id)) {
      cart[id]!['qty'] += 1;
    } else {
      cart[id] = {'product': product, 'qty': 1, 'price': price};
    }
    notifyListeners();
  }

  void removeFromCart(String id) {
    if (!cart.containsKey(id)) return;
    if (cart[id]!['qty'] > 1) {
      cart[id]!['qty'] -= 1;
    } else {
      cart.remove(id);
    }
    notifyListeners();
  }

  void deleteItem(String id) {
    cart.remove(id);
    notifyListeners();
  }

  int get totalItems {
    int count = 0;
    for (var item in cart.values) {
      count += item['qty'] as int;
    }
    return count;
  }

  double get totalPrice {
    double total = 0.0;
    for (var item in cart.values) {
      total += (item['price'] as double) * (item['qty'] as int);
    }
    return total;
  }

  List<MapEntry<String, Map<String, dynamic>>> get items =>
      cart.entries.toList();

  void clearCart() {
    cart.clear();
    notifyListeners();
  }
}
