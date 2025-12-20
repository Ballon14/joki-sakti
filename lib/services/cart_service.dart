import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save cart item to Firestore DATABASE
  Future<void> saveCartItem(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      print('💾 [DATABASE] Saving to Firestore: users/$userId/cart/$productId');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .set({
        'productId': productId,
        'quantity': quantity,
        'addedAt': FieldValue.serverTimestamp(),
      });
      print('✅ [DATABASE] Successfully saved to Firestore!');
      print('   Path: users/$userId/cart/$productId');
      print('   Data: {productId: $productId, quantity: $quantity}');
    } catch (e) {
      print('❌ [DATABASE] Failed to save to Firestore: $e');
      throw Exception('Failed to save cart item: ${e.toString()}');
    }
  }

  // Remove cart item from Firestore DATABASE
  Future<void> removeCartItem(String userId, String productId) async {
    try {
      print('🗑️ [DATABASE] Removing from Firestore: users/$userId/cart/$productId');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
      print('✅ [DATABASE] Successfully removed from Firestore!');
    } catch (e) {
      print('❌ [DATABASE] Failed to remove from Firestore: $e');
      throw Exception('Failed to remove cart item: ${e.toString()}');
    }
  }

  // Clear all cart items for a user from DATABASE
  Future<void> clearCart(String userId) async {
    try {
      print('🧹 [DATABASE] Clearing all cart from Firestore: users/$userId/cart');
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart');
      
      final snapshot = await cartRef.get();
      print('   Found ${snapshot.docs.length} items to delete');
      
      // Delete all documents in batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      print('✅ [DATABASE] Successfully cleared ${snapshot.docs.length} items from Firestore!');
    } catch (e) {
      print('❌ [DATABASE] Failed to clear cart from Firestore: $e');
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  // Get user cart as stream (real-time updates from DATABASE)
  Stream<Map<String, int>> getUserCart(String userId) {
    print('📡 [DATABASE] Setting up real-time listener: users/$userId/cart');
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .snapshots()
        .map((snapshot) {
      final Map<String, int> cartItems = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        cartItems[data['productId'] as String] = data['quantity'] as int;
      }
      print('📡 [DATABASE] Real-time update: ${cartItems.length} items in cart');
      return cartItems;
    });
  }

  // Load cart items once (for initial load from DATABASE)
  Future<Map<String, int>> loadUserCart(String userId) async {
    try {
      print('📥 [DATABASE] Loading cart from Firestore: users/$userId/cart');
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      print('   Retrieved ${snapshot.docs.length} documents from Firestore');
      final Map<String, int> cartItems = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final productId = data['productId'] as String;
        final quantity = data['quantity'] as int;
        cartItems[productId] = quantity;
        print('   - Product: $productId, Quantity: $quantity');
      }
      print('✅ [DATABASE] Successfully loaded ${cartItems.length} items from Firestore!');
      return cartItems;
    } catch (e) {
      print('❌ [DATABASE] Error loading cart from Firestore: $e');
      return {};
    }
  }
}
