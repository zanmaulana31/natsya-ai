---
name: Flutter Gemma LLM Model Installation
description: Install and configure flutter_gemma in the Flutter project for on-device LLM inference using LiteRT (MediaPipe .task format) models on Android (replaces tflite_flutter + dart_sentencepiece_tokenizer)
targets:
  - ../smartai_chat/pubspec.yaml
  - ../smartai_chat/android/app/build.gradle.kts
  - ../smartai_chat/android/app/src/main/AndroidManifest.xml
  - ../smartai_chat/lib/core/llm_service.dart
  - ../smartai_chat/lib/main.dart
---

# Flutter Gemma LLM Model Installation

## Pubspec Dependencies

- Add `flutter_gemma: ^0.16.3` under `dependencies` in `pubspec.yaml`
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- Removed: `tflite_flutter`, `dart_sentencepiece_tokenizer`, `http`, `path_provider`
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- `flutter pub get` resolves all transitive dependencies without errors
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- Transitive dependencies are compatible with existing deps (`forui`, `flutter_riverpod`)
  `[@test] ../smartai_chat/test/pubspec_test.dart`

## Android Configuration

### build.gradle.kts

- `minSdk` is set to at least `24` (Android 7.0) in `android/app/build.gradle.kts`
  `[@test] ../smartai_chat/test/android_config_test.dart`
- `ndk { abiFilters += listOf("arm64-v8a") }` is configured for native .so loading
  `[@test] ../smartai_chat/test/android_config_test.dart`
- Build completes without native linking errors (`flutter build apk --debug`)
  `[@test] ../smartai_chat/test/build_test.dart`

### AndroidManifest.xml Permissions

- INTERNET permission present (required for model download from Hugging Face)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- WRITE_EXTERNAL_STORAGE permission present
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- RECORD_AUDIO permission present (optional, for STT features)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- GPU acceleration handled by flutter_gemma/MediaPipe at runtime (no `<uses-native-library>` — AAPT on current AGP doesn't support it)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`

## Model Source

- Default on-device LLM model: `litert-community/SmolLM-135M-Instruct` (135M params, ~159 MB, Apache 2.0)
  `[@test] ../smartai_chat/test/llm_model_test.dart`
- Model format: `.task` (MediaPipe-managed chat templates, Type 1 in flutter_gemma)
  `[@test] ../smartai_chat/test/llm_model_test.dart`
- Model URL: `https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task`
  `[@test] ../smartai_chat/test/llm_model_test.dart`
- Model is downloaded via `FlutterGemma.installModel(modelType: ModelType.general)` at first launch and cached locally
  `[@test] ../smartai_chat/test/llm_model_test.dart`
- `FlutterGemma.installModel()` handles download, resume, retry, caching internally (no custom download code)
  `[@test] ../smartai_chat/test/llm_model_test.dart`

## LLM Service

- `lib/core/llm_service.dart` exports an `LlmService` singleton class via Riverpod provider
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `LlmService.initialize()`:
  1. Calls `FlutterGemma.initialize()` (idempotent — safe to call multiple times)
  2. Installs model via `FlutterGemma.installModel(modelType: ModelType.general).fromNetwork(url).withProgress(callback).install()`
  3. Creates model instance via `FlutterGemma.getActiveModel(maxTokens: 2048, preferredBackend: PreferredBackend.cpu)`
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `LlmService.generateText(List<ChatMessage> messages)` returns `Stream<String>`:
  - Single `InferenceChat` created once during `initialize()` via `model.createChat(modelType: ModelType.general)` — reused for all turns
  - `_isGenerating` guard prevents concurrent calls (MediaPipe `LlmInferenceSession` is single-flight)
  - Adds only the **last** message via `chat.addQueryChunk()` with correct `isUser` flag
  - Streams via `chat.generateChatResponseAsync()`, filters `TextResponse` tokens
  - Does **not** break stream on EOS — continues consuming until MediaPipe engine completes (`done=true`). Breaking early leaves session in busy state causing `IllegalStateException` on next `addQueryChunk`.
  - Tokens with `<|im_end|>` or `<|im_start|>` silently skipped (`continue`); clean text yielded to UI
  - Does **not** close chat after generation — single `InferenceChat` reused across all turns
  - Chat closed only once during `LlmService.dispose()`
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `LlmService.dispose()` calls `_model.close()` and clears references
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `isModelDownloaded()` delegates to `FlutterGemma.listInstalledModels()` — no manual disk access
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`

## App Integration

- `main.dart` imports `lib/core/llm_service.dart`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` before `runApp()`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` does NOT eagerly call `FlutterGemma.initialize()` — deferred to user action on `ModelLoadingScreen`
  `[@test] ../smartai_chat/test/main_test.dart`
- App launches without runtime crashes on Android
  `[@test] ../smartai_chat/test/build_test.dart`

## Resource Requirements

- APK size increase: ~30 MB (flutter_gemma native libs — smaller than tflite_flutter + llm_toolkit)
- Model download: ~159 MB on first launch (SmolLM-135M-Instruct `.task` quantized)
- Runtime RAM: ~300-600 MB (SmolLM-135M via MediaPipe, KV cache managed internally)
- Minimum storage: 300 MB free after installation
