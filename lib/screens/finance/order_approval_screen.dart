import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import '../../services/order_service.dart';
import '../../utils/helpers.dart';

class OrderApprovalScreen extends StatefulWidget {
  const OrderApprovalScreen({Key? key}) : super(key: key);

  @override
  State<OrderApprovalScreen> createState() => _OrderApprovalScreenState();
}

class _OrderApprovalScreenState extends State<OrderApprovalScreen> {
  final _orderService = OrderService();
  List<Order> _pendingOrders = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPendingOrders();
  }

  Future<void> _loadPendingOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders = await _orderService.getPendingOrders();
      if (mounted) {
        setState(() {
          _pendingOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading orders: $e')),
        );
      }
    }
  }

  Future<void> _approveOrder(Order order) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;

    if (user == null) return;

    try {
      await _orderService.approveOrderPayment(
        order.id,
        user.id,
        user.name,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order approved and receipt generated'),
            backgroundColor: Colors.green,
          ),
        );
        _loadPendingOrders();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Payment Approvals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPendingOrders,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pendingOrders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag, size: 100, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'No pending orders',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text('Orders will appear here for approval'),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPendingOrders,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingOrders.length,
                    itemBuilder: (context, index) {
                      final order = _pendingOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                ),
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_bag, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Order #${order.id.substring(0, 8).toUpperCase()}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                Chip(
                  label: Text(
                    order.status.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(fontSize: 10),
                  ),
                  backgroundColor: Colors.orange,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const Divider(height: 24),
            _buildInfoRow('Customer', order.farmerName),
            _buildInfoRow('Items', '${order.items.length} products'),
            _buildInfoRow('Total Amount', AppHelpers.formatCurrency(order.totalAmount)),
            _buildInfoRow('Delivery Address', order.deliveryAddress),
            _buildInfoRow(
              'Order Date',
              AppHelpers.formatDate(order.createdAt),
            ),
            const SizedBox(height: 12),
            const Text(
              'Order Items:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text('${item.productName} x${item.quantity}'),
                      ),
                      Text(
                        AppHelpers.formatCurrency(item.totalPrice),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _approveOrder(order),
                icon: const Icon(Icons.check_circle),
                label: const Text('Approve Payment & Generate Receipt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
