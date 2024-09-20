// // User Doctor MOdel
// class DocModel {
//   final String name;
//   final String position;
//   final int averageReview;
//   final int totalReview;
//   final String profile;

//   DocModel({
//     required this.name,
//     required this.position,
//     required this.averageReview,
//     required this.totalReview,
//     required this.profile,
//   });
// }

// List<DocModel> nearbyDoctors = [
//   DocModel(
//     name: "Luke Holland",
//     position: "General Practitioner",
//     averageReview: 3,
//     totalReview: 195,
//     profile: 'assets/doctor_1.jpg',
//   ),
//   DocModel(
//     name: "Sophie harmon",
//     position: "General Practitioner",
//     averageReview: 4,
//     totalReview: 214,
//     profile: 'assets/doctor_2.jpg',
//   ),
//   DocModel(
//     name: "Louise Reid",
//     position: "General Practitioner",
//     averageReview: 4,
//     totalReview: 233,
//     profile: 'assets/doctor_3.jpg',
//   ),
// ];

class DoctorModel {
  final String id;
  final String name;
  final String specialty;
  final Map<String, List<String>> availableSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.availableSlots,
  });

  factory DoctorModel.fromFirestore(Map<String, dynamic> data, String id) {
    Map<String, List<String>> parsedSlots = {};
    if (data['availableSlots'] != null) {
      (data['availableSlots'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          parsedSlots[key] = List<String>.from(value);
        }
      });
    }

    return DoctorModel(
      id: id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      availableSlots: parsedSlots,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'specialty': specialty,
      'availableSlots': availableSlots,
    };
  }
}
