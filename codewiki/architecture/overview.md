# Arsitektur

```text
# Related Code
- `lib/main.dart`
- `lib/screens/chat_screen.dart`
- `lib/providers/`
- `lib/widgets/`
- `lib/models/`
```

## Design Rationale

Arsitektur SmartAI Chat mengikuti pola **unidirectional data flow** dengan Riverpod sebagai state management. Setiap bagian state (chat messages, sidebar, theme) memiliki `Notifier` sendiri yang independen. Widget `ConsumerWidget` dan `ConsumerStatefulWidget` dari Riverpod digunakan untuk mendengarkan perubahan state secara reaktif.

Forui dipilih sebagai design system untuk menggantikan Material Design standar, memberikan tampilan yang lebih modern dengan kustomisasi tema yang mudah melalui `FTheme` dan `FColors`.

## Component Diagram

```mermaid
graph TD
    subgraph "Layers"
        UI[UI Layer - Widgets / Screens]
        State[State Layer - Providers]
        Model[Model Layer - Data Classes]
        Mock[Mock Data Layer]
    end

    subgraph "Screens"
        CS[ChatScreen]
    end

    subgraph "Widgets"
        MB[MessageBubble]
        MI[MessageInput]
        SB[Sidebar]
        STB[SidebarToggleButton]
    end

    subgraph "Providers"
        CP[ChatProvider]
        SP[SidebarProvider]
        TP[ThemeProvider]
    end

    subgraph "Models"
        M[Message]
        S[ChatSession]
    end

    CS --> CP
    CS --> SP
    CS --> TP
    CS --> MB
    CS --> MI
    CS --> SB

    MI --> CP
    SB --> M

    CP --> M
    SP --> bool
    TP --> ThemeMode

    M --> Mock
    S --> Mock
```

## Data Flow — Chat

```mermaid
sequenceDiagram
    participant User as User
    participant MI as MessageInput
    participant CP as ChatProvider
    participant CS as ChatScreen
    participant M as Message List

    User->>MI: Mengetik & tekan send
    MI->>CP: sendMessage(text)
    CP->>M: menambah Message baru
    CP-->>CS: state berubah (ref.listen)
    CS->>CS: auto-scroll ke bawah
```

## Data Flow — Sidebar

```mermaid
sequenceDiagram
    participant User as User
    participant STB as SidebarToggleButton
    participant SP as SidebarProvider
    participant CS as ChatScreen

    User->>STB: tap toggle
    STB->>SP: toggle()
    SP-->>CS: state berubah
    CS->>CS: AnimatedPositioned slide
```

## Tech Debt Notes

1. **Tidak Ada Repository Layer** — Data mock langsung di-provider. Untuk produksi, perlu abstraksi repository antara provider dan sumber data.
2. **Sidebar Mengandalkan Mock Langsung** — `Sidebar` widget mengimport `MockSessions` secara langsung, bukan melalui provider. Ini membuat testing dan penggantian data lebih sulit.
3. **Tidak Ada Error Handling** — Provider tidak memiliki mekanisme error atau loading state karena data mock selalu tersedia.
