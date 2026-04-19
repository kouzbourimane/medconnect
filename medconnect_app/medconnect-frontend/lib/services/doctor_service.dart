import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/doctor.dart';
<<<<<<< HEAD
import '../repositories/doctor_repository.dart';
=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

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

<<<<<<< HEAD
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
=======
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
      throw Exception('Erreur de chargement des disponibilités');
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
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
