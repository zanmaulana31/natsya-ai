import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/main.dart';
import 'package:smartai_chat/models/ai_model_status.dart';
import 'package:smartai_chat/providers/ai_model_provider.dart';

class _ReadyAiModelNotifier extends AiModelNotifier {
  @override
  AiModelState build() => const AiModelState(status: AiModelStatus.ready);
}

void main() {
  testWidgets('App renders chat screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          aiModelProvider.overrideWith(_ReadyAiModelNotifier.new),
        ],
        child: const SmartAiApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Chat with Natsya'), findsOneWidget);
  });
}
