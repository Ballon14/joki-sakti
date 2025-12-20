import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';
import '../../services/admin_service.dart';
import '../../services/sound_service.dart';
import '../../services/notification_service.dart';
import '../../models/order.dart';
import '../../models/notification.dart' as notif;
import '../auth/login_screen.dart';
import 'admin_dashboard_tab.dart';
import 'admin_products_tab.dart';
import 'admin_orders_tab.dart';

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  State<AdminMainScreen> createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;
  final _authService = AuthService();
  final _adminService = AdminService();
  final _soundService = SoundService();
  final _notificationService = NotificationService();
  
  StreamSubscription<List<OrderModel>>? _ordersSubscription;
  int _previousPendingCount = -1; // -1 means not initialized yet
  int _newOrdersCount = 0;

  final List<Widget> _tabs = const [
    AdminDashboardTab(),
    AdminProductsTab(),
    AdminOrdersTab(),
  ];

  @override
  void initState() {
    super.initState();
    _soundService.init();
    _listenForNewOrders();
  }

  void _listenForNewOrders() {
    _ordersSubscription = _adminService.getAllOrdersStream().listen((orders) {
      final pendingCount = orders.where((o) => o.status == OrderStatus.pending).length;
      
      // Only play sound if there are MORE pending orders than before
      // And this is not the first load (-1 means first load)
      if (_previousPendingCount != -1 && pendingCount > _previousPendingCount) {
        // New order detected!
        final newOrders = pendingCount - _previousPendingCount;
        _onNewOrderReceived(newOrders);
      }
      
      _previousPendingCount = pendingCount;
    });
  }

  void _onNewOrderReceived(int count) async {
    // Play loud notification sound
    await _soundService.playNewOrderSound();
    
    setState(() {
      _newOrdersCount += count;
    });
    
    // Show snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.notifications_active, color: Colors.white),
              const SizedBox(width: 12),
              Text(
                count == 1 
                  ? '🔔 New order received!' 
                  : '🔔 $count new orders received!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'View',
            textColor: Colors.white,
            onPressed: () {
              setState(() => _currentIndex = 2); // Go to Orders tab
            },
          ),
        ),
      );
    }
    
    // Send notification to admin
    final adminId = _authService.currentUser?.uid;
    if (adminId != null) {
      await _notificationService.createNotification(
        userId: adminId,
        title: '🆕 Pesanan Baru!',
        message: count == 1 
          ? 'Ada 1 pesanan baru yang menunggu diproses.'
          : 'Ada $count pesanan baru yang menunggu diproses.',
        type: notif.NotificationType.general,
      );
    }
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: AppTheme.errorRed)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.softOrange,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'ADMIN',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 12),
            const Text('ROTIKU Dashboard'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _handleLogout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index == 2) {
              _newOrdersCount = 0; // Reset badge when viewing orders
            }
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              children: [
                const Icon(Icons.receipt_long),
                if (_newOrdersCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _newOrdersCount > 9 ? '9+' : '$_newOrdersCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}
