import 'package:flutter_test/flutter_test.dart';
import 'package:medconnect_app/models/appointment.dart';

void main() {
  group('Appointment', () {
    test('fromJson maps API fields and default values', () {
      final appointment = Appointment.fromJson({
        'id': 12,
        'doctor': 4,
        'patient': 8,
        'doctor_name': 'Dr Martin',
        'patient_name': 'Sara',
        'date': '2026-05-10T09:30:00.000',
      });

      expect(appointment.id, 12);
      expect(appointment.doctorId, 4);
      expect(appointment.patientId, 8);
      expect(appointment.doctorName, 'Dr Martin');
      expect(appointment.patientName, 'Sara');
      expect(appointment.specialty, 'General');
      expect(appointment.duration, 30);
      expect(appointment.status, Appointment.statusPending);
      expect(appointment.statusLabel, 'En attente');
      expect(appointment.dateTime, DateTime(2026, 5, 10, 9, 30));
    });

    test('copyWith keeps unchanged fields and updates selected fields', () {
      final appointment = Appointment(
        id: 1,
        doctorId: 2,
        patientId: 3,
        doctorName: 'Dr Ali',
        patientName: 'Nadia',
        specialty: 'Cardiologie',
        date: '2026-05-10T09:30:00.000',
        duration: 45,
        status: Appointment.statusPending,
      );

      final updated = appointment.copyWith(
        status: Appointment.statusConfirmed,
        notesPatient: 'Premier rendez-vous',
      );

      expect(updated.id, appointment.id);
      expect(updated.status, Appointment.statusConfirmed);
      expect(updated.statusLabel, 'Confirme');
      expect(updated.notesPatient, 'Premier rendez-vous');
      expect(updated.date, appointment.date);
    });
  });
}
