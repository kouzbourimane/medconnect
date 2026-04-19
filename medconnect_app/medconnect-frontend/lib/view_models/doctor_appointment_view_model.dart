import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

class DoctorAppointmentViewModel with ChangeNotifier {
  final AppointmentRepository _appointmentRepository;

  DoctorAppointmentViewModel(this._appointmentRepository);

  bool _isLoading = false;
  String? _error;
  List<Appointment> _appointments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Appointment> get appointments => _appointments;

  // Getters for filtered lists
  List<Appointment> get pendingAppointments =>
      _appointments.where((a) => a.status == Appointment.statusPending).toList();

  List<Appointment> get upcomingAppointments =>
      _appointments.where((a) => a.status == Appointment.statusConfirmed && a.dateTime.isAfter(DateTime.now())).toList();

  List<Appointment> get pastAppointments =>
      _appointments.where((a) => a.status == Appointment.statusCompleted || a.status == Appointment.statusCancelled || (a.status == Appointment.statusConfirmed && a.dateTime.isBefore(DateTime.now()))).toList();

  List<Appointment> get todayAppointments {
    final now = DateTime.now();
    return _appointments.where((a) =>
      a.status == Appointment.statusConfirmed &&
      a.dateTime.year == now.year &&
      a.dateTime.month == now.month &&
      a.dateTime.day == now.day
    ).toList();
  }

  Future<void> fetchAppointments(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _appointmentRepository.getDoctorAppointments(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> acceptAppointment(String token, int id) async {
    try {
      final updated = await _appointmentRepository.updateAppointmentStatus(token, id, Appointment.statusConfirmed);
      _updateLocalAppointment(updated);
    } catch (e) {
       // Handle error (maybe show snackbar in UI)
       rethrow;
    }
  }

  Future<void> refuseAppointment(String token, int id) async {
    try {
      final updated = await _appointmentRepository.updateAppointmentStatus(token, id, Appointment.statusRefused);
       _updateLocalAppointment(updated);
    } catch (e) {
       rethrow;
    }
  }

  Future<void> cancelAppointment(String token, int id) async {
    try {
      final updated = await _appointmentRepository.updateAppointmentStatus(token, id, Appointment.statusCancelled);
       _updateLocalAppointment(updated);
    } catch (e) {
       rethrow;
    }
  }

  Future<void> rescheduleAppointment(String token, int id, DateTime newDate) async {
    try {
      final updated = await _appointmentRepository.rescheduleAppointment(token, id, newDate);
      _updateLocalAppointment(updated);
    } catch (e) {
      rethrow;
    }
  }

  void _updateLocalAppointment(Appointment updated) {
    final index = _appointments.indexWhere((a) => a.id == updated.id);
    if (index != -1) {
      _appointments[index] = updated;
      notifyListeners();
    }
  }
}
