
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepository(this._appointmentService);

  Future<List<Appointment>> getDoctorAppointments(String token) {
    return _appointmentService.getAppointments(token);
  }

  Future<Appointment> updateAppointmentStatus(
    String token,
    int id,
    String status, {
    String? reason,
  }) {
    return _appointmentService.updateStatus(
      token,
      id,
      status,
      reason: reason,
    );
  }

  Future<void> cancelAppointment(String token, int id) {
    return _appointmentService.cancelAppointment(token, id);
  }

  Future<Appointment> rescheduleAppointment(String token, int id, DateTime newDate) {
    return _appointmentService.reschedule(token, id, newDate);
  }
}
