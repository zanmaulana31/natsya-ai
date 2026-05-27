import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/providers/theme_provider.dart';

void main() {
  group('ThemeNotifier', () {
    test('initializes with light mode', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(themeProvider), ThemeMode.light);
    });

    test('toggle switches between light and dark', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(themeProvider.notifier);

      notifier.toggle();
      expect(container.read(themeProvider), ThemeMode.dark);

      notifier.toggle();
      expect(container.read(themeProvider), ThemeMode.light);
    });
  });
}
