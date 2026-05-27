---
name: AI Chat UI
description: Single chat view with AI assistant Natsya, text message bubbles, rounded design, dark/light mode toggle, using Forui widgets and Riverpod
targets:
  - ../smartai_chat/lib/screens/chat_screen.dart
  - ../smartai_chat/lib/widgets/message_bubble.dart
  - ../smartai_chat/lib/widgets/message_input.dart
  - ../smartai_chat/lib/models/message.dart
  - ../smartai_chat/lib/providers/chat_provider.dart
  - ../smartai_chat/lib/providers/theme_provider.dart
  - ../smartai_chat/lib/mock/mock_data.dart
  - ../smartai_chat/lib/main.dart
---

# AI Chat UI — Natsya

## Models

```dart
enum MessageSender { user, ai }

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final MessageSender sender;
}
```

- `Message` holds id, text, timestamp, and sender enum (user/ai)
  `[@test] ../smartai_chat/test/models/message_test.dart`
- `Message.id` is a unique string identifier
  `[@test] ../smartai_chat/test/models/message_test.dart`

## Mock Data

- `MockData` provides a pre-populated list of `Message` objects simulating an AI conversation
  `[@test] ../smartai_chat/test/mock/mock_data_test.dart`
- Returns at least 10 messages with alternating `MessageSender.user` and `MessageSender.ai`
  `[@test] ../smartai_chat/test/mock/mock_data_test.dart`
- Messages have realistic timestamps spanning multiple hours
  `[@test] ../smartai_chat/test/mock/mock_data_test.dart`
- AI messages feel natural (greeting, answers, follow-ups)
  `[@test] ../smartai_chat/test/mock/mock_data_test.dart`

## State Management (Riverpod)

```dart
class ChatNotifier extends StateNotifier<List<Message>> { ... }
final chatProvider = StateNotifierProvider<ChatNotifier, List<Message>>(...);
```

- `ChatNotifier` initializes state from `MockData.messages`
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- `sendMessage(String text)` adds a new `Message` with sender=user and current timestamp
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Empty or whitespace-only text is ignored (message not added)
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- Messages are ordered by timestamp ascending (newest appended to end)
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

```dart
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>(...);
```

- `ThemeNotifier` initializes with `ThemeMode.light`
  `[@test] ../smartai_chat/test/providers/theme_provider_test.dart`
- `toggle()` switches between light and dark
  `[@test] ../smartai_chat/test/providers/theme_provider_test.dart`

## Chat Screen Layout

- The screen uses `FScaffold` as the root layout widget
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Top bar: `FHeader` displays "Chat with Natsya" with a theme toggle icon button
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Body: A scrollable `ListView` of message bubbles
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Bottom: A `MessageInput` bar anchored to the bottom of the screen
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

## Message Bubbles

- Each `Message` renders as a styled bubble with rounded corners
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- User messages align to the **right** with `primary` (violet) background, white text
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- AI messages align to the **left** with `muted` background, foreground text
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- Each bubble shows message text and timestamp (HH:mm)
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- Bubbles have asymmetrical `BorderRadius.circular()` — sharper corner on sender side, rounder on opposite side
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`
- Consecutive same-sender messages compress spacing (no avatar gap)
  `[@test] ../smartai_chat/test/widgets/message_bubble_test.dart`

## Message Input Bar

- Contains an `FTextField.multiline` for typing
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Contains a send `FButton` with rounded style — disabled when text field is empty
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Pressing send or keyboard submit dispatches `sendMessage` and clears the field
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- The input bar stays at bottom, above keyboard when focused
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`

## Auto-scroll

- `ListView` auto-scrolls to latest message when new message is sent
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`
- Auto-scroll only triggers when user is near the bottom (not when scrolled up reading history)
  `[@test] ../smartai_chat/test/screens/chat_screen_test.dart`

## Theming (Forui)

- App wraps with `FTheme` using `FThemes.violet.light.touch` by default
  `[@test] ../smartai_chat/test/main_test.dart`
- Dark mode uses `FThemes.violet.dark.touch`
  `[@test] ../smartai_chat/test/main_test.dart`
- Violet = primary accent (buttons, user bubbles, active elements). White/dark = base background
  `[@test] ../smartai_chat/test/main_test.dart`
- Wraps with `FToaster` and `FTooltipGroup`
  `[@test] ../smartai_chat/test/main_test.dart`
- Theme toggle animation transitions between themes
  `[@test] ../smartai_chat/test/main_test.dart`
