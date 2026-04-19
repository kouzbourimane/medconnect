import 'medical_document_model.dart';

class MedicalRecordModel {
  final PatientHealthInfo patientInfo;
  final List<ConsultationInfo> consultations;
  final List<MedicalDocument> documents;

  MedicalRecordModel({
    required this.patientInfo,
    required this.consultations,
    required this.documents,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      patientInfo: PatientHealthInfo.fromJson(json['patient_info']),
      consultations: (json['consultations'] as List)
          .map((i) => ConsultationInfo.fromJson(i))
          .toList(),
      documents: (json['documents'] as List)
          .map((i) => MedicalDocument.fromJson(i))
          .toList(),
    );
  }
}

class PatientHealthInfo {
  final String fullName;
  final String? bloodType;
  final String? allergies;
  final double? height;
  final double? weight;
  final String? emergencyContact;
  final String? emergencyPhone;

  PatientHealthInfo({
    required this.fullName,
    this.bloodType,
    this.allergies,
    this.height,
    this.weight,
    this.emergencyContact,
    this.emergencyPhone,
  });

  factory PatientHealthInfo.fromJson(Map<String, dynamic> json) {
    return PatientHealthInfo(
      fullName: json['full_name'],
      bloodType: json['blood_type'],
      allergies: json['allergies'],
      height: json['height']?.toDouble(),
      weight: json['weight']?.toDouble(),
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
    );
  }
}

class ConsultationInfo {
  final int id;
  final String doctorName;
  final String specialty;
  final String date;
  final String? reason;
  final String? notes;

  ConsultationInfo({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    this.reason,
    this.notes,
  });

  factory ConsultationInfo.fromJson(Map<String, dynamic> json) {
    return ConsultationInfo(
      id: json['id'],
      doctorName: json['doctor_name'],
      specialty: json['specialty'],
      date: json['date'],
      reason: json['reason'],
      notes: json['notes_patient'],
    );
  }
}
