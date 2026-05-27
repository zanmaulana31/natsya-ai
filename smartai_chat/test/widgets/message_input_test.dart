import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:smartai_chat/widgets/message_input.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: FTheme(
      data: FThemes.zinc.light.touch,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  group('MessageInput layout', () {
    testWidgets('renders Row with Expanded text field and send button', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('has consistent vertical padding container', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.padding, isNotNull);
    });
  });

  group('MessageInput text field', () {
    testWidgets('uses FTextField with textInputAction.send', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      final field = tester.widget<FTextField>(find.byType(FTextField));
      expect(field.textInputAction, TextInputAction.send);
    });

    testWidgets('hint text is "Message"', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      expect(find.text('Message'), findsOneWidget);
    });

    testWidgets('onSubmit clears the field', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, isEmpty);
    });

    testWidgets('FTextField renders without error (pill border)', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      expect(find.byType(FTextField), findsOneWidget);
    });

    testWidgets('field accepts input again after sending (focus retained)', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      await tester.enterText(find.byType(TextField), 'first');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      await tester.enterText(find.byType(TextField), 'second');
      await tester.pump();
      expect(find.text('second'), findsOneWidget);
    });
  });

  group('MessageInput send button', () {
    testWidgets('send button is circular with arrow icon', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
      final containers = tester.widgetList<AnimatedContainer>(find.byType(AnimatedContainer));
      expect(
        containers.any((c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle),
        isTrue,
      );
    });

    testWidgets('button uses muted color when field is empty', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      final container = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .firstWhere((c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(FColors.zincLight.muted));
    });

    testWidgets('button uses primary color when text is present', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      final container = tester
          .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
          .firstWhere((c) => (c.decoration as BoxDecoration?)?.shape == BoxShape.circle);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(FColors.zincLight.primary));
    });

    testWidgets('button is not tappable when field is empty', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      final gesture = find.byType(GestureDetector).last;
      final detector = tester.widget<GestureDetector>(gesture);
      expect(detector.onTap, isNull);
    });

    testWidgets('button is tappable when text is present', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      final gesture = find.byType(GestureDetector).last;
      final detector = tester.widget<GestureDetector>(gesture);
      expect(detector.onTap, isNotNull);
    });
  });

  group('MessageInput send behavior', () {
    testWidgets('whitespace-only message does not clear the field', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      await tester.enterText(find.byType(TextField), '   ');
      await tester.pump();
      await tester.tap(find.byType(GestureDetector).last);
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, equals('   '));
    });

    testWidgets('tapping button with valid text clears the field', (tester) async {
      await tester.pumpWidget(_wrap(const MessageInput()));
      await tester.enterText(find.byType(TextField), 'hello');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.arrow_upward));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).controller?.text, isEmpty);
    });
  });
}
