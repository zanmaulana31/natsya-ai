import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartai_chat/core/llm_service.dart';
import 'package:smartai_chat/models/ai_model_status.dart';
import 'package:smartai_chat/models/chat_message.dart';
import 'package:smartai_chat/services/ai_model_service.dart';

class MockLlmService extends Mock implements LlmService {}

void main() {
  group('AiModelService', () {
    late MockLlmService mockLlm;
    late AiModelService service;

    setUp(() {
      mockLlm = MockLlmService();
      service = AiModelService(llm: mockLlm);
    });

    test('constructs without throwing', () {
      expect(AiModelService(), isNotNull);
    });

    test('initial status is notDownloaded', () {
      expect(service.status, AiModelStatus.notDownloaded);
    });

    group('downloadModel', () {
      test('transitions to downloaded on success', () async {
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});

        await service.downloadModel();

        expect(service.status, AiModelStatus.downloaded);
      });

      test('sets error on failure', () async {
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenThrow(Exception('network error'));

        await service.downloadModel();

        expect(service.status, AiModelStatus.error);
        expect(service.errorMessage, contains('network error'));
      });

      test('retries once on SocketException', () async {
        var attempt = 0;
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {
          attempt++;
          if (attempt == 1) {
            throw const SocketException('Connection refused');
          }
        });

        await service.downloadModel();

        expect(attempt, 2);
        expect(service.status, AiModelStatus.downloaded);
      });

      test('retries once on TimeoutException', () async {
        var attempt = 0;
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {
          attempt++;
          if (attempt == 1) {
            throw TimeoutException('Connection timeout');
          }
        });

        await service.downloadModel();

        expect(attempt, 2);
        expect(service.status, AiModelStatus.downloaded);
      });

      test('error on retry failure', () async {
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenThrow(const SocketException('Connection refused'));

        await service.downloadModel();

        expect(service.status, AiModelStatus.error);
        expect(service.errorMessage, isNotNull);
      });
    });

    group('initializeModel', () {
      test('transitions to ready on success', () async {
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});

        await service.downloadModel();
        await service.initializeModel();

        expect(service.status, AiModelStatus.ready);
      });

      test('throws when not downloaded', () {
        expect(
          () => service.initializeModel(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('generateCompletion', () {
      test('delegates to LlmService when ready', () async {
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockLlm.generateText(any())).thenAnswer((_) async* {
          yield 'Hello!';
        });

        await service.downloadModel();
        await service.initializeModel();
        final result = await service.generateCompletion([
          ChatMessage(content: 'Hi', role: 'user'),
        ]);

        expect(result.response, 'Hello!');
      });

      test('throws when model is not ready', () {
        expect(
          () => service.generateCompletion([
            ChatMessage(content: 'Hi', role: 'user'),
          ]),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('generateCompletionStream', () {
      test('delegates to LlmService when ready', () async {
        final controller = StreamController<String>();

        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockLlm.generateText(any())).thenAnswer((_) => controller.stream);

        await service.downloadModel();
        await service.initializeModel();
        final result = await service.generateCompletionStream([
          ChatMessage(content: 'Hi', role: 'user'),
        ]);

        expect(result.stream, isNotNull);
        controller.add('world');
        controller.close();
        final tokens = await result.stream.toList();
        expect(tokens, ['world']);
      });

      test('throws when model is not ready', () {
        expect(
          () => service.generateCompletionStream([
            ChatMessage(content: 'Hi', role: 'user'),
          ]),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('isDownloaded', () {
      test('returns true when model file exists', () async {
        when(() => mockLlm.isModelDownloaded()).thenAnswer((_) async => true);

        expect(await service.isDownloaded(), isTrue);
      });
    });

    group('unload', () {
      test('calls LlmService.dispose and resets status', () async {
        when(() => mockLlm.initialize(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockLlm.dispose()).thenAnswer((_) async {});

        await service.downloadModel();
        await service.initializeModel();
        expect(service.status, AiModelStatus.ready);

        service.unload();

        verify(() => mockLlm.dispose()).called(1);
        expect(service.status, AiModelStatus.notDownloaded);
      });
    });

    group('dispose', () {
      test('calls unload without throwing', () {
        when(() => mockLlm.dispose()).thenAnswer((_) async {});
        expect(service.dispose, returnsNormally);
      });
    });
  });
}
