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

  // ─── Getters filtrés ────────────────────────────────────────────────────────

  /// Demandes PENDING dont la date n'est pas encore dépassée
  List<Appointment> get pendingAppointments => _appointments
      .where((a) => a.status == Appointment.statusPending)
      .toList()
    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

  /// Demandes PENDING dont la date est dépassée (expirées — pour affichage dans "Demandes")
  List<Appointment> get expiredPendingAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusPending &&
              a.dateTime.isBefore(now),
        )
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// Toutes les demandes PENDING (actives + expirées)
  List<Appointment> get allPendingAppointments {
    return _appointments
        .where((a) => a.status == Appointment.statusPending)
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  /// RDV confirmés à venir
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

  /// Historique : terminés, annulés, refusés, ou confirmés avec date passée
  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusCompleted ||
              a.status == Appointment.statusCancelled ||
              a.status == Appointment.statusRefused ||
              (a.status == Appointment.statusConfirmed &&
                  a.dateTime.isBefore(now)),
        )
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  /// RDV d'aujourd'hui (confirmés)
  List<Appointment> get todayAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) =>
              a.status == Appointment.statusConfirmed &&
              a.dateTime.year == now.year &&
              a.dateTime.month == now.month &&
              a.dateTime.day == now.day,
        )
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // ─── Actions ────────────────────────────────────────────────────────────────

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
      final updated = await _appointmentRepository.updateAppointmentStatus(
        token,
        id,
        Appointment.statusConfirmed,
      );
      _updateLocalAppointment(updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> refuseAppointment(String token, int id, {String? reason}) async {
    try {
      final updated = await _appointmentRepository.updateAppointmentStatus(
        token,
        id,
        Appointment.statusRefused,
        reason: reason,
      );
      _updateLocalAppointment(updated);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> cancelAppointment(String token, int id) async {
    try {
      final updated = await _appointmentRepository.updateAppointmentStatus(
        token,
        id,
        Appointment.statusCancelled,
      );
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
