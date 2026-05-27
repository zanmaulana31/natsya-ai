# Model Data

```text
# Related Code
- `lib/models/message.dart`
- `lib/models/session.dart`
- `lib/mock/mock_data.dart`
- `lib/mock/mock_sessions.dart`
```

## Entities

### Message (`lib/models/message.dart:10277`)

```dart
enum MessageSender { user, ai }

class Message {
  final String id;
  final String text;
  final DateTime timestamp;
  final MessageSender sender;
}
```

Model utama untuk pesan chat. `MessageSender` enum membedakan pesan dari user vs AI. `id` menggunakan `DateTime.now().millisecondsSinceEpoch.toString()` saat pembuatan — ini rentan collision jika ada operasi async.

### ChatSession (`lib/models/session.dart:10294`)

```dart
class ChatSession {
  final String id;
  final String title;
  final bool isActive;
}
```

Model untuk sesi percakapan. `isActive` default `false`. Tidak ada relasi langsung antara `ChatSession` dan `Message` — saat ini kedua model berdiri sendiri.

## Entity Relationship

```mermaid
classDiagram
    class Message {
        +String id
        +String text
        +DateTime timestamp
        +MessageSender sender
        +Message({id, text, timestamp, sender})
    }

    class ChatSession {
        +String id
        +String title
        +bool isActive
        +ChatSession({id, title, isActive})
    }

    class MessageSender {
        <<enumeration>>
        user
        ai
    }

    Message --> MessageSender
```

## Mock Data

**`MockData.messages`** — 7 pesan percakapan dummy antara user dan AI tentang Flutter development. Timestamp tersebar dari jam 9:00 hingga 14:00 pada 23 Mei 2026.

**`MockSessions.sessions`** — 5 sesi dummy: "Flutter Development Help" (aktif), "Project Planning Discussion", "Bug Fixing Session", "Code Review", "UI Design Ideas".

## Catatan Arsitektur Data

- **Tidak ada koneksi session-message** — ChatSession dan Message tidak terhubung. Semua pesan milik satu sesi global.
- **Tidak ada persistence** — Data hilang saat app di-restart. Perlu database lokal (SQLite/Hive) untuk produksi.
- **Mock langsung di-widget** — Sidebar membaca `MockSessions.sessions` langsung, bukan melalui provider. Ini melanggar pola separation of concern.
