import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medconnect_app/repositories/auth_repository.dart';
import 'package:medconnect_app/models/auth_response.dart';

class DoctorAuthViewModel with ChangeNotifier {
  final AuthRepository _authRepository;

  DoctorAuthViewModel(this._authRepository);

  bool _isLoading = false;
  String? _errorMessage;
  AuthResponse? _authResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AuthResponse? get authResponse => _authResponse;
  
  // Getter for easy access to user
  get user => _authResponse?.user;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _authResponse = await _authRepository.loginDoctor(email, password);

      if (_authResponse?.user?.role != 'DOCTOR') {
        _authResponse = null;
        _errorMessage =
            'Ce compte n\'est pas un compte médecin. Connectez-vous depuis l\'espace patient.';
        return false;
      }

      // TODO: Save token
      if (_authResponse?.token != null) {
        print('Doctor Token received: ${_authResponse!.token}');
        
        // Save token and user info
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', _authResponse!.token!);
        if (_authResponse!.user != null) {
          await prefs.setString('user_id', _authResponse!.user!.id.toString());
          await prefs.setString('username', _authResponse!.user!.username);
          await prefs.setString('user_role', 'DOCTOR');
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

  Future<void> logout() async {
    _authResponse = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
