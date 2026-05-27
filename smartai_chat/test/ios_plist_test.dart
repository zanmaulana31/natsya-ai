import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('iOS Info.plist', () {
    const plistPath = 'ios/Runner/Info.plist';
    late String plist;

    setUpAll(() {
      final file = File(plistPath);
      expect(file.existsSync(), isTrue,
          reason: '$plistPath must exist');
      plist = file.readAsStringSync();
    });

    test('has NSMicrophoneUsageDescription key', () {
      expect(
        plist.contains('NSMicrophoneUsageDescription'),
        isTrue,
      );
    });

    test('NSMicrophoneUsageDescription has non-empty string value', () {
      // Find the key and then the next <string> tag
      final keyIndex = plist.indexOf('NSMicrophoneUsageDescription');
      expect(keyIndex, greaterThan(-1));
      final afterKey = plist.substring(keyIndex);
      final stringMatch = RegExp(r'<string>(.+?)</string>').firstMatch(afterKey);
      expect(stringMatch, isNotNull);
      final value = stringMatch!.group(1)!;
      expect(value.trim(), isNotEmpty);
    });
  });
}
