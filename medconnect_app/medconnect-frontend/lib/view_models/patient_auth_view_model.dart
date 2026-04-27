import 'package:flutter/foundation.dart';
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../repositories/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientAuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository;

  PatientAuthViewModel(this._authRepository);

  bool _isLoading = false;
  String? _errorMessage;
  AuthResponse? _authResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthResponse? get authResponse => _authResponse;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _authResponse = await _authRepository.loginPatient(email, password);

      if (_authResponse?.user?.role != 'PATIENT') {
        _authResponse = null;
        _errorMessage =
            'Ce compte n\'est pas un compte patient. Connectez-vous depuis l\'espace médecin.';
        return false;
      }

      if (_authResponse?.token != null) {
        print('Patient Key received: ${_authResponse!.token}');

        // Sauvegarder le token et les infos utilisateur
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authResponse!.token!);
        if (_authResponse!.user != null) {
          await prefs.setString('user_id', _authResponse!.user!.id.toString());
          await prefs.setString('username', _authResponse!.user!.username);
          await prefs.setString('user_role', 'PATIENT');
        }

        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      print("Erreur de connexion ViewModel: $_errorMessage");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Expose register functionality here or keep it separately?
  // Existing AuthViewModel had registerPatient. I should probably include it here too or just use AuthViewModel for registration if unified.
  // But unified login implies unified auth handling split by role.
  // I'll add registerPatient here as well to be self-contained for patients.

  Future<bool> register(RegisterRequest request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _authResponse = await _authRepository.registerPatient(request);
      if (_authResponse?.token != null) {
        print('Patient Registered, Token: ${_authResponse!.token}');

        // Sauvegarder le token après inscription
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authResponse!.token!);
        if (_authResponse!.user != null) {
          await prefs.setString('user_id', _authResponse!.user!.id.toString());
          await prefs.setString('username', _authResponse!.user!.username);
          await prefs.setString('user_role', 'PATIENT');
        }

        return true;
      }
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _authResponse = null;
    notifyListeners();
  }
}
