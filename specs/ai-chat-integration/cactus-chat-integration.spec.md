---
name: Cactus AI Chat Integration
description: Wire the Cactus LFM 2 350M model into the chat provider so user messages trigger AI inference with streaming, typing indicator, and error retry
targets:
  - ../smartai_chat/lib/providers/chat_provider.dart
  - ../smartai_chat/lib/widgets/message_input.dart
  - ../smartai_chat/lib/widgets/message_bubble.dart
  - ../smartai_chat/lib/widgets/typing_indicator.dart
  - ../smartai_chat/lib/widgets/error_bubble.dart
  - ../smartai_chat/lib/screens/chat_screen.dart
---

# Cactus AI Chat Integration

## Overview

Bridge the existing `AiModelService` (Cactus on-device LLM) with the chat UI so that when a user sends a message, the AI generates a response — either streamed token-by-token or as a full completion. A typing indicator shows during generation and failed messages offer a retry button.

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
- Default mode is `stream`; falls back to `complete` if the model does not support streaming
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Chat Provider — Integration Wiring

### State Changes
- `ChatNotifier` gains a `bool isGenerating` field and a `String? lastFailedMessage` field
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `isGenerating` is `true` from the moment AI inference starts until the response is fully received or cancelled
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### sendMessage
- `sendMessage(String text, {AiResponseMode mode = AiResponseMode.stream})` is now `async`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Still appends the user `Message` first and trims whitespace
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- After appending the user message, checks `AiModelService.status == AiModelStatus.ready`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- If model is **not ready**, appends an error `Message` saying "Model is not ready yet. Please wait for initialization to complete."
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- If model **is ready**, delegates to `_generateStream()` or `_generateComplete()` based on mode
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Stream Path (`_generateStream`)
- Calls `_serviceInstance.generateCompletionStream()`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Creates a placeholder AI `Message` with `text: ""` and appends it to state immediately (so the typing indicator hides)
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Listens to the `Stream<String>`, updating `state.last.text` with accumulated tokens on each emission
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On stream done, sets `isGenerating = false` and clears `lastFailedMessage`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On stream error, replaces the placeholder with an error `Message` and sets `lastFailedMessage` to the original user text
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Complete Path (`_generateComplete`)
- Calls `_serviceInstance.generateCompletion()`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On success, appends the full response as a new AI `Message`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On failure, appends an error `Message` and sets `lastFailedMessage`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Sets `isGenerating = false` at the end of either path
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Cancel Generation
- `cancelGeneration()` closes the stream subscription and sets `isGenerating = false`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- The partial AI message (if any) remains in the chat history
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Retry
- `retry()` reads `lastFailedMessage`, removes the last error `Message`, and calls `sendMessage(lastFailedMessage)` again
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `retry()` is a no-op if `lastFailedMessage` is `null`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Typing Indicator

### typing_indicator.dart (NEW)
- `lib/widgets/typing_indicator.dart` exports a `TypingIndicator` widget
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Shows three animated bouncing dots (using `AnimatedOpacity` or `AnimationController`)
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Styled to match an AI message bubble (left-aligned, `muted` background, `foreground` text color)
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Size: 48 × 24 px, dot radius 4 px, with staggered animation
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- Uses `const Key('typing_indicator')` for testability
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`

### Chat Screen Integration
- `ChatScreen.build()` conditionally renders `TypingIndicator` at the bottom of the message list when `chatProvider.isGenerating == true` AND the last message is not already a streaming AI message
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- When streaming has started (placeholder AI message exists), the indicator is hidden — the partial message itself serves as the progress indicator
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

---

## Error Bubble

### error_bubble.dart (NEW)
- `lib/widgets/error_bubble.dart` exports an `ErrorBubble` widget
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Rendered as a left-aligned bubble with `muted` background tinted red (`Colors.red.shade50` for light, `Colors.red.shade900` for dark)
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Content: a `Row` with a warning `Icon` (`Icons.warning_amber_rounded`) and the error text
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Below the error text: a **"Try Again"** `FButton` with `tiny` size
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Tapping "Try Again" calls `ref.read(chatProvider.notifier).retry()`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- Uses `const Key('error_bubble')` and `const Key('error_bubble_retry')` for testability
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`

### Message Bubble — Error State
- `MessageBubble` gains an optional `isError` parameter
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- When `isError == true`, the bubble renders with the error styling (red tint, warning icon)
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`

---

## Message Input — Cancel Button

### message_input.dart changes
- Input bar receives an optional `onCancel` callback and `bool isGenerating`
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- When `isGenerating == true`:
  - The send button changes to a stop/cancel button (icon: `Icons.stop_rounded`, color: `destructive` red)
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
  - Tapping stop calls `onCancel`
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
  - The text field is disabled (`FTextField.enabled = false`)
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- When `isGenerating == false`:
  - Normal send button behavior (unchanged from existing spec)
    `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- `ChatScreen` wires `onCancel` → `ref.read(chatProvider.notifier).cancelGeneration()`
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

---

## Context & History

- All messages (user, AI, error) are preserved in the `List<Message>` state during the session
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- The full message list (excluding error messages) is sent as context to `AiModelService.generateCompletion()` / `generateCompletionStream()` for conversational continuity
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Messages are converted to `ChatMessage` list: `user` → `ChatMessage(role: 'user')`, AI → `ChatMessage(role: 'assistant')`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Context window is capped at `2048` tokens (Cactus default context size); older messages are trimmed from the front if needed
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## Loading State Guard

- `MessageInput` is disabled when `chatProvider.isGenerating == true` (text field locked, send button replaced with stop)
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- `sendMessage()` returns early (no-op) if `isGenerating` is already `true`, preventing duplicate submissions
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## const Optimization (Flutter Expert)

- `TypingIndicator` constructor is `const`
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`
- `ErrorBubble` constructor is `const`
  `[@test] ../smartai_chat/test/widgets/error_bubble_test.dart`
- All static widgets inside these components use `const` constructors
  `[@test] ../smartai_chat/test/widgets/typing_indicator_test.dart`

---

## Files Summary

| File | Action |
|------|--------|
| `lib/providers/chat_provider.dart` | **MODIFY** — add AiModelService dependency, stream/complete generation, isGenerating, retry, cancel, context building |
| `lib/widgets/message_input.dart` | **MODIFY** — add isGenerating/cancel support, disable during generation |
| `lib/widgets/message_bubble.dart` | **MODIFY** — add isError state styling |
| `lib/widgets/typing_indicator.dart` | **NEW** — animated bouncing dots |
| `lib/widgets/error_bubble.dart` | **NEW** — error message with retry button |
| `lib/screens/chat_screen.dart` | **MODIFY** — wire typing indicator, cancel callback, error bubble rendering |
| `test/providers/chat_provider_test.dart` | **MODIFY** — new tests for generation, streaming, retry, cancel, guards |
| `test/widgets/typing_indicator_test.dart` | **NEW** |
| `test/widgets/error_bubble_test.dart` | **NEW** |
| `test/widgets/message_bubble_test.dart` | **MODIFY** — error state tests |
| `test/widgets/message_input_test.dart` | **MODIFY** — cancel/stop tests |
| `test/screens/chat_screen_test.dart` | **MODIFY** — typing indicator + cancel tests |
