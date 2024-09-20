import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PendingAppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<Map<String, dynamic>>> getPendingAppointments() {
    return _firestore
        .collection('appointments_pending')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }

  Future<void> acceptAppointment(Map<String, dynamic> appointmentData) async {
    // Start a batch write
    final batch = _firestore.batch();

    // Add to appointments_accepted collection
    final acceptedAppointmentRef =
        _firestore.collection('appointments_accepted').doc();
    batch.set(acceptedAppointmentRef, {
      ...appointmentData,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });

    // Delete from appointments_pending collection
    final pendingAppointmentRef = _firestore
        .collection('appointments_pending')
        .doc(appointmentData['id']);
    batch.delete(pendingAppointmentRef);

    // Commit the batch
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> getAcceptedAppointments() {
    return _firestore
        .collection('appointments_accepted')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();
    });
  }
}
