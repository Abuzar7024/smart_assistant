import 'package:flutter/material.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  ChatProvider(this._storageService) : _apiService = ApiService(_storageService.getApiKey()) {
    _loadHistory();
  }

  List<Message> _messages = [];
  bool _isTyping = false;

  List<Message> get messages => _messages;
  bool get isTyping => _isTyping;
  bool get hasApiKey => _storageService.getApiKey() != null;

  void _loadHistory() {
    _messages = _storageService.getMessages();
    notifyListeners();
  }

  Future<void> updateApiKey(String key) async {
    await _storageService.saveApiKey(key);
    _apiService.updateApiKey(key);
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    if (!hasApiKey) {
      final systemMessage = Message(
        sender: 'assistant',
        text: "Please set your Gemini API Key in the settings or onboarding screen first.",
        timestamp: DateTime.now(),
      );
      _messages.add(systemMessage);
      notifyListeners();
      return;
    }

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
