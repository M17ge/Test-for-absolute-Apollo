import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/appointment_provider.dart';
import '../../models/appointment_model.dart';
import '../../utils/helpers.dart';
import 'attendance_sheet_screen.dart';

class TrainerAppointmentsScreen extends StatefulWidget {
  final bool showAttendanceOnly;
  
  const TrainerAppointmentsScreen({
    Key? key,
    this.showAttendanceOnly = false,
  }) : super(key: key);

  @override
  State<TrainerAppointmentsScreen> createState() => _TrainerAppointmentsScreenState();
}

class _TrainerAppointmentsScreenState extends State<TrainerAppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    await Provider.of<AppointmentProvider>(context, listen: false).loadAppointments();
  }

  String _getCertificationName(CertificationType type) {
    return type.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  Color _getStatusColor(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return Colors.blue;
      case AppointmentStatus.confirmed:
        return Colors.orange;
      case AppointmentStatus.completed:
        return Colors.green;
      case AppointmentStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final appointmentProvider = Provider.of<AppointmentProvider>(context);
    final user = authProvider.appUser;

    // Filter appointments for this trainer
    final myAppointments = appointmentProvider.appointments
        .where((a) => a.trainerId == user?.id)
        .toList();

    // Further filter if showing attendance only
    final displayAppointments = widget.showAttendanceOnly
        ? myAppointments.where((a) => 
            a.status == AppointmentStatus.confirmed || 
            a.status == AppointmentStatus.completed
          ).toList()
        : myAppointments;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.showAttendanceOnly 
          ? 'Attendance & Sign Sheets' 
          : 'My Appointments'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadAppointments,
        child: displayAppointments.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      widget.showAttendanceOnly ? Icons.how_to_reg : Icons.event_busy,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.showAttendanceOnly 
                        ? 'No Sessions to Track'
                        : 'No Appointments Assigned',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.showAttendanceOnly
                        ? 'Confirmed sessions will appear here'
                        : 'Appointments will appear when assigned by Service Manager',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: displayAppointments.length,
                itemBuilder: (context, index) {
                  final appointment = displayAppointments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: widget.showAttendanceOnly
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AttendanceSheetScreen(
                                    appointment: appointment,
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    _getCertificationName(appointment.certificationType),
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    appointment.status.toString().split('.').last.toUpperCase(),
                                    style: TextStyle(
                                      color: _getStatusColor(appointment.status),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  appointment.farmerName,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Text(
                                  AppHelpers.formatDate(appointment.scheduledDate),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    appointment.location,
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                            if (appointment.certificateIssued) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.emoji_events, color: Colors.green[700], size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Certificate Issued',
                                      style: TextStyle(
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (widget.showAttendanceOnly) ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AttendanceSheetScreen(
                                        appointment: appointment,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.how_to_reg),
                                label: const Text('Mark Attendance'),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
