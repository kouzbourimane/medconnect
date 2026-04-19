import 'package:flutter/material.dart';
import '../models/doctor_dashboard_data.dart';
import '../models/patient_dashboard_data.dart'; // For shared models like DashboardAppointment

class DoctorDashboardViewModel extends ChangeNotifier {
  DoctorDashboardData? _dashboardData;
  bool _isLoading = false;
  String? _error;

  DoctorDashboardData? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchDashboardData(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // TODO: Replace with actual API call
      // await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

      // Mock Data
      final mockData = {
        'doctor_profile': {
          'first_name': 'Dr. Dupont',
          'specialty': 'Cardiologie',
        },
        'today_appointments': [
          {
            'id': 1,
            'doctor_name': 'Patient A', // Reusing field for display
            'specialty': 'Consultation',
            'date': DateTime.now().toIso8601String(),
            'status': 'Confirmé',
          },
          {
            'id': 2,
            'doctor_name': 'Patient B',
            'specialty': 'Suivi',
            'date': DateTime.now().add(const Duration(hours: 2)).toIso8601String(),
            'status': 'En attente',
          },
        ],
        'patients_seen_count': 12,
        'upcoming_appointments_count': 5,
        'unread_messages_count': 3,
        'recent_notifications': [
          {
            'id': 1,
            'title': 'Nouveau RDV',
            'message': 'Patient X souhaite un RDV.',
            'date': DateTime.now().toIso8601String(),
            'type': 'INFO',
          },
          {
            'id': 2,
            'title': 'Document reçu',
            'message': 'Résultats labo disponibles.',
            'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            'type': 'INFO',
          },
        ],
      };

      _dashboardData = DoctorDashboardData.fromJson(mockData);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
