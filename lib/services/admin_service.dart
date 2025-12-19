import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';
import '../models/order.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ========== PRODUCT MANAGEMENT ==========

  /// Add new product
  Future<String> addProduct(Product product) async {
    try {
      final docRef = await _firestore.collection('products').add({
        'name': product.name,
        'description': product.description,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'stock': product.stock,
        'category': product.category,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  /// Update existing product
  Future<void> updateProduct(String productId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('products').doc(productId).update(updates);
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  /// Get all products stream
  Stream<List<Product>> getAllProductsStream() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // ========== ORDER MANAGEMENT ==========

  /// Get all orders stream
  Stream<List<OrderModel>> getAllOrdersStream() {
    return _firestore
        .collection('orders')
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort by createdAt descending
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  /// Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // ========== STATISTICS ==========

  /// Get dashboard statistics
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      // Get total products
      final productsSnapshot = await _firestore.collection('products').get();
      final totalProducts = productsSnapshot.docs.length;

      // Get all orders
      final ordersSnapshot = await _firestore.collection('orders').get();
      final allOrders = ordersSnapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();

      // Count pending orders
      final pendingOrders =
          allOrders.where((order) => order.status == OrderStatus.pending).length;

      // Calculate total revenue (from processed/delivering/delivered orders)
      final totalRevenue = allOrders
          .where((order) =>
              order.status == OrderStatus.processed ||
              order.status == OrderStatus.delivering ||
              order.status == OrderStatus.delivered)
          .fold(0.0, (sum, order) => sum + order.totalAmount);

      // Get recent orders (last 5)
      allOrders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final recentOrders = allOrders.take(5).toList();

      return {
        'totalProducts': totalProducts,
        'pendingOrders': pendingOrders,
        'totalOrders': allOrders.length,
        'totalRevenue': totalRevenue,
        'recentOrders': recentOrders,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: ${e.toString()}');
    }
  }
}
