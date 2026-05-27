import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final densities = <String, int>{
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in densities.entries) {
    test('ic_launcher.png in ${entry.key} should be ${entry.value}x${entry.value} px', () {
      final iconFile = File('android/app/src/main/res/${entry.key}/ic_launcher.png');
      expect(iconFile.existsSync(), isTrue, reason: '${entry.key}/ic_launcher.png not found');

      final bytes = iconFile.readAsBytesSync();

      // PNG IHDR chunk at byte 16 contains width (4 bytes) and height (4 bytes)
      final width = (bytes[16] << 24) | (bytes[17] << 16) | (bytes[18] << 8) | bytes[19];
      final height = (bytes[20] << 24) | (bytes[21] << 16) | (bytes[22] << 8) | bytes[23];

      expect(width, equals(entry.value), reason: '${entry.key} icon width should be ${entry.value}px');
      expect(height, equals(entry.value), reason: '${entry.key} icon height should be ${entry.value}px');
    });
  }

  test('AndroidManifest.xml should keep android:icon="@mipmap/ic_launcher"', () {
    final manifestFile = File('android/app/src/main/AndroidManifest.xml');
    expect(manifestFile.existsSync(), isTrue, reason: 'AndroidManifest.xml not found');

    final content = manifestFile.readAsStringSync();
    expect(content, contains('@mipmap/ic_launcher'),
        reason: 'android:icon should remain @mipmap/ic_launcher');
  });
}
