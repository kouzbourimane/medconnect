// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'utilisateur.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Utilisateur _$UtilisateurFromJson(Map<String, dynamic> json) => Utilisateur(
  id: (json['id'] as num).toInt(),
  username: json['username'] as String,
  firstName: json['first_name'] as String?,
  lastName: json['last_name'] as String?,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role: json['role'] as String,
  dateOfBirth: json['date_of_birth'] as String?,
  address: json['address'] as String?,
  isActive: json['is_active'] as bool,
);

Map<String, dynamic> _$UtilisateurToJson(Utilisateur instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'role': instance.role,
      'date_of_birth': instance.dateOfBirth,
      'address': instance.address,
      'is_active': instance.isActive,
    };
