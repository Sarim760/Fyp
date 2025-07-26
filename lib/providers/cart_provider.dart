import 'package:flutter/foundation.dart';

import '../model/cart_item.dart';
import '../service/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _service = CartService();

  List<CartItem> _items = [];
  bool _isLoading = false;
  String _error = '';

  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  String get error => _error;
  int get totalCount => _items.fold<int>(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _items.fold<double>(0, (sum, item) => sum + item.product.price * item.quantity);

  Future<void> refreshCart() async {
    _setLoading(true);
    try {
      _items = await _service.fetchCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      final ok = await _service.removeItemFromCart(itemId: itemId);
      if (ok) {
        _items.removeWhere((element) => element.product.id.toString() == itemId);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> decrementItem(String itemId) async {
    try {
      final ok = await _service.decrementItemQuantity(itemId: itemId);
      if (ok) {
        final index = _items.indexWhere((element) => element.product.id.toString() == itemId);
        if (index != -1) {
          if (_items[index].quantity > 1) {
            _items[index].quantity -= 1;
          } else {
            _items.removeAt(index);
          }
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> incrementItem(String itemId) async {
    try {
      final ok = await _service.addItemToCart(itemId: itemId, quantity: 1);
      if (ok) {
        final index = _items.indexWhere((element) => element.product.id.toString() == itemId);
        if (index != -1) {
          _items[index].quantity += 1;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeItemBySwipe(String itemId) async {
    await removeItem(itemId);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
} 