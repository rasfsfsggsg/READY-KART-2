import 'package:flutter/material.dart';

class CartController extends ChangeNotifier {
  final Map<String, Map<String, dynamic>> _cartItems = {};

  Map<String, Map<String, dynamic>> get items => _cartItems;

  bool isInCart(String id) => _cartItems.containsKey(id);

  double get totalPrice {
    double total = 0;
    for (var p in _cartItems.values) {
      total += (p['price'] * p['quantity']);
    }
    return total;
  }

  int get totalItems => _cartItems.length;

  void addToCart(String id, Map<String, dynamic> product) {
    if (!_cartItems.containsKey(id)) {
      _cartItems[id] = {
        'name': product['name'],
        'price': double.tryParse(product['price'].toString()) ?? 0.0,
        'imageUrl': product['imageUrl'],
        'quantity': 1,
      };
      notifyListeners();
    }
  }

  void removeFromCart(String id) {
    _cartItems.remove(id);
    notifyListeners();
  }

  void increaseQty(String id) {
    if (_cartItems.containsKey(id)) {
      _cartItems[id]!['quantity']++;
      notifyListeners();
    }
  }

  void decreaseQty(String id) {
    if (_cartItems.containsKey(id)) {
      if (_cartItems[id]!['quantity'] > 1) {
        _cartItems[id]!['quantity']--;
      } else {
        _cartItems.remove(id);
      }
      notifyListeners();
    }
  }
}
