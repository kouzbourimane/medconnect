<<<<<<< HEAD
=======
import 'utilisateur.dart';

>>>>>>> 21b118e356682c0277daf70006db17122b794da3
class PatientProfileModel {
  final String? bloodType;
  final String? allergies;
  final String? emergencyContact;
  final String? emergencyPhone;
  final double? height;
  final double? weight;
<<<<<<< HEAD
=======
  final Utilisateur? user;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  PatientProfileModel({
    this.bloodType,
    this.allergies,
    this.emergencyContact,
    this.emergencyPhone,
    this.height,
    this.weight,
<<<<<<< HEAD
=======
    this.user,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      bloodType: json['blood_type'],
      allergies: json['allergies'],
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      height: json['height'] != null
          ? (json['height'] as num).toDouble()
          : null,
      weight: json['weight'] != null
          ? (json['weight'] as num).toDouble()
          : null,
<<<<<<< HEAD
=======
      user: json['user'] != null ? Utilisateur.fromJson(json['user']) : null,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'blood_type': bloodType,
      'allergies': allergies,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'height': height,
      'weight': weight,
    };
  }

  double? calculateBMI() {
    if (height == null || weight == null || height == 0) return null;
    double heightInMeters = height! / 100;
    return weight! / (heightInMeters * heightInMeters);
  }
}
