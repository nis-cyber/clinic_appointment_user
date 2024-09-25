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
