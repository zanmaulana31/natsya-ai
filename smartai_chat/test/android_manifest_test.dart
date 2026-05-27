import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AndroidManifest', () {
    const manifestPath = 'android/app/src/main/AndroidManifest.xml';
    late String manifest;

    setUpAll(() {
      final file = File(manifestPath);
      expect(file.existsSync(), isTrue,
          reason: '$manifestPath must exist');
      manifest = file.readAsStringSync();
    });

    test('has INTERNET permission', () {
      expect(
        manifest.contains('android:name="android.permission.INTERNET"'),
        isTrue,
      );
    });

    test('has ACCESS_NETWORK_STATE permission', () {
      expect(
        manifest.contains(
            'android:name="android.permission.ACCESS_NETWORK_STATE"'),
        isTrue,
      );
    });

    test('has RECORD_AUDIO permission', () {
      expect(
        manifest.contains(
            'android:name="android.permission.RECORD_AUDIO"'),
        isTrue,
      );
    });

    test('has POST_NOTIFICATIONS permission', () {
      expect(
        manifest.contains(
            'android:name="android.permission.POST_NOTIFICATIONS"'),
        isTrue,
      );
    });
  });
}
