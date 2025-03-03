import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:intl/intl.dart';

class EmailService {
  static const String _username = 'nishant.kharel135@gmail.com';
  static const String _password = 'mfar rwsb emqq nrur';

  // Send confirmation email
  static Future<bool> sendConfirmationEmail({
    required String userName,
    required String userEmail,
    required String date,
    required String timeSlot,
    required String doctorName,
  }) async {
    try {
      final smtpServer = gmail(_username, _password);
      final formattedDate =
          DateFormat('EEEE, MMMM d, y').format(DateTime.parse(date));

      final message = Message()
        ..from = const Address(_username, 'Clinic Appointment System')
        ..recipients.add(userEmail)
        ..subject = 'Appointment Confirmation - $doctorName'
        ..html = '''
          <h3>Appointment Confirmation</h3>
          <p>Dear $userName,</p>
          <p>Your appointment has been successfully sent to the clinic :</p>
          <p>Please wait until the clinic confirm your appointment !!!!!</p>
          <p><strong>Doctor:</strong> $doctorName</p>
          <p><strong>Date:</strong> $formattedDate</p>
          <p><strong>Time:</strong> $timeSlot</p>
          <br/>
          <p>Please arrive 10 minutes prior to your appointment time.</p>
          <p>Thank you for choosing our clinic!</p>
        ''';

      await send(message, smtpServer);
      return true;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }
}
