import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:palm_analysis/models/chat_conversation.dart';

/// Service for storing and retrieving chat conversations
class ChatStorageService {
  static const String _key = 'chat_conversations';

  /// Get all conversations, sorted by updatedAt (newest first)
  Future<List<ChatConversation>> getConversations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    final conversations = jsonList
        .map((json) => ChatConversation.fromJson(jsonDecode(json)))
        .toList();

    // Sort by updatedAt descending
    conversations.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    return conversations;
  }

  /// Get a specific conversation by ID
  Future<ChatConversation?> getConversation(String id) async {
    final conversations = await getConversations();
    try {
      return conversations.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Save or update a conversation
  Future<void> saveConversation(ChatConversation conversation) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    // Parse existing conversations
    final conversations = jsonList
        .map((json) => ChatConversation.fromJson(jsonDecode(json)))
        .toList();

    // Find and update or add new
    final existingIndex = conversations.indexWhere((c) => c.id == conversation.id);
    if (existingIndex >= 0) {
      conversations[existingIndex] = conversation;
    } else {
      conversations.add(conversation);
    }

    // Convert back to JSON list and save
    final updatedJsonList = conversations
        .map((c) => jsonEncode(c.toJson()))
        .toList();

    await prefs.setStringList(_key, updatedJsonList);
  }

  /// Delete a conversation by ID
  Future<void> deleteConversation(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_key) ?? [];

    final conversations = jsonList
        .map((json) => ChatConversation.fromJson(jsonDecode(json)))
        .toList();

    conversations.removeWhere((c) => c.id == id);

    final updatedJsonList = conversations
        .map((c) => jsonEncode(c.toJson()))
        .toList();

    await prefs.setStringList(_key, updatedJsonList);
  }

  /// Delete all conversations
  Future<void> deleteAllConversations() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Generate unique conversation ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Create preview text from analysis (first 100 chars)
  static String createPreview(String analysisText) {
    if (analysisText.length <= 100) return analysisText;
    return '${analysisText.substring(0, 100)}...';
  }
}
