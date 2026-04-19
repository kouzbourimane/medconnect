// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Patient _$PatientFromJson(Map<String, dynamic> json) => Patient(
  id: (json['id'] as num).toInt(),
  user: Utilisateur.fromJson(json['user'] as Map<String, dynamic>),
  bloodType: json['blood_type'] as String?,
  allergies: json['allergies'] as String?,
  emergencyContact: json['emergency_contact'] as String?,
  emergencyPhone: json['emergency_phone'] as String?,
);

Map<String, dynamic> _$PatientToJson(Patient instance) => <String, dynamic>{
  'id': instance.id,
  'user': instance.user,
  'blood_type': instance.bloodType,
  'allergies': instance.allergies,
  'emergency_contact': instance.emergencyContact,
  'emergency_phone': instance.emergencyPhone,
};
