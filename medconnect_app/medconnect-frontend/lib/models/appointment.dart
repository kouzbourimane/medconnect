class Appointment {
<<<<<<< HEAD
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
=======
  final int id;
  final int doctorId;
  final String doctorName;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  final String specialty;
  final String date;
  final int duration;
  final String status;
  final String? reason;
  final String? notesPatient;
<<<<<<< HEAD

  // Computed properties
  DateTime get dateTime => DateTime.parse(date);
=======
  final String? createdAt; // Pour le tri des annulés

  // Computed properties
  DateTime get dateTime => DateTime.parse(date);
  DateTime? get createdDate =>
      createdAt != null ? DateTime.parse(createdAt!) : null;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  Appointment({
    required this.id,
    required this.doctorId,
<<<<<<< HEAD
    required this.patientId,
    required this.doctorName,
    required this.patientName,
=======
    required this.doctorName,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    required this.specialty,
    required this.date,
    required this.duration,
    required this.status,
    this.reason,
    this.notesPatient,
<<<<<<< HEAD
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
=======
    this.createdAt,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      doctorId: json['doctor'],
      doctorName: json['doctor_name'] ?? 'Inconnu',
      specialty: json['specialty'] ?? 'Général',
      date: json['date'],
      duration: json['duration'] ?? 30,
      status: json['status'],
      reason: json['reason'],
      notesPatient: json['notes_patient'],
      createdAt: json['created_at'],
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    );
  }
}
