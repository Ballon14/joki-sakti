import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Product>> getProducts() {
    return _firestore.collection('products').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => Product.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Get product by ID
  Future<Product?> getProductById(String id) async {
    try {
      DocumentSnapshot doc =
          await _firestore.collection('products').doc(id).get();
      if (doc.exists) {
        return Product.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  // Update product stock
  Future<void> updateStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
      });
    } catch (e) {
      throw Exception('Failed to update stock: ${e.toString()}');
    }
  }
}
