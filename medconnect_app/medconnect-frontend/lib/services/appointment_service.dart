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
      try {
        return Appointment.fromJson(json.decode(response.body));
      } catch (e) {
        throw Exception('Réponse serveur invalide (JSON attendu).');
      }
    } else {
      throw Exception(_parseErrorResponse(response));
    }
  }

  Future<Appointment> updateStatus(
    String token,
    int id,
    String status, {
    String? reason,
  }) async {
    // Mapper le statut vers l'action backend dédiée
    String action;
    switch (status) {
      case Appointment.statusConfirmed:
        action = 'accept';
        break;
      case Appointment.statusRefused:
        action = 'refuse';
        break;
      case Appointment.statusCancelled:
        action = 'cancel';
        break;
      case Appointment.statusCompleted:
        action = 'complete';
        break;
      default:
        action = 'cancel';
    }

    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/$action/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
      body: json.encode({
        if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
      }),
    );

    if (response.statusCode == 200) {
      try {
        return Appointment.fromJson(json.decode(response.body));
      } catch (e) {
        throw Exception('Réponse serveur invalide (JSON attendu).');
      }
    } else {
      throw Exception(_parseErrorResponse(response));
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
      body: json.encode({'date': newDate.toIso8601String()}),
    );

    if (response.statusCode == 200) {
      try {
        return Appointment.fromJson(json.decode(response.body));
      } catch (e) {
        throw Exception('Réponse serveur invalide (JSON attendu).');
      }
    } else {
      throw Exception(_parseErrorResponse(response));
    }
  }

  Future<void> cancelAppointment(String token, int id) async {
    final url = Uri.parse('${ApiService.apiPrefix}/appointments/$id/cancel/');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_parseErrorResponse(response));
    }
  }

  /// Parse une réponse d'erreur en toute sécurité.
  /// Si le backend renvoie du HTML (page d'erreur Django 404/500),
  /// retourne un message lisible au lieu de planter.
  String _parseErrorResponse(http.Response response) {
    final body = response.body;
    if (body.isEmpty) {
      return 'Erreur serveur (${response.statusCode})';
    }

    // Si le corps commence par '<', c'est du HTML — pas du JSON
    if (body.trim().startsWith('<')) {
      switch (response.statusCode) {
        case 400:
          return 'Données invalides. Veuillez vérifier les informations.';
        case 401:
          return 'Session expirée. Veuillez vous reconnecter.';
        case 403:
          return 'Action refusée. Vous n\'avez pas les permissions nécessaires.';
        case 404:
          return 'Ressource introuvable sur le serveur.';
        case 500:
          return 'Erreur interne du serveur (500). Nos équipes ont été notifiées.';
        default:
          return 'Erreur serveur (${response.statusCode}).';
      }
    }

    // Essayer de parser en JSON
    try {
      final decoded = json.decode(body);
      if (decoded is Map) {
        if (decoded.containsKey('detail')) {
          return decoded['detail'].toString();
        }
        if (decoded.containsKey('non_field_errors')) {
          final errors = decoded['non_field_errors'];
          if (errors is List && errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
        if (decoded.containsKey('error')) {
          return decoded['error'].toString();
        }
        if (decoded.containsKey('message')) {
          return decoded['message'].toString();
        }
        // Premier champ d'erreur trouvé
        for (final entry in decoded.entries) {
          final val = entry.value;
          if (val is List && val.isNotEmpty) {
            return '${entry.key}: ${val.first}';
          }
          if (val is String && val.isNotEmpty) {
            return '${entry.key}: $val';
          }
        }
      } else if (decoded is List && decoded.isNotEmpty) {
        return decoded.first.toString();
      }
      return 'Erreur (${response.statusCode})';
    } catch (_) {
      return 'Erreur serveur (${response.statusCode}) — réponse inattendue.';
    }
  }
}
