import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/restock_request_model.dart';

class RestockRequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'restock_requests';

  Future<String> createRestockRequest(RestockRequest request) async {
    try {
      final docRef = await _firestore.collection(_collection).add(request.toMap());
      return docRef.id;
    } catch (e) {
      print('Create restock request error: $e');
      rethrow;
    }
  }

  Future<List<RestockRequest>> getAllRestockRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RestockRequest.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all restock requests error: $e');
      return [];
    }
  }

  Future<List<RestockRequest>> getPendingRestockRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RestockRequest.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get pending restock requests error: $e');
      return [];
    }
  }

  Future<List<RestockRequest>> getRestockRequestsBySupplier(String supplierId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RestockRequest.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get restock requests by supplier error: $e');
      return [];
    }
  }

  Future<List<RestockRequest>> getRestockRequestsForFinanceApproval() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: 'invoiceGenerated')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => RestockRequest.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get restock requests for finance approval error: $e');
      return [];
    }
  }

  Future<void> approveRestockRequestBySupplier(
    String requestId,
    String supplierId,
    String supplierName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'approvedBySupplier',
        'supplierId': supplierId,
        'supplierName': supplierName,
        'approvedBySupplierAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Approve restock request error: $e');
      rethrow;
    }
  }

  Future<void> rejectRestockRequest(String requestId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'rejected',
        'rejectionReason': reason,
      });
    } catch (e) {
      print('Reject restock request error: $e');
      rethrow;
    }
  }

  Future<void> generateInvoice(String requestId, String invoiceId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'invoiceGenerated',
        'invoiceId': invoiceId,
        'invoiceGeneratedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Generate invoice error: $e');
      rethrow;
    }
  }

  Future<void> approveByFinanceManager(
    String requestId,
    String financeManagerId,
    String financeManagerName,
  ) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'approvedByFinance',
        'financeManagerId': financeManagerId,
        'financeManagerName': financeManagerName,
        'approvedByFinanceAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Approve by finance manager error: $e');
      rethrow;
    }
  }

  Future<void> markAsDispatched(String requestId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'dispatched',
        'dispatchedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Mark as dispatched error: $e');
      rethrow;
    }
  }

  Future<void> markAsCompleted(String requestId) async {
    try {
      await _firestore.collection(_collection).doc(requestId).update({
        'status': 'completed',
        'completedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Mark as completed error: $e');
      rethrow;
    }
  }

  Future<RestockRequest?> getRestockRequestById(String requestId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(requestId).get();
      if (doc.exists) {
        return RestockRequest.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get restock request by id error: $e');
    }
    return null;
  }
}
