import 'package:flutter/foundation.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService = OrderService();
  List<Order> _orders = [];
  bool _isLoading = false;
  List<OrderItem> _cart = [];

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  List<OrderItem> get cart => _cart;
  int get cartItemCount => _cart.length;
  double get cartTotal => _cart.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> loadOrders({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userId != null) {
        _orders = await _orderService.getOrdersByUser(userId);
      } else {
        _orders = await _orderService.getAllOrders();
      }
    } catch (e) {
      print('Load orders error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void addToCart(OrderItem item) {
    final existingIndex = _cart.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      final existing = _cart[existingIndex];
      _cart[existingIndex] = OrderItem(
        productId: existing.productId,
        productName: existing.productName,
        quantity: existing.quantity + item.quantity,
        unitPrice: existing.unitPrice,
        totalPrice: existing.unitPrice * (existing.quantity + item.quantity),
      );
    } else {
      _cart.add(item);
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, int quantity) {
    final index = _cart.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      final item = _cart[index];
      _cart[index] = OrderItem(
        productId: item.productId,
        productName: item.productName,
        quantity: quantity,
        unitPrice: item.unitPrice,
        totalPrice: item.unitPrice * quantity,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _cart.clear();
    notifyListeners();
  }

  Future<bool> placeOrder(Order order) async {
    try {
      await _orderService.createOrder(order);
      clearCart();
      await loadOrders(userId: order.farmerId);
      return true;
    } catch (e) {
      print('Place order error: $e');
      return false;
    }
  }

  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      await loadOrders();
      return true;
    } catch (e) {
      print('Update order status error: $e');
      return false;
    }
  }

  Future<bool> assignDriver(String orderId, String driverId) async {
    try {
      await _orderService.assignDriver(orderId, driverId);
      await loadOrders();
      return true;
    } catch (e) {
      print('Assign driver error: $e');
      return false;
    }
  }
}
