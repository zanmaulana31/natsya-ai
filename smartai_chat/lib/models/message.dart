enum MessageSender { user, ai }

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final MessageSender sender;

  const Message({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.sender,
  });
}
