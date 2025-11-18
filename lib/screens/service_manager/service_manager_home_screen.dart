import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import 'assign_trainer_screen.dart';

class ServiceManagerHomeScreen extends StatefulWidget {
  const ServiceManagerHomeScreen({Key? key}) : super(key: key);

  @override
  State<ServiceManagerHomeScreen> createState() => _ServiceManagerHomeScreenState();
}

class _ServiceManagerHomeScreenState extends State<ServiceManagerHomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    await Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);

    // Filter appointments that need trainer assignment
    final pendingAssignments = appointmentProvider.appointments
        .where((a) => 
          a.trainerId.isEmpty && 
          a.paymentStatus == PaymentStatus.approved)
        .toList();

    final assignedAppointments = appointmentProvider.appointments
        .where((a) => a.trainerId.isNotEmpty)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Management Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            
            // Stats Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Pending Assignments',
                    '${pendingAssignments.length}',
                    Icons.pending_actions,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Assigned',
                    '$assignedAppointments',
                    Icons.assignment_turned_in,
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            Text(
              'Appointments Needing Trainer Assignment',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            if (pendingAssignments.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, size: 60, color: Colors.green[300]),
                        const SizedBox(height: 16),
                        Text(
                          'All Caught Up!',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'No appointments need trainer assignment',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...pendingAssignments.map((appointment) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.orange,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(appointment.farmerName),
                  subtitle: Text(
                    '${_getCertificationName(appointment.certificationType)}\nPayment: Approved',
                  ),
                  isThreeLine: true,
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssignTrainerScreen(
                            appointment: appointment,
                          ),
                        ),
                      ).then((_) => _loadAppointments());
                    },
                    child: const Text('Assign'),
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  String _getCertificationName(CertificationType type) {
    return type.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
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
