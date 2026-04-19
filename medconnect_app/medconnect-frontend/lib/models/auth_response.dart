import 'package:json_annotation/json_annotation.dart';
import 'utilisateur.dart';
import 'patient.dart';

part 'auth_response.g.dart';

@JsonSerializable()
class AuthResponse {
  final String? token;
  final Utilisateur? user;
  final Patient? patient_profile;
  final String? message;

  AuthResponse({
    this.token,
    this.user,
    this.patient_profile,
    this.message,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}