class MedicalDocument {
  final int id;
  final String title;
  final String documentType;
  final String? description;
  final String? file;
  final String? fileUrl;
  final int? doctor;
  final String? doctorName;
  final String uploadedBy;
  final DateTime createdAt;

  MedicalDocument({
    required this.id,
    required this.title,
    required this.documentType,
    this.description,
    this.file,
    this.fileUrl,
    this.doctor,
    this.doctorName,
    required this.uploadedBy,
    required this.createdAt,
  });

  factory MedicalDocument.fromJson(Map<String, dynamic> json) {
    return MedicalDocument(
      id: json['id'],
      title: json['title'],
      documentType: json['document_type'],
      description: json['description'],
      file: json['file'],
      fileUrl: json['file_url'],
      doctor: json['doctor'],
      doctorName: json['doctor_name'],
      uploadedBy: json['uploaded_by'] ?? 'DOCTOR',
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'document_type': documentType,
      'description': description,
      'file': file,
      'file_url': fileUrl,
      'doctor': doctor,
      'doctor_name': doctorName,
      'uploaded_by': uploadedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
