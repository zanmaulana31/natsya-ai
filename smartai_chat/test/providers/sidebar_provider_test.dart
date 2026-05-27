import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/providers/sidebar_provider.dart';

void main() {
  group('SidebarProvider', () {
    test('initial state is closed (false)', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(sidebarProvider), isFalse);
    });

    test('toggle switches state', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sidebarProvider.notifier).toggle();
      expect(container.read(sidebarProvider), isTrue);

      container.read(sidebarProvider.notifier).toggle();
      expect(container.read(sidebarProvider), isFalse);
    });

    test('open sets state to true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sidebarProvider.notifier).open();
      expect(container.read(sidebarProvider), isTrue);
    });

    test('close sets state to false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(sidebarProvider.notifier).open();
      container.read(sidebarProvider.notifier).close();
      expect(container.read(sidebarProvider), isFalse);
    });
  });
}
