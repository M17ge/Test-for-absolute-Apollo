import 'package:flutter/foundation.dart';
import '../models/appointment_model.dart';
import '../services/appointment_service.dart';

class AppointmentProvider with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();
  List<Appointment> _appointments = [];
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _pendingPaymentRequests = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  List<Appointment> get pendingAppointments => _pendingAppointments;
  List<Appointment> get pendingPaymentRequests => _pendingPaymentRequests;
  bool get isLoading => _isLoading;

  Future<void> loadAppointments({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userId != null) {
        _appointments = await _appointmentService.getAppointmentsByUser(userId);
      } else {
        _appointments = await _appointmentService.getAllAppointments();
      }
    } catch (e) {
      print('Load appointments error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadPendingAppointments(String userId) async {
    try {
      _pendingAppointments = await _appointmentService.getPendingAppointments(userId);
      notifyListeners();
    } catch (e) {
      print('Load pending appointments error: $e');
    }
  }

  Future<void> loadPendingPaymentRequests() async {
    _isLoading = true;
    notifyListeners();

    try {
      _pendingPaymentRequests = await _appointmentService.getPendingPaymentRequests();
    } catch (e) {
      print('Load pending payment requests error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createAppointment(Appointment appointment) async {
    try {
      await _appointmentService.createAppointment(appointment);
      await loadAppointments(userId: appointment.farmerId);
      await loadPendingAppointments(appointment.farmerId);
      return true;
    } catch (e) {
      print('Create appointment error: $e');
      return false;
    }
  }

  Future<bool> updateAppointmentStatus(String appointmentId, AppointmentStatus status) async {
    try {
      await _appointmentService.updateAppointmentStatus(appointmentId, status);
      await loadAppointments();
      return true;
    } catch (e) {
      print('Update appointment status error: $e');
      return false;
    }
  }

  Future<bool> approvePayment(String appointmentId, String financeManagerId) async {
    try {
      await _appointmentService.approvePayment(appointmentId, financeManagerId);
      await loadPendingPaymentRequests();
      return true;
    } catch (e) {
      print('Approve payment error: $e');
      return false;
    }
  }

  Future<bool> rejectPayment(String appointmentId, String financeManagerId) async {
    try {
      await _appointmentService.rejectPayment(appointmentId, financeManagerId);
      await loadPendingPaymentRequests();
      return true;
    } catch (e) {
      print('Reject payment error: $e');
      return false;
    }
  }

  Appointment? getAppointmentById(String id) {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
