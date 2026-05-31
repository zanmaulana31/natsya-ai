---
name: Flutter Gemma LLM Chat Integration
description: Wire the SmolLM-135M-Instruct model (via flutter_gemma MediaPipe .task format) into the chat provider so user messages trigger AI inference with streaming, typing indicator, and error retry
targets:
  - ../smartai_chat/lib/providers/chat_provider.dart
  - ../smartai_chat/lib/widgets/message_input.dart
  - ../smartai_chat/lib/widgets/message_bubble.dart
  - ../smartai_chat/lib/widgets/typing_indicator.dart
  - ../smartai_chat/lib/widgets/error_bubble.dart
  - ../smartai_chat/lib/screens/chat_screen.dart
  - ../smartai_chat/lib/screens/model_loading_screen.dart
  - ../smartai_chat/lib/screens/login_screen.dart
  - ../smartai_chat/lib/main.dart
---

# Flutter Gemma LLM Chat Integration

## Overview

Bridge `AiModelService` (which wraps `LlmService` → `FlutterGemma` with SmolLM-135M-Instruct `.task` model) with the chat UI. When a user sends a message, flutter_gemma generates a response via MediaPipe runtime — either streamed token-by-token or as a full completion. A typing indicator shows during generation and failed messages offer a retry button.

Two AI paths coexist:
- **Cloud AI** (`cloudAiConfigProvider`) — uses OpenAPI-compatible HTTP API
- **Local LLM** (`aiModelProvider`) — uses on-device inference via `FlutterGemma` (MediaPipe `.task` model)

---

## Launch Flow — Auth → ModelChoice → Chat

### Navigation Decision (main.dart)
- `SmartAiApp.build()` watches `authProvider` and sets `home` widget:
  - `AsyncLoading` → spinner
  - `AsyncData(user != null)` → authenticated
  - `AsyncData(user == null)` → `LoginScreen`
  `[@test] ../smartai_chat/test/main_test.dart`

### Authenticated Routing
- Setelah auth, `home` selalu `ModelLoadingScreen` — user harus memilih setiap kali
  `[@test] ../smartai_chat/test/main_test.dart`
- `AiModelStatus.ready` hanya mempengaruhi perilaku tombol "Download Local Model" (langsung navigate jika sudah ready), bukan routing
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### LoginScreen → ModelLoadingScreen
- After successful auth, `LoginScreen` pushes `ModelLoadingScreen` (not `ChatScreen` directly)
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- `ModelLoadingScreen` then decides cloud vs local — no auto-redirect based on cloud config

### ModelLoadingScreen (lib/screens/model_loading_screen.dart)
- Shows logo (`assets/images/n_logo.png`, 120×120), title "Preparing Natsya AI"
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Two choice buttons when `notDownloaded` or `ready` (selalu ditampilkan — user harus pilih setiap kali):
  - **"Use Cloud AI"** (`Key('model_choice_cloud')`) → `Navigator.pushReplacement` to `ChatScreen`
    `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
  - **"Download Local Model"** (`Key('model_choice_local')`):
    - Jika status `ready` → langsung `Navigator.pushReplacement` ke `ChatScreen` (model sudah ada)
    - Jika status `notDownloaded` → panggil `AiModelNotifier.downloadAndInit()`
    `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Progress section during download (`Key('model_loading_progress')`):
  - Determinate bar with percentage when `AiModelStatus.downloading`
  - Indeterminate bar when `AiModelStatus.initializing` or `AiModelStatus.downloaded`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Error section on failure: error message + "Try Again" retry button
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Guards against double-navigation via `_didNavigate` flag
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## AiModelService → LlmService Bridge

### AiModelService (lib/services/ai_model_service.dart)

- Wraps `LlmService` singleton and exposes a download/init/generate lifecycle
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `downloadModel()` calls `LlmService.initialize()` which installs the model via `FlutterGemma.installModel()` and loads it via `FlutterGemma.getActiveModel()`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `generateCompletion(List<ChatMessage>)` passes raw `List<ChatMessage>` directly to `LlmService.generateText()` — no string-building needed
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `generateCompletionStream(List<ChatMessage>)` passes raw messages to `LlmService.generateText()` stream
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `isDownloaded()` delegates to `LlmService.isModelDownloaded()` → `FlutterGemma.listInstalledModels()`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `unload()` calls `LlmService.dispose()` and resets status
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### LlmService (lib/core/llm_service.dart)

- Singleton initialized via `LlmService.initialize()` which calls `FlutterGemma.initialize()` then `FlutterGemma.installModel()` then `FlutterGemma.getActiveModel()`
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- Creates a single `InferenceChat` instance during `initialize()` via `model.createChat(modelType: ModelType.general)` — reused for the entire app lifetime
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `_isGenerating` guard prevents concurrent `generateText()` calls (MediaPipe `LlmInferenceSession` is single-flight — triggers `IllegalStateException` if a second invocation starts before `done=true`)
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `generateText(List<ChatMessage> messages)`:
  - Adds only the **last** message via `_chat!.addQueryChunk()` with correct `isUser` flag — `InferenceChat` manages full conversation history internally
  - Streams via `_chat!.generateChatResponseAsync()`, filters `TextResponse` tokens
  - Does **not** break/stop the stream on EOS — continues consuming all tokens until MediaPipe's engine naturally completes (`done=true`). Breaking early causes `IllegalStateException: Previous invocation still processing` on next turn because MediaPipe `LlmInferenceSession` is single-flight and never receives the done signal.
  - Tokens containing `<|im_end|>` or `<|im_start|>` are **silently skipped** (`continue`) instead of breaking the stream. Clean text tokens are yielded to UI.
  - Does **not** close the chat after generation — the same `_chat` instance persists across all turns.
  - **Trade-off**: Model generates useless tokens after EOS (hallucinated conversations), silently filtered. `maxTokens` set to 256 (down from 2048) to limit wasted generation to ~1-2 seconds. Long-term fix: rebuild `.task` bundle with `<|im_end|>` as explicit stop token.
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- `dispose()` closes `_chat` then `_model` — called only once when the service is torn down
  `[@test] ../smartai_chat/test/core/llm_service_test.dart`
- Model cached internally by `FlutterGemma` (no custom disk management)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

### Local Models (not from cactus)

- `ChatMessage(content, role)` — `lib/models/chat_message.dart`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `CompletionResult(response)` — `lib/models/completion_result.dart`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- `StreamedCompletionResult(stream)` — `lib/models/completion_result.dart`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`

---

## Stream & Non-Stream Mode

### AiResponseMode
```dart
enum AiResponseMode { stream, complete }
```

- `AiResponseMode.stream` calls `AiModelService.generateCompletionStream()` and renders tokens as they arrive
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `AiResponseMode.complete` calls `AiModelService.generateCompletion()` and appends the full response at once
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Current default: `AiResponseMode.complete` (can be overridden per-call)
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Chat Provider — Integration Wiring

### State Changes
- `ChatNotifier` holds `List<Message> messages`, `bool isGenerating`, and `String? lastFailedMessage`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `isGenerating` is `true` from the moment AI inference starts until the response is fully received or cancelled
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### sendMessage Flow
1. Trims input, checks empty, checks `isGenerating` guard → early return
   `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
2. Appends user `Message` with `sender: MessageSender.user`
   `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
3. Reads `cloudAiConfigProvider` — if cloud AI is **enabled**, delegates to cloud path
   `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
4. If cloud disabled, checks `aiModelProvider.status == AiModelStatus.ready`
   `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
5. If model **not ready**, appends error `Message`: `"Model is not ready yet..."`
   `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
6. If model **ready**, routes to `_generateStream()` or `_generateComplete()` based on mode
   `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Stream Path (`_generateStream`)
- Calls `service.generateCompletionStream(_buildContext())`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Creates placeholder AI `Message` with `text: ""` and appends immediately
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Listens to `Stream<String>` via `_streamSubscription`, updates last message text with each token
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On stream done: removes empty placeholder if needed, sets `isGenerating = false`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On stream error: replaces placeholder with error `Message`, sets `lastFailedMessage`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Complete Path (`_generateComplete`)
- Calls `service.generateCompletion(_buildContext())`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On success: appends `Message(text: result.response)` with AI sender
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On failure: appends error `Message`, sets `lastFailedMessage`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Cloud AI Paths
- `_generateStreamCloud()` — uses `CloudAiService.generateCompletionStream()`, same streaming pattern
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `_generateCompleteCloud()` — uses `CloudAiService.generateCompletion()`, same complete pattern
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Cancel Generation
- `cancelGeneration()` cancels `_streamSubscription` and sets `isGenerating = false`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Partial AI message (if any) stays in chat history
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Retry
- `retry()` reads `lastFailedMessage`, removes the last error `Message`, and calls `sendMessage()` with the original text
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- No-op if `lastFailedMessage` is `null`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Context & History

- All messages (user, AI, error) preserved in `List<Message>` during the session
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `_buildContext()` filters out error messages, converts `Message` → `ChatMessage(role, content)`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Messages reversed to keep newest first, older messages trimmed when total chars exceed 8000
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `_buildCloudContext()` same logic but uses `CloudMessage` and 32000 char cap
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Typing Indicator

### typing_indicator.dart
- `lib/widgets/typing_indicator.dart` exports `TypingIndicator` StatefulWidget with `const` constructor
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Three animated bouncing dots using `AnimationController` + `AnimatedBuilder` + `math.sin` bounce
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Styled as AI message bubble (left-aligned, `colors.muted` background, `colors.mutedForeground` dots, `BorderRadius.circular(18)`)
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Size: 48×24 px inner, 8 px dot radius, 1200 ms animation cycle
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Uses `const Key('typing_indicator')` for testability
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`

### Chat Screen Integration
- `ChatScreen.build()` shows `TypingIndicator` when `isGenerating == true` AND (message list empty OR last message is not an AI message)
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Once streaming starts (placeholder AI message exists), the indicator is hidden — the partial message itself serves as progress feedback
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

---

## Error Bubble

### error_bubble.dart
- `lib/widgets/error_bubble.dart` exports `ErrorBubble` StatelessWidget with `const` constructor
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Left-aligned bubble with `colors.muted` background, `BorderRadius.circular(18)`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Content: `Row` with warning `Icon(Icons.warning_amber_rounded, color: colors.destructive)` + error text in `colors.mutedForeground`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Below the error text: `FButton` "Try Again" with `const Key('error_bubble_retry')`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Tapping retry calls `onRetry` callback wired to `ref.read(chatProvider.notifier).retry()`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Uses `const Key('error_bubble')` for testability
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`

### Message Bubble — Error State
- `MessageBubble` checks `message.isError` → delegates to `ErrorBubble` widget
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`

---

## Message Input — Cancel Button

### message_input.dart
- `MessageInput` receives `bool isGenerating` and `VoidCallback? onCancel`
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- When `isGenerating == true`:
  - Send button replaced by stop button (`_StopButton` with `Icons.stop_rounded`, `colors.destructive` background)
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
  - Tapping stop calls `onCancel`
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
  - Text field disabled (`FTextField.enabled = false`)
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
  - `onSubmit` callback is `null`
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- When `isGenerating == false`:
  - Normal send button (`_SendButton` with `Icons.arrow_upward`, `colors.primary` when active)
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
  - Text field enabled
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- `ChatScreen` wires `onCancel` → `ref.read(chatProvider.notifier).cancelGeneration()`
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

---

## Loading State Guard

- `MessageInput` disabled when `isGenerating == true` (text field locked, send → stop button)
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- `sendMessage()` returns early if `isGenerating` already `true` — prevents duplicate submissions
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Scroll Behavior

- `ChatScreen` uses `ScrollController` + `ListView.builder` for the message list
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Listens to `chatProvider` changes: auto-scrolls to bottom on new messages when user is near bottom (< 100 px offset)
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Does not auto-scroll if user has scrolled up to read history
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

---

## Const Optimization

- `TypingIndicator` → `const`
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- `ErrorBubble` → `const`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- `MessageBubble` → `const`
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- `_SendButton` / `_StopButton` → `const`
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- All static widgets use `const` constructors
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`

---

## Keys for Testability

| Key | Widget |
|-----|--------|
| `Key('typing_indicator')` | TypingIndicator container |
| `Key('error_bubble')` | ErrorBubble container |
| `Key('error_bubble_retry')` | ErrorBubble retry button |
| `Key('model_choice_cloud')` | ModelLoadingScreen "Use Cloud AI" button |
| `Key('model_choice_local')` | ModelLoadingScreen "Download Local Model" button |
| `Key('model_loading_progress')` | ModelLoadingScreen progress bar |
| `Key('model_loading_error')` | ModelLoadingScreen error message |
| `Key('model_loading_retry')` | ModelLoadingScreen retry button |

---

## Files Summary

| File | Action | Description |
|------|--------|-------------|
| `lib/providers/chat_provider.dart` | MODIFIED | Empty initial state (removed mock data); Cloud AI + local LLM dual path, stream/complete generation, retry, cancel, context building |
| `lib/services/ai_model_service.dart` | MODIFIED | Wraps `LlmService` → `FlutterGemma`; passes raw `List<ChatMessage>` directly |
| `lib/core/llm_service.dart` | REWRITTEN | `generateText(List<ChatMessage>)`; per-message `addQueryChunk`; EOS stop + STT filter |
| `lib/models/chat_message.dart` | UNCHANGED | Local `ChatMessage` replacement |
| `lib/models/completion_result.dart` | UNCHANGED | `CompletionResult` + `StreamedCompletionResult` |
| `lib/widgets/message_input.dart` | UNCHANGED | Cancel button + generation lock |
| `lib/widgets/message_bubble.dart` | UNCHANGED | Error state delegates to `ErrorBubble` |
| `lib/widgets/typing_indicator.dart` | UNCHANGED | Animated bouncing dots |
| `lib/widgets/error_bubble.dart` | UNCHANGED | Error bubble with retry |
| `lib/screens/chat_screen.dart` | UNCHANGED | Typing indicator + cancel wiring + auto-scroll |
| `lib/screens/model_loading_screen.dart` | UNCHANGED | Launch choice: cloud AI vs download local model |
| `lib/screens/login_screen.dart` | UNCHANGED | Post-auth navigation → `ModelLoadingScreen` |
| `lib/main.dart` | UNCHANGED | Declarative home routing after auth check |
| `pubspec.yaml` | MODIFIED | `tflite_flutter` → `flutter_gemma: ^0.16.3`, removed `http`, `dart_sentencepiece_tokenizer`, `path_provider` |
| `test/providers/chat_provider_test.dart` | UNCHANGED | Tests for generation paths |
| `test/services/ai_model_service_test.dart` | UNCHANGED | Tests with `MockLlmService` |
| `test/screens/model_loading_screen_test.dart` | UNCHANGED | Logo, choice buttons, progress, error, navigation |
| `test/widgets/message_input_test.dart` | UNCHANGED | Cancel/stop tests |

---

## Resource Notes

- Local LLM inference uses `SmolLM-135M-Instruct` via flutter_gemma (MediaPipe `.task` format, ~159 MB download, ~300–600 MB RAM at runtime)
- `flutter_gemma` handles all low-level inference (KV cache, sampling, GPU acceleration via XNNPack/NNAPI)
- Single `InferenceChat` instance created during `LlmService.initialize()` and reused for all turns — prevents MediaPipe `IllegalStateException: Previous invocation still processing` which occurs when closing or recreating sessions mid-generation
- Only the **last** message (the new user query) is passed to `addQueryChunk()` each turn — `InferenceChat` manages full conversation history internally
- `_isGenerating` state guard prevents concurrent inference invocations on the single-flight MediaPipe session
- EOS stopping implemented in `LlmService` because `.task` bundle's built-in stop tokens may not include `<|im_end|>` — safe guard to prevent hallucinated multi-turn output
- All `<|im_start|>` / `<|im_end|>` tokens stripped from output before yielding to UI
- `InferenceChat` closed only once during `LlmService.dispose()` — never between turns
- Inference runs on background threads managed by MediaPipe — no main thread blocking
- Cloud AI path is independent (only requires network + API key)
- When both cloud AI is enabled AND local model is ready, cloud path takes priority
- Context window for local LLM: ~8000 character prompt (~2000 tokens for SmolLM)
