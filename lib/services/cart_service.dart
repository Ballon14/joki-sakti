import 'package:cloud_firestore/cloud_firestore.dart';

class CartService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save cart item to Firestore
  Future<void> saveCartItem(
    String userId,
    String productId,
    int quantity,
  ) async {
    try {
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
    } catch (e) {
      throw Exception('Failed to save cart item: ${e.toString()}');
    }
  }

  // Remove cart item from Firestore
  Future<void> removeCartItem(String userId, String productId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(productId)
          .delete();
    } catch (e) {
      throw Exception('Failed to remove cart item: ${e.toString()}');
    }
  }

  // Clear all cart items for a user
  Future<void> clearCart(String userId) async {
    try {
      final cartRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cart');
      
      final snapshot = await cartRef.get();
      
      // Delete all documents in batch
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to clear cart: ${e.toString()}');
    }
  }

  // Get user cart as stream (real-time updates)
  Stream<Map<String, int>> getUserCart(String userId) {
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
      return cartItems;
    });
  }

  // Load cart items once (for initial load)
  Future<Map<String, int>> loadUserCart(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .get();

      final Map<String, int> cartItems = {};
      for (var doc in snapshot.docs) {
        final data = doc.data();
        cartItems[data['productId'] as String] = data['quantity'] as int;
      }
      return cartItems;
    } catch (e) {
      print('Error loading cart: $e');
      return {};
    }
  }
}
