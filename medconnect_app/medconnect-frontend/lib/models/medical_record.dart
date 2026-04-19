class MedicalRecord {
  final int id;
  final int patientId;
  final int doctorId;
  final String doctorName;
  final String title;
  final String description;
  final String? diagnosis;
  final String? treatment;
  final DateTime recordDate;

  MedicalRecord({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.doctorName,
    required this.title,
    required this.description,
    this.diagnosis,
    this.treatment,
    required this.recordDate,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'],
      patientId: json['patient'],
      doctorId: json['doctor'] ?? 0,
      doctorName: json['doctor_name'] ?? 'Inconnu',
      title: json['title'],
      description: json['description'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      recordDate: DateTime.parse(json['record_date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient': patientId,
      'title': title,
      'description': description,
      'diagnosis': diagnosis,
      'treatment': treatment,
      // Date is managed by backend
    };
  }
}
