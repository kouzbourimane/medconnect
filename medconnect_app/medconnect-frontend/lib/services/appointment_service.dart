import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import 'api_service.dart';

class AppointmentService {
  Future<Appointment> _postAppointmentAction(
    String token,
    int id,
    String action, {
    Map<String, dynamic>? body,
  }) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/$action/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode(body ?? const {}),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    }

    final errorBody = json.decode(response.body);
    throw Exception(
      errorBody['detail'] ??
          errorBody['non_field_errors']?[0] ??
          errorBody['reason']?.first ??
          'Erreur lors de l\'action sur le rendez-vous',
    );
  }

  Future<List<Appointment>> getAppointments(String token) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/');
    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> body = json.decode(response.body);
      return body.map((e) => Appointment.fromJson(e)).toList();
    }

    throw Exception('Erreur de chargement des rendez-vous');
  }

  Future<Appointment> createAppointment(
    String token,
    int doctorId,
    DateTime date,
    String reason,
  ) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'doctor': doctorId,
        'date': date.toIso8601String(),
        'reason': reason,
      }),
    );

    if (response.statusCode == 201) {
      return Appointment.fromJson(json.decode(response.body));
    }

    final errorBody = json.decode(response.body);
    throw Exception(
      errorBody['non_field_errors']?[0] ??
          'Erreur lors de la prise de rendez-vous',
    );
  }

  Future<Appointment> acceptAppointment(String token, int id) {
    return _postAppointmentAction(token, id, 'accept');
  }

  Future<Appointment> refuseAppointment(String token, int id, {String? reason}) {
    return _postAppointmentAction(
      token,
      id,
      'refuse',
      body: {'reason': reason ?? ''},
    );
  }

  Future<Appointment> cancelAppointment(String token, int id, {String? reason}) {
    return _postAppointmentAction(
      token,
      id,
      'cancel',
      body: {'reason': reason ?? ''},
    );
  }

  Future<Appointment> completeAppointment(String token, int id) {
    return _postAppointmentAction(token, id, 'complete');
  }
}
