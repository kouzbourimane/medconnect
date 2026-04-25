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
              a.status != 'CANCELLED' &&
              a.status != 'REJECTED' &&
              a.dateTime.isAfter(now),
        )
        .toList();
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == 'COMPLETED' ||
              (a.status != 'CANCELLED' && a.dateTime.isBefore(now)),
        )
        .toList();
  }

  List<Appointment> get cancelledAppointments {
    return _appointments
        .where((a) => a.status == 'CANCELLED' || a.status == 'REJECTED')
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
}
