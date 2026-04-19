import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository(this._authService);

  Future<AuthResponse> registerPatient(RegisterRequest request) {
    return _authService.registerPatient(request);
  }

<<<<<<< HEAD
  Future<AuthResponse> registerDoctor(Map<String, dynamic> data) {
    return _authService.registerDoctor(data);
  }

=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
  Future<AuthResponse> loginPatient(String email, String password) {
    return _authService.loginPatient(email, password);
  }

  Future<AuthResponse> loginDoctor(String email, String password) {
    return _authService.loginDoctor(email, password);
  }
}
