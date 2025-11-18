import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/product_model.dart';
import '../../models/order_model.dart';
import '../../models/cart_model.dart';
import '../../utils/helpers.dart';
import '../products/product_list_screen.dart';
import '../orders/order_list_screen.dart';
import '../credits/credit_list_screen.dart';
import '../appointments/appointment_list_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({Key? key}) : super(key: key);

  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const FarmerDashboard(),
    const ProductListScreen(),
    const OrderListScreen(),
    const CreditListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Apollo Agriculture'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user?.name ?? 'Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  // Navigate to profile
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.event),
                  title: Text('Appointments'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentListScreen()),
                  );
                },
              ),
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.credit_card),
            label: 'Credits',
          ),
        ],
      ),
    );
  }
}

class FarmerDashboard extends StatelessWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome message
          Text(
            'Welcome, ${authProvider.appUser?.name ?? "Farmer"}!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Quick stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Active Orders',
                  '${orderProvider.orders.where((o) => o.status != OrderStatus.delivered && o.status != OrderStatus.cancelled).length}',
                  Icons.shopping_bag,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Credits',
                  AppHelpers.formatCurrency(creditProvider.getTotalCreditAmount()),
                  Icons.credit_card,
                  Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Quick actions
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildActionCard(
                context,
                'Browse Products',
                Icons.store,
                Colors.green,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProductListScreen()),
                  );
                },
              ),
              _buildActionCard(
                context,
                'My Orders',
                Icons.shopping_bag,
                Colors.blue,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const OrderListScreen()),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Request Credit',
                Icons.credit_card,
                Colors.orange,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CreditListScreen()),
                  );
                },
              ),
              _buildActionCard(
                context,
                'Book Training',
                Icons.event,
                Colors.purple,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AppointmentListScreen()),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 40),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty')),
      );
      return;
    }

    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter delivery address')),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);

    try {
      final user = authProvider.appUser!;
      
      // Create order items
      final orderItems = cartProvider.items.map((cartItem) {
        return OrderItem(
          productId: cartItem.productId,
          productName: cartItem.productName,
          quantity: cartItem.quantity,
          unitPrice: cartItem.price,
          totalPrice: cartItem.totalPrice,
        );
      }).toList();

      // Create order
      final order = Order(
        id: '',
        farmerId: user.id,
        farmerName: user.name,
        items: orderItems,
        totalAmount: cartProvider.totalAmount,
        status: OrderStatus.pending,
        deliveryAddress: _addressController.text,
        createdAt: DateTime.now(),
      );

      await orderProvider.createOrder(order);

      // Clear cart
      cartProvider.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order placed successfully! Pending payment approval.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isPlacingOrder = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping Cart'),
      ),
      body: cartProvider.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 100, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add products to get started'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartProvider.items.length,
                    itemBuilder: (context, index) {
                      final item = cartProvider.items[index];
                      return _buildCartItem(item, cartProvider);
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Delivery Address',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Total'),
                              Text(
                                AppHelpers.formatCurrency(cartProvider.totalAmount),
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green[700],
                                    ),
                              ),
                            ],
                          ),
                          ElevatedButton.icon(
                            onPressed: _isPlacingOrder ? null : _placeOrder,
                            icon: _isPlacingOrder
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.shopping_bag),
                            label: Text(_isPlacingOrder ? 'Placing...' : 'Place Order'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCartItem(CartItem item, CartProvider cartProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            if (item.imageUrl != null)
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(item.imageUrl!),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppHelpers.formatCurrency(item.price)} / ${item.unit}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppHelpers.formatCurrency(item.totalPrice),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => cartProvider.decrementQuantity(item.productId),
                      icon: const Icon(Icons.remove_circle_outline),
                      iconSize: 28,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => cartProvider.incrementQuantity(item.productId),
                      icon: const Icon(Icons.add_circle_outline),
                      iconSize: 28,
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => cartProvider.removeFromCart(item.productId),
                  icon: const Icon(Icons.delete, size: 16),
                  label: const Text('Remove'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
