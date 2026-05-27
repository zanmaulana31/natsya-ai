# Komponen Inti

```text
# Related Code
- `lib/models/message.dart`
- `lib/models/session.dart`
- `lib/providers/chat_provider.dart`
- `lib/providers/sidebar_provider.dart`
- `lib/providers/theme_provider.dart`
- `lib/screens/chat_screen.dart`
- `lib/widgets/message_bubble.dart`
- `lib/widgets/message_input.dart`
- `lib/widgets/sidebar.dart`
- `lib/widgets/sidebar_toggle_button.dart`
- `lib/mock/mock_data.dart`
- `lib/mock/mock_sessions.dart`
```

## Component Dictionary

| Komponen | Tanggung Jawab | File |
|----------|---------------|------|
| `SmartAiApp` | Root widget, konfigurasi tema Forui & MaterialApp | `lib/main.dart` |
| `ChatScreen` | Halaman utama: header, message list, input, sidebar overlay | `lib/screens/chat_screen.dart` |
| `ChatNotifier` | State daftar pesan, logic sendMessage | `lib/providers/chat_provider.dart` |
| `SidebarNotifier` | State boolean toggle sidebar | `lib/providers/sidebar_provider.dart` |
| `ThemeNotifier` | State ThemeMode (light/dark) | `lib/providers/theme_provider.dart` |
| `MessageBubble` | Render satu pesan dengan bubble styling | `lib/widgets/message_bubble.dart` |
| `MessageInput` | Input field + send button dengan state lokal | `lib/widgets/message_input.dart` |
| `Sidebar` | Panel navigasi dengan brand header & daftar sesi | `lib/widgets/sidebar.dart` |
| `SidebarToggleButton` | Tombol untuk membuka/menutup sidebar | `lib/widgets/sidebar_toggle_button.dart` |
| `Message` | Model data pesan (id, text, timestamp, sender) | `lib/models/message.dart` |
| `ChatSession` | Model data sesi chat (id, title, isActive) | `lib/models/session.dart` |
| `MockData` | Data pesan dummy untuk development | `lib/mock/mock_data.dart` |
| `MockSessions` | Data sesi dummy untuk development | `lib/mock/mock_sessions.dart` |

## Relationship Graph

```mermaid
graph TD
    SA[SmartAiApp] -->|home| CS[ChatScreen]
    SA -->|theme| FTheme[FTheme Forui]
    SA -->|MaterialApp| MA[MaterialApp]

    CS -->|watch| CP[ChatProvider]
    CS -->|watch| SP[SidebarProvider]
    CS -->|watch| TP[ThemeProvider]
    CS --> MB[MessageBubble]
    CS --> MI[MessageInput]
    CS --> SB[Sidebar]
    CS --> STB[SidebarToggleButton]

    CP -->|List<Message>| M[Message model]
    CP --> MD[MockData]

    SB -->|List<ChatSession>| MS[MockSessions]
    SB --> SS[SessionItem]

    MI -->|sendMessage| CP
    STB -->|toggle| SP

    MB --> M

    subgraph "Data Models"
        M
        S[ChatSession]
    end

    subgraph "Mock Data"
        MD
        MS
    end
```

## Critical Path — Render Pesan

```mermaid
sequenceDiagram
    participant App as SmartAiApp
    participant CS as ChatScreen
    participant CP as ChatProvider
    participant LB as ListView.builder
    participant MB as MessageBubble

    App->>CS: build()
    CS->>CP: ref.watch(chatProvider)
    CP-->>CS: List<Message>
    CS->>LB: itemCount = messages.length
    loop setiap index
        LB->>MB: MessageBubble(message, isConsecutive)
        MB->>MB: styling bubble (user vs AI)
    end
```

## Critical Path — Kirim Pesan

```mermaid
sequenceDiagram
    participant User as User
    participant MI as MessageInput
    participant CP as ChatProvider
    participant CS as ChatScreen
    participant LB as ListView

    User->>MI: tap send / Enter
    MI->>MI: validasi text.trim()
    MI->>CP: sendMessage(text)
    CP->>CP: buat Message baru
    CP-->>CS: state berubah
    CS->>LB: scrollToBottom()
    MI->>MI: clear controller
```
