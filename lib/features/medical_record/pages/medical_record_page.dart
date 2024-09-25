import 'package:clinic_users/features/medical_record/pages/report_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:intl/intl.dart';

class MedicalReportPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String? currentUserId =
        FirebaseAuth.instance.currentUser?.uid; // Get current user ID

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 173, 205, 204)!,
        title: const Text('Medical Reports'),
        centerTitle: true,
      ),
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
              .collection('medical_reports')
              .where('userId',
                  isEqualTo: currentUserId) // Filter by current user ID
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No medical reports available.'));
            }

            return ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                var reportDoc = snapshot.data!.docs[index];
                var reportData = reportDoc.data() as Map<String, dynamic>;

                return InkWell(
                  onTap: () {
                    // Navigate to the detailed report page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ReportDetailPage(reportData: reportData),
                      ),
                    );
                  },
                  child: Card(
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
                          _buildInfoRow('Doctor', reportData['doctor_name']),
                          _buildInfoRow('Diagnosis', reportData['diagnosis']),
                          _buildInfoRow('Treatment', reportData['treatment']),
                          _buildInfoRow(
                              'Medications', reportData['medications']),
                          _buildInfoRow('Speciality', reportData['speciality']),
                          _buildInfoRow(
                              'Date',
                              DateFormat('yyyy-MM-dd')
                                  .format(DateTime.parse(reportData['date']))),
                        ],
                      ),
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
