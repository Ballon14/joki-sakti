import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
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
  bool _cartProductsLoaded = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartScreen(),
    OrdersScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Load products into cart if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCartProducts();
    });
  }

  Future<void> _loadCartProducts() async {
    if (_cartProductsLoaded) return;

    final cart = Provider.of<CartProvider?>(context, listen: false);
    if (cart == null) {
      print('⚠️ No cart available');
      return;
    }

    if (cart.isLoading) {
      print('⏳ Cart is still loading...');
      return;
    }

    try {
      print('🔄 Loading products for cart...');
      final productService = ProductService();
      final products = await productService.getProducts().first;
      final productsMap = {for (var p in products) p.id: p};
      
      await cart.loadCartWithProducts(productsMap);
      
      setState(() {
        _cartProductsLoaded = true;
      });
    } catch (e) {
      print('❌ Error loading cart products: $e');
      setState(() {
        _cartProductsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider?>(context);
    
    // Cart might be null if user not logged in (shouldn't happen in MainScreen)
    if (cart == null) {
      return const Scaffold(
        body: Center(
          child: Text('Loading...'),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Consumer<CartProvider?>(
        builder: (context, cart, child) {
          final itemCount = cart?.itemCount ?? 0;
          
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
                icon: itemCount > 0
                    ? Badge(
                        label: Text('$itemCount'),
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

