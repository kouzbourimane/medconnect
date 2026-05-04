import 'package:flutter/foundation.dart';
import '../../models/appointment.dart';
import '../../services/appointment_service.dart';

class AppointmentViewModel with ChangeNotifier {
  final AppointmentService _appointmentService = AppointmentService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Filtered lists
  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status != Appointment.statusCancelled &&
              a.status != Appointment.statusRefused &&
              a.dateTime.isAfter(now),
        )
        .toList();
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusCompleted ||
              ((a.status == Appointment.statusPending ||
                      a.status == Appointment.statusConfirmed) &&
                  a.dateTime.isBefore(now)),
        )
        .toList();
  }

  List<Appointment> get cancelledAppointments {
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusCancelled ||
              a.status == Appointment.statusRefused,
        )
        .toList();
  }

  Future<void> fetchAppointments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _appointmentService.getAppointments(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> bookAppointment(
    String token,
    int doctorId,
    DateTime date,
    String reason,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appointmentService.createAppointment(
        token,
        doctorId,
        date,
        reason,
      );
      await fetchAppointments(token); // Refresh list
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String token, int id, {String? reason}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _appointmentService.cancelAppointment(
        token,
        id,
        reason: reason,
      );
      final index = _appointments.indexWhere((a) => a.id == id);
      if (index != -1) {
        _appointments[index] = updated;
      }
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
