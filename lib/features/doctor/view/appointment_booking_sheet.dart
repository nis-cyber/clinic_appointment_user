import 'package:clinic_users/features/doctor/model/appointment_model.dart';
import 'package:clinic_users/features/doctor/services/email_service.dart';
import 'package:clinic_users/features/doctor/services/firestore_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppointmentBookingSheet extends StatefulWidget {
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String date;
  final String timeSlot;

  const AppointmentBookingSheet({
    super.key,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.date,
    required this.timeSlot,
  });

  @override
  _AppointmentBookingSheetState createState() =>
      _AppointmentBookingSheetState();
}

class _AppointmentBookingSheetState extends State<AppointmentBookingSheet> {
  final _formKey = GlobalKey<FormState>();
  final _userNameController = TextEditingController();
  final _userPhoneController = TextEditingController();
  final _userEmailController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String? _fileName;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Book Appointment',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
              ),
              const SizedBox(height: 24),
              _buildTextField(
                controller: _userNameController,
                label: 'Patient Name',
                icon: Icons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter patient name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _userEmailController,
                label: 'Email Address',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter email address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _userPhoneController,
                label: 'Patient Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const SizedBox(height: 32),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[800]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitAppointment,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 80, 133, 82),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          'Submit Appointment Request',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
      });
    }
  }

  void _submitAppointment() async {
    if (_formKey.currentState!.validate()) {
      try {
        String? userId = FirebaseAuth.instance.currentUser?.uid;

        var appointment = Appointment(
          doctorId: widget.doctorId,
          doctorName: widget.doctorName,
          doctorSpecialty: widget.doctorSpecialty,
          userName: _userNameController.text,
          userPhone: _userPhoneController.text,
          userEmail: _userEmailController.text,
          date: widget.date,
          timeSlot: widget.timeSlot,
          userId: userId ?? 'Unknown',
          status: 'pending',
        );

        await _firestoreService.bookAppointment(appointment);

        final emailSent = await EmailService.sendConfirmationEmail(
          userName: _userNameController.text,
          userEmail: _userEmailController.text,
          date: widget.date,
          timeSlot: widget.timeSlot,
          doctorName: widget.doctorName,
        );

        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(emailSent
                ? 'Appointment booked successfully! Confirmation email sent.'
                : 'Appointment booked! Email failed to send.'),
            backgroundColor: emailSent ? Colors.green : Colors.orange,
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error booking appointment: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
