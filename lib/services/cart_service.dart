import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save cart item to Firestore DATABASE
  Future<void> saveCartItem(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
      debugPrint(
          '💾 [DATABASE] Saving to Firestore: users/$userId/cart/$productId');
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
      debugPrint('✅ [DATABASE] Successfully saved to Firestore!');
      debugPrint('   Path: users/$userId/cart/$productId');
      debugPrint('   Data: {productId: $productId, quantity: $quantity}');
    } catch (e) {
      debugPrint('❌ [DATABASE] Failed to save to Firestore: $e');
      throw Exception('Failed to save cart item: ${e.toString()}');
    }
  }

  // Remove cart item from Firestore DATABASE
  Future<void> removeCartItem(String userId, String productId) async {
    try {
      debugPrint(
          '🗑️ [DATABASE] Removing from Firestore: users/$userId/cart/$productId');
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
      debugPrint('✅ [DATABASE] Successfully removed from Firestore!');
    } catch (e) {
      debugPrint('❌ [DATABASE] Failed to remove from Firestore: $e');
      throw Exception('Failed to remove cart item: ${e.toString()}');
    }
  }

  // Clear all cart items for a user from DATABASE
  Future<void> clearCart(String userId) async {
    try {
      debugPrint(
          '🧹 [DATABASE] Clearing all cart from Firestore: users/$userId/cart');
      final cartRef =
          _firestore.collection('users').doc(userId).collection('cart');

      final snapshot = await cartRef.get();
      debugPrint('   Found ${snapshot.docs.length} items to delete');

      // Delete all documents in batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint(
          '✅ [DATABASE] Successfully cleared ${snapshot.docs.length} items from Firestore!');
    } catch (e) {
      debugPrint('❌ [DATABASE] Failed to clear cart from Firestore: $e');
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  // Get user cart as stream (real-time updates from DATABASE)
  Stream<Map<String, int>> getUserCart(String userId) {
    debugPrint(
        '📡 [DATABASE] Setting up real-time listener: users/$userId/cart');
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
      debugPrint(
          '📡 [DATABASE] Real-time update: ${cartItems.length} items in cart');
      return cartItems;
    });
  }

  // Load cart items once (for initial load from DATABASE)
  Future<Map<String, int>> loadUserCart(String userId) async {
    try {
      debugPrint(
          '📥 [DATABASE] Loading cart from Firestore: users/$userId/cart');
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      debugPrint(
          '   Retrieved ${snapshot.docs.length} documents from Firestore');
      final Map<String, int> cartItems = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final productId = data['productId'] as String;
        final quantity = data['quantity'] as int;
        cartItems[productId] = quantity;
        debugPrint('   - Product: $productId, Quantity: $quantity');
      }
      debugPrint(
          '✅ [DATABASE] Successfully loaded ${cartItems.length} items from Firestore!');
      return cartItems;
    } catch (e) {
      debugPrint('❌ [DATABASE] Error loading cart from Firestore: $e');
      return {};
    }
  }
}
