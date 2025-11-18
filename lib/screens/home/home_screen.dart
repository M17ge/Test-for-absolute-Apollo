import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../farmer/farmer_home_screen.dart';
import '../finance/finance_home_screen.dart';
import '../inventory/inventory_home_screen.dart';
import '../supplier/supplier_home_screen.dart';
import '../driver/driver_home_screen.dart';
import '../dispatch/dispatch_home_screen.dart';
import '../trainer/trainer_home_screen.dart';
import '../service_manager/service_manager_home_screen.dart';
import '../admin/admin_home_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.appUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Route to appropriate home screen based on user role
    switch (user.role) {
      case UserRole.farmer:
        return const FarmerHomeScreen();
      case UserRole.financeManager:
        return const FinanceHomeScreen();
      case UserRole.inventoryManager:
        return const InventoryHomeScreen();
      case UserRole.supplier:
        return const SupplierHomeScreen();
      case UserRole.driver:
        return const DriverHomeScreen();
      case UserRole.dispatchManager:
        return const DispatchHomeScreen();
      case UserRole.trainer:
        return const TrainerHomeScreen();
      case UserRole.serviceManager:
        return const ServiceManagerHomeScreen();
      case UserRole.admin:
        return const AdminHomeScreen();
      default:
        return const FarmerHomeScreen();
    }
  }
}
