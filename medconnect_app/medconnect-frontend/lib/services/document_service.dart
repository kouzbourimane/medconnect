import 'dart:convert';
import 'dart:io';
<<<<<<< HEAD
import 'dart:typed_data';
=======
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
import 'package:http/http.dart' as http;
import '../models/medical_document_model.dart';
import 'api_service.dart';

class DocumentService {
  final String _baseUrl = ApiService.apiPrefix;

  Future<List<MedicalDocument>> getDocuments(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/patient/documents/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
      return data.map((json) => MedicalDocument.fromJson(json)).toList();
    } else {
      throw Exception(
        'Erreur de chargement des documents (${response.statusCode})',
      );
    }
  }

  Future<MedicalDocument> uploadDocument({
    required String token,
<<<<<<< HEAD
    File? file,
    Uint8List? fileBytes,
    String? fileName,
=======
    required File file,
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    required String title,
    required String documentType,
    String? description,
  }) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/patient/documents/upload/'),
    );

    request.headers['Authorization'] = 'Token $token';
    request.fields['title'] = title;
    request.fields['document_type'] = documentType;
    if (description != null) {
      request.fields['description'] = description;
    }

<<<<<<< HEAD
    if (fileBytes != null) {
      // Web Upload
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName ?? 'document.pdf',
      ));
    } else if (file != null) {
      // Mobile Upload
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    } else {
       throw Exception("Aucun fichier fourni");
    }
=======
    request.files.add(await http.MultipartFile.fromPath('file', file.path));
>>>>>>> 21b118e356682c0277daf70006db17122b794da3

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return MedicalDocument.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      final errorData = json.decode(utf8.decode(response.bodyBytes));
      throw Exception(errorData['error'] ?? 'Erreur lors de l\'upload');
    }
  }
}
