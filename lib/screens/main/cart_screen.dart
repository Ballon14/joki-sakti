import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import '../../models/product.dart';
import '../../widgets/buttons/primary_button.dart';
import '../checkout/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _authService = AuthService();
  final _productService = ProductService();
  
  Map<String, Product> _productsMap = {};
  bool _productsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProducts().first;
      setState(() {
        _productsMap = {for (var p in products) p.id: p};
        _productsLoaded = true;
      });
      print('✅ Products loaded: ${_productsMap.length}');
    } catch (e) {
      print('❌ Error loading products: $e');
      setState(() {
        _productsLoaded = true;
      });
    }
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    if (newQuantity <= 0) {
      await _removeItem(productId);
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .update({'quantity': newQuantity});
  }

  Future<void> _removeItem(String productId) async {
    final userId = _authService.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(productId)
        .delete();
  }

  @override
  Widget build(BuildContext context) {
    final userId = _authService.currentUser?.uid;
    final currencyFormatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Text('Please login to view cart'),
        ),
      );
    }

    if (!_productsLoaded) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Cart'),
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // DIRECTLY STREAM FROM FIRESTORE DATABASE
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .doc(userId)
            .collection('cart')
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error state
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Get cart items from database
          final cartDocs = snapshot.data?.docs ?? [];
          
          print('📦 Cart from database: ${cartDocs.length} items');

          // Empty cart
          if (cartDocs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: AppTheme.warmBrown.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your cart is empty',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Let's find some fresh bread!",
                    style: TextStyle(
                      fontSize: 14,
                      color: AppTheme.darkGray,
                    ),
                  ),
                ],
              ),
            );
          }

          // Build cart items list from database
          final List<_CartItemData> cartItems = [];
          double totalAmount = 0;

          for (var doc in cartDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final productId = data['productId'] as String;
            final quantity = data['quantity'] as int;
            
            final product = _productsMap[productId];
            if (product != null) {
              cartItems.add(_CartItemData(
                product: product,
                quantity: quantity,
              ));
              totalAmount += product.price * quantity;
            }
          }

          print('🛒 Valid cart items: ${cartItems.length}');

          if (cartItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 100,
                    color: AppTheme.warmBrown.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Products not available',
                    style: TextStyle(fontSize: 18, color: AppTheme.darkGray),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${cartDocs.length} items in DB but products may have been deleted',
                    style: const TextStyle(fontSize: 12, color: AppTheme.darkGray),
                  ),
                ],
              ),
            );
          }

          // Show cart items
          return Column(
            children: [
              // Cart Items List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartItems[index];
                    final product = cartItem.product;

                    return Dismissible(
                      key: Key(product.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.errorRed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      onDismissed: (_) {
                        _removeItem(product.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${product.name} removed from cart'),
                            backgroundColor: AppTheme.darkGray,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              // Product Image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: product.imageUrl,
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    color: AppTheme.lightGray,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    color: AppTheme.lightGray,
                                    child: const Icon(
                                      Icons.bakery_dining,
                                      color: AppTheme.warmBrown,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Product Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: AppTheme.warmBrown,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currencyFormatter.format(product.price),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.softOrange,
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Quantity Controls
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: AppTheme.warmBrown,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              _updateQuantity(
                                                product.id,
                                                cartItem.quantity - 1,
                                              );
                                            },
                                            child: const SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: Icon(
                                                Icons.remove,
                                                size: 18,
                                                color: AppTheme.warmBrown,
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '${cartItem.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.warmBrown,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.softOrange,
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              _updateQuantity(
                                                product.id,
                                                cartItem.quantity + 1,
                                              );
                                            },
                                            child: const SizedBox(
                                              width: 32,
                                              height: 32,
                                              child: Icon(
                                                Icons.add,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Delete Button
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppTheme.errorRed,
                                ),
                                onPressed: () {
                                  _removeItem(product.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Summary Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: AppTheme.warmBeige,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Subtotal',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkGray,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warmBrown,
                          ),
                        ),
                        Text(
                          currencyFormatter.format(totalAmount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.softOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: 'Checkout',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const CheckoutScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Simple data class for cart items
class _CartItemData {
  final Product product;
  final int quantity;

  _CartItemData({
    required this.product,
    required this.quantity,
  });
}
