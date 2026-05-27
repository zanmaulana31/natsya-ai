---
name: Cactus SDK Installation
description: Install and configure Cactus AI SDK (cactus ^1.3.0) in the Flutter project for on-device LLM inference on Android and iOS
targets:
  - ../smartai_chat/pubspec.yaml
  - ../smartai_chat/android/app/src/main/AndroidManifest.xml
  - ../smartai_chat/android/app/build.gradle.kts
  - ../smartai_chat/ios/Runner/Info.plist
  - ../smartai_chat/lib/core/cactus_config.dart
  - ../smartai_chat/lib/main.dart
---

# Cactus SDK Installation

## Pubspec Dependency

- Add `cactus: ^1.3.0` under `dependencies` in `pubspec.yaml`
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- `flutter pub get` resolves and downloads all transitive dependencies without errors
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- `cactus` transitive dependencies (objectbox, permission_handler, ffi, etc.) are compatible with existing deps (`forui`, `flutter_riverpod`)
  `[@test] ../smartai_chat/test/pubspec_test.dart`

## Android Configuration

### AndroidManifest.xml Permissions

- Add `<uses-permission android:name="android.permission.INTERNET" />` to `AndroidManifest.xml`
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- Add `<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />` to `AndroidManifest.xml`
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- Add `<uses-permission android:name="android.permission.RECORD_AUDIO" />` to `AndroidManifest.xml` (optional, required for STT features)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`

### build.gradle.kts

- `minSdk` is set to at least `24` (Android 7.0) in `build.gradle.kts`
  `[@test] ../smartai_chat/test/android_config_test.dart`
- `ndk { abiFilters += listOf("arm64-v8a") }` is configured because Cactus only provides `libcactus.so` for arm64-v8a
  `[@test] ../smartai_chat/test/android_config_test.dart`
- Build completes without native library linking errors (`flutter build apk --debug`)
  `[@test] ../smartai_chat/test/build_test.dart`

## iOS Configuration

### Info.plist

- Add `NSMicrophoneUsageDescription` key to `ios/Runner/Info.plist` with a non-empty description string
  `[@test] ../smartai_chat/test/ios_plist_test.dart`

### Podfile

- iOS deployment target is at least `12.0` in `ios/Podfile` (or `ios/Podfile` is generated with `flutter build ios` if not yet present)
  `[@test] ../smartai_chat/test/ios_config_test.dart`
- Build completes without CocoaPods errors (`flutter build ios --no-codesign`)
  `[@test] ../smartai_chat/test/build_test.dart`

## SDK Configuration

### CactusConfig

- `lib/core/cactus_config.dart` exports a `CactusConfig` class
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`
- `CactusConfig.isTelemetryEnabled` defaults to `false`
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`
- `CactusConfig.setTelemetryToken(String token)` stores the provided telemetry token
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`
- `CactusConfig.setProKey(String proKey)` stores the provided Pro key for NPU acceleration
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`

## App Integration

- `main.dart` imports `package:cactus/cactus.dart`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` before `runApp()`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` sets `CactusConfig.isTelemetryEnabled = false` before `runApp()`
  `[@test] ../smartai_chat/test/main_test.dart`
- App launches without runtime crashes on Android and iOS
  `[@test] ../smartai_chat/test/build_test.dart`
