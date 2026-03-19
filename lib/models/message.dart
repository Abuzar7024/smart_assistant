import 'package:hive/hive.dart';

part 'message.g.dart';

@HiveType(typeId: 0)
class Message extends HiveObject {
  @HiveField(0)
  final String sender; // 'user' or 'assistant'
  @HiveField(1)
  final String text;
  @HiveField(2)
  final DateTime timestamp;

  Message({
    required this.sender,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      sender: json['sender'],
      text: json['message'],
      timestamp: DateTime.now(), // API doesn't provide timestamp, so we add it
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': text,
    };
  }
}
