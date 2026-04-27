class Appointment {
  static const String statusPending = 'En attente';
  static const String statusConfirmed = 'Confirmé';
  static const String statusCancelled = 'Annulé';
  static const String statusRefused = 'Refusé';
  static const String statusCompleted = 'Terminé';

  final int id;
  final int doctorId;
  final int patientId; // Added for matching history
  final String doctorName;
  final String patientName;
  final String specialty;
  final String date;
  final int duration;
  final String status;
  final String? reason;
  final String? notesPatient;
  final String? refusalReason;

  // Computed properties
  DateTime get dateTime => DateTime.parse(date);

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
    this.notesPatient,
    this.refusalReason,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    String apiStatus = json['status'] ?? 'PENDING';
    String displayStatus = statusPending;
    
    switch (apiStatus) {
      case 'PENDING':
        displayStatus = statusPending;
        break;
      case 'CONFIRMED':
        displayStatus = statusConfirmed;
        break;
      case 'CANCELLED':
        displayStatus = statusCancelled;
        break;
      case 'REFUSED':
        displayStatus = statusRefused;
        break;
      case 'COMPLETED':
        displayStatus = statusCompleted;
        break;
      default:
        displayStatus = apiStatus; // Fallback for 'En attente' etc if already translated
    }

    return Appointment(
      id: json['id'],
      doctorId: json['doctor'] ?? 0,
      patientId: json['patient'] ?? 0,
      doctorName: json['doctor_name'] ?? 'Inconnu',
      patientName: json['patient_name'] ?? 'Inconnu',
      specialty: json['specialty'] ?? 'Général',
      date: json['date'],
      duration: json['duration'] ?? 30,
      status: displayStatus,
      reason: json['reason'],
      notesPatient: json['notes_patient'],
      refusalReason: json['refusal_reason'],
    );
  }

  Appointment copyWith({
    String? status,
  }) {
    return Appointment(
      id: id,
      doctorId: doctorId,
      patientId: patientId,
      doctorName: doctorName,
      patientName: patientName,
      specialty: specialty,
      date: date,
      duration: duration,
      status: status ?? this.status,
      reason: reason,
      notesPatient: notesPatient,
      refusalReason: refusalReason,
    );
  }
}
