
import '../models/appointment.dart';
import '../services/appointment_service.dart';

class AppointmentRepository {
  final AppointmentService _appointmentService;

  AppointmentRepository(this._appointmentService);

  Future<List<Appointment>> getDoctorAppointments(String token) {
    return _appointmentService.getAppointments(token);
  }

  Future<Appointment> acceptAppointment(String token, int id) {
    return _appointmentService.acceptAppointment(token, id);
  }

  Future<Appointment> refuseAppointment(String token, int id, {String? reason}) {
    return _appointmentService.refuseAppointment(token, id, reason: reason);
  }

  Future<Appointment> cancelAppointment(String token, int id, {String? reason}) {
    return _appointmentService.cancelAppointment(token, id, reason: reason);
  }

  Future<Appointment> completeAppointment(String token, int id) {
    return _appointmentService.completeAppointment(token, id);
  }
}
