import 'package:medconnect_app/models/auth_response.dart';
import 'package:medconnect_app/models/register_request.dart';
import 'package:medconnect_app/services/auth_service.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({
    this.patientLoginResponse,
    this.doctorLoginResponse,
    this.registerPatientResponse,
    this.registerDoctorResponse,
    this.loginError,
  });

  final AuthResponse? patientLoginResponse;
  final AuthResponse? doctorLoginResponse;
  final AuthResponse? registerPatientResponse;
  final AuthResponse? registerDoctorResponse;
  final Exception? loginError;

  @override
  Future<AuthResponse> loginPatient(String email, String password) async {
    if (loginError != null) {
      throw loginError!;
    }
    return patientLoginResponse ?? AuthResponse(message: 'ok');
  }

  @override
  Future<AuthResponse> loginDoctor(String email, String password) async {
    if (loginError != null) {
      throw loginError!;
    }
    return doctorLoginResponse ?? AuthResponse(message: 'ok');
  }

  @override
  Future<AuthResponse> registerPatient(RegisterRequest request) async {
    return registerPatientResponse ?? AuthResponse(message: 'ok');
  }

  @override
  Future<AuthResponse> registerDoctor(Map<String, dynamic> data) async {
    return registerDoctorResponse ?? AuthResponse(message: 'ok');
  }

  @override
  Future<void> logout() async {}
}
