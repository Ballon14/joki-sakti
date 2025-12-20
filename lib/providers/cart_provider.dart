import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final String userId;
  final CartService _cartService = CartService();
  final Map<String, CartItem> _items = {};
  bool _isInitialized = false;
  bool _isLoading = false;

  CartProvider({required this.userId}) {
    print('🛒 CartProvider created for user: $userId');
    _loadInitialCart();
  }

  Map<String, CartItem> get items => {..._items};
  int get itemCount => _items.length;
  int get totalQuantity {
    return _items.values.fold(0, (sum, item) => sum + item.quantity);
  }
  double get totalAmount {
    return _items.values.fold(0.0, (sum, item) => sum + item.totalPrice);
  }
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  bool productInCart(String productId) {
    return _items.containsKey(productId);
  }

  // Auto-load cart from Firestore on creation
  Future<void> _loadInitialCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      print('📥 Loading cart from Firestore for user: $userId');
      final cartData = await _cartService.loadUserCart(userId);
      
      if (cartData.isNotEmpty) {
        print('✅ Found ${cartData.length} items in Firestore cart');
        // Note: We'll need to fetch products to populate cart items
        // This will be handled by the UI layer providing products
      } else {
        print('📭 No cart items found in Firestore');
      }
      
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      print('✅ Cart initialization complete');
    } catch (e) {
      print('❌ Error loading cart: $e');
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load cart with product data
  Future<void> loadCartWithProducts(Map<String, Product> productsMap) async {
    if (_isInitialized && _items.isNotEmpty) {
      print('⏭️ Cart already loaded with products, skipping');
      return;
    }

    try {
      print('📥 Loading cart with product details for user: $userId');
      final cartData = await _cartService.loadUserCart(userId);
      
      _items.clear();
      int loadedCount = 0;
      int skippedCount = 0;

      for (var entry in cartData.entries) {
        final productId = entry.key;
        final quantity = entry.value;
        
        final product = productsMap[productId];
        if (product != null) {
          _items[productId] = CartItem(
            product: product,
            quantity: quantity,
          );
          loadedCount++;
          print('  ✓ Loaded: ${product.name} x$quantity');
        } else {
          skippedCount++;
          print('  ⚠️ Product $productId not found in catalog');
        }
      }
      
      _isInitialized = true;
      notifyListeners();
      print('✅ Cart loaded: $loadedCount items (skipped: $skippedCount)');
    } catch (e) {
      print('❌ Error loading cart with products: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  void addItem(Product product, {int quantity = 1}) {
    print('➕ Adding to cart: ${product.name} x$quantity (user: $userId)');
    
    if (_items.containsKey(product.id)) {
      int newQuantity = _items[product.id]!.quantity + quantity;
      
      if (newQuantity > product.stock) {
        print('❌ Insufficient stock for ${product.name}');
        throw Exception('Insufficient stock');
      }
      
      _items[product.id]!.quantity = newQuantity;
      print('  Updated quantity to: $newQuantity');
    } else {
      if (quantity > product.stock) {
        print('❌ Insufficient stock for ${product.name}');
        throw Exception('Insufficient stock');
      }
      
      _items[product.id] = CartItem(
        product: product,
        quantity: quantity,
      );
      print('  Added new item to cart');
    }
    
    // Sync to Firestore - userId is guaranteed to be set
    _cartService.saveCartItem(userId, product.id, _items[product.id]!.quantity).then((_) {
      print('✅ Saved to Firestore: ${product.name}');
    }).catchError((e) {
      print('❌ Failed to save to Firestore: $e');
    });
    
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (_items.containsKey(productId)) {
      if (quantity <= 0) {
        removeItem(productId);
      } else {
        if (quantity > _items[productId]!.product.stock) {
          throw Exception('Insufficient stock');
        }
        
        print('🔄 Updating quantity for $productId: $quantity (user: $userId)');
        _items[productId]!.quantity = quantity;
        
        _cartService.saveCartItem(userId, productId, quantity).then((_) {
          print('✅ Updated in Firestore');
        }).catchError((e) {
          print('❌ Failed to update in Firestore: $e');
        });
        
        notifyListeners();
      }
    }
  }

  void removeItem(String productId) {
    print('🗑️ Removing from cart: $productId (user: $userId)');
    _items.remove(productId);
    
    _cartService.removeCartItem(userId, productId).then((_) {
      print('✅ Removed from Firestore');
    }).catchError((e) {
      print('❌ Failed to remove from Firestore: $e');
    });
    
    notifyListeners();
  }

  Future<void> clear() async {
    print('🧹 Clearing cart for user: $userId');
    _items.clear();
    
    try {
      await _cartService.clearCart(userId);
      print('✅ Cart cleared from Firestore');
    } catch (e) {
      print('❌ Failed to clear cart from Firestore: $e');
    }
    
    notifyListeners();
  }

  @override
  void dispose() {
    print('🗑️ CartProvider disposed for user: $userId');
    super.dispose();
  }
}
