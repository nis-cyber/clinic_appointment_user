class Appointment {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String userName;
  final String userPhone;
  final String userEmail;
  final String date;
  final String timeSlot;
  final String userId;
  final String status;

  Appointment({
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.userName,
    required this.userPhone,
    required this.userEmail,
    required this.date,
    required this.timeSlot,
    required this.userId,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctor_id': doctorId,
      'doctor_name': doctorName,
      'doctor_specialty': doctorSpecialty,
      'user_name': userName,
      'user_phone': userPhone,
      'user_email': userEmail,
      'date': date,
      'time_slot': timeSlot,
      'user_id': userId,
      'status': status,
    };
  }
}
