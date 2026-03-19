import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService;

  ChatProvider(this._storageService) {
    _loadHistory();
  }

  List<Message> _messages = [];
  bool _isTyping = false;

  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;

  void _loadHistory() {
    _messages = _storageService.getMessages();
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
      final replyText = await _apiService.sendChatMessage(text);
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

  Future<void> clearHistory() async {
    await _storageService.clearHistory();
    _messages = [];
    notifyListeners();
  }
}
