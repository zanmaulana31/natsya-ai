---
name: Cactus Model Installation
description: Download, initialize, and manage the Cactus LFM2.5 1.2B Thinking model for on-device inference in the SmartAI Flutter app
targets:
  - ../smartai_chat/lib/services/ai_model_service.dart
  - ../smartai_chat/lib/providers/ai_model_provider.dart
  - ../smartai_chat/lib/models/ai_model_status.dart
---

# Cactus Model Installation

## Model Identity

- Target model slug is `lfm2.5-1.2b-thinking` (Cactus LFM2.5 1.2B Thinking)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Model supports text completion, streaming, and tool calling
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Default quantization is `int8` (balance of model size and inference accuracy)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Default context size is `2048` tokens
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

## Model Status Enum

```dart
enum AiModelStatus {
  notDownloaded,
  downloading,
  downloaded,
  initializing,
  ready,
  error,
}
```

- `AiModelStatus` tracks the lifecycle state of the model
  `[@test] ../smartai_chat/test/models/ai_model_status_test.dart`
- Status transitions forward: `notDownloaded` → `downloading` → `downloaded` → `initializing` → `ready`
  `[@test] ../smartai_chat/test/models/ai_model_status_test.dart`
- Status can jump to `error` from any state
  `[@test] ../smartai_chat/test/models/ai_model_status_test.dart`

## AI Model Service

- `AiModelService` encapsulates all Cactus LM operations
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Constructor creates an internal `CactusLM` instance
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Download Model

- `downloadModel()` calls `CactusLM.downloadModel(model: 'lfm2.5-1.2b-thinking')` with an optional progress callback
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Download reports progress as `double` from `0.0` to `1.0`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Download errors set status to `AiModelStatus.error` and expose a human-readable error message
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Successful download transitions status to `AiModelStatus.downloaded`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Initialize Model

- `initializeModel()` calls `CactusLM.initializeModel()` with `CactusInitParams(model: 'lfm2.5-1.2b-thinking', contextSize: 2048)`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Status transitions to `AiModelStatus.initializing` before initialization begins
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Successful initialization transitions status to `AiModelStatus.ready`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Initialization errors set status to `AiModelStatus.error`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Model Info

- `getModelInfo()` returns `CactusModel` metadata (slug, sizeMb, supportsToolCalling, supportsVision, isDownloaded, quantization)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `isDownloaded()` returns `bool` based on `CactusModel.isDownloaded`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Generate Completion

- `generateCompletion(List<ChatMessage> messages, {CactusCompletionParams? params})` delegates to `CactusLM.generateCompletion()`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Returns `CactusCompletionResult` with fields: `success`, `response`, `timeToFirstTokenMs`, `totalTimeMs`, `tokensPerSecond`, `totalTokens`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- Streaming variant `generateCompletionStream(List<ChatMessage> messages, {CactusCompletionParams? params})` returns `CactusStreamedCompletionResult` containing a `Stream<String>` and a `Future<CactusCompletionResult>`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Cleanup

- `unload()` calls `CactusLM.unload()` to free the model from memory
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `unload()` transitions status back to `AiModelStatus.notDownloaded`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `AiModelService` implements `dispose()` for Riverpod compatibility
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

## Riverpod Provider

- `aiModelProvider` is a `StateNotifierProvider<AiModelNotifier, AiModelState>`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `AiModelState` holds `AiModelStatus status`, `double? downloadProgress`, and `String? errorMessage`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Provider initializes with `AiModelState(status: AiModelStatus.notDownloaded)`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `downloadAndInit()` orchestrates download → init in sequence, updating state at each step
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `unloadModel()` calls service `unload()` and resets state to `AiModelStatus.notDownloaded`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- `generate(String userMessage)` wraps a single user message into `ChatMessage` list and calls `generateCompletion`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`

## Error Handling

- All async operations in `AiModelService` catch exceptions and surface them as `AiModelStatus.error` with a human-readable message (e.g. "Model download failed: network error")
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `AiModelService` retries model download exactly once on transient network errors
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `AiModelNotifier` propagates service errors into `AiModelState.errorMessage` without crashing the UI
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
