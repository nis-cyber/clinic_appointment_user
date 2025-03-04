import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class DoctorFeedbackPage extends StatefulWidget {
  final String doctorId;

  DoctorFeedbackPage({required this.doctorId});

  @override
  _DoctorFeedbackPageState createState() => _DoctorFeedbackPageState();
}

class _DoctorFeedbackPageState extends State<DoctorFeedbackPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Feedback'),
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
        child: StreamBuilder(
          stream: _firestore
              .collection('doctor_feedback')
              .where('doctor_id', isEqualTo: widget.doctorId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                  child: Text('No feedback available for this doctor.'));
            }

            var feedbacks = snapshot.data!.docs;

            return ListView.builder(
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                var feedback = feedbacks[index].data() as Map;
                Timestamp timestamp = feedback['timestamp'] ?? Timestamp.now();
                DateTime dateTime = timestamp.toDate();
                String timeAgo = timeago.format(dateTime);

                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(feedback['patientName'] ?? 'Anonymous'),
                    subtitle: Text(
                        '${feedback['feedback'] ?? 'No feedback text'}\n$timeAgo'),
                    trailing: Text('Rating: ${feedback['rating'] ?? 'N/A'}'),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
