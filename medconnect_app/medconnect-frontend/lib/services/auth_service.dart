import '../models/register_request.dart';
import '../models/auth_response.dart';

abstract class AuthService {
  Future<AuthResponse> registerPatient(RegisterRequest request);
<<<<<<< HEAD
  Future<AuthResponse> registerDoctor(Map<String, dynamic> data);
  Future<AuthResponse> loginPatient(String email, String password);
  Future<AuthResponse> loginDoctor(String email, String password);
  // Future<AuthResponse> login(String email, String password); // Removed generic login
=======
  Future<AuthResponse> loginPatient(String email, String password);
  Future<AuthResponse> loginDoctor(String email, String password);
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

  Future<void> logout();
}
