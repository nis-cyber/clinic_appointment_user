import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart';

class AppointmentPendingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? currentUserId =
        FirebaseAuth.instance.currentUser?.uid; // Get current user ID

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
              .collection('appointment_pending')
              .where('user_id', isEqualTo: currentUserId) // Filter by user ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No pending appointments.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var appointmentDoc = snapshot.data!.docs[index];
                var appointmentData =
                    appointmentDoc.data() as Map<String, dynamic>;

                return Card(
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
                            'User Name', appointmentData['user_name']),
                        _buildInfoRow(
                            'Phone Number', appointmentData['user_phone']),
                        _buildInfoRow(
                            'Date',
                            DateFormat('yyyy-MM-dd').format(
                                DateTime.parse(appointmentData['date']))),
                        _buildInfoRow(
                            'Time Slot', appointmentData['time_slot']),
                        _buildInfoRow('Document', appointmentData['document']),
                        _buildInfoRow('Status', appointmentData['status']),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            _cancelAppointment(
                              context,
                              appointmentDoc.id,
                              appointmentData['doctor_id'],
                              appointmentData['date'],
                              appointmentData['time_slot'],
                            );
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Cancel Appointment'),
                        ),
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

  Future<void> _cancelAppointment(
    BuildContext context,
    String appointmentId,
    String doctorId,
    String date,
    String timeSlot,
  ) async {
    try {
      // Delete the appointment from 'appointment_pending'
      await FirebaseFirestore.instance
          .collection('appointment_pending')
          .doc(appointmentId)
          .delete();

      // Fetch the doctor's document from Firestore
      DocumentSnapshot doctorSnapshot = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (doctorSnapshot.exists) {
        var doctorData = doctorSnapshot.data() as Map<String, dynamic>;

        // Restore the time slot to the doctor's availability
        if (doctorData['availableSlots'] != null) {
          List<dynamic> slots = doctorData['availableSlots'][date] ?? [];

          if (!slots.contains(timeSlot)) {
            slots.add(
                timeSlot); // Add the canceled time slot back to availability

            // Update the doctor's document with the restored time slot
            await FirebaseFirestore.instance
                .collection('doctors')
                .doc(doctorId)
                .update({
              'availableSlots.$date': slots,
            });
          }
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Appointment canceled successfully!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      // Handle any errors during the cancellation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
