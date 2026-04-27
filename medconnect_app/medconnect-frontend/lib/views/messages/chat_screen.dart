import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import '../../view_models/doctor_auth_view_model.dart';
import '../../view_models/messages_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';

class ChatScreen extends StatefulWidget {
  final String role;
  final Conversation conversation;

  const ChatScreen({
    Key? key,
    required this.role,
    required this.conversation,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _resolveToken() {
    if (widget.role == 'DOCTOR') {
      return Provider.of<DoctorAuthViewModel>(context, listen: false)
          .authResponse
          ?.token;
    }
    return Provider.of<PatientAuthViewModel>(context, listen: false)
        .authResponse
        ?.token;
  }

  Future<void> _loadMessages() async {
    final token = _resolveToken();
    if (token == null) return;
    await Provider.of<MessagesViewModel>(context, listen: false).loadMessages(
      token,
      widget.conversation.id,
    );
    if (!mounted) return;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    final token = _resolveToken();
    if (content.isEmpty || token == null) return;

    final viewModel = Provider.of<MessagesViewModel>(context, listen: false);
    final success = await viewModel.sendMessage(
      token,
      widget.conversation.id,
      content,
    );

    if (!mounted) return;
    if (success) {
      _controller.clear();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error ?? 'Envoi impossible')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MessagesViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: Text(widget.conversation.counterpartName),
        backgroundColor: const Color(0xFF567991),
      ),
      body: Column(
        children: [
          Expanded(
            child: viewModel.isLoading && viewModel.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: viewModel.messages.length,
                    itemBuilder: (context, index) {
                      final message = viewModel.messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x11000000),
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Écrire un message...',
                        filled: true,
                        fillColor: const Color(0xFFF5F9FC),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF567991),
                    child: IconButton(
                      onPressed: _sendMessage,
                      icon: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final dateText = DateFormat(
      'dd/MM HH:mm',
    ).format(message.createdDate.toLocal());

    return Align(
      alignment: message.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 290),
        decoration: BoxDecoration(
          color: message.isMine ? const Color(0xFF567991) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: message.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!message.isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  message.senderName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF567991),
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: message.isMine ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              dateText,
              style: TextStyle(
                fontSize: 11,
                color: message.isMine ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
