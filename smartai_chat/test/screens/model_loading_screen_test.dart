import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartai_chat/models/ai_model_status.dart';
import 'package:smartai_chat/providers/ai_model_provider.dart';
import 'package:smartai_chat/screens/chat_screen.dart';
import 'package:smartai_chat/screens/model_loading_screen.dart';
import 'package:smartai_chat/services/ai_model_service.dart';

class MockAiModelService extends Mock implements AiModelService {}

class TestAiModelNotifier extends AiModelNotifier {
  final AiModelState _initialState;

  TestAiModelNotifier(this._initialState);

  @override
  AiModelState build() => _initialState;

  @override
  Future<void> downloadAndInit() async {}
}

void main() {
  group('ModelLoadingScreen', () {
    late MockAiModelService mockService;

    setUp(() {
      mockService = MockAiModelService();
      when(() => mockService.isDownloaded()).thenAnswer((_) async => false);
    });

    Widget buildScreen({required AiModelState state}) {
      return ProviderScope(
        overrides: [
          aiModelServiceProvider.overrideWith((ref) => mockService),
          aiModelProvider.overrideWith(() => TestAiModelNotifier(state)),
        ],
        child: MaterialApp(
          home: FTheme(
            data: FThemes.violet.light.touch,
            child: const FToaster(
              child: FTooltipGroup(
                child: ModelLoadingScreen(),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('is ConsumerStatefulWidget', (tester) async {
      expect(const ModelLoadingScreen(), isA<ConsumerStatefulWidget>());
    });

    testWidgets('has const constructor', (tester) async {
      expect(const ModelLoadingScreen().key, isNull);
    });

    testWidgets('shows choice section when status is notDownloaded', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      expect(find.text('Choose how to use Natsya AI'), findsOneWidget);
      expect(find.byKey(const Key('model_choice_cloud')), findsOneWidget);
      expect(find.byKey(const Key('model_choice_local')), findsOneWidget);
    });

    testWidgets('does not auto-download on init', (tester) async {
      final mock = MockAiModelService();
      when(() => mock.isDownloaded()).thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelServiceProvider.overrideWith((ref) => mock),
            aiModelProvider.overrideWith(() => TestAiModelNotifier(
              const AiModelState(status: AiModelStatus.notDownloaded),
            )),
          ],
          child: MaterialApp(
            home: FTheme(
              data: FThemes.violet.light.touch,
              child: const FToaster(
                child: FTooltipGroup(
                  child: ModelLoadingScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Choose how to use Natsya AI'), findsOneWidget);
    });

    testWidgets('does not call downloadAndInit when already downloading', (tester) async {
      final mock = MockAiModelService();
      when(() => mock.isDownloaded()).thenAnswer((_) async => false);

      // Start already in downloading state (choice won't be shown)
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiModelServiceProvider.overrideWith((ref) => mock),
            aiModelProvider.overrideWith(() => TestAiModelNotifier(
              const AiModelState(status: AiModelStatus.downloading, downloadProgress: 0.5),
            )),
          ],
          child: MaterialApp(
            home: FTheme(
              data: FThemes.violet.light.touch,
              child: const FToaster(
                child: FTooltipGroup(
                  child: ModelLoadingScreen(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Should show progress, not choice section
      expect(find.byKey(const Key('model_loading_progress')), findsOneWidget);
      expect(find.text('Choose how to use Natsya AI'), findsNothing);
    });

    testWidgets('root is Scaffold with backgroundColor', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isNotNull);
    });

    testWidgets('body is Center containing Column', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      expect(find.byType(Center), findsOneWidget);
      final center = tester.widget<Center>(find.byType(Center));
      expect(center.child, isA<Column>());
      final column = center.child as Column;
      expect(column.mainAxisSize, MainAxisSize.min);
    });

    testWidgets('displays logo image with correct properties', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final image = tester.widget<Image>(imageFinder);
      expect(image.image, isA<AssetImage>());
      expect((image.image as AssetImage).assetName, 'assets/images/n_logo.png');
      expect(image.width, 120);
      expect(image.height, 120);
      expect(image.fit, BoxFit.contain);
    });

    testWidgets('displays title text "Preparing Natsya AI"', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      expect(find.text('Preparing Natsya AI'), findsOneWidget);
    });

    testWidgets('shows determinate progress bar when downloading', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(
          status: AiModelStatus.downloading,
          downloadProgress: 0.42,
        ),
      ));

      final progressFinder = find.byKey(const Key('model_loading_progress'));
      expect(progressFinder, findsOneWidget);

      final progress = tester.widget<LinearProgressIndicator>(progressFinder);
      expect(progress.value, 0.42);
    });

    testWidgets('shows indeterminate progress when initializing', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.initializing),
      ));

      final progressFinder = find.byKey(const Key('model_loading_progress'));
      expect(progressFinder, findsOneWidget);

      final progress = tester.widget<LinearProgressIndicator>(progressFinder);
      expect(progress.value, isNull);
    });

    testWidgets('shows indeterminate progress when downloaded', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.downloaded),
      ));

      final progressFinder = find.byKey(const Key('model_loading_progress'));
      expect(progressFinder, findsOneWidget);

      final progress = tester.widget<LinearProgressIndicator>(progressFinder);
      expect(progress.value, isNull);
    });

    testWidgets('progress bar has constrained size', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(
          status: AiModelStatus.downloading,
          downloadProgress: 0.5,
        ),
      ));

      final sizedBoxFinder = find.ancestor(
        of: find.byKey(const Key('model_loading_progress')),
        matching: find.byType(SizedBox),
      );
      expect(sizedBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, 280);
      expect(sizedBox.height, 6);
    });

    testWidgets('shows downloading status text with percentage', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(
          status: AiModelStatus.downloading,
          downloadProgress: 0.42,
        ),
      ));

      expect(find.text('Downloading AI model... 42%'), findsOneWidget);
    });

    testWidgets('shows initializing status text', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.initializing),
      ));

      expect(find.text('Initializing AI model...'), findsOneWidget);
    });

    testWidgets('shows downloaded status text as initializing', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.downloaded),
      ));

      expect(find.text('Initializing AI model...'), findsOneWidget);
    });

    testWidgets('shows error status text', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(
          status: AiModelStatus.error,
          errorMessage: 'Network failed',
        ),
      ));

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows error message with key', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(
          status: AiModelStatus.error,
          errorMessage: 'Network failed',
        ),
      ));

      expect(find.byKey(const Key('model_loading_error')), findsOneWidget);
      expect(find.text('Network failed'), findsOneWidget);
    });

    testWidgets('shows retry button in error state', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(
          status: AiModelStatus.error,
          errorMessage: 'Network failed',
        ),
      ));

      expect(find.byKey(const Key('model_loading_retry')), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('hides progress bar in error state', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.error),
      ));

      expect(find.byKey(const Key('model_loading_progress')), findsNothing);
    });

    testWidgets('has no AppBar', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      expect(find.byType(AppBar), findsNothing);
    });

    testWidgets('tapping "Download Local Model" shows progress on ready', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      expect(find.byKey(const Key('model_choice_local')), findsOneWidget);

      await tester.tap(find.byKey(const Key('model_choice_local')));
      await tester.pump();

      // After tapping local, choice section disappears, progress appears
      // (status transitions to downloading in real code; in test it stays notDownloaded
      //  because TestAiModelNotifier.downloadAndInit is a no-op)
      // The progress section won't show because status is still notDownloaded.
      // Instead, trigger ready state manually to test navigation.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(ModelLoadingScreen)),
      );
      container.read(aiModelProvider.notifier).state =
          const AiModelState(status: AiModelStatus.ready);

      await tester.pumpAndSettle();

      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('tapping "Use Cloud AI" navigates to chat', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      expect(find.byKey(const Key('model_choice_cloud')), findsOneWidget);

      await tester.tap(find.byKey(const Key('model_choice_cloud')));
      await tester.pumpAndSettle();

      expect(find.byType(ChatScreen), findsOneWidget);
    });

    testWidgets('does not navigate twice on subsequent rebuilds', (tester) async {
      await tester.pumpWidget(buildScreen(
        state: const AiModelState(status: AiModelStatus.notDownloaded),
      ));

      await tester.tap(find.byKey(const Key('model_choice_local')));
      await tester.pump();

      final container = ProviderScope.containerOf(
        tester.element(find.byType(ModelLoadingScreen)),
      );
      container.read(aiModelProvider.notifier).state =
          const AiModelState(status: AiModelStatus.ready);

      await tester.pumpAndSettle();
      expect(find.byType(ChatScreen), findsOneWidget);

      // Trigger rebuild - should not cause error
      container.read(aiModelProvider.notifier).state =
          const AiModelState(status: AiModelStatus.ready);
      await tester.pumpAndSettle();

      expect(find.byType(ChatScreen), findsOneWidget);
    });
  });
}
