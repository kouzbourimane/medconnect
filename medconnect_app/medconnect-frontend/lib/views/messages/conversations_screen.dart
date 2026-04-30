import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/conversation.dart';
import '../../view_models/doctor_auth_view_model.dart';
import '../../view_models/messages_view_model.dart';
import '../../view_models/patient_auth_view_model.dart';
import 'chat_screen.dart';

class ConversationsScreen extends StatefulWidget {
  final String role;

  const ConversationsScreen({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  State<ConversationsScreen> createState() => _ConversationsScreenState();
}

class _ConversationsScreenState extends State<ConversationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
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

  Future<void> _loadData() async {
    final token = _resolveToken();
    if (token == null) return;
    await Provider.of<MessagesViewModel>(context, listen: false)
        .loadConversations(token);
  }

  Future<void> _openContacts() async {
    final token = _resolveToken();
    if (token == null) return;

    final viewModel = Provider.of<MessagesViewModel>(context, listen: false);
    await viewModel.loadContacts(token);
    if (!mounted) return;
    if (viewModel.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(viewModel.error!)),
      );
      return;
    }

    final selected = await showModalBottomSheet<ConversationContact>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        final contacts = context.watch<MessagesViewModel>().contacts;
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Column(
              children: [
                const SizedBox(height: 12),
                const Text(
                  'Choisir un contact',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(),
                Expanded(
                  child: contacts.isEmpty
                      ? const Center(
                          child: Text(
                            'Aucun contact disponible.\nUn rendez-vous est nécessaire pour discuter.',
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: contacts.length,
                          itemBuilder: (context, index) {
                            final contact = contacts[index];
                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF567991)
                                    .withOpacity(0.12),
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Color(0xFF567991),
                                  ),
                                ),
                              ),
                              title: Text(contact.name),
                              subtitle: Text(contact.subtitle),
                              trailing: contact.conversationId != null
                                  ? const Icon(Icons.chat_bubble_outline)
                                  : const Icon(Icons.add_comment_outlined),
                              onTap: () => Navigator.pop(context, contact),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null || !mounted) return;

    final conversation = await viewModel.startConversation(
      token,
      doctorId: widget.role == 'PATIENT' ? selected.id : null,
      patientId: widget.role == 'DOCTOR' ? selected.id : null,
    );

    if (!mounted) return;
    if (conversation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            viewModel.error ??
                "Impossible d'ouvrir cette conversation pour le moment.",
          ),
        ),
      );
      return;
    }
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          role: widget.role,
          conversation: conversation,
        ),
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MessagesViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F9FC),
      appBar: AppBar(
        title: const Text('Messages'),
        backgroundColor: const Color(0xFF567991),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null && viewModel.conversations.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      viewModel.error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: viewModel.conversations.isEmpty
                      ? ListView(
                          children: const [
                            SizedBox(height: 140),
                            Center(
                              child: Text(
                                'Aucune conversation pour le moment.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: viewModel.conversations.length,
                          itemBuilder: (context, index) {
                            final conversation = viewModel.conversations[index];
                            return _buildConversationTile(conversation);
                          },
                        ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openContacts,
        backgroundColor: const Color(0xFF567991),
        icon: const Icon(Icons.add_comment_outlined),
        label: const Text('Nouveau'),
      ),
    );
  }

  Widget _buildConversationTile(Conversation conversation) {
    final formattedDate = DateFormat(
      'dd/MM HH:mm',
    ).format(conversation.sortDate.toLocal());

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF567991).withOpacity(0.12),
          child: Text(
            conversation.counterpartName.isNotEmpty
                ? conversation.counterpartName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Color(0xFF567991),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          conversation.counterpartName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              conversation.lastMessage.isEmpty
                  ? 'Aucun message envoyé'
                  : conversation.lastMessage,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              formattedDate,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: conversation.unreadCount > 0
            ? CircleAvatar(
                radius: 13,
                backgroundColor: Colors.red,
                child: Text(
                  '${conversation.unreadCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 11),
                ),
              )
            : const Icon(Icons.chevron_right),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                role: widget.role,
                conversation: conversation,
              ),
            ),
          );
          _loadData();
        },
      ),
    );
  }
}
