import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Android build.gradle.kts', () {
    const gradlePath = 'android/app/build.gradle.kts';
    late String gradle;

    setUpAll(() {
      final file = File(gradlePath);
      expect(file.existsSync(), isTrue,
          reason: '$gradlePath must exist');
      gradle = file.readAsStringSync();
    });

    test('minSdk is at least 24', () {
      // Accept either minSdk = 24 or minSdk = flutter.minSdkVersion with 24 elsewhere
      final minSdkMatch = RegExp(r'minSdk\s*=\s*(\d+)').firstMatch(gradle);
      expect(minSdkMatch, isNotNull,
          reason: 'minSdk assignment not found');
      final minSdkValue = int.parse(minSdkMatch!.group(1)!);
      expect(minSdkValue, greaterThanOrEqualTo(24),
          reason: 'minSdk must be >= 24');
    });

    test('abiFilters includes arm64-v8a', () {
      expect(
        gradle.contains('arm64-v8a'),
        isTrue,
        reason: 'ndk abiFilters must include arm64-v8a',
      );
    });
  });
}
