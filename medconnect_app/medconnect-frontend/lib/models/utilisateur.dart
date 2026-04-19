import 'package:json_annotation/json_annotation.dart';

part 'utilisateur.g.dart';

@JsonSerializable()
class Utilisateur {
  final int id;
  final String username;
  @JsonKey(name: 'first_name')
  final String? firstName;
  @JsonKey(name: 'last_name')
  final String? lastName;
  final String email;
  final String? phone;
  final String role;
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? address;
  @JsonKey(name: 'is_active')
  final bool isActive;

  Utilisateur({
    required this.id,
    required this.username,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    required this.role,
    this.dateOfBirth,
    this.address,
    required this.isActive,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) =>
      _$UtilisateurFromJson(json);
  Map<String, dynamic> toJson() => _$UtilisateurToJson(this);
}