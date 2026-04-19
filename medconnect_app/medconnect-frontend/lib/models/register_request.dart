import 'package:json_annotation/json_annotation.dart';

part 'register_request.g.dart';

@JsonSerializable()
class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final String? first_name;
  final String? last_name;
  final String? phone;
  final String role;
  final String? blood_type;
  final String? allergies;
  final String? emergency_contact;
  final String? emergency_phone;
<<<<<<< HEAD
=======
  @JsonKey(name: 'date_of_birth')
  final String? dateOfBirth;
  final String? address;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    this.first_name,
    this.last_name,
    this.phone,
    this.role = "PATIENT",
    this.blood_type,
    this.allergies,
    this.emergency_contact,
    this.emergency_phone,
<<<<<<< HEAD
=======
    this.dateOfBirth,
    this.address,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
<<<<<<< HEAD
}
=======
}
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
