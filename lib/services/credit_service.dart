import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/credit_model.dart';

class CreditService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'credits';

  Future<List<Credit>> getAllCredits() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Credit.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all credits error: $e');
      return [];
    }
  }

  Future<List<Credit>> getCreditsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: userId)
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Credit.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get credits by user error: $e');
      return [];
    }
  }

  Future<Credit?> getCreditById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Credit.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get credit by id error: $e');
    }
    return null;
  }

  Future<void> createCredit(Credit credit) async {
    try {
      await _firestore.collection(_collection).add(credit.toMap());
    } catch (e) {
      print('Create credit error: $e');
      rethrow;
    }
  }

  Future<void> approveCredit(String creditId, String financeManagerId) async {
    try {
      final approvalDate = DateTime.now();
      final credit = await getCreditById(creditId);
      
      if (credit != null) {
        final dueDate = approvalDate.add(Duration(days: credit.durationMonths * 30));
        
        await _firestore.collection(_collection).doc(creditId).update({
          'status': CreditStatus.approved.toString().split('.').last,
          'financeManagerId': financeManagerId,
          'approvalDate': approvalDate.toIso8601String(),
          'dueDate': dueDate.toIso8601String(),
        });
      }
    } catch (e) {
      print('Approve credit error: $e');
      rethrow;
    }
  }

  Future<void> rejectCredit(String creditId) async {
    try {
      await _firestore.collection(_collection).doc(creditId).update({
        'status': CreditStatus.rejected.toString().split('.').last,
      });
    } catch (e) {
      print('Reject credit error: $e');
      rethrow;
    }
  }

  Future<void> addPayment(String creditId, Payment payment) async {
    try {
      final credit = await getCreditById(creditId);
      if (credit != null) {
        final payments = [...credit.payments, payment];
        final amountPaid = credit.amountPaid + payment.amount;
        final amountDue = credit.amountDue - payment.amount;
        
        final updates = {
          'payments': payments.map((p) => p.toMap()).toList(),
          'amountPaid': amountPaid,
          'amountDue': amountDue,
        };

        if (amountDue <= 0) {
          updates['status'] = CreditStatus.paid.toString().split('.').last;
        }

        await _firestore.collection(_collection).doc(creditId).update(updates);
      }
    } catch (e) {
      print('Add payment error: $e');
      rethrow;
    }
  }

  Future<List<Credit>> getPendingCredits() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('status', isEqualTo: CreditStatus.pending.toString().split('.').last)
          .orderBy('requestDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Credit.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get pending credits error: $e');
      return [];
    }
  }
}
