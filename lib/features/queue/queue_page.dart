import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QueuePage extends StatelessWidget {
  const QueuePage({super.key});

  Future<String?> _getCurrentUserId() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Queues'),
        backgroundColor: Colors.blue,
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
        child: FutureBuilder<String?>(
          future: _getCurrentUserId(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (userSnapshot.hasError || userSnapshot.data == null) {
              return const Center(
                child: Text(
                  'Error fetching user data. Please log in again.',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              );
            }

            String userId = userSnapshot.data!;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('queues')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'You have not joined any queues.',
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  );
                }

                var queues = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: queues.length,
                  itemBuilder: (context, index) {
                    var queue = queues[index];
                    var data = queue.data() as Map<String, dynamic>;

                    return FutureBuilder<int?>(
                      future: _getQueuePosition(data['doctorId'], data['date'],
                          data['timeSlot'], userId),
                      builder: (context, positionSnapshot) {
                        if (positionSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        data['position'] = positionSnapshot.data ?? 'N/A';
                        return _buildQueueCard(data);
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<int?> _getQueuePosition(
      String doctorId, String date, String timeSlot, String userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('queues')
        .where('doctorId', isEqualTo: doctorId)
        .where('date', isEqualTo: date)
        .where('timeSlot', isEqualTo: timeSlot)
        .orderBy('createdAt')
        .get();

    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i]['userId'] == userId) {
        return i + 1;
      }
    }
    return null;
  }

  Widget _buildQueueCard(Map<String, dynamic> data) {
    return Card(
      elevation: 6,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['doctorName'] ?? 'Unknown Doctor',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Specialty: ${data['doctorSpecialty'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  data['date'] ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  data['timeSlot'] ?? 'N/A',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
