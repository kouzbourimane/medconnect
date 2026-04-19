import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/medical_record.dart';

class MedicalRecordRepository {
  final String _baseUrl = '${ApiService.apiPrefix}/medical-records/';

  Future<List<MedicalRecord>> getRecordsByPatient(String token, int patientId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?patient=$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((e) => MedicalRecord.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement dossiers: ${response.statusCode}');
    }
  }

  Future<MedicalRecord> addRecord(String token, MedicalRecord record) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode(record.toJson()),
    );

    if (response.statusCode == 201) {
      return MedicalRecord.fromJson(json.decode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception('Erreur ajout dossier: ${response.body}');
    }
  }
}
