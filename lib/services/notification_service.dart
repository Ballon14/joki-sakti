import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification.dart';
import '../models/order.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get notifications stream for a user
  Stream<List<NotificationModel>> getNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Get unread count
  Stream<int> getUnreadCountStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // Create notification
  Future<void> createNotification({
    required String userId,
    required String title,
    required String message,
    required NotificationType type,
    String? orderId,
  }) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'message': message,
      'type': type.name,
      'orderId': orderId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Create order notification
  Future<void> createOrderNotification({
    required String userId,
    required String orderId,
    required OrderStatus status,
  }) async {
    String title;
    String message;
    NotificationType type;

    switch (status) {
      case OrderStatus.pending:
        title = '🎉 Pesanan Diterima!';
        message = 'Pesanan Anda telah diterima dan sedang diproses.';
        type = NotificationType.orderCreated;
        break;
      case OrderStatus.processed:
        title = '👨‍🍳 Pesanan Diproses';
        message = 'Pesanan Anda sedang disiapkan oleh toko.';
        type = NotificationType.orderProcessed;
        break;
      case OrderStatus.delivering:
        title = '🚚 Pesanan Dikirim';
        message = 'Pesanan Anda dalam perjalanan!';
        type = NotificationType.orderDelivering;
        break;
      case OrderStatus.delivered:
        title = '✅ Pesanan Selesai';
        message = 'Pesanan Anda telah sampai. Selamat menikmati!';
        type = NotificationType.orderDelivered;
        break;
      case OrderStatus.cancelled:
        title = '❌ Pesanan Dibatalkan';
        message = 'Maaf, pesanan Anda telah dibatalkan.';
        type = NotificationType.orderCancelled;
        break;
    }

    await createNotification(
      userId: userId,
      title: title,
      message: message,
      type: type,
      orderId: orderId,
    );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    await _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Mark all as read
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }

  // Clear all notifications for user
  Future<void> clearAllNotifications(String userId) async {
    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();

    for (var doc in notifications.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}
