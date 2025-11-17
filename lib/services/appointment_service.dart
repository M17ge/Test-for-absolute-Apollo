import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment_model.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'appointments';

  Future<List<Appointment>> getAllAppointments() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .orderBy('scheduledDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get all appointments error: $e');
      return [];
    }
  }

  Future<List<Appointment>> getAppointmentsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: userId)
          .orderBy('scheduledDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get appointments by user error: $e');
      return [];
    }
  }

  Future<List<Appointment>> getPendingAppointments(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: userId)
          .where('status', whereIn: ['scheduled', 'confirmed'])
          .orderBy('scheduledDate')
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get pending appointments error: $e');
      return [];
    }
  }

  Future<List<Appointment>> getPendingPaymentRequests() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('paymentStatus', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Appointment.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get pending payment requests error: $e');
      return [];
    }
  }

  Future<Appointment?> getAppointmentById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Appointment.fromMap(doc.data()!, doc.id);
      }
    } catch (e) {
      print('Get appointment by id error: $e');
    }
    return null;
  }

  Future<void> createAppointment(Appointment appointment) async {
    try {
      await _firestore.collection(_collection).add(appointment.toMap());
    } catch (e) {
      print('Create appointment error: $e');
      rethrow;
    }
  }

  Future<void> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      print('Update appointment status error: $e');
      rethrow;
    }
  }

  Future<void> approvePayment(String appointmentId, String financeManagerId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'paymentStatus': PaymentStatus.approved.toString().split('.').last,
        'financeManagerId': financeManagerId,
        'paymentApprovedDate': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Approve payment error: $e');
      rethrow;
    }
  }

  Future<void> rejectPayment(String appointmentId, String financeManagerId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'paymentStatus': PaymentStatus.rejected.toString().split('.').last,
        'financeManagerId': financeManagerId,
      });
    } catch (e) {
      print('Reject payment error: $e');
      rethrow;
    }
  }

  Future<void> markPaymentAsPaid(String appointmentId) async {
    try {
      await _firestore.collection(_collection).doc(appointmentId).update({
        'paymentStatus': PaymentStatus.paid.toString().split('.').last,
      });
    } catch (e) {
      print('Mark payment as paid error: $e');
      rethrow;
    }
  }
}
