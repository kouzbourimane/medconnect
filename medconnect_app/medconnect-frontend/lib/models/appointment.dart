class Appointment {
  static const String statusPending = 'PENDING';
  static const String statusConfirmed = 'CONFIRMED';
  static const String statusCancelled = 'CANCELLED';
  static const String statusRefused = 'REFUSED';
  static const String statusCompleted = 'COMPLETED';

  final int id;
  final int doctorId;
  final int patientId;
  final String doctorName;
  final String patientName;
  final String specialty;
  final String date;
  final int duration;
  final String status;
  final String? reason;
  final String? refusalReason;
  final String? cancelReason;
  final String? notesPatient;

  DateTime get dateTime => DateTime.parse(date);

  String get statusLabel {
    switch (status) {
      case statusPending:
        return 'En attente';
      case statusConfirmed:
        return 'Confirme';
      case statusCancelled:
        return 'Annule';
      case statusRefused:
        return 'Refuse';
      case statusCompleted:
        return 'Termine';
      default:
        return status;
    }
  }

  Appointment({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.specialty,
    required this.date,
    required this.duration,
    required this.status,
    this.reason,
    this.refusalReason,
    this.cancelReason,
    this.notesPatient,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctor'] ?? 0,
      patientId: json['patient'] ?? 0,
      doctorName: json['doctor_name'] ?? 'Inconnu',
      patientName: json['patient_name'] ?? 'Inconnu',
      specialty: json['specialty'] ?? 'General',
      date: json['date'],
      duration: json['duration'] ?? 30,
      status: json['status'] ?? statusPending,
      reason: json['reason'],
      refusalReason: json['refusal_reason'],
      cancelReason: json['cancel_reason'],
      notesPatient: json['notes_patient'],
    );
  }

  Appointment copyWith({
    String? status,
    String? date,
    String? refusalReason,
    String? cancelReason,
    String? notesPatient,
  }) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      specialty: specialty,
      date: date ?? this.date,
      duration: duration,
      status: status ?? this.status,
      reason: reason,
      refusalReason: refusalReason ?? this.refusalReason,
      cancelReason: cancelReason ?? this.cancelReason,
      notesPatient: notesPatient ?? this.notesPatient,
    );
  }
}
