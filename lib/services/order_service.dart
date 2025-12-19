import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create order
  Future<String> createOrder({
    required String userId,
    required List<CartItem> items,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    try {
      double totalAmount = items.fold(0.0, (sum, item) => sum + item.totalPrice);

      List<OrderItem> orderItems = items.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
        );
      }).toList();

      OrderModel order = OrderModel(
        id: '',
        userId: userId,
        items: orderItems,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress,
        paymentMethod: paymentMethod,
        status: OrderStatus.pending,
        createdAt: DateTime.now(),
      );

      DocumentReference docRef =
          await _firestore.collection('orders').add(order.toMap());

      // Update product stocks
      for (var item in items) {
        await _firestore.collection('products').doc(item.product.id).update({
          'stock': FieldValue.increment(-item.quantity),
        });
      }

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Get user orders
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        // Removed orderBy to avoid needing composite index
        .snapshots()
        .map((snapshot) {
      final orders = snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
      
      // Sort in memory instead
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    });
  }

  // Get order by ID
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('orders').doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }
}
