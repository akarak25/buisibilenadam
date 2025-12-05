/// Chat conversation model for storing chat history
class ChatConversation {
  final String id;
  final String analysisPreview; // First 100 chars of analysis
  final List<ChatMessageLocal> messages;
  final DateTime createdAt;
  final DateTime updatedAt;

  ChatConversation({
    required this.id,
    required this.analysisPreview,
    required this.messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ChatConversation.fromJson(Map<String, dynamic> json) {
    return ChatConversation(
      id: json['id'],
      analysisPreview: json['analysisPreview'],
      messages: (json['messages'] as List)
          .map((m) => ChatMessageLocal.fromJson(m))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'analysisPreview': analysisPreview,
      'messages': messages.map((m) => m.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ChatConversation copyWith({
    String? id,
    String? analysisPreview,
    List<ChatMessageLocal>? messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ChatConversation(
      id: id ?? this.id,
      analysisPreview: analysisPreview ?? this.analysisPreview,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Local chat message model
class ChatMessageLocal {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  ChatMessageLocal({
    required this.content,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory ChatMessageLocal.fromJson(Map<String, dynamic> json) {
    return ChatMessageLocal(
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
