import 'package:flutter/foundation.dart';
import '../models/credit_model.dart';
import '../services/credit_service.dart';

class CreditProvider with ChangeNotifier {
  final CreditService _creditService = CreditService();
  List<Credit> _credits = [];
  bool _isLoading = false;

  List<Credit> get credits => _credits;
  bool get isLoading => _isLoading;

  Future<void> loadCredits({String? userId}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userId != null) {
        _credits = await _creditService.getCreditsByUser(userId);
      } else {
        _credits = await _creditService.getAllCredits();
      }
    } catch (e) {
      print('Load credits error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> requestCredit(Credit credit) async {
    try {
      await _creditService.createCredit(credit);
      await loadCredits(userId: credit.farmerId);
      return true;
    } catch (e) {
      print('Request credit error: $e');
      return false;
    }
  }

  Future<bool> approveCredit(String creditId, String financeManagerId) async {
    try {
      await _creditService.approveCredit(creditId, financeManagerId);
      await loadCredits();
      return true;
    } catch (e) {
      print('Approve credit error: $e');
      return false;
    }
  }

  Future<bool> rejectCredit(String creditId) async {
    try {
      await _creditService.rejectCredit(creditId);
      await loadCredits();
      return true;
    } catch (e) {
      print('Reject credit error: $e');
      return false;
    }
  }

  Future<bool> makePayment(String creditId, Payment payment) async {
    try {
      await _creditService.addPayment(creditId, payment);
      await loadCredits();
      return true;
    } catch (e) {
      print('Make payment error: $e');
      return false;
    }
  }

  Credit? getCreditById(String id) {
    try {
      return _credits.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  double getTotalCreditAmount() {
    return _credits
        .where((c) => c.status == CreditStatus.active || c.status == CreditStatus.approved)
        .fold(0, (sum, credit) => sum + credit.amount);
  }

  double getTotalAmountDue() {
    return _credits
        .where((c) => c.status == CreditStatus.active)
        .fold(0, (sum, credit) => sum + credit.amountDue);
  }
}
