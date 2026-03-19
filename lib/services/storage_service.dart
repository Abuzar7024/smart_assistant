import 'package:hive_flutter/hive_flutter.dart';
import '../models/message.dart';

class StorageService {
  static const String _chatBoxName = 'chat_messages';
  static const String _settingsBoxName = 'settings';
  static const String _apiKeyKey = 'gemini_api_key';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MessageAdapter());
    await Hive.openBox<Message>(_chatBoxName);
    await Hive.openBox(_settingsBoxName);
  }

  Box<Message> get _chatBox => Hive.box<Message>(_chatBoxName);
  Box get _settingsBox => Hive.box(_settingsBoxName);

  // API Key Storage
  Future<void> saveApiKey(String key) async {
    await _settingsBox.put(_apiKeyKey, key);
  }

  String? getApiKey() {
    return _settingsBox.get(_apiKeyKey) as String?;
  }

  Future<void> clearApiKey() async {
    await _settingsBox.delete(_apiKeyKey);
  }

  // Chat History
  Future<void> saveMessage(Message message) async {
    await _chatBox.add(message);
  }

  List<Message> getMessages() {
    return _chatBox.values.toList();
  }

  Future<void> clearHistory() async {
    await _chatBox.clear();
  }
}
