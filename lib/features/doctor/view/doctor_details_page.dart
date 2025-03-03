import 'package:clinic_users/features/doctor/model/doctor_model.dart';
import 'package:clinic_users/features/doctor/view/appointment_booking_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import '../services/firestore_service.dart';

class DoctorDetailPage extends StatelessWidget {
  final String doctorId;
  final FirestoreService _firestoreService = FirestoreService();

  DoctorDetailPage({super.key, required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Details'),
        backgroundColor: const Color.fromARGB(255, 173, 205, 204),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 173, 205, 204),
              Color.fromARGB(255, 180, 152, 225),
            ],
          ),
        ),
        child: StreamBuilder<Doctor>(
          stream: _firestoreService.getDoctor(doctorId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData) {
              return const Center(child: Text('Doctor not found.'));
            }

            var doctor = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('Doctor Information', [
                    _buildInfoRow('Name', doctor.name),
                    _buildInfoRow('Specialty', doctor.specialty),
                  ]),
                  const SizedBox(height: 16),
                  _buildAvailabilitySection(
                      doctor.availability, doctor, context),
                  _buildRatingAndFeedbackSection(doctorId),
                  const SizedBox(height: 495),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 6,
      color: Colors.white.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      shadowColor: Colors.grey.withOpacity(0.5),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 52, 81, 133),
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection(
      Map<String, dynamic> availability, Doctor doctor, BuildContext context) {
    List<Widget> availabilityWidgets = [];

    availability.forEach((date, slots) {
      availabilityWidgets.add(
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
          shadowColor: Colors.grey.withOpacity(0.4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEEE, MMMM d, y').format(DateTime.parse(date)),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 70, 130, 180),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (slots as List<dynamic>).map((slot) {
                    // Check if the slot is booked
                    bool isBooked = slot.toString().contains("(Booked)");

                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isBooked
                            ? Colors.grey // Disabled color
                            : const Color.fromARGB(
                                255, 98, 165, 220), // Active color
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(slot),
                      onPressed: isBooked
                          ? () {
                              _showJoinQueueDialog(context, doctor.id,
                                  doctor.name, doctor.specialty, date, slot);
                            }
                          : () {
                              _bookAppointment(context, doctor.id, doctor.name,
                                  doctor.specialty, date, slot);
                            },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Availability',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 52, 81, 133),
          ),
        ),
        const SizedBox(height: 12),
        ...availabilityWidgets,
      ],
    );
  }

  void _showJoinQueueDialog(
    BuildContext context,
    String doctorId,
    String doctorName,
    String doctorSpecialty,
    String date,
    String timeSlot,
  ) async {
    // Check if the user is already in the queue for this time slot
    bool isUserInQueue =
        await _isUserInQueueOrAppointment(doctorId, date, timeSlot);

    if (isUserInQueue) {
      // Show a message that the user is already in the queue
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already in the queue for this time slot.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // If the user is not in the queue, show the dialog to join the queue
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Row(
            children: [
              Icon(Icons.access_time, color: Colors.blue),
              const SizedBox(width: 8),
              Text(
                "Join the Queue",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Do you want to join the queue for",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    date,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    timeSlot,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel", style: TextStyle(color: Colors.red)),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _joinQueue(
                  context,
                  doctorId,
                  doctorName,
                  doctorSpecialty,
                  date,
                  timeSlot,
                );
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("Join Queue"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _isUserInQueueOrAppointment(
      String doctorId, String date, String timeSlot) async {
    // Get the current user ID from Firebase Authentication
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('No user is currently logged in.');
      return false;
    }

    // Check if the user is already in the queue for this time slot
    QuerySnapshot queueQuery = await FirebaseFirestore.instance
        .collection('queues')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('userId', isEqualTo: userId)
        .get();

    // Check if the user has already booked an appointment for this time slot
    QuerySnapshot appointmentQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .where('userId', isEqualTo: userId)
        .get();

    // If the user is in either the queue or has an appointment, return true
    return queueQuery.docs.isNotEmpty || appointmentQuery.docs.isNotEmpty;
  }

  void _joinQueue(
    BuildContext context, // Add BuildContext to show the dialog
    String doctorId,
    String doctorName,
    String doctorSpecialty,
    String date,
    String timeSlot,
  ) async {
    // Get the current user ID from Firebase Authentication
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      print('No user is currently logged in.');
      return;
    }

    // Check again if the user is already in the queue (to handle race conditions)
    bool isUserInQueue =
        await _isUserInQueueOrAppointment(doctorId, date, timeSlot);

    if (isUserInQueue) {
      print('User is already in the queue.');
      // Show a dialog if the user is already in the queue
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Already in Queue'),
          content:
              const Text('You are already in the queue for this time slot.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // Fetch the user details from the 'user' collection
    DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!userSnapshot.exists) {
      print('User details not found.');
      return;
    }

    var userData = userSnapshot.data() as Map<String, dynamic>;

    // Add the user to the queue with user details
    FirebaseFirestore.instance.collection('queues').add({
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'date': date,
      'timeSlot': timeSlot,
      'userId': userId,
      'name': userData['fullname'],
      'email': userData['email'],
      'address': userData['address'],
      'phone': userData['phone'],
      // Add any other user details you need

      'timestamp': DateTime.now(),
    }).then((value) {
      print('Joined the queue successfully');
      // Show a success dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Queue Joined'),
          content: const Text('You have successfully joined the queue.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }).catchError((error) {
      print('Failed to join the queue: $error');
      // Show an error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Failed to join the queue. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildRatingAndFeedbackSection(String doctorId) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getDoctorFeedback(doctorId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        var feedbacks = snapshot.data?.docs ?? [];
        double averageRating = 0;
        if (feedbacks.isNotEmpty) {
          averageRating = feedbacks
                  .map((doc) => doc['rating'] as num)
                  .reduce((a, b) => a + b) /
              feedbacks.length;
        }

        return Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ratings & Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal[700],
                      ),
                    ),
                    const SizedBox(width: 8),
                    RatingBarIndicator(
                      rating: averageRating,
                      itemBuilder: (context, index) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      itemCount: 5,
                      itemSize: 20.0,
                      direction: Axis.horizontal,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '(${feedbacks.length} reviews)',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...feedbacks.map((feedback) => _buildFeedbackItem(feedback)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFeedbackItem(QueryDocumentSnapshot feedback) {
    var data = feedback.data() as Map<String, dynamic>;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              RatingBarIndicator(
                rating: data['rating'].toDouble(),
                itemBuilder: (context, index) => const Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                itemCount: 5,
                itemSize: 16.0,
                direction: Axis.horizontal,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMM d, yyyy').format(data['timestamp'].toDate()),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            data['feedback'],
            style: const TextStyle(fontSize: 14),
          ),
          const Divider(),
        ],
      ),
    );
  }

  void _bookAppointment(
    BuildContext context,
    String doctorId,
    String doctorName,
    String doctorSpecialty,
    String date,
    String timeSlot,
  ) {
    // Navigate to the appointment booking sheet
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return AppointmentBookingSheet(
          doctorId: doctorId,
          doctorName: doctorName,
          doctorSpecialty: doctorSpecialty,
          date: date,
          timeSlot: timeSlot,
        );
      },
    );
  }
}
