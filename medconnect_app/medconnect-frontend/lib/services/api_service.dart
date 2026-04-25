import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/register_request.dart';
import '../models/auth_response.dart';
import '../models/patient_profile_model.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000";
  static const String apiPrefix = "$baseUrl/api";

  Future<AuthResponse> registerPatient(RegisterRequest request) async {
    final url = Uri.parse('$apiPrefix/auth/register/patient/');

    print('URL d\'inscription: $url');
    print('Données envoyées: ${request.toJson()}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(request.toJson()),
    );

    print('Statut de réponse: ${response.statusCode}');
    print('Corps de réponse: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      try {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['error'] ??
              errorBody['message'] ??
              'Erreur d\'inscription (${response.statusCode})',
        );
      } catch (e) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    }
  }

  Future<AuthResponse> registerDoctor(Map<String, dynamic> data) async {
    final url = Uri.parse('$apiPrefix/auth/register/doctor/');

    print('URL d\'inscription Médecin: $url');
    print('Données envoyées: $data');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );

    print('Statut de réponse: ${response.statusCode}');
    print('Corps de réponse: ${response.body}');

    if (response.statusCode == 201 || response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      try {
        final errorBody = json.decode(response.body);
        throw Exception(
          errorBody['error'] ??
              errorBody['message'] ??
              'Erreur d\'inscription (${response.statusCode})',
        );
      } catch (e) {
        throw Exception('Erreur serveur: ${response.statusCode}');
      }
    }
  }

  Future<PatientProfileModel> getPatientProfile(String token) async {
    final url = Uri.parse('$apiPrefix/patient/profile/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Erreur de chargement du profil: ${response.statusCode}');
    }
  }

  Future<PatientProfileModel> updatePatientProfile(
    String token,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$apiPrefix/patient/profile/');
    final response = await http.put(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 200) {
      return PatientProfileModel.fromJson(
        json.decode(utf8.decode(response.bodyBytes)),
      );
    } else {
      throw Exception('Erreur de mise à jour: ${response.statusCode}');
    }
  }

  Future<AuthResponse> loginPatient(String email, String password) async {
    final url = Uri.parse('$apiPrefix/auth/login/');
    return _loginStrict(url, email, password);
  }

  Future<AuthResponse> loginDoctor(String email, String password) async {
    final url = Uri.parse('$apiPrefix/auth/login/');
    return _loginStrict(url, email, password);
  }

  Future<AuthResponse> _loginStrict(
    Uri url,
    String email,
    String password,
  ) async {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception('Identifiants incorrects (${response.statusCode})');
    }
  }

  // Keeping generic login for backward compatibility if needed, but pointing to patient by default or deprecated?
  // User asked for specific endpoints. I will comment out or remove generic login if not used elsewhere,
  // but to be safe I will leave it or redirect it.
  // Given the user request, I'll just keep the new methods.
  // The generic login might be used by existing code. I'll check usages later or just keep it separate.
  // Actually, I'll replace the existing `login` to avoiding conflict if I use the same name,
  // but I can't overload. I'll just add the new ones and keep `login` for now or remove it if I replace usages.
  // The tool call `replace_file_content` replaces the specific chunk. I will replace the `login` function with `loginPatient` and `loginDoctor` and a private helper.
  // Wait, `ApiAuthService` uses `login`. I should check `ApiAuthService` first.
}
