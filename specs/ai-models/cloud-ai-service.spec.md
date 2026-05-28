---
name: Cloud AI Service
description: OpenAI-compatible cloud inference service as fallback when on-device model is unavailable or crashes, using PublicAI free API
targets:
  - ../smartai_chat/lib/services/cloud_ai_service.dart
  - ../smartai_chat/lib/providers/cloud_ai_provider.dart
  - ../smartai_chat/lib/models/cloud_ai_config.dart
  - ../smartai_chat/lib/providers/chat_provider.dart
  - ../smartai_chat/lib/screens/chat_screen.dart
---

# Cloud AI Service

## Overview

Cloud-based AI inference using OpenAI-compatible API (PublicAI, Groq, OpenRouter, etc.) as a fallback when the on-device Cactus model fails or is unavailable. Uses standard HTTP requests — no native dependencies, no SIGILL crashes.

---

## Provider Support

- **Default provider:** PublicAI (`https://api.publicai.co/v1`)
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- **Default model:** `swiss-ai/apertus-8b-instruct`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Provider-agnostic design — any OpenAI-compatible API works (Groq, OpenRouter, DeepSeek, HuggingFace, etc.)
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- OpenAI API format: endpoint `POST /v1/chat/completions`, auth via `Authorization: Bearer <key>`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

---

## CloudAiConfig

### cloud_ai_config.dart (NEW)

- `lib/models/cloud_ai_config.dart` exports a `CloudAiConfig` class
  `[@test] ../smartai_chat/test/models/cloud_ai_config_test.dart`
- Fields:
  - `String baseUrl` — API endpoint (default: `https://api.publicai.co/v1`)
  - `String apiKey` — Bearer token (default: empty, must be set before use)
  - `String model` — Model name (default: `swiss-ai/apertus-8b-instruct`)
  - `double temperature` — Generation temperature (default: `0.7`)
  - `int maxTokens` — Max output tokens (default: `2048`)
  - `bool enabled` — Whether cloud is active (default: `false`)
  `[@test] ../smartai_chat/test/models/cloud_ai_config_test.dart`
- `CloudAiConfig` has `copyWith` for immutable updates
  `[@test] ../smartai_chat/test/models/cloud_ai_config_test.dart`

---

## CloudAiService

### cloud_ai_service.dart (NEW)

- `lib/services/cloud_ai_service.dart` exports a `CloudAiService` class
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Constructor takes `CloudAiConfig` (default config if omitted)
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Uses `dart:io` `HttpClient` — no external HTTP package needed
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

### generateCompletion

- `Future<String> generateCompletion(List<CloudMessage> messages, {CloudAiConfig? config})`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Sends `POST` request to `$baseUrl/chat/completions`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Request body JSON structure:
  ```json
  {
    "model": "swiss-ai/apertus-8b-instruct",
    "messages": [
      {"role": "system", "content": "You are Natsya AI, a helpful assistant."},
      {"role": "user", "content": "..."},
      {"role": "assistant", "content": "..."}
    ],
    "temperature": 0.7,
    "max_tokens": 2048
  }
  ```
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Response parsing: extracts `choices[0].message.content`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- On HTTP error or API error, throws `CloudAiException` with human-readable message
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

### generateCompletionStream

- `Stream<String> generateCompletionStream(List<CloudMessage> messages, {CloudAiConfig? config})`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Uses SSE (Server-Sent Events) streaming via `HttpClient` with `stream: true`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Request body includes `"stream": true` parameter
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Parses `data: {"choices":[{"delta":{"content":"token"}}]}` SSE events
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Stops on `data: [DONE]` signal
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Each event yields the content delta as a String
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Stream closes on completion or error
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

### Configuration Update

- `updateConfig(CloudAiConfig config)` replaces the current config
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- `resetConfig()` restores defaults
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

---

## CloudMessage Model

### cloud_message.dart (optional, in models/)

- Simple model for API messages:
  ```dart
  class CloudMessage {
    final String role;   // 'system' | 'user' | 'assistant'
    final String content;

    const CloudMessage({required this.role, required this.content});
  }
  ```
  `[@test] ../smartai_chat/test/models/cloud_message_test.dart`

---

## CloudAiProvider

### cloud_ai_provider.dart (NEW)

- `lib/providers/cloud_ai_provider.dart` exports:
  - `cloudAiConfigProvider` — `StateNotifierProvider<CloudAiConfigNotifier, CloudAiConfig>`
  - `cloudAiServiceProvider` — `Provider<CloudAiService>`
  `[@test] ../smartai_chat/test/providers/cloud_ai_provider_test.dart`
- `cloudAiConfigProvider` initializes with `CloudAiConfig()` (disabled by default)
  `[@test] ../smartai_chat/test/providers/cloud_ai_provider_test.dart`
- `CloudAiConfigNotifier.setApiKey(String key)` enables cloud mode
  `[@test] ../smartai_chat/test/providers/cloud_ai_provider_test.dart`
- `CloudAiConfigNotifier.setProvider(url, model, key)` configures all at once
  `[@test] ../smartai_chat/test/providers/cloud_ai_provider_test.dart`
- `CloudAiConfigNotifier.disable()` sets `enabled = false`
  `[@test] ../smartai_chat/test/providers/cloud_ai_provider_test.dart`

---

## Chat Provider Integration

### chat_provider.dart — AI Source Selection

- `ChatNotifier.sendMessage()` checks `cloudAiConfigProvider.enabled` first
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- If cloud is **enabled**: uses `CloudAiService.generateCompletion()` / `generateCompletionStream()`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- If cloud is **disabled**: falls back to existing on-device `AiModelService` (unchanged behavior)
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- If both are unavailable (cloud disabled AND model not ready): shows "No AI service available" error
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Message Conversion

- `ChatMessage` (Cactus) → `CloudMessage` (cloud) conversion:
  - Role: `user` → `'user'`, `assistant` → `'assistant'`
  - System prompt prepended: `"You are Natsya AI, a helpful assistant."`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Error messages are excluded from context (same as current behavior)
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

### Streaming

- When cloud streaming is active:
  - SSE events feed token-by-token into the last AI message (same UX as on-device streaming)
  - Cancel button works the same (closes HTTP connection)
  - Error handling: non-200 responses, network errors → error bubble + retry
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

---

## UI — Settings Integration

### Cloud API Key Input (optional, for future)

- A settings screen or dialog to input API key and select provider
- Not required for MVP — key can be hardcoded for now in `main.dart` or env config
- Future: settings page with provider dropdown (PublicAI / Groq / OpenRouter / Custom)

---

## No Additional Dependencies

- Uses `dart:io` `HttpClient` — no `http` or `dio` package needed
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

---

## Error Handling

- `CloudAiException` with fields: `message`, `statusCode`, `body`
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Network errors (timeout, DNS failure) caught and wrapped
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- API errors (4xx, 5xx) parsed and surfaced
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`
- Rate limit exceeded (429) detected and reported as "Rate limit reached. Please wait."
  `[@test] ../smartai_chat/test/services/cloud_ai_service_test.dart`

---

## Files Summary

| File | Action |
|------|--------|
| `lib/models/cloud_ai_config.dart` | **NEW** — config class |
| `lib/services/cloud_ai_service.dart` | **NEW** — HTTP API client |
| `lib/providers/cloud_ai_provider.dart` | **NEW** — Riverpod providers |
| `lib/providers/chat_provider.dart` | **MODIFY** — add cloud fallback path |
| `test/models/cloud_ai_config_test.dart` | **NEW** |
| `test/services/cloud_ai_service_test.dart` | **NEW** |
| `test/providers/cloud_ai_provider_test.dart` | **NEW** |
| `test/providers/chat_provider_test.dart` | **MODIFY** — cloud path tests |
