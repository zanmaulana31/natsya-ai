import 'package:cactus/cactus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartai_chat/models/ai_model_status.dart';
import 'package:smartai_chat/providers/ai_model_provider.dart';
import 'package:smartai_chat/services/ai_model_service.dart';

class MockAiModelService extends Mock implements AiModelService {}

void main() {
  group('AiModelNotifier', () {
    late MockAiModelService mockService;
    late ProviderContainer container;

    setUp(() {
      mockService = MockAiModelService();
      when(() => mockService.isDownloaded()).thenAnswer((_) async => false);
      container = ProviderContainer(
        overrides: [
          aiModelServiceProvider.overrideWith((ref) => mockService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initializes with notDownloaded state', () {
      final state = container.read(aiModelProvider);
      expect(state.status, AiModelStatus.notDownloaded);
      expect(state.downloadProgress, isNull);
      expect(state.errorMessage, isNull);
    });

    group('downloadAndInit', () {
      test('orchestrates download -> init -> ready', () async {
        when(() => mockService.downloadModel(onProgress: any(named: 'onProgress')))
            .thenAnswer((invocation) async {
          final callback = invocation.namedArguments[
            const Symbol('onProgress')
          ] as void Function(double)?;
          callback?.call(0.5);
        });
        when(() => mockService.status).thenReturn(AiModelStatus.downloaded);
        when(() => mockService.initializeModel()).thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.ready);

        await container.read(aiModelProvider.notifier).downloadAndInit();

        expect(container.read(aiModelProvider).status, AiModelStatus.ready);
      });

      test('propagates download error', () async {
        when(() => mockService.downloadModel(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.error);
        when(() => mockService.errorMessage).thenReturn('Download failed');

        await container.read(aiModelProvider.notifier).downloadAndInit();

        expect(container.read(aiModelProvider).status, AiModelStatus.error);
        expect(container.read(aiModelProvider).errorMessage, 'Download failed');
      });

      test('propagates init error', () async {
        when(() => mockService.downloadModel(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.downloaded);
        when(() => mockService.initializeModel()).thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.error);
        when(() => mockService.errorMessage).thenReturn('Init failed');

        await container.read(aiModelProvider.notifier).downloadAndInit();

        expect(container.read(aiModelProvider).status, AiModelStatus.error);
        expect(container.read(aiModelProvider).errorMessage, 'Init failed');
      });
    });

    group('unloadModel', () {
      test('resets state to notDownloaded', () async {
        when(() => mockService.downloadModel(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.downloaded);
        when(() => mockService.initializeModel()).thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.ready);

        await container.read(aiModelProvider.notifier).downloadAndInit();
        expect(container.read(aiModelProvider).status, AiModelStatus.ready);

        container.read(aiModelProvider.notifier).unloadModel();

        verify(() => mockService.unload()).called(1);
        expect(container.read(aiModelProvider).status, AiModelStatus.notDownloaded);
        expect(container.read(aiModelProvider).errorMessage, isNull);
      });
    });

    group('generate', () {
      test('wraps user message and delegates to service', () async {
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

        when(() => mockService.downloadModel(onProgress: any(named: 'onProgress')))
            .thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.downloaded);
        when(() => mockService.initializeModel()).thenAnswer((_) async {});
        when(() => mockService.status).thenReturn(AiModelStatus.ready);
        when(() => mockService.generateCompletion(any(), params: any(named: 'params')))
            .thenAnswer((_) async => expectedResult);

        await container.read(aiModelProvider.notifier).downloadAndInit();
        final result = await container.read(aiModelProvider.notifier).generate('Hi');

        expect(result.success, isTrue);
        expect(result.response, 'Hello!');
      });
    });
  });

  group('aiModelProvider', () {
    test('provides AiModelNotifier', () {
      final container = ProviderContainer();
      final notifier = container.read(aiModelProvider.notifier);
      expect(notifier, isA<AiModelNotifier>());
      container.dispose();
    });

    test('initial state is notDownloaded', () {
      final container = ProviderContainer();
      final state = container.read(aiModelProvider);
      expect(state.status, AiModelStatus.notDownloaded);
      container.dispose();
    });
  });
}
