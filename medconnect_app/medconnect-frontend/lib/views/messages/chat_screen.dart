import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/chat_message.dart';
import '../../models/conversation.dart';
import '../../view_models/doctor_auth_view_model.dart';
import '../../view_models/messages_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';
import '../common/document_viewer_screen.dart';

class ChatScreen extends StatefulWidget {
  final String role;
  final Conversation conversation;

  const ChatScreen({
    required this.role,
    required this.conversation,
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  PlatformFile? _selectedAttachment;
  bool _isSending = false;

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

  Future<void> _pickAttachment() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    setState(() {
      _selectedAttachment = result.files.single;
    });
  }

  Future<void> _sendMessage() async {
    final content = _controller.text.trim();
    final token = _resolveToken();
    if ((content.isEmpty && _selectedAttachment == null) || token == null) {
      return;
    }

    final viewModel = Provider.of<MessagesViewModel>(context, listen: false);
    setState(() => _isSending = true);
    final success = await viewModel.sendMessage(
      token,
      widget.conversation.id,
      content,
      fileBytes: _selectedAttachment?.bytes,
      fileName: _selectedAttachment?.name,
    );

    if (!mounted) return;
    setState(() {
      _isSending = false;
      if (success) {
        _selectedAttachment = null;
      }
    });

    if (success) {
      _controller.clear();
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error ?? 'Envoi impossible')),
      );
    }
  }

  void _openAttachment(ChatAttachment attachment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentViewerScreen(
          url: attachment.fileUrl,
          title: attachment.fileName,
          documentType: attachment.fileType,
        ),
      ),
    );
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_selectedAttachment != null)
                    Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9F1F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.attach_file,
                            color: Color(0xFF567991),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedAttachment!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() => _selectedAttachment = null);
                            },
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFE9F1F5),
                        child: IconButton(
                          onPressed: _isSending ? null : _pickAttachment,
                          icon: const Icon(
                            Icons.attach_file,
                            color: Color(0xFF567991),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                          onPressed: _isSending ? null : _sendMessage,
                          icon: _isSending
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile(ChatAttachment attachment, bool isMine) {
    return InkWell(
      onTap: attachment.fileUrl.isEmpty ? null : () => _openAttachment(attachment),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isMine ? const Color(0x338BC6EC) : const Color(0xFFF2F5F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              attachment.isImage
                  ? Icons.image_outlined
                  : Icons.picture_as_pdf_outlined,
              color: isMine ? Colors.white : const Color(0xFF567991),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                attachment.fileName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isMine ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
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
            if (message.content.isNotEmpty)
              Text(
                message.content,
                style: TextStyle(
                  color: message.isMine ? Colors.white : Colors.black87,
                ),
              ),
            for (final attachment in message.attachments)
              _buildAttachmentTile(attachment, message.isMine),
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
