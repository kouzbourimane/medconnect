import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/doctor.dart';
import '../repositories/doctor_repository.dart';

class DoctorService {
  Future<Map<String, dynamic>> getAvailability(
    String token,
    int doctorId,
    DateTime date,
  ) async {
    final dateStr = date.toIso8601String().split('T')[0];
    final url = Uri.parse(
      '${ApiService.apiPrefix}/doctors/$doctorId/availability/?date=$dateStr',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Token $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        print("Erreur disponibilité: ${response.body}");
        return {'slots': []};
      }
    } catch (e) {
      print("Erreur réseau disponibilité: $e");
      return {'slots': []};
    }
  }

  // Placeholder for fetching doctor list if needed
  Future<List<Doctor>> getDoctors(String token) async {
    final url = Uri.parse('${ApiService.apiPrefix}/doctors/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => Doctor.fromJson(e)).toList();
    } else {
      throw Exception('Erreur de chargement des médecins');
    }
  }
}
