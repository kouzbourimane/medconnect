import 'package:flutter/foundation.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../repositories/auth_repository.dart';

class AuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  bool _isLoading = false;
  String? _errorMessage;
  AuthResponse? _authResponse;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthResponse? get authResponse => _authResponse;

  // Inscription
  Future<bool> registerPatient(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _authResponse = await _authRepository.registerPatient(request);
      // Stocker le token dans SharedPreferences
      if (_authResponse?.token != null) {
        // TODO: Sauvegarder token avec shared_preferences
        print('Token reçu: ${_authResponse!.token}');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> registerDoctor(Map<String, dynamic> payload) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _authResponse = await _authRepository.registerDoctor(payload);
      if (_authResponse?.token != null) {
        // TODO: Sauvegarder token
        print('Token médecin reçu: ${_authResponse!.token}');
        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Connexion (Legacy/Generic - defaulting to Patient or deprecated)
  // Utiliser PatientAuthViewModel ou DoctorAuthViewModel pour les nouvelles implémentations.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Defaulting to patient for backward compatibility if strict needed
      _authResponse = await _authRepository.loginPatient(email, password);
      if (_authResponse?.token != null) {
        // TODO: Sauvegarder token
        print('Token reçu: ${_authResponse!.token}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
