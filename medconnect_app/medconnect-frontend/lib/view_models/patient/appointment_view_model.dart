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

  List<Appointment> get pendingAppointments {
    return _appointments
        .where((a) => a.status == Appointment.statusPending)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusConfirmed &&
              a.dateTime.isAfter(now),
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusCompleted ||
              a.status == Appointment.statusCancelled ||
              a.status == Appointment.statusRefused ||
              ((a.status == Appointment.statusPending ||
                      a.status == Appointment.statusConfirmed) &&
                  a.dateTime.isBefore(now)),
        )
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
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
      await fetchAppointments(token);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelAppointment(String token, int appointmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appointmentService.cancelAppointment(token, appointmentId);
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = _appointments[index].copyWith(
          status: Appointment.statusCancelled,
        );
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
