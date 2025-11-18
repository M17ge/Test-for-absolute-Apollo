import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/attendance_model.dart';

class AttendanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'attendance';

  Future<void> createAttendance(SessionAttendance attendance) async {
    try {
      await _firestore.collection(_collection).add(attendance.toMap());
    } catch (e) {
      print('Create attendance error: $e');
      rethrow;
    }
  }

  Future<List<SessionAttendance>> getAttendanceByAppointment(String appointmentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy('sessionDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionAttendance.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get attendance by appointment error: $e');
      return [];
    }
  }

  Future<List<SessionAttendance>> getAttendanceByTrainer(String trainerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('trainerId', isEqualTo: trainerId)
          .orderBy('sessionDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionAttendance.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get attendance by trainer error: $e');
      return [];
    }
  }

  Future<List<SessionAttendance>> getAttendanceByFarmer(String farmerId) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('farmerId', isEqualTo: farmerId)
          .orderBy('sessionDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => SessionAttendance.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get attendance by farmer error: $e');
      return [];
    }
  }

  Future<void> markAttendance(
    String attendanceId,
    AttendanceStatus status, {
    String? notes,
  }) async {
    try {
      await _firestore.collection(_collection).doc(attendanceId).update({
        'status': status.toString().split('.').last,
        'notes': notes,
      });
    } catch (e) {
      print('Mark attendance error: $e');
      rethrow;
    }
  }

  Future<void> addSignature(
    String attendanceId, {
    String? farmerSignature,
    String? trainerSignature,
  }) async {
    try {
      final updates = <String, dynamic>{
        'signedAt': DateTime.now().toIso8601String(),
      };
      if (farmerSignature != null) {
        updates['farmerSignature'] = farmerSignature;
      }
      if (trainerSignature != null) {
        updates['trainerSignature'] = trainerSignature;
      }
      
      await _firestore.collection(_collection).doc(attendanceId).update(updates);
    } catch (e) {
      print('Add signature error: $e');
      rethrow;
    }
  }

  Future<void> updateAttendance(String attendanceId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection(_collection).doc(attendanceId).update(updates);
    } catch (e) {
      print('Update attendance error: $e');
      rethrow;
    }
  }
}
