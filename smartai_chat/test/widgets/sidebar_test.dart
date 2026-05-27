import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:smartai_chat/widgets/sidebar.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: FTheme(
      data: FThemes.zinc.light.touch,
      child: MaterialApp(home: Scaffold(body: SizedBox(width: 400, height: 600, child: child))),
    ),
  );
}

void main() {
  group('Sidebar', () {
    testWidgets('renders brand header with Natsya Ai text', (tester) async {
      await tester.pumpWidget(_wrap(const Sidebar()));
      await tester.pump();
      expect(find.text('Natsya Ai'), findsOneWidget);
    });

    testWidgets('renders session list from MockSessions', (tester) async {
      await tester.pumpWidget(_wrap(const Sidebar()));
      await tester.pump();
      expect(find.text('Flutter Development Help'), findsOneWidget);
      expect(find.text('Project Planning Discussion'), findsOneWidget);
      expect(find.text('Bug Fixing Session'), findsOneWidget);
      expect(find.text('Code Review'), findsOneWidget);
      expect(find.text('UI Design Ideas'), findsOneWidget);
    });

    testWidgets('active session has primary colored text', (tester) async {
      await tester.pumpWidget(_wrap(const Sidebar()));
      await tester.pump();

      final activeText = tester.widget<Text>(
        find.text('Flutter Development Help'),
      );
      expect(activeText.style?.color, FColors.zincLight.primary);
    });

    testWidgets('inactive sessions have muted foreground color', (tester) async {
      await tester.pumpWidget(_wrap(const Sidebar()));
      await tester.pump();

      final inactiveText = tester.widget<Text>(
        find.text('Project Planning Discussion'),
      );
      expect(inactiveText.style?.color, FColors.zincLight.mutedForeground);
    });
  });
}
