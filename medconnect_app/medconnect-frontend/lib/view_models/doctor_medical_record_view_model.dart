import 'package:flutter/material.dart';
import '../models/medical_record.dart';
import '../repositories/medical_record_repository.dart';

class DoctorMedicalRecordViewModel extends ChangeNotifier {
  final MedicalRecordRepository _repository = MedicalRecordRepository();
  List<MedicalRecord> _records = [];
  bool _isLoading = false;
  String? _error;

  List<MedicalRecord> get records => _records;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRecords(String token, int patientId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repository.getRecordsByPatient(token, patientId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addRecord(String token, MedicalRecord record) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRecord = await _repository.addRecord(token, record);
      _records.insert(0, newRecord); // Add to top
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
