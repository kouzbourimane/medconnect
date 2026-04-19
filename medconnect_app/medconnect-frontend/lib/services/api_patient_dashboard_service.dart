import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient_dashboard_data.dart';
import 'api_service.dart';

class ApiPatientDashboardService {
  Future<PatientDashboardData> fetchDashboardData(String token) async {
    final url = Uri.parse('${ApiService.apiPrefix}/patient/dashboard/');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return PatientDashboardData.fromJson(json.decode(response.body));
    } else {
      throw Exception(
        'Erreur de chargement du tableau de bord (${response.statusCode})',
      );
    }
  }
}
