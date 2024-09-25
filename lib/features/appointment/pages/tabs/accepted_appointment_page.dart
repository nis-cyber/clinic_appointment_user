import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyAcceptedAppointmentsPage extends StatelessWidget {
  const MyAcceptedAppointmentsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color.fromARGB(255, 173, 205, 204)!,
              const Color.fromARGB(255, 180, 152, 225)!
            ],
          ),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('accepted_appointments')
              .where('user_id', isEqualTo: currentUser) // Filter by user ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No accepted appointments.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var appointmentData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                return Card(
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(
                            'Doctor Name', appointmentData['doctor_name']),
                        _buildInfoRow(
                            'Specialty', appointmentData['doctor_specialty']),
                        _buildInfoRow(
                            'Date',
                            DateFormat('yyyy-MM-dd').format(
                                DateTime.parse(appointmentData['date']))),
                        _buildInfoRow(
                            'Time Slot', appointmentData['time_slot']),
                        _buildInfoRow('Status', appointmentData['status']),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
