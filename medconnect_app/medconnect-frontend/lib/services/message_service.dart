import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/chat_message.dart';
import '../models/conversation.dart';
import 'api_service.dart';

class MessageService {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Token $token',
      };

  dynamic _decode(http.Response response) {
    final body = utf8.decode(response.bodyBytes);
    if (body.isEmpty) {
      return null;
    }
    try {
      return json.decode(body);
    } on FormatException {
      return null;
    }
  }

  String _responsePreview(http.Response response) {
    final body = utf8.decode(response.bodyBytes).trim();
    if (body.isEmpty) {
      return 'Réponse vide';
    }
    final compact = body.replaceAll(RegExp(r'\s+'), ' ');
    return compact.length > 120 ? '${compact.substring(0, 120)}...' : compact;
  }

  String _parseError(http.Response response) {
    final decoded = _decode(response);
    if (decoded is Map<String, dynamic>) {
      if (decoded['detail'] != null) return decoded['detail'].toString();
      if (decoded['error'] != null) return decoded['error'].toString();
      if (decoded['message'] != null) return decoded['message'].toString();
      if (decoded['non_field_errors'] is List &&
          decoded['non_field_errors'].isNotEmpty) {
        return decoded['non_field_errors'].first.toString();
      }
      for (final entry in decoded.entries) {
        if (entry.value is List && entry.value.isNotEmpty) {
          return '${entry.key}: ${entry.value.first}';
        }
      }
    }
    final contentType = response.headers['content-type'] ?? '';
    if (contentType.contains('text/html')) {
      return 'Le serveur a renvoyé une page HTML au lieu du JSON attendu (${response.statusCode}). Vérifiez l’URL API et la connexion au backend.';
    }
    return 'Erreur serveur (${response.statusCode})';
  }

  T _expectJson<T>(http.Response response, String endpointLabel) {
    final decoded = _decode(response);
    if (decoded is T) {
      return decoded;
    }
    final contentType = response.headers['content-type'] ?? 'inconnu';
    throw Exception(
      'Réponse invalide pour $endpointLabel: JSON attendu, reçu $contentType. Aperçu: ${_responsePreview(response)}',
    );
  }

  Future<List<Conversation>> getConversations(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.apiPrefix}/conversations/'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = _expectJson<List<dynamic>>(response, 'la liste des conversations');
    return body.map((item) => Conversation.fromJson(item)).toList();
  }

  Future<List<ConversationContact>> getContacts(String token) async {
    final response = await http.get(
      Uri.parse('${ApiService.apiPrefix}/conversations/contacts/'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = _expectJson<List<dynamic>>(response, 'la liste des contacts');
    return body.map((item) => ConversationContact.fromJson(item)).toList();
  }

  Future<Conversation> startConversation(
    String token, {
    int? doctorId,
    int? patientId,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.apiPrefix}/conversations/start/'),
      headers: _headers(token),
      body: json.encode({
        if (doctorId != null) 'doctor_id': doctorId,
        if (patientId != null) 'patient_id': patientId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_parseError(response));
    }

    return Conversation.fromJson(
      _expectJson<Map<String, dynamic>>(response, 'la création de conversation'),
    );
  }

  Future<List<ChatMessage>> getMessages(String token, int conversationId) async {
    final response = await http.get(
      Uri.parse('${ApiService.apiPrefix}/conversations/$conversationId/messages/'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }

    final body = _expectJson<List<dynamic>>(response, 'les messages');
    return body.map((item) => ChatMessage.fromJson(item)).toList();
  }

  Future<ChatMessage> sendMessage(
    String token,
    int conversationId,
    String content, {
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    final uri = Uri.parse(
      '${ApiService.apiPrefix}/conversations/$conversationId/send/',
    );
    http.Response response;

    if (file != null || fileBytes != null) {
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Token $token';
      request.headers['Accept'] = 'application/json';
      request.fields['content'] = content;

      if (fileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            fileBytes,
            filename: fileName ?? 'piece-jointe.pdf',
          ),
        );
      } else if (file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            file.path,
            filename: fileName,
          ),
        );
      }

      response = await http.Response.fromStream(await request.send());
    } else {
      response = await http.post(
        uri,
        headers: _headers(token),
        body: json.encode({'content': content}),
      );
    }

    if (response.statusCode != 201) {
      throw Exception(_parseError(response));
    }

    return ChatMessage.fromJson(
      _expectJson<Map<String, dynamic>>(response, 'l’envoi de message'),
    );
  }

  Future<void> markRead(String token, int conversationId) async {
    final response = await http.post(
      Uri.parse('${ApiService.apiPrefix}/conversations/$conversationId/mark_read/'),
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception(_parseError(response));
    }
  }
}
