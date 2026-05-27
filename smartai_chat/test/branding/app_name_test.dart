import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('AndroidManifest.xml should have android:label set to Natsya Ai', () {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    expect(manifestFile.existsSync(), isTrue, reason: 'AndroidManifest.xml not found');

    final content = manifestFile.readAsStringSync();
    expect(content, contains('android:label="Natsya Ai"'),
        reason: 'android:label should be "Natsya Ai"');
  });
}
