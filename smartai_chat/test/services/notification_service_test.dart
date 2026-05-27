import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dexterous.com/flutter/local_notifications');

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
      switch (call.method) {
        case 'initialize':
          return true;
        case 'createNotificationChannel':
          return null;
        case 'show':
          return null;
        case 'requestPermissions':
          return {'authorized': true};
        default:
          return null;
      }
    });
  });

  tearDownAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('NotificationService structural', () {
    late String source;

    setUpAll(() {
      final file = File('lib/services/notification_service.dart');
      source = file.readAsStringSync();
    });

    test('exports NotificationService class', () {
      expect(source.contains('class NotificationService'), isTrue);
    });

    test('is singleton accessible via instance', () {
      expect(source.contains('static final NotificationService instance'), isTrue);
      expect(source.contains('NotificationService._internal'), isTrue);
    });

    test('has initialize method', () {
      expect(source.contains('Future<void> initialize()'), isTrue);
    });

    test('has showModelReadyNotification method', () {
      expect(source.contains('Future<void> showModelReadyNotification()'), isTrue);
    });

    test('uses correct Android channel ID', () {
      expect(source.contains("'natsya_ai_model'"), isTrue);
    });

    test('uses correct Android channel name', () {
      expect(source.contains("'Natsya AI Model'"), isTrue);
    });

    test('uses correct Android channel description', () {
      expect(source.contains("'Notifications for AI model readiness'"), isTrue);
    });

    test('uses Importance.high', () {
      expect(source.contains('Importance.high'), isTrue);
    });

    test('uses iOS presentation options', () {
      expect(source.contains('presentAlert: true'), isTrue);
      expect(source.contains('presentBadge: true'), isTrue);
      expect(source.contains('presentSound: true'), isTrue);
    });

    test('showModelReadyNotification has correct title', () {
      expect(source.contains("'Natsya AI'"), isTrue);
    });

    test('showModelReadyNotification has correct body', () {
      expect(source.contains("'Natsya AI can you try right now!'"), isTrue);
    });

    test('showModelReadyNotification uses payload model_ready', () {
      expect(source.contains("'model_ready'"), isTrue);
    });

    test('showModelReadyNotification uses fixed ID 1', () {
      expect(source.contains('show(\n      1,'), isTrue);
    });

    test('guards against calling show before initialize', () {
      expect(source.contains('if (!_initialized) return;'), isTrue);
    });
  });

  group('NotificationService behavioral', () {
    test('instance is singleton', () {
      expect(NotificationService.instance, same(NotificationService.instance));
    });

    test('initialize completes without error', () async {
      await NotificationService.instance.initialize();
    });

    test('showModelReadyNotification does not throw', () async {
      await NotificationService.instance.showModelReadyNotification();
    });
  });
}
