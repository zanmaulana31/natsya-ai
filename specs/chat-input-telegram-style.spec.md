---
name: Chat Input — Telegram Style
description: Redesign message input bar to match Telegram mobile style with horizontal layout, expandable text field, and keyboard Enter-to-send
targets:
  - ../smartai_chat/lib/widgets/message_input.dart
  - ../smartai_chat/test/widgets/message_input_test.dart
---

# Chat Input — Telegram Style

## Layout

- Input bar uses a horizontal `Row`: text field fills remaining space (`Expanded`), send button anchored to the right
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Input bar has consistent vertical padding so it never feels cramped on mobile
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`

## Text Field

- Uses `FTextField` (not multiline) with `textInputAction: TextInputAction.send`
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Mobile keyboard shows **Send** action key instead of newline
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- `onSubmitted` callback triggers `sendMessage` and clears the field
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Text field has rounded pill-shaped border (`BorderRadius.circular(24)`)
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Hint text reads **"Message"**
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Field stays focused after sending a message
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`

## Send Button

- Circular icon button with a send/arrow icon (`Icons.send` or `Icons.arrow_upward`), placed to the right of the text field
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Button background uses `primary` (violet) color when active, `muted` when disabled
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Button is **disabled** when the text field is empty or whitespace-only
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- Tapping the button dispatches `sendMessage` and clears the field — same behavior as keyboard Send
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`

## Send Behavior

- Sending an empty or whitespace-only message is a no-op (no dispatch, no clear)
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
- After a successful send, text field is cleared and focus is retained on the field
  `[@test] ../smartai_chat/test/widgets/message_input_test.dart`
