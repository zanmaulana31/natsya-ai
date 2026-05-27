import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/main.dart';

void main() {
  testWidgets('App renders chat screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartAiApp()));
    expect(find.text('Chat with Natsya'), findsOneWidget);
  });
}
