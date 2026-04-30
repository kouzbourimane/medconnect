class Conversation {
  final int id;
  final int patientId;
  final int doctorId;
  final String patientName;
  final String doctorName;
  final String counterpartName;
  final String counterpartRole;
  final int counterpartId;
  final String lastMessage;
  final String lastMessageAt;
  final int unreadCount;
  final String updatedAt;

  Conversation({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.counterpartName,
    required this.counterpartRole,
    required this.counterpartId,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.updatedAt,
  });

  DateTime get sortDate => DateTime.tryParse(lastMessageAt) ?? DateTime.now();

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      id: json['id'],
      patientId: json['patient'],
      doctorId: json['doctor'],
      patientName: json['patient_name'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      counterpartName: json['counterpart_name'] ?? '',
      counterpartRole: json['counterpart_role'] ?? '',
      counterpartId: json['counterpart_id'] ?? 0,
      lastMessage: json['last_message'] ?? '',
      lastMessageAt: json['last_message_at'] ?? json['updated_at'] ?? '',
      unreadCount: json['unread_count'] ?? 0,
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ConversationContact {
  final int id;
  final String name;
  final String subtitle;
  final String role;
  final int? conversationId;

  ConversationContact({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.role,
    this.conversationId,
  });

  factory ConversationContact.fromJson(Map<String, dynamic> json) {
    return ConversationContact(
      id: json['id'],
      name: json['name'] ?? '',
      subtitle: json['subtitle'] ?? '',
      role: json['role'] ?? '',
      conversationId: json['conversation_id'],
    );
  }
}
