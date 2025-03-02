import 'package:clinic_users/features/doctor/model/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/appointment_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch doctor details
  Stream<Doctor> getDoctor(String doctorId) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .snapshots()
        .map((snapshot) => Doctor.fromMap(snapshot.data()!, snapshot.id));
  }

  // Fetch doctor feedback
  Stream<QuerySnapshot> getDoctorFeedback(String doctorId) {
    return _firestore
        .collection('doctor_feedback')
        .where('doctor_id', isEqualTo: doctorId)
        .snapshots();
  }

  Future<void> bookAppointment(Appointment appointment) async {
    // Add the appointment to the 'appointment_pending' collection
    await _firestore.collection('appointment_pending').add(appointment.toMap());

    // Update doctor's availability
    DocumentSnapshot doctorSnapshot =
        await _firestore.collection('doctors').doc(appointment.doctorId).get();

    if (doctorSnapshot.exists) {
      var doctorData = doctorSnapshot.data() as Map<String, dynamic>;
      if (doctorData['availability'] != null &&
          doctorData['availability'][appointment.date] != null) {
        List<dynamic> slots = doctorData['availability'][appointment.date];

        // Find the time slot and mark it as "booked"
        for (int i = 0; i < slots.length; i++) {
          if (slots[i] == appointment.timeSlot) {
            slots[i] = "${appointment.timeSlot} (Booked)"; // Mark as booked
            break;
          }
        }

        // Update the doctor's availability with the modified slots
        doctorData['availability'][appointment.date] = slots;

        await _firestore
            .collection('doctors')
            .doc(appointment.doctorId)
            .update({'availability': doctorData['availability']});
      }
    }
  }
}
