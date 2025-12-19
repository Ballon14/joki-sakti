import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool productInCart(String productId) {
    return _items.containsKey(productId);
  }

  void addItem(Product product, {int quantity = 1}) {
    if (_items.containsKey(product.id)) {
      // Update quantity
      int newQuantity = _items[product.id]!.quantity + quantity;
      
      // Check stock
      if (newQuantity > product.stock) {
        throw Exception('Insufficient stock');
      }
      
      _items[product.id]!.quantity = newQuantity;
    } else {
      // Check stock
      if (quantity > product.stock) {
        throw Exception('Insufficient stock');
      }
      
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
      );
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        // Check stock
        if (quantity > _items[productId]!.product.stock) {
          throw Exception('Insufficient stock');
        }
        
        _items[productId]!.quantity = quantity;
        notifyListeners();
      }
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
