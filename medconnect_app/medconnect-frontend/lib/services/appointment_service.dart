import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/appointment.dart';
import 'api_service.dart';

class AppointmentService {
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
    } else {
      throw Exception('Erreur de chargement des rendez-vous');
    }
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
    } else {
      final errorBody = json.decode(response.body);
      throw Exception(
        errorBody['non_field_errors']?[0] ??
            'Erreur lors de la prise de rendez-vous',
      );
    }
  }
<<<<<<< HEAD
  Future<Appointment> updateStatus(String token, int id, String status) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/');
    // Typically PATCH or PUT for status update
    final response = await http.patch(
=======

  Future<void> cancelAppointment(String token, int appointmentId) async {
    final url = Uri.parse(
      '${ApiService.apiPrefix}/appointments/$appointmentId/cancel/',
    );
    final response = await http.post(
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
<<<<<<< HEAD
      body: json.encode({
        'status': status,
      }),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la mise à jour du rendez-vous');
    }
  }

  Future<Appointment> reschedule(String token, int id, DateTime newDate) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/');
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        'date': newDate.toIso8601String(),
      }),
    );

    if (response.statusCode == 200) {
      return Appointment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Erreur lors de la modification du rendez-vous');
=======
    );

    if (response.statusCode != 200) {
      final body = json.decode(response.body);
      throw Exception(body['error'] ?? 'Impossible d\'annuler le rendez-vous');
>>>>>>> 21b118e356682c0277daf70006db17122b794da3
    }
  }
}
