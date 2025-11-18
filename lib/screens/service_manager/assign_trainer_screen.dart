import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../../services/appointment_service.dart';
import '../../services/record_service.dart';
import '../../models/record_model.dart';
import '../../utils/helpers.dart';
import 'package:uuid/uuid.dart';

class AssignTrainerScreen extends StatefulWidget {
  final Appointment appointment;

  const AssignTrainerScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AssignTrainerScreen> createState() => _AssignTrainerScreenState();
}

class _AssignTrainerScreenState extends State<AssignTrainerScreen> {
  final AuthService _authService = AuthService();
  final AppointmentService _appointmentService = AppointmentService();
  final RecordService _recordService = RecordService();
  
  List<AppUser> _trainers = [];
  AppUser? _selectedTrainer;
  bool _isLoading = true;
  bool _isAssigning = false;

  @override
  void initState() {
    super.initState();
    _loadTrainers();
  }

  Future<void> _loadTrainers() async {
    setState(() => _isLoading = true);
    _trainers = await _authService.getUsersByRole(UserRole.trainer);
    setState(() => _isLoading = false);
  }

  String _getCertificationName(CertificationType type) {
    return type.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  Future<void> _assignTrainer() async {
    if (_selectedTrainer == null) {
      AppHelpers.showSnackBar(context, 'Please select a trainer', isError: true);
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;
    if (user == null) return;

    setState(() => _isAssigning = true);

    try {
      // Update appointment with trainer info
      await _appointmentService.assignTrainer(
        widget.appointment.id,
        _selectedTrainer!.id,
        _selectedTrainer!.name,
      );

      // Create activity record
      final record = ActivityRecord(
        id: const Uuid().v4(),
        type: RecordType.trainerAssigned,
        userId: user.id,
        userName: user.name,
        userRole: user.role,
        entityId: widget.appointment.id,
        entityType: 'appointment',
        details: {
          'appointmentId': widget.appointment.id,
          'farmerId': widget.appointment.farmerId,
          'farmerName': widget.appointment.farmerName,
          'trainerId': _selectedTrainer!.id,
          'trainerName': _selectedTrainer!.name,
          'certificationType': widget.appointment.certificationType.toString().split('.').last,
        },
        timestamp: DateTime.now(),
        notes: 'Trainer assigned to certification course',
      );
      await _recordService.createRecord(record);

      if (mounted) {
        AppHelpers.showSnackBar(context, 'Trainer assigned successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Failed to assign trainer', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isAssigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Trainer'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Appointment Details
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Appointment Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(Icons.person, 'Farmer', widget.appointment.farmerName),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.school,
                            'Certification',
                            _getCertificationName(widget.appointment.certificationType),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.calendar_today,
                            'Scheduled',
                            AppHelpers.formatDate(widget.appointment.scheduledDate),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.location_on,
                            'Location',
                            widget.appointment.location,
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.attach_money,
                            'Course Fee',
                            AppHelpers.formatCurrency(widget.appointment.courseFee),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Select Trainer
                  Text(
                    'Select Trainer',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (_trainers.isEmpty)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.person_off, size: 60, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'No Trainers Available',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please register trainers first',
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
                    ..._trainers.map((trainer) => Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: _selectedTrainer?.id == trainer.id
                          ? Theme.of(context).primaryColor.withOpacity(0.1)
                          : null,
                      child: RadioListTile<AppUser>(
                        value: trainer,
                        groupValue: _selectedTrainer,
                        onChanged: (value) {
                          setState(() {
                            _selectedTrainer = value;
                          });
                        },
                        title: Text(
                          trainer.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(trainer.email),
                            Text(trainer.phone),
                          ],
                        ),
                        secondary: CircleAvatar(
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            trainer.name[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    )),

                  if (_trainers.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isAssigning ? null : _assignTrainer,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isAssigning
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text('Assign Trainer'),
                    ),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
