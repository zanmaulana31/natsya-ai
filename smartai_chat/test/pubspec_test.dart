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

    test('contains cactus dependency with ^1.3.0', () {
      final deps = pubspec['dependencies'] as Map;
      expect(deps.containsKey('cactus'), isTrue);
      expect(deps['cactus'], '^1.3.0');
    });

    test('contains flutter_local_notifications dependency with ^17.2.1', () {
      final deps = pubspec['dependencies'] as Map;
      expect(deps.containsKey('flutter_local_notifications'), isTrue);
      expect(deps['flutter_local_notifications'], '^17.2.1');
    });

    test('flutter pub get resolves flutter_local_notifications', () {
      final lockFile = File('pubspec.lock');
      if (!lockFile.existsSync()) {
        markTestSkipped('pubspec.lock not found; run flutter pub get first');
        return;
      }
      final lock = loadYaml(lockFile.readAsStringSync()) as Map;
      final packages = lock['packages'] as Map;
      expect(packages.containsKey('flutter_local_notifications'), isTrue,
          reason: 'flutter_local_notifications must be in pubspec.lock');
    });

    test('declares n_logo.png asset', () {
      final flutter = pubspec['flutter'] as Map;
      final assets = flutter['assets'] as List;
      expect(assets, contains('assets/images/n_logo.png'));
    });

    test('flutter pub get resolves cactus', () {
      // If pubspec.lock exists, verify cactus is present
      final lockFile = File('pubspec.lock');
      if (!lockFile.existsSync()) {
        markTestSkipped('pubspec.lock not found; run flutter pub get first');
        return;
      }
      final lock = loadYaml(lockFile.readAsStringSync()) as Map;
      final packages = lock['packages'] as Map;
      expect(packages.containsKey('cactus'), isTrue,
          reason: 'cactus must be in pubspec.lock');
    });
  });
}
