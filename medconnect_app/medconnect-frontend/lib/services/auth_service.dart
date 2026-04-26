import '../models/register_request.dart';
import '../models/auth_response.dart';

abstract class AuthService {
  Future<AuthResponse> registerPatient(RegisterRequest request);
  Future<AuthResponse> registerDoctor(Map<String, dynamic> data);
  Future<AuthResponse> loginPatient(String email, String password);
  Future<AuthResponse> loginDoctor(String email, String password);
  // Future<AuthResponse> login(String email, String password); // Removed generic login

  Future<void> logout();
}
