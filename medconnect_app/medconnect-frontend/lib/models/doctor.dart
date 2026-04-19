class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String speciality;
  final double consultationFee;
<<<<<<< HEAD
  final String? bio;
=======
  final bool isAvailable;
  final bool isActive;
  final String? bio;
  final String phone;
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.consultationFee,
<<<<<<< HEAD
=======
    required this.isAvailable,
    required this.isActive,
    required this.phone,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    this.bio,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      firstName: json['user']['first_name'] ?? '',
      lastName: json['user']['last_name'] ?? '',
      speciality: json['speciality_name'] ?? 'Général',
      consultationFee: json['consultation_fee'] != null
          ? double.tryParse(json['consultation_fee'].toString()) ?? 0.0
          : 0.0,
      bio: json['bio'],
<<<<<<< HEAD
=======
      isAvailable: json['is_available'] ?? false,
      isActive: json['user']['is_active'] ?? false,
      phone: json['user']['phone'] ?? 'Non disponible',
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    );
  }

  String get fullName => "Dr. $firstName $lastName";
}
