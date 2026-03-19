import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/message.dart';
import '../models/conversation.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ChatProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  ChatProvider(this._storageService) : _apiService = ApiService() {
    _loadHistory();
  }

  List<Conversation> _conversations = [];
  String? _activeConversationId;
  bool _isTyping = false;

  List<Conversation> get conversations => _conversations;
  String? get activeConversationId => _activeConversationId;
  bool get isTyping => _isTyping;

  List<Message> get messages {
    if (_activeConversationId == null) return [];
    try {
      return _conversations.firstWhere((c) => c.id == _activeConversationId).messages;
    } catch (_) {
      return [];
    }
  }

  bool get hasApiKey => true;
  String get userName => _storageService.getUserName();
  String get userAge => _storageService.getUserAge();
  String get chatTone => _storageService.getChatTone();
  String get reactionStyle => _storageService.getReactionStyle();
  AiProvider get currentProvider => _apiService.currentProvider;

  void _loadHistory() {
    _conversations = _storageService.getConversations();
    notifyListeners();
  }

  void updateUserName(String name) {
    _storageService.saveUserName(name);
    notifyListeners();
  }

  void setProvider(AiProvider provider) {
    _apiService.setProvider(provider);
    notifyListeners();
  }

  void setActiveConversation(String? id) {
    _activeConversationId = id;
    notifyListeners();
  }

  Future<void> startNewChat() async {
    _activeConversationId = null;
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

    // Create a new conversation if none is active
    if (_activeConversationId == null) {
      final newId = const Uuid().v4();
      final newConversation = Conversation(
        id: newId,
        title: 'New Chat',
        createdAt: DateTime.now(),
        messages: [],
      );
      _conversations.insert(0, newConversation);
      _activeConversationId = newId;
      await _storageService.saveConversation(newConversation);
    }

    final conversation = _conversations.firstWhere((c) => c.id == _activeConversationId);
    
    final userMessage = Message(
      sender: 'user',
      text: text,
      timestamp: DateTime.now(),
    );

    conversation.messages.add(userMessage);
    await _storageService.saveConversation(conversation);
    _isTyping = true;
    notifyListeners();

    try {
      final systemInstruction = _buildSystemInstruction();
    // Get AI response with context (pass last 10 messages for history)
    final history = conversation.messages.length > 1 
        ? conversation.messages.sublist(0, conversation.messages.length - 1)
        : <Message>[];
        
    final replyText = await _apiService.sendChatMessage(text, history: history, systemInstruction: systemInstruction);
      final assistantMessage = Message(
        sender: 'assistant',
        text: replyText,
        timestamp: DateTime.now(),
      );

      conversation.messages.add(assistantMessage);
      await _storageService.saveConversation(conversation);
      
      // Auto-titling: Generate title if it's a new chat and we have at least one back-and-forth
      if (conversation.title == 'New Chat' && conversation.messages.length >= 2) {
        final newTitle = await _apiService.generateConversationTitle(conversation.messages);
        conversation.title = newTitle;
        await _storageService.saveConversation(conversation);
      }
      
    } catch (e) {
      final errorMessage = Message(
        sender: 'assistant',
        text: "Sorry, I'm having trouble connecting. Please try again later.",
        timestamp: DateTime.now(),
      );
      conversation.messages.add(errorMessage);
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

  Future<void> deleteConversation(String id) async {
    await _storageService.deleteConversation(id);
    _conversations.removeWhere((c) => c.id == id);
    if (_activeConversationId == id) {
      _activeConversationId = null;
    }
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storageService.clearAllConversations();
    _conversations = [];
    _activeConversationId = null;
    notifyListeners();
  }
}
