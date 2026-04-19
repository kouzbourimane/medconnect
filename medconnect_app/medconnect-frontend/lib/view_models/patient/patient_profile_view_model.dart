import 'package:flutter/material.dart';
import '../../models/patient_profile_model.dart';
import '../../services/api_service.dart';

class PatientProfileViewModel extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  PatientProfileModel? _profileData;
  bool _isLoading = false;
  String? _error;

  PatientProfileModel? get profileData => _profileData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchProfile(String token) async {
    _setLoading(true);
    _clearError();
    try {
      _profileData = await _apiService.getPatientProfile(token);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile(String token, Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      _profileData = await _apiService.updatePatientProfile(token, data);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String value) {
    _error = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
<<<<<<< HEAD
=======

  Future<bool> changePassword(
    String token,
    String oldPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    _setLoading(true);
    _clearError();
    try {
      await _apiService.changePassword(
        token,
        oldPassword,
        newPassword,
        confirmPassword,
      );
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
}
