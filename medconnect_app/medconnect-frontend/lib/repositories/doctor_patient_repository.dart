import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/patient.dart';
import '../models/appointment.dart';
import '../services/api_service.dart';

class DoctorPatientRepository {
  Future<List<Patient>> getMyPatients(String token) async {
    final url = Uri.parse('${ApiService.apiPrefix}/doctors/my_patients/');

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        return body.map((e) => Patient.fromJson(e)).toList();
      } else {
        print("Erreur API my_patients: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Erreur réseau my_patients: $e");
      return [];
    }
  }

  Future<List<Appointment>> getPatientHistory(String token, int patientId) async {
    // Fetch all doctor appointments
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body);
        final allAppointments = body.map((e) => Appointment.fromJson(e)).toList();
        
        // Filter locally by patientId
        return allAppointments.where((appt) => appt.patientId == patientId).toList();
      } else {
        print("Erreur API appointments: ${response.statusCode}");
        return [];
      }
    } catch (e) {
       print("Erreur réseau appointments: $e");
      return [];
    }
  }
}
