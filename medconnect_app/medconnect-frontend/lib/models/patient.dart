import 'package:json_annotation/json_annotation.dart';
import 'utilisateur.dart';

part 'patient.g.dart';

@JsonSerializable()
class Patient {
  final int id;
  final Utilisateur user;
  @JsonKey(name: 'blood_type')
  final String? bloodType;
  final String? allergies;
  @JsonKey(name: 'emergency_contact')
  final String? emergencyContact;
  @JsonKey(name: 'emergency_phone')
  final String? emergencyPhone;

  Patient({
    required this.id,
    required this.user,
    this.bloodType,
    this.allergies,
    this.emergencyContact,
    this.emergencyPhone,
  });

  factory Patient.fromJson(Map<String, dynamic> json) =>
      _$PatientFromJson(json);
  Map<String, dynamic> toJson() => _$PatientToJson(this);
}