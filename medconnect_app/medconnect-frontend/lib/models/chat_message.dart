class ChatMessage {
  final int id;
  final int conversationId;
  final int senderId;
  final String senderName;
  final String senderRole;
  final String content;
  final bool isRead;
  final String createdAt;
  final bool isMine;

  ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderName,
    required this.senderRole,
    required this.content,
    required this.isRead,
    required this.createdAt,
    required this.isMine,
  });

  DateTime get createdDate => DateTime.tryParse(createdAt) ?? DateTime.now();

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      conversationId: json['conversation'],
      senderId: json['sender'],
      senderName: json['sender_name'] ?? '',
      senderRole: json['sender_role'] ?? '',
      content: json['content'] ?? '',
      isRead: json['is_read'] ?? false,
      createdAt: json['created_at'] ?? '',
      isMine: json['is_mine'] ?? false,
    );
  }
}
