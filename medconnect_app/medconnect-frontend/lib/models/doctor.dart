class Doctor {
  final int id;
  final String firstName;
  final String lastName;
  final String speciality;
  final double consultationFee;
  final String? bio;

  Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.speciality,
    required this.consultationFee,
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
    );
  }

  String get fullName => "Dr. $firstName $lastName";
}
