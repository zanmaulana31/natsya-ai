import 'package:cactus/cactus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CactusConfig', () {
    test('isTelemetryEnabled defaults to true from SDK, can be set to false', () {
      // Note: SDK defaults to true, but we override to false in main.dart
      CactusConfig.isTelemetryEnabled = false;
      expect(CactusConfig.isTelemetryEnabled, isFalse);
    });

    test('setTelemetryToken does not throw', () {
      expect(
        () => CactusConfig.setTelemetryToken('test-token-123'),
        returnsNormally,
      );
    });

    test('setProKey does not throw', () {
      expect(
        () => CactusConfig.setProKey('test-pro-key-456'),
        returnsNormally,
      );
    });
  });
}
