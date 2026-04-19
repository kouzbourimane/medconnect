import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';
import '../models/medical_document_model.dart';

class MedicalDocumentRepository {
  final String _baseUrl = '${ApiService.apiPrefix}/patient/documents/'; // Note: Prefix might be /patient/documents or just /medical-documents?
  // In urls.py: router.register(r'patient/documents', MedicalDocumentViewSet, basename='patient-documents')
  
  Future<List<MedicalDocument>> getDocumentsByPatient(String token, int patientId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?patient=$patientId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(utf8.decode(response.bodyBytes));
      return body.map((e) => MedicalDocument.fromJson(e)).toList();
    } else {
      throw Exception('Erreur chargement documents: ${response.statusCode}');
    }
  }

  Future<MedicalDocument> uploadDocument({
    required String token,
    File? file,
    Uint8List? fileBytes,
    String? fileName,
    required String title,
    required String type,
    required int patientId,
    String? description,
  }) async {
    final uri = Uri.parse('${_baseUrl}upload/');
    final request = http.MultipartRequest('POST', uri);
    
    request.headers['Authorization'] = 'Token $token';
    request.fields['patient'] = patientId.toString();
    request.fields['title'] = title;
    request.fields['document_type'] = type;
    if (description != null) request.fields['description'] = description;

    http.MultipartFile multipartFile;
    if (fileBytes != null) {
      multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'document.pdf',
      );
    } else if (file != null) {
      multipartFile = await http.MultipartFile.fromPath('file', file.path);
    } else {
      throw Exception('Aucun fichier fourni');
    }
    request.files.add(multipartFile);

    final response = await request.send();
    
    if (response.statusCode == 201) {
      final respStr = await response.stream.bytesToString();
      return MedicalDocument.fromJson(json.decode(respStr));
    } else {
      final respStr = await response.stream.bytesToString();
      throw Exception('Erreur upload: $respStr');
    }
  }
}
