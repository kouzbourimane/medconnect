
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepository(this._appointmentService);

  Future<List<Appointment>> getDoctorAppointments(String token) {
    return _appointmentService.getAppointments(token);
  }

  Future<Appointment> updateAppointmentStatus(String token, int id, String status) {
    return _appointmentService.updateStatus(token, id, status);
  }

  Future<void> cancelAppointment(String token, int id) {
    // Assuming cancel just updates status to cancelled
    return _appointmentService.updateStatus(token, id, Appointment.statusCancelled);
  }

  Future<Appointment> rescheduleAppointment(String token, int id, DateTime newDate) {
    return _appointmentService.reschedule(token, id, newDate);
  }
}
