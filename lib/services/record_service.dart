import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/record_model.dart';

class RecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'records';

  Future<void> createRecord(ActivityRecord record) async {
    try {
      await _firestore.collection(_collection).add(record.toMap());
    } catch (e) {
      print('Create record error: $e');
      rethrow;
    }
  }

  Future<List<ActivityRecord>> getAllRecords({
    int? limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore.collection(_collection).orderBy('timestamp', descending: true);

      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }
      if (endDate != null) {
        query = query.where('timestamp', isLessThanOrEqualTo: endDate.toIso8601String());
      }
      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ActivityRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Get all records error: $e');
      return [];
    }
  }

  Future<List<ActivityRecord>> getRecordsByType(RecordType type, {int? limit}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('type', isEqualTo: type.toString().split('.').last)
          .orderBy('timestamp', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => ActivityRecord.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Get records by type error: $e');
      return [];
    }
  }

  Future<List<ActivityRecord>> getRecordsByEntity(String entityId, String entityType) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('entityId', isEqualTo: entityId)
          .where('entityType', isEqualTo: entityType)
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ActivityRecord.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      print('Get records by entity error: $e');
      return [];
    }
  }

  Future<Map<String, int>> getRecordsSummary({DateTime? startDate, DateTime? endDate}) async {
    try {
      final records = await getAllRecords(startDate: startDate, endDate: endDate);
      final summary = <String, int>{};
      
      for (var record in records) {
        final typeKey = record.type.toString().split('.').last;
        summary[typeKey] = (summary[typeKey] ?? 0) + 1;
      }
      
      return summary;
    } catch (e) {
      print('Get records summary error: $e');
      return {};
    }
  }
}
