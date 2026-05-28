import 'dart:async';
import 'dart:io';

import 'package:cactus/cactus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartai_chat/models/ai_model_status.dart';
import 'package:smartai_chat/services/ai_model_service.dart';

class MockCactusLM extends Mock implements CactusLM {}

class FakeChatMessage extends Fake implements ChatMessage {}

class FakeCactusCompletionParams extends Fake implements CactusCompletionParams {}

void main() {
  group('AiModelService', () {
    late MockCactusLM mockLM;
    late AiModelService service;

    setUpAll(() {
      registerFallbackValue(FakeChatMessage());
      registerFallbackValue(FakeCactusCompletionParams());
    });

    setUp(() {
      mockLM = MockCactusLM();
      service = AiModelService(lm: mockLM);
    });

    test('constructs without throwing', () {
      expect(AiModelService(), isNotNull);
    });

    test('initial status is notDownloaded', () {
      expect(service.status, AiModelStatus.notDownloaded);
    });

    group('downloadModel', () {
      test('transitions to downloaded on success', () async {
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});

        await service.downloadModel();

        expect(service.status, AiModelStatus.downloaded);
      });

      test('reports progress via callback', () async {
        final progressValues = <double>[];
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((invocation) async {
          final callback = invocation.namedArguments[
            const Symbol('downloadProcessCallback')
          ] as CactusProgressCallback?;
          callback?.call(0.5, 'downloading', false);
        });

        await service.downloadModel(onProgress: progressValues.add);

        expect(progressValues, contains(0.5));
      });

      test('sets error on failure', () async {
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenThrow(Exception('network error'));

        await service.downloadModel();

        expect(service.status, AiModelStatus.error);
        expect(service.errorMessage, contains('network error'));
      });

      test('retries once on SocketException', () async {
        var attempt = 0;
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {
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
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {
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
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenThrow(const SocketException('Connection refused'));

        await service.downloadModel();

        expect(service.status, AiModelStatus.error);
        expect(service.errorMessage, isNotNull);
      });
    });

    group('initializeModel', () {
      test('transitions to ready on success', () async {
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});
        when(() => mockLM.initializeModel(params: any(named: 'params')))
            .thenAnswer((_) async {});

        await service.downloadModel();
        await service.initializeModel();

        expect(service.status, AiModelStatus.ready);
      });

      test('transitions to initializing before init', () async {
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});

        await service.downloadModel();
        expect(service.status, AiModelStatus.downloaded);

        when(() => mockLM.initializeModel(params: any(named: 'params')))
            .thenAnswer((_) async {
          expect(service.status, AiModelStatus.initializing);
        });

        await service.initializeModel();
      });

      test('sets error on init failure', () async {
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});
        when(() => mockLM.initializeModel(params: any(named: 'params')))
            .thenThrow(Exception('init failed'));

        await service.downloadModel();
        await service.initializeModel();

        expect(service.status, AiModelStatus.error);
        expect(service.errorMessage, contains('init failed'));
      });

      test('throws when not downloaded', () {
        expect(
          () => service.initializeModel(),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('generateCompletion', () {
      test('delegates to CactusLM when ready', () async {
        final expectedResult = CactusCompletionResult(
          success: true,
          response: 'Hello!',
          timeToFirstTokenMs: 100,
          totalTimeMs: 200,
          tokensPerSecond: 50,
          prefillTokens: 10,
          decodeTokens: 5,
          totalTokens: 15,
        );

        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});
        when(() => mockLM.initializeModel(params: any(named: 'params')))
            .thenAnswer((_) async {});
        when(() => mockLM.generateCompletion(
          messages: any(named: 'messages'),
          params: any(named: 'params'),
        )).thenAnswer((_) async => expectedResult);

        await service.downloadModel();
        await service.initializeModel();
        final result = await service.generateCompletion([
          ChatMessage(content: 'Hi', role: 'user'),
        ]);

        expect(result.success, isTrue);
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
      test('delegates to CactusLM when ready', () async {
        final controller = StreamController<String>();
        final completer = Completer<CactusCompletionResult>();
        final streamedResult = CactusStreamedCompletionResult(
          stream: controller.stream,
          result: completer.future,
        );

        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});
        when(() => mockLM.initializeModel(params: any(named: 'params')))
            .thenAnswer((_) async {});
        when(() => mockLM.generateCompletionStream(
          messages: any(named: 'messages'),
          params: any(named: 'params'),
        )).thenAnswer((_) async => streamedResult);

        await service.downloadModel();
        await service.initializeModel();
        final result = await service.generateCompletionStream([
          ChatMessage(content: 'Hi', role: 'user'),
        ]);

        expect(result.stream, isNotNull);
        controller.close();
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

    group('getModelInfo', () {
      test('returns model with matching slug', () async {
        final models = [
          CactusModel(
            createdAt: DateTime.now(),
            slug: 'lfm2-1.2b',
            downloadUrl: 'http://example.com',
            sizeMb: 100,
            supportsToolCalling: true,
            supportsVision: false,
            name: 'LFM 2 1.2B',
            isDownloaded: true,
          ),
        ];

        when(() => mockLM.getModels()).thenAnswer((_) async => models);

        final info = await service.getModelInfo();

        expect(info, isNotNull);
        expect(info!.slug, 'lfm2-1.2b');
      });

      test('returns null when model not found', () async {
        when(() => mockLM.getModels()).thenAnswer((_) async => []);

        final info = await service.getModelInfo();

        expect(info, isNull);
      });
    });

    group('isDownloaded', () {
      test('returns true when model is downloaded', () async {
        final models = [
          CactusModel(
            createdAt: DateTime.now(),
            slug: 'lfm2-1.2b',
            downloadUrl: 'http://example.com',
            sizeMb: 100,
            supportsToolCalling: true,
            supportsVision: false,
            name: 'LFM 2 1.2B',
            isDownloaded: true,
          ),
        ];

        when(() => mockLM.getModels()).thenAnswer((_) async => models);

        expect(await service.isDownloaded(), isTrue);
      });

      test('returns false on error', () async {
        when(() => mockLM.getModels()).thenThrow(Exception('network error'));

        expect(await service.isDownloaded(), isFalse);
      });
    });

    group('unload', () {
      test('calls CactusLM.unload and resets status', () async {
        when(() => mockLM.downloadModel(
          model: any(named: 'model'),
          downloadProcessCallback: any(named: 'downloadProcessCallback'),
        )).thenAnswer((_) async {});
        when(() => mockLM.initializeModel(params: any(named: 'params')))
            .thenAnswer((_) async {});

        await service.downloadModel();
        await service.initializeModel();
        expect(service.status, AiModelStatus.ready);

        service.unload();

        verify(() => mockLM.unload()).called(1);
        expect(service.status, AiModelStatus.notDownloaded);
      });
    });

    group('dispose', () {
      test('calls unload without throwing', () {
        expect(service.dispose, returnsNormally);
      });
    });
  });
}
