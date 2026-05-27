class ChatSession {
  final String id;
  final String title;
  final bool isActive;

  const ChatSession({
    required this.id,
    required this.title,
    this.isActive = false,
  });
}
