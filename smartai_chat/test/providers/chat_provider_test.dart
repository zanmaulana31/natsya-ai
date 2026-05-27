import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/models/message.dart';
import 'package:smartai_chat/providers/chat_provider.dart';

void main() {
  group('ChatNotifier', () {
    test('initializes from MockData', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final messages = container.read(chatProvider);
      expect(messages.length, greaterThanOrEqualTo(10));
    });

    test('sendMessage adds a new user message', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final initialCount = container.read(chatProvider).length;

      notifier.sendMessage('Test message');
      final messages = container.read(chatProvider);

      expect(messages.length, initialCount + 1);
      expect(messages.last.text, 'Test message');
      expect(messages.last.sender, MessageSender.user);
    });

    test('empty text is ignored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final initialCount = container.read(chatProvider).length;

      notifier.sendMessage('');
      expect(container.read(chatProvider).length, initialCount);
    });

    test('whitespace-only text is ignored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final initialCount = container.read(chatProvider).length;

      notifier.sendMessage('   ');
      expect(container.read(chatProvider).length, initialCount);
    });

    test('messages are ordered by timestamp ascending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final messages = container.read(chatProvider);
      for (int i = 1; i < messages.length; i++) {
        expect(
          messages[i].timestamp.isAfter(messages[i - 1].timestamp) ||
              messages[i].timestamp == messages[i - 1].timestamp,
          isTrue,
        );
      }
    });
  });
}
