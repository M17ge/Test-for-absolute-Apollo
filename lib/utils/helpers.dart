import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

class AppHelpers {
  // Format currency
  static String formatCurrency(double amount, {String symbol = '\$'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  // Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format date and time
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('MMM dd, yyyy hh:mm a').format(dateTime);
  }

  // Format phone number
  static String formatPhoneNumber(String phone) {
    if (phone.length == 10) {
      return '(${phone.substring(0, 3)}) ${phone.substring(3, 6)}-${phone.substring(6)}';
    }
    return phone;
  }

  // Validate email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate phone
  static bool isValidPhone(String phone) {
    return RegExp(r'^\d{10}$').hasMatch(phone.replaceAll(RegExp(r'[^\d]'), ''));
  }

  // Show snackbar
  static void showSnackBar(context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Calculate credit total with interest
  static double calculateCreditTotal(
      double amount, double interestRate, int months) {
    final monthlyRate = interestRate / 100 / 12;
    final totalInterest = amount * monthlyRate * months;
    return amount + totalInterest;
  }

  // Calculate monthly payment
  static double calculateMonthlyPayment(
      double amount, double interestRate, int months) {
    final total = calculateCreditTotal(amount, interestRate, months);
    return total / months;
  }
}
