import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/models/cloud_ai_config.dart';
import 'package:smartai_chat/models/message.dart';
import 'package:smartai_chat/providers/chat_provider.dart';
import 'package:smartai_chat/providers/cloud_ai_provider.dart';
import 'package:smartai_chat/services/cloud_ai_service.dart';

class _TestCloudAiConfigNotifier extends CloudAiConfigNotifier {
  @override
  CloudAiConfig build() => const CloudAiConfig(apiKey: 'test-key', enabled: true);
}

class _MockCloudAiService extends CloudAiService {
  final String _response;

  _MockCloudAiService(this._response, {CloudAiConfig? config}) : super(config);

  @override
  Future<String> generateCompletion(
    List<CloudMessage> messages, {
    CloudAiConfig? config,
  }) async {
    return _response;
  }
}

void main() {
  group('ChatNotifier', () {
    test('initializes from MockData', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(chatProvider);
      expect(state.messages.length, greaterThanOrEqualTo(10));
    });

    test('sendMessage adds a new user message', () async {
      final container = ProviderContainer(
        overrides: [
          cloudAiConfigProvider.overrideWith(
            _TestCloudAiConfigNotifier.new,
          ),
          cloudAiServiceProvider.overrideWith(
            (_) => _MockCloudAiService(
              'Hello from mock AI!',
              config: const CloudAiConfig(apiKey: 'test-key', enabled: true),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final initialCount = container.read(chatProvider).messages.length;

      await notifier.sendMessage('Test message');
      final state = container.read(chatProvider);

      expect(state.messages.length, initialCount + 2);
      expect(state.messages[state.messages.length - 2].text, 'Test message');
      expect(state.messages[state.messages.length - 2].sender, MessageSender.user);
      expect(state.messages.last.sender, MessageSender.ai);
    });

    test('empty text is ignored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final initialCount = container.read(chatProvider).messages.length;

      notifier.sendMessage('');
      expect(container.read(chatProvider).messages.length, initialCount);
    });

    test('whitespace-only text is ignored', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(chatProvider.notifier);
      final initialCount = container.read(chatProvider).messages.length;

      notifier.sendMessage('   ');
      expect(container.read(chatProvider).messages.length, initialCount);
    });

    test('messages are ordered by timestamp ascending', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(chatProvider);
      final messages = state.messages;
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
