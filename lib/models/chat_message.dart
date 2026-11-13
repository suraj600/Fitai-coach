/// Chat message model for AI Coach conversations.
library;

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatMessage {
  final String id;
  final String userId;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final List<String> suggestions; // suggestion chips for user
  final String? imageUrl;

  ChatMessage({
    required this.id,
    required this.userId,
    required this.content,
    required this.isUser,
    DateTime? timestamp,
    this.suggestions = const [],
    this.imageUrl,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'userId': userId,
        'content': content,
        'isUser': isUser,
        'timestamp': Timestamp.fromDate(timestamp),
        'suggestions': suggestions,
        'imageUrl': imageUrl,
      };

  factory ChatMessage.fromFirestore(Map<String, dynamic> data) {
    return ChatMessage(
      id: data['id'] ?? '',
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      isUser: data['isUser'] ?? true,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      suggestions: List<String>.from(data['suggestions'] ?? []),
      imageUrl: data['imageUrl'],
    );
  }
}
