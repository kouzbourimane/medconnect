import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/medical_record_model.dart';
import 'api_service.dart';

class MedicalRecordService {
  final String _endpoint = "${ApiService.apiPrefix}/patient/medical-record/";

  Future<MedicalRecordModel> getMedicalRecord(String token) async {
    final response = await http.get(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      return MedicalRecordModel.fromJson(decodedData);
    } else {
      throw Exception(
        'Erreur lors de la récupération du dossier médical: ${response.statusCode}',
      );
    }
  }
}
