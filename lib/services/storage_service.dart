import 'package:hive_flutter/hive_flutter.dart';
import '../models/message.dart';

class StorageService {
  static const String _chatBoxName = 'chat_messages';

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(MessageAdapter());
    await Hive.openBox<Message>(_chatBoxName);
  }

  Box<Message> get _chatBox => Hive.box<Message>(_chatBoxName);

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
