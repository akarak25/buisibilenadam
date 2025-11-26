/// Query model compatible with elcizgisi.com backend
/// Represents a palm analysis query/result
class Query {
  final String id;
  final String userId;
  final String imageUrl;
  final String question;
  final String response;
  final bool isPremium;
  final List<ChatMessage> chatHistory;
  final int chatMessageCount;
  final bool isFavorite;
  final String userNote;
  final DateTime createdAt;

  Query({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.question,
    required this.response,
    this.isPremium = false,
    this.chatHistory = const [],
    this.chatMessageCount = 0,
    this.isFavorite = false,
    this.userNote = '',
    required this.createdAt,
  });

  factory Query.fromJson(Map<String, dynamic> json) {
    return Query(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      question: json['question'] ?? '',
      response: json['response'] ?? '',
      isPremium: json['isPremium'] ?? false,
      chatHistory: json['chatHistory'] != null
          ? (json['chatHistory'] as List)
              .map((e) => ChatMessage.fromJson(e))
              .toList()
          : [],
      chatMessageCount: json['chatMessageCount'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      userNote: json['userNote'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'question': question,
      'response': response,
      'isPremium': isPremium,
      'chatHistory': chatHistory.map((e) => e.toJson()).toList(),
      'chatMessageCount': chatMessageCount,
      'isFavorite': isFavorite,
      'userNote': userNote,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Query copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? question,
    String? response,
    bool? isPremium,
    List<ChatMessage>? chatHistory,
    int? chatMessageCount,
    bool? isFavorite,
    String? userNote,
    DateTime? createdAt,
  }) {
    return Query(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      question: question ?? this.question,
      response: response ?? this.response,
      isPremium: isPremium ?? this.isPremium,
      chatHistory: chatHistory ?? this.chatHistory,
      chatMessageCount: chatMessageCount ?? this.chatMessageCount,
      isFavorite: isFavorite ?? this.isFavorite,
      userNote: userNote ?? this.userNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// Chat message within a query
class ChatMessage {
  final String role;
  final String content;
  final DateTime timestamp;

  ChatMessage({
    required this.role,
    required this.content,
    required this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'user',
      content: json['content'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
