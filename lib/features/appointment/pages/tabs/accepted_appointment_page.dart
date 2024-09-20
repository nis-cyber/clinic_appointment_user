import 'package:clinic_users/features/appointment/data/appointment_provider.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AcceptedAppointmentTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsyncValue = ref.watch(acceptedAppointmentsProvider);

    return Scaffold(
      body: appointmentsAsyncValue.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return const Center(child: Text('No accepted appointments.'));
          }
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              var appointment = appointments[index];
              return _buildAppointmentCard(context, appointment);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Text('Error: $error'),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, Map<String, dynamic> data) {
    DateTime createdAt = (data['createdAt'] as Timestamp).toDate();
    DateTime acceptedAt = (data['acceptedAt'] as Timestamp).toDate();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('Dr. ${data['doctorName']}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date: ${data['day']}'),
            Text('Time: ${data['slot']}'),
            Text('Status: ${data['status']}'),
            Text(
                'Booked on: ${DateFormat('MMM d, yyyy HH:mm').format(createdAt)}'),
            Text(
                'Accepted on: ${DateFormat('MMM d, yyyy HH:mm').format(acceptedAt)}'),
          ],
        ),
        trailing: _buildStatusIcon(data['status']),
        onTap: () => _showAppointmentDetails(context, data),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    return Icon(Icons.check_circle, color: Colors.green);
  }

  void _showAppointmentDetails(
      BuildContext context, Map<String, dynamic> appointmentData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Appointment Details'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Doctor: Dr. ${appointmentData['doctorName']}'),
              Text('Date: ${appointmentData['day']}'),
              Text('Time: ${appointmentData['slot']}'),
              Text('Status: ${appointmentData['status']}'),
              Text(
                  'Booked on: ${DateFormat('MMM d, yyyy HH:mm').format((appointmentData['createdAt'] as Timestamp).toDate())}'),
              Text(
                  'Accepted on: ${DateFormat('MMM d, yyyy HH:mm').format((appointmentData['acceptedAt'] as Timestamp).toDate())}'),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
