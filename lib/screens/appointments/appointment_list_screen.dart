import 'package:flutter/material.dart';

class AppointmentListScreen extends StatelessWidget {
  const AppointmentListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training Appointments'),
      ),
      body: const Center(
        child: Text('Appointments feature - Book training sessions for certifications'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to book appointment screen
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
