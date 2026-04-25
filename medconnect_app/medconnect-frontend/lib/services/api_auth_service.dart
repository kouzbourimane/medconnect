import 'package:http/http.dart' as storage;

import 'auth_service.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import 'api_service.dart';

/// Implémentation réelle qui envoie les requêtes à votre backend Django.
class ApiAuthService implements AuthService {
  final ApiService _apiService = ApiService();

  @override
  Future<AuthResponse> registerPatient(RegisterRequest request) async {
    return await _apiService.registerPatient(request);
  }

  @override
  Future<AuthResponse> registerDoctor(Map<String, dynamic> data) async {
    return await _apiService.registerDoctor(data);
  }

  @override
  Future<AuthResponse> loginPatient(String email, String password) async {
    return await _apiService.loginPatient(email, password);
  }

  @override
  Future<AuthResponse> loginDoctor(String email, String password) async {
    return await _apiService.loginDoctor(email, password);
  }

  @override
  Future<void> logout() async {
    // Implémentation de la déconnexion
    //await storage.delete(key: 'auth_token');
    print("Déconnexion de l'API");
  }
}
