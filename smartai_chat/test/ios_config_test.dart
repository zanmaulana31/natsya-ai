import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS Podfile', () {
    const podfilePath = 'ios/Podfile';
    late File podfile;

    setUpAll(() {
      podfile = File(podfilePath);
    });

    test('Podfile exists', () {
      expect(podfile.existsSync(), isTrue,
          reason: '$podfilePath must exist');
    });

    test('platform is at least 12.0', () {
      final content = podfile.readAsStringSync();
      final match = RegExp(r'platform :ios, .?(\d+\.\d+).?')
          .firstMatch(content);
      expect(match, isNotNull,
          reason: 'platform line not found in Podfile');
      final version = double.parse(match!.group(1)!);
      expect(version, greaterThanOrEqualTo(12.0),
          reason: 'iOS platform must be >= 12.0');
    });
  });
}
