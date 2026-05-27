---
name: Sidebar Natsya
description: Sidebar with floating toggle button, brand logo, and static session list with purple glow indicator
targets:
  - ../smartai_chat/lib/widgets/sidebar.dart
  - ../smartai_chat/lib/widgets/sidebar_toggle_button.dart
  - ../smartai_chat/lib/models/session.dart
---

# Sidebar — Natsya

## Models

```dart
class ChatSession {
  final String id;
  final String title;
  final bool isActive;
}
```

- `ChatSession` holds id, title, and isActive flag
  `[@test] ../smartai_chat/test/models/session_test.dart`
- `ChatSession.id` is a unique string identifier
  `[@test] ../smartai_chat/test/models/session_test.dart`

## Mock Data

- `MockSessions` provides a pre-populated list of `ChatSession` objects
  `[@test] ../smartai_chat/test/mock/mock_sessions_test.dart`
- Returns at least 5 sessions with exactly one marked `isActive = true`
  `[@test] ../smartai_chat/test/mock/mock_sessions_test.dart`

## Sidebar Toggle Button

- A floating button positioned at the **left edge** of the screen, **vertically centered**
  `[@test] ../smartai_chat/test/widgets/sidebar_toggle_button_test.dart`
- Displays a `">"` icon (pointing right when sidebar is closed)
  `[@test] ../smartai_chat/test/widgets/sidebar_toggle_button_test.dart`
- When sidebar is open, the icon flips / changes to indicate close direction
  `[@test] ../smartai_chat/test/widgets/sidebar_toggle_button_test.dart`
- The button is always visible on screen, overlaying content
  `[@test] ../smartai_chat/test/widgets/sidebar_toggle_button_test.dart`

## Sidebar Panel Layout

- The sidebar slides in/out from the **left** edge of the screen
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`
- Sidebar has a fixed width with a distinct background color
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`

### Brand Header

- At the very top of the sidebar: brand logo + **"Natsya Ai"** text to the right of the logo
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`

### Session List

- Below the brand header, a list of `ChatSession` items rendered vertically
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`
- Each session shows its title as text
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`
- All sessions are **static** — no click/tap actions
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`

### Active Session Indicator

- The currently active session (`isActive == true`) has a **purple glow/lighting effect** (bukan garis) beneath the text
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`
- The glow is a soft purple luminance (not a hard underline) that subtly illuminates the active item
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`
- Inactive sessions have no glow effect
  `[@test] ../smartai_chat/test/widgets/sidebar_test.dart`
