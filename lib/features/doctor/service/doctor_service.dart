import 'package:clinic_users/features/doctor/model/doctor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DoctorModel>> getAllDoctors() async {
    try {
      QuerySnapshot querySnapshot =
          await _firestore.collection('doctors').get();
      return querySnapshot.docs
          .map((doc) => DoctorModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching doctors: $e');
      return [];
    }
  }

  Future<DoctorModel?> getDoctorById(String id) async {
    try {
      DocumentSnapshot docSnapshot =
          await _firestore.collection('doctors').doc(id).get();
      if (docSnapshot.exists) {
        return DoctorModel.fromFirestore(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
      } else {
        print('Doctor not found');
        return null;
      }
    } catch (e) {
      print('Error fetching doctor: $e');
      return null;
    }
  }

  Future<List<DoctorModel>> getDoctorsBySpecialty(String specialty) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('doctors')
          .where('specialty', isEqualTo: specialty)
          .get();
      return querySnapshot.docs
          .map((doc) => DoctorModel.fromFirestore(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print('Error fetching doctors by specialty: $e');
      return [];
    }
  }

  Future<void> addDoctor(DoctorModel doctor) async {
    try {
      await _firestore.collection('doctors').add(doctor.toFirestore());
    } catch (e) {
      print('Error adding doctor: $e');
      rethrow;
    }
  }

  Future<void> updateDoctor(DoctorModel doctor) async {
    try {
      await _firestore
          .collection('doctors')
          .doc(doctor.id)
          .update(doctor.toFirestore());
    } catch (e) {
      print('Error updating doctor: $e');
      rethrow;
    }
  }

  Future<void> deleteDoctor(String id) async {
    try {
      await _firestore.collection('doctors').doc(id).delete();
    } catch (e) {
      print('Error deleting doctor: $e');
      rethrow;
    }
  }
}
