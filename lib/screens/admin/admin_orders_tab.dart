import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../services/admin_service.dart';
import '../../services/notification_service.dart';
import '../../models/order.dart';

class AdminOrdersTab extends StatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  State<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends State<AdminOrdersTab> {
  final _adminService = AdminService();
  final _notificationService = NotificationService();
  OrderStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter chips
        Container(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _filterStatus == null,
                  onSelected: (selected) {
                    setState(() => _filterStatus = null);
                  },
                ),
                const SizedBox(width: 8),
                ...OrderStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(_getStatusText(status)),
                      selected: _filterStatus == status,
                      onSelected: (selected) {
                        setState(() => _filterStatus = selected ? status : null);
                      },
                      selectedColor: _getStatusColor(status).withValues(alpha: 0.3),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),

        // Orders list
        Expanded(
          child: StreamBuilder<List<OrderModel>>(
            stream: _adminService.getAllOrdersStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              var orders = snapshot.data ?? [];

              // Apply filter
              if (_filterStatus != null) {
                orders = orders.where((o) => o.status == _filterStatus).toList();
              }

              if (orders.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.receipt_long, size: 80, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders found',
                        style: TextStyle(fontSize: 18, color: AppTheme.darkGray),
                      ),
                    ],
                  ),
                );
              }

              final currencyFormatter = NumberFormat.currency(
                locale: 'id_ID',
                symbol: 'Rp ',
                decimalDigits: 0,
              );

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(order.status).withValues(alpha: 0.2),
                        child: Icon(
                          Icons.receipt,
                          color: _getStatusColor(order.status),
                        ),
                      ),
                      title: Text(
                        '${order.items.length} items',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, HH:mm').format(order.createdAt),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            currencyFormatter.format(order.totalAmount),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.warmBrown,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order.status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _getStatusText(order.status),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Items:',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              ...order.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    '${item.quantity}x ${item.productName} - ${currencyFormatter.format(item.price * item.quantity)}',
                                  ),
                                );
                              }),
                              const Divider(height: 24),
                              Text('Delivery: ${order.deliveryAddress}'),
                              Text('Payment: ${order.paymentMethod}'),
                              const SizedBox(height: 16),
                              
                              // Status update buttons
                              Wrap(
                                spacing: 8,
                                children: OrderStatus.values.map((status) {
                                  if (status == order.status) return const SizedBox();
                                  
                                  return ElevatedButton(
                                    onPressed: () => _updateStatus(order, status),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _getStatusColor(status),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                    child: Text(
                                      'Mark as ${_getStatusText(status)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _updateStatus(OrderModel order, OrderStatus newStatus) async {
    try {
      await _adminService.updateOrderStatus(order.id, newStatus);
      
      // Send notification to user
      await _notificationService.createOrderNotification(
        userId: order.userId,
        orderId: order.id,
        status: newStatus,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order status updated!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppTheme.warningOrange;
      case OrderStatus.processed:
        return Colors.blue;
      case OrderStatus.delivering:
        return Colors.purple;
      case OrderStatus.delivered:
        return AppTheme.successGreen;
      case OrderStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processed:
        return 'Processed';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
