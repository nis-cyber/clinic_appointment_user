class Doctor {
  final String id;
  final String name;
  final String specialty;
  final Map<String, dynamic> availability;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.availability,
  });

  factory Doctor.fromMap(Map<String, dynamic> data, String id) {
    return Doctor(
      id: id,
      name: data['name'] ?? '',
      specialty: data['specialty'] ?? '',
      availability: data['availability'] ?? {},
    );
  }
}
