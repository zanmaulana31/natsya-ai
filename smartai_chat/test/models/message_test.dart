import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/models/message.dart';

void main() {
  group('Message', () {
    test('creates a message with all fields', () {
      final now = DateTime.now();
      final message = Message(
        id: '1',
        text: 'Hello',
        timestamp: now,
        sender: MessageSender.user,
      );

      expect(message.id, '1');
      expect(message.text, 'Hello');
      expect(message.timestamp, now);
      expect(message.sender, MessageSender.user);
    });

    test('id is a unique string identifier', () {
      final m1 = Message(
        id: 'unique-id',
        text: 'Hi',
        timestamp: DateTime.now(),
        sender: MessageSender.user,
      );
      final m2 = Message(
        id: 'another-id',
        text: 'Hey',
        timestamp: DateTime.now(),
        sender: MessageSender.ai,
      );

      expect(m1.id, isNot(equals(m2.id)));
    });
  });
}
