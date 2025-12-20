import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  final CartService _cartService = CartService();
  String? _userId;
  bool _isInitialized = false;

  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }

  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  bool get isInitialized => _isInitialized;

  bool productInCart(String productId) {
    return _items.containsKey(productId);
  }

  // Initialize cart for a specific user
  Future<void> initializeForUser(String userId) async {
    _userId = userId;
    _isInitialized = false;
    _items.clear();
    notifyListeners();
  }

  // Load cart from Firestore
  Future<void> loadCartFromFirestore(Map<String, Product> productsMap) async {
    if (_userId == null) {
      print('⚠️ Cannot load cart: userId is null');
      return;
    }

    try {
      final cartData = await _cartService.loadUserCart(_userId!);
      
      _items.clear();
      for (var entry in cartData.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        
        // Get product from the provided products map
        final product = productsMap[productId];
        if (product != null) {
          _items[productId] = CartItem(
            product: product,
            quantity: quantity,
          );
        } else {
          print('⚠️ Product $productId not found in catalog');
        }
      }
      
      _isInitialized = true;
      notifyListeners();
      print('✅ Cart loaded: ${_items.length} items');
    } catch (e) {
      print('❌ Error loading cart: $e');
      _isInitialized = true;
      notifyListeners();
    }
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
    
    // Sync to Firestore
    if (_userId != null) {
      _cartService.saveCartItem(_userId!, product.id, _items[product.id]!.quantity);
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
        
        // Sync to Firestore
        if (_userId != null) {
          _cartService.saveCartItem(_userId!, productId, quantity);
        }
        
        notifyListeners();
      }
    }
  }

  void removeItem(String productId) {
    _items.remove(productId);
    
    // Sync to Firestore
    if (_userId != null) {
      _cartService.removeCartItem(_userId!, productId);
    }
    
    notifyListeners();
  }

  Future<void> clear() async {
    _items.clear();
    
    // Sync to Firestore
    if (_userId != null) {
      await _cartService.clearCart(_userId!);
    }
    
    notifyListeners();
  }

  // Reset provider (on logout)
  void reset() {
    _userId = null;
    _items.clear();
    _isInitialized = false;
    notifyListeners();
  }
}
