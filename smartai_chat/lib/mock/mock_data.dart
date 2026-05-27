import '../models/message.dart';

class MockData {
  static List<Message> get messages => [
    Message(
      id: '1',
      text: 'Hello! I\'m Natsya, your AI assistant. How can I help you today?',
      timestamp: DateTime(2026, 5, 23, 9, 0),

      sender: MessageSender.ai,
    ),
    Message(
      id: '2',
      text: 'Hi Natsya! Can you help me with Flutter development?',
      timestamp: DateTime(2026, 5, 23, 9, 2),
      sender: MessageSender.user,
    ),
    Message(
      id: '3',
      text: 'Of course! I\'d be happy to help with Flutter. What specifically would you like to know?',
      timestamp: DateTime(2026, 5, 23, 9, 30),
      sender: MessageSender.ai,
    ),
    Message(
      id: '4',
      text: 'I\'m trying to build a chat UI with Forui widgets.',
      timestamp: DateTime(2026, 5, 23, 10, 5),
      sender: MessageSender.user,
    ),
    Message(
      id: '5',
      text: 'Great choice! Forui has beautiful components like FScaffold, FHeader, FTextField, and FTile that work perfectly for chat interfaces. Would you like me to show you some examples?',
      timestamp: DateTime(2026, 5, 23, 10, 6),
      sender: MessageSender.ai,
    ),
    Message(
      id: '6',
      text: 'Yes please! Show me how to use the FTextField.',
      timestamp: DateTime(2026, 5, 23, 10, 30),
      sender: MessageSender.user,
    ),
    Message(
      id: '7',
      text: 'Here\'s a simple example:\n\n```dart\nFTextField(\n  label: Text(\'Message\'),\n  hint: \'Type your message...\',\n)\n```\n\nYou can also use FTextField.multiline for longer messages.',
      timestamp: DateTime(2026, 5, 23, 11, 0),
      sender: MessageSender.ai,
    ),
    Message(
      id: '8',
      text: 'That looks clean! What about theming?',
      timestamp: DateTime(2026, 5, 23, 11, 30),
      sender: MessageSender.user,
    ),
    Message(
      id: '9',
      text: 'Forui uses FTheme with built-in themes. You can use FThemes.violet for a purple accent — it looks modern and polished. Just wrap your app:\n\n```dart\nFTheme(\n  data: FThemes.violet.light.touch,\n  child: YourApp(),\n)\n```',
      timestamp: DateTime(2026, 5, 23, 12, 0),
      sender: MessageSender.ai,
    ),
    Message(
      id: '10',
      text: 'Awesome! Let me try that right now.',
      timestamp: DateTime(2026, 5, 23, 13, 0),
      sender: MessageSender.user,
    ),
    Message(
      id: '11',
      text: 'Perfect! Let me know how it goes. I\'m here to help with any questions! 😊',
      timestamp: DateTime(2026, 5, 23, 14, 0),
      sender: MessageSender.ai,
    ),
  ];
}
