import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/receipt_model.dart';

class ReceiptService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'receipts';

  Future<String> createReceipt(Receipt receipt) async {
    try {
      final docRef = await _firestore.collection(_collection).add(receipt.toMap());
      return docRef.id;
    } catch (e) {
      print('Create receipt error: $e');
      rethrow;
    }
  }

  Future<List<Receipt>> getAllReceipts() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Receipt.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all receipts error: $e');
      return [];
    }
  }

  Future<List<Receipt>> getReceiptsByFarmer(String farmerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Receipt.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get receipts by farmer error: $e');
      return [];
    }
  }

  Future<List<Receipt>> getReceiptsBySupplier(String supplierId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Receipt.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get receipts by supplier error: $e');
      return [];
    }
  }

  Future<Receipt?> getReceiptById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Receipt.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get receipt by id error: $e');
    }
    return null;
  }

  Future<Receipt?> getReceiptByEntity(String entityId, ReceiptType type) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('type', isEqualTo: type.toString().split('.').last)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Receipt.fromMap(querySnapshot.docs.first.data(), querySnapshot.docs.first.id);
      }
    } catch (e) {
      print('Get receipt by entity error: $e');
    }
    return null;
  }

  Future<void> approveReceipt(String receiptId, String financeManagerId, String financeManagerName) async {
    try {
      await _firestore.collection(_collection).doc(receiptId).update({
        'status': ReceiptStatus.approved.toString().split('.').last,
        'financeManagerId': financeManagerId,
        'financeManagerName': financeManagerName,
        'approvedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Approve receipt error: $e');
      rethrow;
    }
  }

  Future<void> markAsPaid(String receiptId) async {
    try {
      await _firestore.collection(_collection).doc(receiptId).update({
        'status': ReceiptStatus.paid.toString().split('.').last,
        'paidAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Mark as paid error: $e');
      rethrow;
    }
  }

  Future<void> cancelReceipt(String receiptId) async {
    try {
      await _firestore.collection(_collection).doc(receiptId).update({
        'status': ReceiptStatus.cancelled.toString().split('.').last,
      });
    } catch (e) {
      print('Cancel receipt error: $e');
      rethrow;
    }
  }
}
