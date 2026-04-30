class ChatAttachment {
  final int id;
  final String fileUrl;
  final String fileName;
  final String fileType;
  final int fileSize;
  final String uploadedAt;

  ChatAttachment({
    required this.id,
    required this.fileUrl,
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.uploadedAt,
  });

  bool get isPdf =>
      fileName.toLowerCase().endsWith('.pdf') ||
      fileType.toLowerCase().contains('pdf');

  bool get isImage {
    final name = fileName.toLowerCase();
    final type = fileType.toLowerCase();
    return name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        name.endsWith('.png') ||
        type.contains('image/');
  }

  factory ChatAttachment.fromJson(Map<String, dynamic> json) {
    return ChatAttachment(
      id: json['id'],
      fileUrl: json['file_url'] ?? '',
      fileName: json['file_name'] ?? '',
      fileType: json['file_type'] ?? '',
      fileSize: json['file_size'] ?? 0,
      uploadedAt: json['uploaded_at'] ?? '',
    );
  }
}

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
  final List<ChatAttachment> attachments;
  final bool hasAttachments;

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
    required this.attachments,
    required this.hasAttachments,
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
      attachments: ((json['attachments'] as List?) ?? [])
          .map((item) => ChatAttachment.fromJson(item))
          .toList(),
      hasAttachments: json['has_attachments'] ?? false,
    );
  }
}
