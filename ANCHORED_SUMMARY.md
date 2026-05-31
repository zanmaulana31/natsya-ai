## Goal
Get on-device LLM running via `flutter_gemma` (replaces raw `tflite_flutter`), with Cloud AI / Local AI routing that respects user choice.

## Constraints & Preferences
- User must always see the ModelLoadingScreen choice after auth — no auto-redirect.
- `flutter_gemma` v0.16.3 supports `ModelType.general` (SmolLM, DeepSeek, Qwen, etc.), so raw `tflite_flutter` is no longer needed.
- `.task` (MediaPipe) vs `.litertlm` (LiteRT-LM/FFI): **`.litertlm` not fully supported on Android via `getActiveModel()`** in v0.16.3 (EngineFactory rejects it — needs FFI path).
- Qwen2.5-0.5B-Instruct tersedia dalam `.task` format (547 MB) — fully compatible.
- ChatML format (`<|im_start|>`/`<|im_end|>`) — handled by `flutter_gemma` `transformToChatPrompt`.

## Progress
### Done
- Migrated from `tflite_flutter` + `dart_sentencepiece_tokenizer` + `http` + `path_provider` to `flutter_gemma: ^0.16.3`.
- Rewrote `LlmService`: uses `FlutterGemma.installModel()` for download, `FlutterGemma.getActiveModel()` for model loading, `InferenceChat.generateChatResponseAsync()` for streaming generation.
- Switched from SmolLM-135M → Qwen3-0.6B (.litertlm) → **Qwen2.5-0.5B-Instruct** (`.task`, 547 MB). Qwen3 `.litertlm` tidak kompatibel dengan `getActiveModel()` di Android v0.16.3.
- KV cache, threading, GPU acceleration all handled by `flutter_gemma`/MediaPipe internally.
- Removed all manual KV cache mapping (`_kvMap`, `_inputTokenIndex`, etc.).
- Switched to `InferenceChat` (`model.createChat(modelType: ModelType.general)`) with **break-on-EOS** + **close-and-recreate** pattern: after each generation, the old chat (stuck busy) is closed (error caught) and a fresh `InferenceChat` is created for the next turn. This gives clean UX (break on EOS = fast response) while avoiding `IllegalStateException` on next `addQueryChunk` (fresh session = not busy).
- `_isGenerating` guard prevents concurrent inference.
- Only the **last** message passed to `addQueryChunk()` each turn.
- `maxTokens: 2048` restored (no endless loop since we break on EOS; the abandoned session finishes in background).
- Chat closed only once during `LlmService.dispose()`, never between turns.
- Removed all string-building helpers from `AiModelService` — passes raw `List<ChatMessage>` directly.
- Removed mock data from `ChatProvider` initial state (empty `[]`).
- Added EOS stopping in `LlmService.generateText()` — breaks stream on `<|im_end|>` or `<|im_start|>` to prevent hallucinated multi-turn output.
- Added special token filtering — strips `<|im_start|>`/`<|im_end|>` from all output chunks via regex before yielding to UI.
- Removed OpenCL `<uses-native-library>` entries from `AndroidManifest.xml` (AAPT on current AGP doesn't recognize the element; GPU handled by flutter_gemma at runtime).
- App builds and runs on device (V2434), model downloads and starts streaming inference.
- Updated all three specs for per-message `addQueryChunk` + EOS filtering.
- Fixed `test/pubspec_test.dart` — replaced `tflite_flutter`/`llm_toolkit` tests with `flutter_gemma` test.

### In Progress
- Rebuild & test Qwen2.5-0.5B-Instruct on device (clear app cache first — old models from SmolLM/Qwen3 may conflict).
- Verify EOS filtering works, response is clean, multi-turn doesn't crash.

### Blocked
- (none)

## Key Decisions
- Migrate from raw `tflite_flutter` to `flutter_gemma` because v0.16.3 supports SmolLM 135M natively (`ModelType.general`), eliminating all manual KV cache management.
- Keep `ai_model_provider.dart` → `AiModelService` → `LlmService` abstraction layer intact; only the inner `LlmService` implementation changed.
- Model URL uses `.task` file (`multi-prefill-seq_q8_ekv1280.task`) for MediaPipe-managed templates and automatic KV cache.
- `LlmService.generateText()` accepts `List<ChatMessage>` and calls `session.addQueryChunk()` per message with correct `isUser` flag. This lets `transformToChatPrompt` build `<|im_start|>role\ncontent<|im_end|>` per turn — eliminating both flat-format (special token leakage) and double-ChatML (template echoing) issues.
- `InferenceModel.createSession()` used with `temperature: 0.8, topK: 1`.
- EOS stopping + special token filtering in `LlmService` because `.task` bundle's built-in stop tokens may not include `<|im_end|>` — safe guard to prevent hallucinated output.
- Removed OpenCL `<uses-native-library>` — unnecessary on current AGP, GPU acceleration still handled by flutter_gemma at runtime.

## Next Steps
1. Rebuild and hot restart on device to verify:
   - Break-on-EOS shows response immediately (no waiting for ghost tokens)
   - Second message works without `IllegalStateException` (fresh chat per turn)
   - System instruction ("Your name is Natsya AI") takes effect in responses

## Critical Context
- Model file: `Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task` (547 MB)
- Model URL: `https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task`
- Model type for `FlutterGemma.installModel()`: `ModelType.general`
- Preferred backend: `PreferredBackend.cpu`
- ChatML format: `<|im_start|>role\ncontent<|im_end|>\n` ending with `<|im_start|>assistant\n`
- EOS token: `<|im_end|>` — streaming stops when this is detected
- `FlutterGemma.initialize()` is idempotent (checks `ServiceRegistry._instance != null`)
- `FlutterGemma.installModel().withProgress()` reports 0–100 (mapped to 0.0–1.0 in LlmService)
- `FlutterGemma.listInstalledModels()` replaces disk-file check for `isModelDownloaded()`
- Streaming: `InferenceChat.generateChatResponseAsync()` yields `Stream<ModelResponse>` — filter for `TextResponse` to extract tokens

## Relevant Files
- `smartai_chat/lib/core/llm_service.dart`: `generateText(List<ChatMessage>)` — single `InferenceChat` reused; no break on EOS (silent skip); `maxTokens: 256`; `systemInstruction` for Natsya AI identity
- `smartai_chat/lib/services/ai_model_service.dart`: Passes raw `List<ChatMessage>` to `_llm.generateText()` directly (no string building)
- `smartai_chat/pubspec.yaml`: `flutter_gemma: ^0.16.3` replaces `tflite_flutter`, `http`, `dart_sentencepiece_tokenizer`, `path_provider`
- `smartai_chat/android/app/src/main/AndroidManifest.xml`: OpenCL entries removed (AAPT limitation)
- `smartai_chat/test/pubspec_test.dart`: Updated to test for `flutter_gemma` instead of `tflite_flutter`/`llm_toolkit`
- `specs/ai-models/llm-model-loading-screen.spec.md`, `llm-model-installation.spec.md`, `specs/ai-chat-integration/llm-chat-integration.spec.md`: Updated for per-message `addQueryChunk` + EOS filtering
