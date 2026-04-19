import 'auth_service.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/patient.dart';
import '../models/utilisateur.dart';

class MockAuthService implements AuthService {
  // Simule un délai réseau
  Future<void> _simulateDelay() => Future.delayed(const Duration(seconds: 2));

  @override
  Future<AuthResponse> registerPatient(RegisterRequest request) async {
    await _simulateDelay();

    // Simule une erreur si l'email existe déjà
    if (request.email == 'existe@test.com') {
      throw Exception('Email déjà utilisé');
    }

    final utilisateur = Utilisateur(
      id: 1,
      username: request.username,
      firstName: request.first_name,
      lastName: request.last_name,
      email: request.email,
      phone: request.phone,
      role: request.role,
      dateOfBirth: null,
      address: null,
      isActive: true,
    );

    final patient = Patient(
      id: 1,
      user: utilisateur,
      bloodType: request.blood_type,
      allergies: request.allergies,
      emergencyContact: request.emergency_contact,
      emergencyPhone: request.emergency_phone,
    );

    final authResponse = AuthResponse(
      token: "mock_jwt_token_${request.username}",
      user: utilisateur,
      patient_profile: patient,
      message: "Inscription réussie",
    );

    return authResponse;
  }

  @override
  Future<AuthResponse> loginPatient(String email, String password) async {
    await _simulateDelay();

    if (email == 'patient@test.com' && password == 'password') {
      // Simule un utilisateur patient pour les tests
      final utilisateur = Utilisateur(
        id: 1,
        username: 'testpatient',
        firstName: 'Test',
        lastName: 'Patient',
        email: email,
        phone: '+1234567890',
        role: 'PATIENT',
        dateOfBirth: null,
        address: null,
        isActive: true,
      );

      final patient = Patient(
        id: 1,
        user: utilisateur,
        bloodType: 'A+',
        allergies: null,
        emergencyContact: 'Contact Urgence',
        emergencyPhone: '+0987654321',
      );

      return AuthResponse(
        token: "mock_jwt_token_patient_12345",
        user: utilisateur,
        patient_profile: patient,
      );
    } else {
      throw Exception('Identifiants incorrects');
    }
  }

  @override
  Future<AuthResponse> loginDoctor(String email, String password) async {
    await _simulateDelay();

    if (email == 'doctor@test.com' && password == 'password') {
      // Simule un utilisateur médecin
      final utilisateur = Utilisateur(
        id: 2,
        username: 'testdoctor',
        firstName: 'Test',
        lastName: 'Doctor',
        email: email,
        phone: '+1234567890',
        role: 'DOCTOR',
        dateOfBirth: null,
        address: null,
        isActive: true,
      );

      // Note: AuthResponse structure might need doctor_profile if separate,
      // but assuming consistent response structure or patient_profile is null.
      return AuthResponse(
        token: "mock_jwt_token_doctor_67890",
        user: utilisateur,
        patient_profile: null,
      );
    } else {
      throw Exception('Identifiants incorrects');
    }
  }

  @override
  Future<void> logout() async {
    await _simulateDelay();
    print("Déconnexion simulée");
  }
}
