import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  group('Pubspec', () {
    late Map pubspec;

    setUpAll(() {
      final file = File('pubspec.yaml');
      expect(file.existsSync(), isTrue, reason: 'pubspec.yaml must exist');
      pubspec = loadYaml(file.readAsStringSync()) as Map;
    });

    test('contains flutter_gemma dependency with ^0.16.3', () {
      final deps = pubspec['dependencies'] as Map;
      expect(deps.containsKey('flutter_gemma'), isTrue);
      expect(deps['flutter_gemma'], '^0.16.3');
    });

    test('does NOT contain cactus dependency', () {
      final deps = pubspec['dependencies'] as Map;
      expect(deps.containsKey('cactus'), isFalse,
          reason: 'cactus SDK must be removed');
    });

    test('contains flutter_local_notifications dependency with ^17.2.1', () {
      final deps = pubspec['dependencies'] as Map;
      expect(deps.containsKey('flutter_local_notifications'), isTrue);
      expect(deps['flutter_local_notifications'], '^17.2.1');
    });

    test('declares n_logo.png asset', () {
      final flutter = pubspec['flutter'] as Map;
      final assets = flutter['assets'] as List;
      expect(assets, contains('assets/images/n_logo.png'));
    });
  });
}
