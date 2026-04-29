import 'package:flutter/foundation.dart';
import 'dart:io';

import '../models/chat_message.dart';
import '../models/conversation.dart';
import '../services/message_service.dart';

class MessagesViewModel with ChangeNotifier {
  final MessageService _messageService = MessageService();

  bool _isLoading = false;
  String? _error;
  List<Conversation> _conversations = [];
  List<ConversationContact> _contacts = [];
  List<ChatMessage> _messages = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Conversation> get conversations => _conversations;
  List<ConversationContact> get contacts => _contacts;
  List<ChatMessage> get messages => _messages;
  int get totalUnreadCount =>
      _conversations.fold(0, (sum, item) => sum + item.unreadCount);

  Future<void> loadConversations(String token) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _conversations = await _messageService.getConversations(token)
        ..sort((a, b) => b.sortDate.compareTo(a.sortDate));
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadContacts(String token) async {
    _error = null;
    try {
      _contacts = await _messageService.getContacts(token);
      notifyListeners();
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<Conversation?> startConversation(
    String token, {
    int? doctorId,
    int? patientId,
  }) async {
    _error = null;
    try {
      final conversation = await _messageService.startConversation(
        token,
        doctorId: doctorId,
        patientId: patientId,
      );
      await loadConversations(token);
      return conversation;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }

  Future<void> loadMessages(String token, int conversationId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _messages = await _messageService.getMessages(token, conversationId);
      await _messageService.markRead(token, conversationId);
      await loadConversations(token);
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(
    String token,
    int conversationId,
    String content, {
    File? file,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final message = await _messageService.sendMessage(
        token,
        conversationId,
        content,
        file: file,
        fileBytes: fileBytes,
        fileName: fileName,
      );
      _messages = [..._messages, message];
      await loadConversations(token);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
