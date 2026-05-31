---
name: Flutter Gemma Model Loading Screen with Background Download & Notification
description: Blocking launch screen that downloads the Qwen2.5-0.5B-Instruct model via FlutterGemma, shows branded progress UI, and sends a local push notification when ready
targets:
  - ../smartai_chat/lib/main.dart
  - ../smartai_chat/lib/screens/model_loading_screen.dart
  - ../smartai_chat/lib/services/notification_service.dart
  - ../smartai_chat/lib/providers/ai_model_provider.dart
  - ../smartai_chat/lib/core/llm_service.dart
  - ../smartai_chat/android/app/src/main/AndroidManifest.xml
  - ../smartai_chat/pubspec.yaml
---

# Flutter Gemma Model Loading Screen

## Overview

A **blocking** screen shown on first app launch when the SmolLM-135M-Instruct model is not yet downloaded. The model download runs via `FlutterGemma.installModel()` so the UI remains responsive. When download completes, a **local push notification** is shown even if the user has minimized or backgrounded the app.

If the user **force-closes** the app during download, the download stops (OS limitation). On the next launch, `LlmService.isModelDownloaded()` → `FlutterGemma.listInstalledModels()` checks disk and skips the blocking screen if the model file exists.

---

## Dependencies

- `flutter_gemma: ^0.16.3` in pubspec.yaml (handles download, MediaPipe template, KV cache, GPU acceleration)
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- `flutter_local_notifications: ^17.2.1` in pubspec.yaml
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- `flutter pub get` succeeds without errors
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- Removed: `tflite_flutter`, `dart_sentencepiece_tokenizer`, `http`, `path_provider`
  `[@test] ../smartai_chat/test/pubspec_test.dart`

---

## Android Configuration

### AndroidManifest.xml Permissions

- INTERNET permission present (required for Hugging Face model download)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- WRITE_EXTERNAL_STORAGE permission present
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- RECORD_AUDIO permission present (optional, for STT)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- POST_NOTIFICATIONS permission present (Android 13+)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- GPU acceleration handled by flutter_gemma/MediaPipe at runtime (no `<uses-native-library>` — AAPT on current AGP doesn't support it)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`

### build.gradle.kts

- `minSdk` >= 24
  `[@test] ../smartai_chat/test/android_config_test.dart`
- `ndk { abiFilters += listOf("arm64-v8a") }` configured
  `[@test] ../smartai_chat/test/android_config_test.dart`

---

## LlmService (lib/core/llm_service.dart)

- Exports `LlmService` class as a singleton via `factory LlmService()`
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `isInitialized` returns `false` before `initialize()` completes
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `isModelDownloaded()` delegates to `FlutterGemma.listInstalledModels()` — returns `true`/`false` without network access
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `initialize()` calls `FlutterGemma.initialize()`, installs model via `FlutterGemma.installModel(modelType: ModelType.general).fromNetwork(url)`, loads via `FlutterGemma.getActiveModel()`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `generateText(List<ChatMessage> messages)` returns `Stream<String>`:
  - Single `InferenceChat` created once during `initialize()` via `model.createChat(modelType: ModelType.general)` — reused across all turns
  - Adds only the **last** message via `chat.addQueryChunk()` with correct `isUser` flag
  - `_isGenerating` guard prevents concurrent calls (MediaPipe single-flight)
  - Streams via `chat.generateChatResponseAsync()`, filters `TextResponse` tokens
  - Does **not** break stream on EOS — continues consuming until MediaPipe engine signals `done=true`. Breaking leaves session busy causing `IllegalStateException` on next message.
  - Tokens with `<|im_end|>` or `<|im_start|>` silently skipped; clean text yielded to UI
  - Same `InferenceChat` reused across all turns
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `dispose()` calls `_model.close()` and clears references
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Exposed via Riverpod provider `llmServiceProvider`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Model URL: `https://huggingface.co/litert-community/SmolLM-135M-Instruct/resolve/main/SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task`
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`

---

## Notification Service (lib/services/notification_service.dart)

- `NotificationService` singleton
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- `initialize()` sets up `FlutterLocalNotificationsPlugin`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Android channel ID: `"natsya_ai_model"`, name: `"Natsya AI Model"`, importance: `high`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- `showModelReadyNotification()` shows title `"Natsya AI"`, body `"Natsya AI can you try right now!"`, payload `"model_ready"`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Does not throw if called before `initialize()` (no-op)
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`

---

## Routing Logic (main.dart)

- `SmartAiApp.build()` watches `aiModelProvider` to determine initial route
  `[@test] ../smartai_chat/test/main_test.dart`
- Setelah auth, `home` selalu `ModelLoadingScreen` — user harus memilih setiap kali, tidak peduli status model
  `[@test] ../smartai_chat/test/main_test.dart`
- `AiModelStatus.ready` hanya mempengaruhi apakah tombol "Download Local Model" langsung navigate atau perlu download dulu
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- `main()` does **not** eagerly call `FlutterGemma.initialize()` — deferred to `ModelLoadingScreen`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main()` calls `WidgetsFlutterBinding.ensureInitialized()` then `NotificationService.instance.initialize()` then sets up Supabase before `runApp()`
  `[@test] ../smartai_chat/test/main_test.dart`

---

## Model Download Flow

### User Choice (Every Launch)

1. `ModelLoadingScreen` shows logo, title "Preparing Natsya AI", and two buttons (always visible — user memilih setiap kali):
   - **"Use Cloud AI"** → navigates directly to `ChatScreen` (Cloud tetap enabled dari `.env`)
   - **"Download Local Model"**:
     - Memanggil `cloudAiConfigProvider.notifier.disable()` untuk nonaktifkan Cloud AI
     - Selalu panggil `AiModelNotifier.downloadAndInit()` — baik status `ready` maupun `notDownloaded`
       (karena `ready` dari cache disk belum berarti model di-load ke memory; `LlmService.initialize()`
        perlu dipanggil untuk load model via FlutterGemma)
   `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

2. `downloadAndInit()` calls `AiModelService.downloadModel()` which delegates to `LlmService.initialize()`:
   - Calls `FlutterGemma.initialize()` (idempotent) then `FlutterGemma.installModel()` with `.task` model URL
   - Model: `SmolLM-135M-Instruct_multi-prefill-seq_q8_ekv1280.task` (~159 MB, quantized MediaPipe format)
   - `FlutterGemma` handles download, caching, retry logic internally
   `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

3. During download, `onProgress` callback (0–100 from flutter_gemma, mapped to 0.0–1.0) updates `AiModelState.downloadProgress`
   `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`

4. After download + load, state transitions to `AiModelStatus.ready`
   `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`

5. `ModelLoadingScreen` listens to `aiModelProvider` and navigates to `ChatScreen` on ready
   `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Subsequent Launches (Model Already Cached)

1. `aiModelProvider.build()` calls `Future.microtask` → `AiModelService.isDownloaded()` → `LlmService.isModelDownloaded()` → `FlutterGemma.listInstalledModels()` checks disk
   `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
2. If model file exists, state is set to `ready`
3. `ModelLoadingScreen` ditampilkan seperti biasa — user tetap bisa pilih "Use Cloud AI" atau "Download Local Model"
4. Jika user memilih "Download Local Model", `downloadAndInit()` tetap dipanggil (tidak langsung navigate) — `LlmService.initialize()` akan load model via `FlutterGemma.getActiveModel()` tanpa re-download
   `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Screen Layout

### Structure

- Root widget: `Scaffold` with `backgroundColor` = `colors.background` (Forui theme)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Body: `Center` > `Column(mainAxisSize: MainAxisSize.min)`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Brand Logo

- `Image.asset('assets/images/n_logo.png')`, 120×120, `BoxFit.contain`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Title Text

- `"Preparing Natsya AI"` using `typography.lg`, `fontWeight: w600`, `colors.foreground`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Progress Bar

- `LinearProgressIndicator`, 280×6 px, border radius 3 px
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Determinate when `downloading` (value = `downloadProgress`)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Indeterminate when `initializing` or `downloaded`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- `backgroundColor` = `colors.muted` alpha 0.3, `valueColor` = `colors.primary`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Status Text

- `downloading`: `"Downloading AI model... {n}%"`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- `initializing`/`downloaded`: `"Initializing AI model..."`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- `error`: `"Something went wrong"`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Style: `typography.sm`, `colors.mutedForeground`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Error State

- Shows error message (max 2 lines) + "Try Again" button
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Retry calls `ref.read(aiModelProvider.notifier).downloadAndInit()`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Progress bar hidden in error state
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Navigation

- User tap "Use Cloud AI" → `Navigator.pushReplacement(ChatScreen)` (guarded by `_didNavigate`), Cloud tetap enabled dari `.env`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- `ref.listen(aiModelProvider, ...)` watches for `ready` status after local model download
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- On ready → `Navigator.pushReplacement(ChatScreen)` (guarded by `_didNavigate`)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Push Notification on Ready

- `AiModelNotifier` calls `NotificationService.instance.showModelReadyNotification()` when state reaches `ready`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Guarded by `_hasNotified` flag — fires only once per download
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`

---

## Blocking Behavior

- User cannot dismiss or skip the screen
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- No AppBar, back button, drawer, or gesture to exit
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Asset Requirement

- `pubspec.yaml` declares `assets/images/n_logo.png`
  `[@test] ../smartai_chat/test/pubspec_test.dart`

---

## const Optimization

- `ModelLoadingScreen` constructor is `const`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Static widgets extracted to private classes (`_ChoiceSection`, `_ProgressSection`, `_ErrorSection`)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Keys for Testability

- Progress bar: `Key('model_loading_progress')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Retry button: `Key('model_loading_retry')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Error message: `Key('model_loading_error')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Cloud choice button: `Key('model_choice_cloud')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Local download button: `Key('model_choice_local')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Resource Requirements

- APK size increase: minimal (flutter_gemma native libs ~30 MB; no tflite_flutter/llm_toolkit)
- Model download: ~159 MB on first launch (SmolLM-135M-Instruct `.task` quantized)
- Runtime RAM: ~300–600 MB (MediaPipe manages KV cache internally)
- Minimum storage: 300 MB free after installation
