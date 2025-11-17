import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/appointment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/appointment_model.dart';
import '../../models/user_model.dart';
import '../../utils/helpers.dart';
import 'package:uuid/uuid.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({Key? key}) : super(key: key);

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  CertificationType _selectedCertification = CertificationType.organicFarming;
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _requestPayment = false;
  final _courseFeeController = TextEditingController(text: '150.00');

  @override
  void dispose() {
    _locationController.dispose();
    _notesController.dispose();
    _courseFeeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getCertificationName(CertificationType type) {
    return type.toString().split('.').last.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(0)}',
    ).trim();
  }

  Future<void> _bookAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
    final user = authProvider.appUser;

    if (user == null) return;

    final appointment = Appointment(
      id: const Uuid().v4(),
      farmerId: user.id,
      farmerName: user.name,
      trainerId: '', // Will be assigned by trainer/admin
      trainerName: 'TBD',
      certificationType: _selectedCertification,
      scheduledDate: _selectedDate,
      location: _locationController.text.trim(),
      status: AppointmentStatus.scheduled,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      certificateIssued: false,
      createdAt: DateTime.now(),
      courseFee: double.tryParse(_courseFeeController.text) ?? 0,
      paymentStatus: _requestPayment ? PaymentStatus.pending : PaymentStatus.approved,
    );

    final success = await appointmentProvider.createAppointment(appointment);

    if (mounted) {
      if (success) {
        AppHelpers.showSnackBar(
          context,
          _requestPayment 
            ? 'Appointment booked! Payment request sent to Finance Manager.'
            : 'Appointment booked successfully!',
        );
        Navigator.pop(context);
      } else {
        AppHelpers.showSnackBar(
          context,
          'Failed to book appointment. Please try again.',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Training Appointment'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Certification Training',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<CertificationType>(
                        value: _selectedCertification,
                        decoration: const InputDecoration(
                          labelText: 'Select Certification',
                          prefixIcon: Icon(Icons.school),
                        ),
                        items: CertificationType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(_getCertificationName(type)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCertification = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_today),
                        title: const Text('Preferred Date'),
                        subtitle: Text(AppHelpers.formatDate(_selectedDate)),
                        trailing: const Icon(Icons.edit),
                        onTap: () => _selectDate(context),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Enter preferred location',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Additional Notes (Optional)',
                          prefixIcon: Icon(Icons.note),
                          hintText: 'Any special requirements',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Information',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _courseFeeController,
                        decoration: const InputDecoration(
                          labelText: 'Course Fee',
                          prefixIcon: Icon(Icons.attach_money),
                          hintText: 'Enter course fee',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter course fee';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Request Payment Approval'),
                        subtitle: const Text(
                          'Finance Manager will review and approve payment',
                        ),
                        value: _requestPayment,
                        onChanged: (value) {
                          setState(() {
                            _requestPayment = value;
                          });
                        },
                      ),
                      if (_requestPayment)
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
                                  'Your payment request will be sent to the Finance Manager for approval.',
                                  style: TextStyle(color: Colors.blue[700]),
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
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Book Appointment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
