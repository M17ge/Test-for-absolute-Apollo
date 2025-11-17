import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';

  Future<List<Order>> getAllOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all orders error: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get orders by user error: $e');
      return [];
    }
  }

  Future<List<Order>> getOrdersByDriver(String driverId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('driverId', isEqualTo: driverId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get orders by driver error: $e');
      return [];
    }
  }

  Future<Order?> getOrderById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Order.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get order by id error: $e');
    }
    return null;
  }

  Future<void> createOrder(Order order) async {
    try {
      await _firestore.collection(_collection).add(order.toMap());
    } catch (e) {
      print('Create order error: $e');
      rethrow;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updates = {
        'status': status.toString().split('.').last,
      };

      if (status == OrderStatus.delivered) {
        updates['deliveredAt'] = DateTime.now().toIso8601String();
      }

      await _firestore.collection(_collection).doc(orderId).update(updates);
    } catch (e) {
      print('Update order status error: $e');
      rethrow;
    }
  }

  Future<void> assignDriver(String orderId, String driverId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'driverId': driverId,
        'status': OrderStatus.processing.toString().split('.').last,
      });
    } catch (e) {
      print('Assign driver error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getOrdersByStatus(OrderStatus status) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: status.toString().split('.').last)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get orders by status error: $e');
      return [];
    }
  }
}
