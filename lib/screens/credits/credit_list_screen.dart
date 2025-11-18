import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/credit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/credit_model.dart';
import '../../utils/helpers.dart';

class CreditListScreen extends StatefulWidget {
  const CreditListScreen({Key? key}) : super(key: key);

  @override
  State<CreditListScreen> createState() => _CreditListScreenState();
}

class _CreditListScreenState extends State<CreditListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final creditProvider = Provider.of<CreditProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      creditProvider.loadCredits(userId: authProvider.appUser?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final creditProvider = Provider.of<CreditProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Credits'),
      ),
      body: creditProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : creditProvider.credits.isEmpty
              ? const Center(child: Text('No credit requests'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: creditProvider.credits.length,
                  itemBuilder: (context, index) {
                    final credit = creditProvider.credits[index];
                    return CreditCard(credit: credit);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to request credit screen
          AppHelpers.showSnackBar(context, 'Request new credit feature');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class CreditCard extends StatelessWidget {
  final Credit credit;

  const CreditCard({Key? key, required this.credit}) : super(key: key);

  Color _getStatusColor(CreditStatus status) {
    switch (status) {
      case CreditStatus.pending:
        return Colors.orange;
      case CreditStatus.approved:
        return Colors.blue;
      case CreditStatus.rejected:
        return Colors.red;
      case CreditStatus.active:
        return Colors.green;
      case CreditStatus.paid:
        return Colors.grey;
      case CreditStatus.defaulted:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppHelpers.formatCurrency(credit.amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(credit.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    credit.status.toString().split('.').last.toUpperCase(),
                    style: TextStyle(
                      color: _getStatusColor(credit.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Purpose: ${credit.purpose}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Duration: ${credit.durationMonths} months',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              'Interest Rate: ${credit.interestRate}%',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (credit.status == CreditStatus.active) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Amount Due: ${AppHelpers.formatCurrency(credit.amountDue)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Paid: ${AppHelpers.formatCurrency(credit.amountPaid)}',
                    style: const TextStyle(color: Colors.green),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Requested: ${AppHelpers.formatDate(credit.requestDate)}',
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
