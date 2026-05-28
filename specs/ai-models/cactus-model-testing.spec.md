---
name: Cactus Model Testing
description: Unit and integration tests that verify the Cactus SDK is installed, the LFM 2 350M model can be downloaded and initialized, and AI inference runs successfully
targets:
  - ../smartai_chat/test/
---

# Cactus Model Testing

## SDK Installation Tests

### Pubspec Test

- `pubspec.yaml` contains a dependency entry for `cactus` with version constraint `^1.3.0`
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- `flutter pub get` completes successfully (lockfile contains `cactus` package)
  `[@test] ../smartai_chat/test/pubspec_test.dart`

### Android Manifest Test

- `AndroidManifest.xml` contains `INTERNET` permission
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- `AndroidManifest.xml` contains `ACCESS_NETWORK_STATE` permission
  `[@test] ../smartai_chat/test/android_manifest_test.dart`

### Android Config Test

- `build.gradle.kts` sets `minSdk` to at least `24`
  `[@test] ../smartai_chat/test/android_config_test.dart`
- `build.gradle.kts` configures `abiFilters` for `arm64-v8a`
  `[@test] ../smartai_chat/test/android_config_test.dart`

### iOS Plist Test

- `Info.plist` contains `NSMicrophoneUsageDescription` key with non-empty string
  `[@test] ../smartai_chat/test/ios_plist_test.dart`

### iOS Config Test

- `Podfile` sets platform to at least `12.0` (or Podfile does not exist yet, which is acceptable before first iOS build)
  `[@test] ../smartai_chat/test/ios_config_test.dart`

### CactusConfig Test

- `CactusConfig.isTelemetryEnabled` is `false` by default
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`
- `CactusConfig.setTelemetryToken('test-token')` stores the token internally
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`
- `CactusConfig.setProKey('test-key')` stores the key internally
  `[@test] ../smartai_chat/test/core/cactus_config_test.dart`

### Main Test

- `main.dart` imports `package:cactus/cactus.dart`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` before `runApp()`
  `[@test] ../smartai_chat/test/main_test.dart`

## Model Status Tests

- `AiModelStatus` has exactly the 6 enum values: `notDownloaded`, `downloading`, `downloaded`, `initializing`, `ready`, `error`
  `[@test] ../smartai_chat/test/models/ai_model_status_test.dart`
- Enum values are ordered as expected for forward lifecycle transitions
  `[@test] ../smartai_chat/test/models/ai_model_status_test.dart`

## AI Model Service Tests

### Lifecycle Tests

- `AiModelService` constructs without throwing
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- After construction, `status` is `AiModelStatus.notDownloaded`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `downloadModel()` transitions status to `AiModelStatus.downloaded` on success (mocked)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `initializeModel()` transitions status to `AiModelStatus.ready` on success (mocked)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `unload()` transitions status back to `AiModelStatus.notDownloaded`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `dispose()` calls `unload()` and does not throw
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Completion Tests (Mocked)

- `generateCompletion()` returns a `CactusCompletionResult` with `success = true` when the model is ready (mocked)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `generateCompletionStream()` returns a `CactusStreamedCompletionResult` with a non-null stream (mocked)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Calling `generateCompletion()` when status is not `ready` throws a `StateError` or returns an error result
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Error Handling Tests

- `downloadModel()` retries once on transient network errors before failing
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- After a failed download, status is `AiModelStatus.error` and error message is non-empty
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- After a failed initialization, status is `AiModelStatus.error` and error message is non-empty
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

## AI Model Provider Tests

- `AiModelNotifier` initializes with `AiModelState(status: AiModelStatus.notDownloaded)`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `downloadAndInit()` updates state through `downloading` → `downloaded` → `initializing` → `ready` sequence on success (mocked)
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `unloadModel()` resets state to `AiModelStatus.notDownloaded`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `generate('Hello')` calls service `generateCompletion()` with a single user message (mocked)
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Errors from the service are reflected in `AiModelState.errorMessage`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`

## Integration / Smoke Tests

### Build Test

- `flutter build apk --debug` completes without native linking errors
  `[@test] ../smartai_chat/test/build_test.dart`
- `flutter build ios --no-codesign` completes without CocoaPods or native linking errors
  `[@test] ../smartai_chat/test/build_test.dart`

### End-to-End Smoke Test (Optional)

- On a real Android arm64 device or emulator, `CactusLM` can be instantiated without crashing
  `[@test] ../smartai_chat/test/integration/cactus_smoke_test.dart`
- The app launches and `AiModelService` status begins at `notDownloaded`
  `[@test] ../smartai_chat/test/integration/cactus_smoke_test.dart`
