import 'package:hive_flutter/hive_flutter.dart';
import '../models/message.dart';
import '../models/conversation.dart';

class StorageService {
  static const String _conversationsBoxName = 'conversations';
  static const String _settingsBoxName = 'settings';
  static const String _apiKeyKey = 'gemini_api_key';
  static const String _userNameKey = 'user_name';
  static const String _userAgeKey = 'user_age';
  static const String _chatToneKey = 'chat_tone';
  static const String _reactionStyleKey = 'reaction_style';
  static const String _aiProviderKey = 'ai_provider';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MessageAdapter());
    Hive.registerAdapter(ConversationAdapter());
    await Hive.openBox<Conversation>(_conversationsBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  Box<Conversation> get _conversationsBox => Hive.box<Conversation>(_conversationsBoxName);
  Box get _settingsBox => Hive.box(_settingsBoxName);

  // API Key Storage
  Future<void> saveApiKey(String key) async {
    await _settingsBox.put(_apiKeyKey, key);
  }

  String? getApiKey() {
    return _settingsBox.get(_apiKeyKey) as String?;
  }

  // User Preferences
  Future<void> saveUserName(String name) async {
    await _settingsBox.put(_userNameKey, name);
  }

  String getUserName() {
    return _settingsBox.get(_userNameKey) as String? ?? 'Friend';
  }

  Future<void> saveUserAge(String age) async {
    await _settingsBox.put(_userAgeKey, age);
  }

  String getUserAge() {
    return _settingsBox.get(_userAgeKey) as String? ?? '25';
  }

  Future<void> saveChatTone(String tone) async {
    await _settingsBox.put(_chatToneKey, tone);
  }

  String getChatTone() {
    return _settingsBox.get(_chatToneKey) as String? ?? 'Friendly';
  }

  Future<void> saveReactionStyle(String style) async {
    await _settingsBox.put(_reactionStyleKey, style);
  }

  String getReactionStyle() {
    return _settingsBox.get(_reactionStyleKey) as String? ?? 'Expressive';
  }

  Future<void> saveAiProvider(String provider) async {
    await _settingsBox.put(_aiProviderKey, provider);
  }

  String getAiProvider() {
    return _settingsBox.get(_aiProviderKey) as String? ?? 'mistral'; // Defaulting to Mistral as requested
  }

  // Conversation Sessions
  Future<void> saveConversation(Conversation conversation) async {
    await _conversationsBox.put(conversation.id, conversation);
  }

  List<Conversation> getConversations() {
    final list = _conversationsBox.values.toList();
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Conversation? getConversation(String id) {
    return _conversationsBox.get(id);
  }

  Future<void> deleteConversation(String id) async {
    await _conversationsBox.delete(id);
  }

  Future<void> clearAllConversations() async {
    await _conversationsBox.clear();
  }
}
