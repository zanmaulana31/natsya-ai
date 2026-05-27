import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('main.dart', () {
    const mainPath = 'lib/main.dart';
    late String mainContent;

    setUpAll(() {
      final file = File(mainPath);
      expect(file.existsSync(), isTrue,
          reason: '$mainPath must exist');
      mainContent = file.readAsStringSync();
    });

    test('imports package:cactus/cactus.dart', () {
      expect(
        mainContent.contains("import 'package:cactus/cactus.dart'"),
        isTrue,
        reason: 'main.dart must import cactus package',
      );
    });

    test('calls WidgetsFlutterBinding.ensureInitialized()', () {
      expect(
        mainContent.contains('WidgetsFlutterBinding.ensureInitialized()'),
        isTrue,
        reason: 'main.dart must call ensureInitialized',
      );
    });

    test('sets CactusConfig.isTelemetryEnabled = false', () {
      expect(
        mainContent.contains('CactusConfig.isTelemetryEnabled = false'),
        isTrue,
        reason: 'main.dart must disable telemetry',
      );
    });

    test('imports notification_service.dart', () {
      expect(
        mainContent.contains("import 'services/notification_service.dart'"),
        isTrue,
        reason: 'main.dart must import notification service',
      );
    });

    test('imports model_loading_screen.dart', () {
      expect(
        mainContent.contains("import 'screens/model_loading_screen.dart'"),
        isTrue,
        reason: 'main.dart must import model loading screen',
      );
    });

    test('initializes NotificationService', () {
      expect(
        mainContent.contains('NotificationService.instance.initialize()'),
        isTrue,
        reason: 'main.dart must initialize notification service',
      );
    });

    test('conditional home based on aiModelProvider status', () {
      expect(
        mainContent.contains('AiModelStatus.ready'),
        isTrue,
        reason: 'main.dart must check AiModelStatus.ready',
      );
      expect(
        mainContent.contains('ModelLoadingScreen'),
        isTrue,
        reason: 'main.dart must route to ModelLoadingScreen',
      );
    });
  });
}
