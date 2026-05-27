import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:smartai_chat/widgets/sidebar_toggle_button.dart';

Widget _wrap(Widget child) {
  return ProviderScope(
    child: FTheme(
      data: FThemes.zinc.light.touch,
      child: MaterialApp(home: Scaffold(body: child)),
    ),
  );
}

void main() {
  group('SidebarToggleButton', () {
    testWidgets('renders chevron_right icon', (tester) async {
      await tester.pumpWidget(_wrap(const SidebarToggleButton()));
      await tester.pump();
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('has proper container styling', (tester) async {
      await tester.pumpWidget(_wrap(const SidebarToggleButton()));
      await tester.pump();
      expect(find.byType(Container), findsOneWidget);
    });
  });
}
