import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/mock/mock_data.dart';
import 'package:smartai_chat/models/message.dart';

void main() {
  group('MockData', () {
    test('provides at least 10 messages', () {
      expect(MockData.messages.length, greaterThanOrEqualTo(10));
    });

    test('messages alternate between user and ai', () {
      final messages = MockData.messages;
      expect(messages.first.sender, MessageSender.ai);
      expect(messages[1].sender, MessageSender.user);
    });

    test('messages have realistic timestamps spanning multiple hours', () {
      final messages = MockData.messages;
      final first = messages.first.timestamp;
      final last = messages.last.timestamp;
      expect(last.difference(first).inHours, greaterThan(0));
    });

    test('first message is an AI greeting', () {
      final first = MockData.messages.first;
      expect(first.sender, MessageSender.ai);
      expect(first.text, contains('Natsya'));
    });
  });
}
