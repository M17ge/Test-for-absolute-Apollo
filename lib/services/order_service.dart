import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import 'product_service.dart';
import 'receipt_service.dart';
import 'record_service.dart';
import '../models/receipt_model.dart';
import '../models/record_model.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'orders';
  final _productService = ProductService();
  final _receiptService = ReceiptService();
  final _recordService = RecordService();

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

  Future<String> createOrder(Order order) async {
    try {
      final docRef = await _firestore.collection(_collection).add(order.toMap());
      
      // Reduce stock for each product in the order
      for (final item in order.items) {
        final product = await _productService.getProductById(item.productId);
        if (product != null) {
          final newStock = product.stockQuantity - item.quantity;
          await _productService.updateStock(item.productId, newStock);
        }
      }
      
      return docRef.id;
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

  Future<void> approveOrderPayment(
    String orderId,
    String financeManagerId,
    String financeManagerName,
  ) async {
    try {
      // Update order status to confirmed
      await updateOrderStatus(orderId, OrderStatus.confirmed);
      
      // Get order details
      final order = await getOrderById(orderId);
      if (order == null) return;
      
      // Generate receipt
      final receipt = Receipt(
        id: '',
        type: ReceiptType.farmer,
        relatedEntityId: orderId,
        amount: order.totalAmount,
        description: 'Order payment for ${order.items.length} items',
        status: ReceiptStatus.approved,
        createdAt: DateTime.now(),
        issuedTo: order.farmerName,
        issuedToId: order.farmerId,
        issuedBy: financeManagerName,
        issuedById: financeManagerId,
        financeManagerId: financeManagerId,
        financeManagerName: financeManagerName,
        financeManagerApprovedAt: DateTime.now(),
      );
      
      await _receiptService.createReceipt(receipt);
      
      // Create activity record
      await _recordService.createRecord(
        ActivityRecord(
          id: '',
          type: RecordType.orderApproval,
          userId: financeManagerId,
          userName: financeManagerName,
          description: 'Approved payment for order by ${order.farmerName}',
          relatedEntityId: orderId,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      print('Approve order payment error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getPendingOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Order.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get pending orders error: $e');
      return [];
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
