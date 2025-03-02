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
                        _buildInfoRow('Status', appointmentData['status']),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            handleAppointmentCancellation(
                              context,
                              appointmentDoc.id,
                              appointmentData['doctor_id'],
                              appointmentData['doctor_name'],
                              appointmentData['doctor_specialty'],
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

  /// Function to handle appointment cancellation and assign to next user in queue
  Future<void> handleAppointmentCancellation(
    BuildContext context,
    String appointmentId,
    String doctorId,
    String doctorName,
    String doctorSpecialty,
    String date,
    String timeSlot,
  ) async {
    try {
      // First, cancel the appointment as normal
      await _cancelAppointment(
        context,
        appointmentId,
        doctorId,
        date,
        timeSlot,
      );

      // Check if there are users in the queue for this specific slot
      QuerySnapshot queueSnapshot = await FirebaseFirestore.instance
          .collection('queues')
          .where('doctorId', isEqualTo: doctorId)
          .where('date', isEqualTo: date)
          .where('timeSlot', isEqualTo: timeSlot)
          .orderBy(
              'timestamp') // Order by timestamp to get the first person who joined
          .limit(1) // Get only the first person in the queue
          .get();

      // If there's at least one person in the queue
      if (queueSnapshot.docs.isNotEmpty) {
        // Get the first person's queue entry
        var queueDoc = queueSnapshot.docs.first;
        var queueData = queueDoc.data() as Map<String, dynamic>;
        String nextUserId = queueData['userId'];

        // Get user information for the new appointment
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(nextUserId)
            .get();

        Map<String, dynamic> userData = {};
        if (userSnapshot.exists) {
          userData = userSnapshot.data() as Map<String, dynamic>;
        }

        // Create the appointment data
        Map<String, dynamic> newAppointmentData = {
          'doctor_id': doctorId,
          'doctor_name': doctorName,
          'doctor_specialty': doctorSpecialty,
          'user_id': nextUserId,
          'user_name': userData['name'] ?? 'Unknown User',
          'user_phone': userData['phone'] ?? 'No Phone',
          'date': date,
          'time_slot': timeSlot,
          'status': 'confirmed',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Add the new appointment
        await FirebaseFirestore.instance
            .collection('appointment_pending')
            .add(newAppointmentData);

        // Remove the user from the queue
        await FirebaseFirestore.instance
            .collection('queues')
            .doc(queueDoc.id)
            .delete();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Appointment cancelled and assigned to next person in queue'),
            duration: Duration(seconds: 3),
          ),
        );
      } else {
        // No one in queue, just show normal cancellation message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Appointment cancelled successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
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

        // The booking function uses 'availability', but cancellation uses 'availableSlots'
        // Fixing to use 'availability' consistently
        if (doctorData['availability'] != null &&
            doctorData['availability'][date] != null) {
          List<dynamic> slots = doctorData['availability'][date];

          // Find the booked slot and restore it to original format
          for (int i = 0; i < slots.length; i++) {
            if (slots[i] == "$timeSlot (Booked)") {
              slots[i] = timeSlot; // Remove the "(Booked)" marker
              break;
            }
          }

          // Update the doctor's availability with the modified slots
          await FirebaseFirestore.instance
              .collection('doctors')
              .doc(doctorId)
              .update({'availability': doctorData['availability']});
        }
      }
    } catch (e) {
      // We'll handle errors in the calling function
      rethrow;
    }
  }
}
