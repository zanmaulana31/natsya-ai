import 'package:flutter/foundation.dart';

enum MessageSender { user, ai }

@immutable
class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final MessageSender sender;
  final bool isError;

  const Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.sender,
    this.isError = false,
  });
}
