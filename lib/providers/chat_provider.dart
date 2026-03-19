import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  ChatProvider(this._storageService) : _apiService = ApiService() {
    _loadHistory();
  }

  List<Message> _messages = [];
  bool _isTyping = false;

  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get hasApiKey => true;
  bool get hasUserName => _storageService.getUserName() != null;
  String get userName => _storageService.getUserName() ?? 'Friend';
  String get chatTone => _storageService.getChatTone();
  String get reactionStyle => _storageService.getReactionStyle();

  void _loadHistory() {
    _messages = _storageService.getMessages();
    notifyListeners();
  }

  // updateApiKey is kept for compatibility but is no-op because the key is hardcoded.
  Future<void> updateApiKey(String key) async {}

  Future<void> updateUserName(String name) async {
    await _storageService.saveUserName(name);
    notifyListeners();
  }

  Future<void> updatePreferences({String? tone, String? style}) async {
    if (tone != null) await _storageService.saveChatTone(tone);
    if (style != null) await _storageService.saveReactionStyle(style);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = Message(
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    await _storageService.saveMessage(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final systemInstruction = _buildSystemInstruction();
      final replyText = await _apiService.sendChatMessage(text, systemInstruction: systemInstruction);
      final assistantMessage = Message(
        sender: 'assistant',
        text: replyText,
        timestamp: DateTime.now(),
      );

      _messages.add(assistantMessage);
      await _storageService.saveMessage(assistantMessage);
    } catch (e) {
      final errorMessage = Message(
        sender: 'assistant',
        text: "Sorry, I'm having trouble connecting. Please try again later.",
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  String _buildSystemInstruction() {
    return "Your name is Smart Assistant. You are talking to $userName. "
           "Always call them by $userName. "
           "Your tone should be $chatTone. "
           "Use a $reactionStyle reaction style.";
  }

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    _messages = [];
    notifyListeners();
  }
}
