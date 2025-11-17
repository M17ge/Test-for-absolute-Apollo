import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/credit_provider.dart';
import '../../models/credit_model.dart';
import '../../utils/helpers.dart';
import '../credits/credit_list_screen.dart';

class FinanceHomeScreen extends StatelessWidget {
  const FinanceHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final creditProvider = Provider.of<CreditProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finance Manager'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
                onTap: () async {
                  await authProvider.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacementNamed('/login');
                  }
                },
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finance Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  context,
                  'Pending Credits',
                  '${creditProvider.credits.where((c) => c.status == CreditStatus.pending).length}',
                  Icons.pending,
                  Colors.orange,
                ),
                _buildStatCard(
                  context,
                  'Active Credits',
                  '${creditProvider.credits.where((c) => c.status == CreditStatus.active).length}',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  context,
                  'Total Amount',
                  AppHelpers.formatCurrency(creditProvider.getTotalCreditAmount()),
                  Icons.monetization_on,
                  Colors.blue,
                ),
                _buildStatCard(
                  context,
                  'Amount Due',
                  AppHelpers.formatCurrency(creditProvider.getTotalAmountDue()),
                  Icons.warning,
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreditListScreen()),
                );
              },
              icon: const Icon(Icons.list),
              label: const Text('View All Credits'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
