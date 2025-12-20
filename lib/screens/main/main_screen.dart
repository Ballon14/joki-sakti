import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import 'home_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  bool _isCartInitialized = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeCart();
  }

  Future<void> _initializeCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authService = AuthService();
    final productService = ProductService();
    final currentUser = authService.currentUser;

    if (currentUser != null && !cartProvider.isInitialized) {
      try {
        // Initialize cart for this user
        await cartProvider.initializeForUser(currentUser.uid);
        
        // Get all products to build the products map
        final products = await productService.getProducts().first;
        final productsMap = {for (var p in products) p.id: p};
        
        // Load cart from Firestore
        await cartProvider.loadCartFromFirestore(productsMap);
        
        setState(() {
          _isCartInitialized = true;
        });
      } catch (e) {
        print('Error initializing cart: $e');
        setState(() {
          _isCartInitialized = true;
        });
      }
    } else {
      setState(() {
        _isCartInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while cart initializes
    if (!_isCartInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, child) {
          return BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            items: [
              const BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: cart.itemCount > 0
                    ? Badge(
                        label: Text('${cart.itemCount}'),
                        child: const Icon(Icons.shopping_cart_rounded),
                      )
                    : const Icon(Icons.shopping_cart_rounded),
                label: 'Cart',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_rounded),
                label: 'Orders',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

