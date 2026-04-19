import 'package:flutter/material.dart';
import '../models/doctor_schedule.dart';
import '../repositories/doctor_repository.dart';

class DoctorProfileViewModel with ChangeNotifier {
  final DoctorRepository _repository;

  DoctorProfileViewModel(this._repository);

  bool _isLoading = false;
  DoctorSchedule _schedule = DoctorSchedule();
  Map<String, dynamic> _profileData = {}; // Stores bio, price, etc.

  bool get isLoading => _isLoading;
  DoctorSchedule get schedule => _schedule;
  Map<String, dynamic> get profileData => _profileData;

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _schedule = await _repository.getSchedule();
      final localProfile = await _repository.getProfile();
      if (localProfile != null) {
        _profileData = localProfile;
      }
    } catch (e) {
      print("Error loading profile data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateSchedule(DoctorSchedule newSchedule) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _repository.saveSchedule(newSchedule);
      _schedule = newSchedule;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
     _isLoading = true;
    notifyListeners();
    try {
      await _repository.saveProfile(data);
      _profileData = data;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
