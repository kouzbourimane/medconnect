import 'package:flutter/foundation.dart';
import '../../models/patient_dashboard_data.dart';
import '../../services/api_patient_dashboard_service.dart';

class PatientDashboardViewModel with ChangeNotifier {
  final ApiPatientDashboardService _dashboardService =
      ApiPatientDashboardService();

  PatientDashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  PatientDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _dashboardData = await _dashboardService.fetchDashboardData(token);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
