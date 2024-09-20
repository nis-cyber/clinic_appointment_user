import 'package:clinic_users/features/appointment/data/appointment_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentNotifier extends StateNotifier<int> {
  AppointmentNotifier() : super(0);
  void refresh() => state++;
}

final appointmentNotifierProvider =
    StateNotifierProvider<AppointmentNotifier, int>((ref) {
  return AppointmentNotifier();
});

final pendingAppointmentServiceProvider =
    Provider<PendingAppointmentService>((ref) {
  return PendingAppointmentService();
});

final acceptedAppointmentServiceProvider =
    Provider<PendingAppointmentService>((ref) {
  return PendingAppointmentService();
});

final pendingAppointmentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(pendingAppointmentServiceProvider);
  return service.getPendingAppointments();
});

final acceptedAppointmentsProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final service = ref.watch(acceptedAppointmentServiceProvider);
  ref.watch(
      appointmentNotifierProvider); // This line makes the provider re-run when the notifier changes
  return service.getAcceptedAppointments();
});
