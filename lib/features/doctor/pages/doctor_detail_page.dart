import 'package:clinic_users/features/doctor/model/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorDetailPage extends StatefulWidget {
  final DoctorModel doctor;

  DoctorDetailPage({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late DoctorModel _doctor;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _doctor = widget.doctor;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.doctor.name),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade800, Colors.blue.shade500],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.person, size: 80, color: Colors.white),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 20),
                  Text('Available Slots',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  _buildAvailableSlotsCard(context),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all(
                                const EdgeInsets.symmetric(
                                    vertical: 8, horizontal: 16)),
                            backgroundColor:
                                WidgetStateProperty.all(Colors.blue.shade500),
                            alignment: Alignment.center,
                          ),
                          onPressed: () => _showBookingDialog(context),
                          child: const Text(
                            'Book Appointment',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(
                Icons.medical_services, 'Specialty', widget.doctor.specialty),
            const Divider(),
            _buildInfoRow(
                Icons.schedule,
                'Total Available Slots',
                widget.doctor.availableSlots.values
                    .expand((slots) => slots)
                    .length
                    .toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade700),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlotsCard(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: widget.doctor.availableSlots.entries.map((entry) {
            return _buildDaySlots(context, entry.key, entry.value);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildDaySlots(BuildContext context, String day, List<String> slots) {
    return ExpansionTile(
      title: Text(day, style: const TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: slots
              .map((slot) => Chip(
                    label: Text(slot),
                    backgroundColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: Colors.blue.shade800),
                  ))
              .toList(),
        ),
      ],
    );
  }

  void _showBookingDialog(BuildContext context) {
    String? selectedDay;
    String? selectedSlot;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Book Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    isExpanded: true,
                    hint: Text('Select Day'),
                    value: selectedDay,
                    items: _doctor.availableSlots.keys.map((String day) {
                      return DropdownMenuItem<String>(
                        value: day,
                        child: Text(day),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedDay = newValue;
                        selectedSlot = null;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  if (selectedDay != null)
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: Text('Select Time Slot'),
                      value: selectedSlot,
                      items: _doctor.availableSlots[selectedDay]!
                          .map((String slot) {
                        return DropdownMenuItem<String>(
                          value: slot,
                          child: Text(slot),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedSlot = newValue;
                        });
                      },
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: Text('Book'),
                  onPressed: (selectedDay != null && selectedSlot != null)
                      ? () =>
                          _bookAppointment(context, selectedDay!, selectedSlot!)
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _bookAppointment(
      BuildContext context, String day, String slot) async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      // Get current user
      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('No user logged in');
      }

      // Fetch user data from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();

      if (!userDoc.exists) {
        throw Exception('User data not found');
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String userFullName = userData['fullName'] ?? 'Unknown User';

      // Start a batch write
      WriteBatch batch = _firestore.batch();

      // Create a new appointment document
      DocumentReference appointmentRef =
          _firestore.collection('appointments_pending').doc();
      batch.set(appointmentRef, {
        'doctorId': _doctor.id,
        'doctorName': _doctor.name,
        'day': day,
        'slot': slot,
        'patientId': currentUser.uid,
        'patientName': userFullName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update doctor's available slots
      DocumentReference doctorRef =
          _firestore.collection('doctors').doc(_doctor.id);
      batch.update(doctorRef, {
        'availableSlots.$day': FieldValue.arrayRemove([slot])
      });

      // Commit the batch
      await batch.commit();

      // Update local state
      setState(() {
        _doctor.availableSlots[day]!.remove(slot);
      });

      // Close loading indicator
      Navigator.of(context).pop();

      // Close booking dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Appointment booked for $day at $slot')),
      );
    } catch (e) {
      print('Error booking appointment: $e');

      // Close loading indicator
      Navigator.of(context).pop();

      // Close booking dialog
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to book appointment. Please try again.')),
      );
    }
  }
}
