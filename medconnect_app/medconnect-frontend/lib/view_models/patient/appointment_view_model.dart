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
<<<<<<< HEAD
    return _appointments
=======
    final list = _appointments
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
        .where(
          (a) =>
              a.status != 'CANCELLED' &&
              a.status != 'REJECTED' &&
              a.dateTime.isAfter(now),
        )
        .toList();
<<<<<<< HEAD
=======
    // Tri croissant (plus proche au plus lointain)
    list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
    return list;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
<<<<<<< HEAD
    return _appointments
=======
    final list = _appointments
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
        .where(
          (a) =>
              a.status == 'COMPLETED' ||
              (a.status != 'CANCELLED' && a.dateTime.isBefore(now)),
        )
        .toList();
<<<<<<< HEAD
  }

  List<Appointment> get cancelledAppointments {
    return _appointments
        .where((a) => a.status == 'CANCELLED' || a.status == 'REJECTED')
        .toList();
=======
    // Tri décroissant (plus récent au plus ancien)
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<Appointment> get cancelledAppointments {
    final list = _appointments
        .where((a) => a.status == 'CANCELLED' || a.status == 'REJECTED')
        .toList();
    // Tri par date d'annulation (si disponible) ou date de RDV
    list.sort((a, b) {
      if (a.createdDate != null && b.createdDate != null) {
        return b.createdDate!.compareTo(a.createdDate!);
      }
      return b.dateTime.compareTo(a.dateTime);
    });
    return list;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
<<<<<<< HEAD
=======

  Future<bool> cancelAppointment(String token, int appointmentId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _appointmentService.cancelAppointment(token, appointmentId);
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
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
}
