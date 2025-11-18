import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/attendance_model.dart';
import '../../services/attendance_service.dart';
import '../../services/record_service.dart';
import '../../models/record_model.dart';
import '../../utils/helpers.dart';
import 'package:uuid/uuid.dart';

class AttendanceSheetScreen extends StatefulWidget {
  final Appointment appointment;

  const AttendanceSheetScreen({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  State<AttendanceSheetScreen> createState() => _AttendanceSheetScreenState();
}

class _AttendanceSheetScreenState extends State<AttendanceSheetScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  final RecordService _recordService = RecordService();
  final _notesController = TextEditingController();
  
  AttendanceStatus _selectedStatus = AttendanceStatus.attended;
  int _durationMinutes = 60;
  bool _isSubmitting = false;
  List<SessionAttendance> _existingAttendance = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExistingAttendance();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingAttendance() async {
    setState(() => _isLoading = true);
    _existingAttendance = await _attendanceService.getAttendanceByAppointment(widget.appointment.id);
    setState(() => _isLoading = false);
  }

  String _getCertificationName(CertificationType type) {
    return type.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  Future<void> _submitAttendance() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.appUser;
    
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final attendance = SessionAttendance(
        id: const Uuid().v4(),
        appointmentId: widget.appointment.id,
        farmerId: widget.appointment.farmerId,
        farmerName: widget.appointment.farmerName,
        trainerId: user.id,
        trainerName: user.name,
        sessionDate: DateTime.now(),
        status: _selectedStatus,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        durationMinutes: _durationMinutes,
      );

      await _attendanceService.createAttendance(attendance);

      // Create activity record
      final record = ActivityRecord(
        id: const Uuid().v4(),
        type: RecordType.attendanceMarked,
        userId: user.id,
        userName: user.name,
        userRole: user.role,
        entityId: widget.appointment.id,
        entityType: 'appointment',
        details: {
          'appointmentId': widget.appointment.id,
          'farmerId': widget.appointment.farmerId,
          'farmerName': widget.appointment.farmerName,
          'status': _selectedStatus.toString().split('.').last,
          'durationMinutes': _durationMinutes,
        },
        timestamp: DateTime.now(),
      );
      await _recordService.createRecord(record);

      if (mounted) {
        AppHelpers.showSnackBar(context, 'Attendance marked successfully');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showSnackBar(context, 'Failed to mark attendance', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance Sheet'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Appointment Details Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Session Details',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildDetailRow(
                            Icons.school,
                            'Certification',
                            _getCertificationName(widget.appointment.certificationType),
                          ),
                          const SizedBox(height: 8),
                          _buildDetailRow(
                            Icons.person,
                            'Farmer',
                            widget.appointment.farmerName,
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Previous Attendance Records
                  if (_existingAttendance.isNotEmpty) ...[
                    Text(
                      'Previous Sessions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._existingAttendance.map((attendance) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: Icon(
                          attendance.status == AttendanceStatus.attended
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: attendance.status == AttendanceStatus.attended
                              ? Colors.green
                              : Colors.red,
                        ),
                        title: Text(AppHelpers.formatDate(attendance.sessionDate)),
                        subtitle: Text('${attendance.durationMinutes} minutes'),
                        trailing: Text(
                          attendance.status.toString().split('.').last.toUpperCase(),
                          style: TextStyle(
                            color: attendance.status == AttendanceStatus.attended
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )),
                    const SizedBox(height: 16),
                  ],

                  // Mark Attendance Form
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mark Attendance',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<AttendanceStatus>(
                            value: _selectedStatus,
                            decoration: const InputDecoration(
                              labelText: 'Attendance Status',
                              prefixIcon: Icon(Icons.how_to_reg),
                            ),
                            items: AttendanceStatus.values.map((status) {
                              return DropdownMenuItem(
                                value: status,
                                child: Text(
                                  status.toString().split('.').last.replaceAllMapped(
                                    RegExp(r'([A-Z])'),
                                    (match) => ' ${match.group(0)}',
                                  ).trim(),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            value: _durationMinutes,
                            decoration: const InputDecoration(
                              labelText: 'Session Duration',
                              prefixIcon: Icon(Icons.timer),
                            ),
                            items: [30, 60, 90, 120, 180].map((minutes) {
                              return DropdownMenuItem(
                                value: minutes,
                                child: Text('$minutes minutes'),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _durationMinutes = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _notesController,
                            decoration: const InputDecoration(
                              labelText: 'Notes (Optional)',
                              prefixIcon: Icon(Icons.note),
                              hintText: 'Any remarks about the session',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.blue[700]),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Digital signature feature for farmers and trainers coming soon!',
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitAttendance,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Submit Attendance'),
                  ),
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
