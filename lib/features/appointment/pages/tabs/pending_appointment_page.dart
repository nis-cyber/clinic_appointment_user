import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PendingAppointmentTab extends StatefulWidget {
  @override
  _PendingAppointmentTabState createState() => _PendingAppointmentTabState();
}

class _PendingAppointmentTabState extends State<PendingAppointmentTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('appointments_pending')
            .snapshots(), // Fetch all appointments
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            if (kDebugMode) {
              print('Error: ${snapshot.error}');
            }
            return Center(
              child: Text('An error occurred: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var appointment = snapshot.data!.docs[index];
              return _buildAppointmentCard(appointment);
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(DocumentSnapshot appointment) {
    Map<String, dynamic> data = appointment.data() as Map<String, dynamic>;
    DateTime createdAt = (data['createdAt'] as Timestamp).toDate();

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
          ],
        ),
        trailing: _buildStatusIcon(data['status']),
        onTap: () => _showAppointmentDetails(context, data),
      ),
    );
  }

  Widget _buildStatusIcon(String status) {
    IconData iconData;
    Color color;

    switch (status.toLowerCase()) {
      case 'booked':
        iconData = Icons.event_available;
        color = Colors.green;
        break;
      case 'cancelled':
        iconData = Icons.event_busy;
        color = Colors.red;
        break;
      case 'completed':
        iconData = Icons.check_circle;
        color = Colors.blue;
        break;
      default:
        iconData = Icons.event_note;
        color = Colors.grey;
    }

    return Icon(iconData, color: color);
  }

  void _showAppointmentDetails(
      BuildContext context, Map<String, dynamic> appointmentData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Appointment Details'),
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
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            if (appointmentData['status'].toLowerCase() == 'booked')
              ElevatedButton(
                child: const Text('Cancel Appointment'),
                onPressed: () => _cancelAppointment(context, appointmentData),
              ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(
      BuildContext context, Map<String, dynamic> appointmentData) {
    // Implement appointment cancellation logic here
    // This should update the appointment status in Firestore and potentially
    // add the slot back to the doctor's available slots
    // After cancellation, close the dialog and show a confirmation message
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Appointment cancellation feature coming soon!')),
    );
  }
}
