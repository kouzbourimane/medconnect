import 'package:flutter/material.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../repositories/doctor_patient_repository.dart';

class DoctorPatientsViewModel with ChangeNotifier {
  final DoctorPatientRepository _repository;

  DoctorPatientsViewModel(this._repository);

  bool _isLoading = false;
  List<Patient> _patients = [];
  List<Patient> _filteredPatients = [];
  
  // Cache for search
  String _searchQuery = '';

  // History cache
  bool _isLoadingHistory = false;
  List<Appointment> _selectedPatientHistory = [];

  bool get isLoading => _isLoading;
  bool get isLoadingHistory => _isLoadingHistory;
  List<Patient> get patients => _filteredPatients;
  List<Appointment> get selectedPatientHistory => _selectedPatientHistory;

  Future<void> fetchPatients(String token) async {
    _isLoading = true;
    notifyListeners();

    try {
      _patients = await _repository.getMyPatients(token);
      _filterPatients();
    } catch (e) {
      print("Error fetching patients: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void search(String query) {
    _searchQuery = query;
    _filterPatients();
  }

  void _filterPatients() {
    if (_searchQuery.isEmpty) {
      _filteredPatients = List.from(_patients);
    } else {
      final lower = _searchQuery.toLowerCase();
      _filteredPatients = _patients.where((p) {
        final first = p.user.firstName?.toLowerCase() ?? '';
        final last = p.user.lastName?.toLowerCase() ?? '';
        return first.contains(lower) || last.contains(lower);
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchPatientHistory(String token, int patientId) async {
    _isLoadingHistory = true;
    _selectedPatientHistory = []; // clear previous
    notifyListeners();

    try {
      _selectedPatientHistory = await _repository.getPatientHistory(token, patientId);
    } catch (e) {
       print("Error fetching history: $e");
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }
}
