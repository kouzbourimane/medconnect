// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      username: json['username'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      first_name: json['first_name'] as String?,
      last_name: json['last_name'] as String?,
      phone: json['phone'] as String?,
      role: json['role'] as String? ?? "PATIENT",
      blood_type: json['blood_type'] as String?,
      allergies: json['allergies'] as String?,
      emergency_contact: json['emergency_contact'] as String?,
      emergency_phone: json['emergency_phone'] as String?,
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'username': instance.username,
      'email': instance.email,
      'password': instance.password,
      'first_name': instance.first_name,
      'last_name': instance.last_name,
      'phone': instance.phone,
      'role': instance.role,
      'blood_type': instance.blood_type,
      'allergies': instance.allergies,
      'emergency_contact': instance.emergency_contact,
      'emergency_phone': instance.emergency_phone,
    };
