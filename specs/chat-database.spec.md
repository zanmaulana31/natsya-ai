---
name: Chat Database — Drift SQLite
description: Local chat history persistence using Drift ORM with SQLite, supporting multi-session chat storage and retrieval
targets:
  - ../smartai_chat/lib/database/app_database.dart
  - ../smartai_chat/lib/database/chat_repository.dart
  - ../smartai_chat/lib/providers/chat_provider.dart
---

# Chat Database — Drift SQLite

## Dependencies

```yaml
dependencies:
  drift: ^2.23.0
  sqlite3: ^2.4.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.0
  path: ^1.9.0

dev_dependencies:
  drift_dev: ^2.23.0
  build_runner: ^2.4.10
```

- `drift` provides the ORM with code generation
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- `sqlite3_flutter_libs` bundles native SQLite for all platforms
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- `path_provider` provides the app documents directory for the database file
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- Database file is stored at `getApplicationDocumentsDirectory() / 'smartai.db'`
  `[@test] ../smartai_chat/test/database/app_database_test.dart`

## Database Tables

### chat_sessions

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` |
| `title` | `TEXT` | nullable |
| `created_at` | `DATETIME` | `NOT NULL` |
| `updated_at` | `DATETIME` | `NOT NULL` |

```dart
class ChatSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get createdAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
}
```

`[@test] ../smartai_chat/test/database/app_database_test.dart`

### chat_messages

| Column | Type | Constraints |
|--------|------|-------------|
| `id` | `INTEGER` | `PRIMARY KEY AUTOINCREMENT` |
| `session_id` | `INTEGER` | `NOT NULL, REFERENCES chat_sessions(id)` |
| `message_id` | `TEXT` | `NOT NULL` |
| `text` | `TEXT` | `NOT NULL` |
| `sender` | `TEXT` | `NOT NULL` ('user' or 'ai') |
| `timestamp` | `DATETIME` | `NOT NULL` |

```dart
class ChatMessages extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get sessionId => integer().map(const ...()).nullable()();
  TextColumn get messageId => text().nullable()();
  TextColumn get text => text().nullable()();
  TextColumn get sender => text().nullable()();
  DateTimeColumn get timestamp => dateTime().nullable()();
}
```

- `chat_messages.session_id` is a foreign key referencing `chat_sessions.id` with cascade delete
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- `chat_messages.sender` stores `MessageSender` as string ('user' or 'ai')
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- Messages are identified by string `message_id` (the existing `Message.id` field)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`

## AppDatabase

- `AppDatabase` extends `_$AppDatabase` with `@DriftDatabase` annotation
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- Tables are registered via `@DriftDatabase(tables: [ChatSessions, ChatMessages])`
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- Constructor accepts a `QueryExecutor` for testability (in-memory vs file-based)
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- `AppDatabase.connect()` factory returns a file-based database using `LazyDatabase` + `path_provider`
  `[@test] ../smartai_chat/test/database/app_database_test.dart`

## ChatRepository

```dart
class ChatRepository {
  ChatRepository(this.db);  // db: AppDatabase

  Future<int> createSession({String? title});
  Future<void> saveMessage(int sessionId, Message message);
  Future<List<Message>> getSessionMessages(int sessionId);
  Future<List<ChatSession>> getAllSessions();
  Future<void> deleteSession(int sessionId);
}
```

### createSession

- `createSession()` creates a new row in `chat_sessions` and returns the generated session ID
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Both `created_at` and `updated_at` are set to the current timestamp
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Optional `title` parameter is stored if provided
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`

### saveMessage

- `saveMessage()` inserts a `Message` into `chat_messages` for the given `sessionId`
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- `message_id` maps to `Message.id` (the existing string identifier)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- `sender` maps to `MessageSender` enum stored as string ('user' / 'ai')
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Duplicate `message_id` within the same session is handled gracefully (no crash)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`

### getSessionMessages

- Returns all messages for a session, ordered by `timestamp` ascending
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Returns an empty list if session has no messages
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Maps `ChatMessages` rows back to `Message` model objects
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Only returns messages for the specified session (isolated per session)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`

### getAllSessions

- Returns all sessions ordered by `updated_at` descending (most recent first)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Returns an empty list when no sessions exist
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`

## ChatNotifier Integration

- `ChatNotifier` receives `ChatRepository` as a dependency via Riverpod
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On `build()`:
  - If a current session exists in DB, load it
  - Otherwise, create a new session via `createSession()`
  - Load mock data as initial static messages (not from DB)
  - Load DB messages via `getSessionMessages()` and merge with mock data by timestamp
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`
- On `sendMessage()`:
  - Message is persisted to DB via `chatRepository.saveMessage()`
  - State is updated in-memory as before
  `[@test] ../smartai_chat/test/providers/chat_provider_test.dart`

## Test Requirements

### app_database_test.dart

- Database creates all tables without error
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- Database can be opened in-memory for testing
  `[@test] ../smartai_chat/test/database/app_database_test.dart`
- Foreign key constraint is enforced (inserting message with invalid sessionId fails)
  `[@test] ../smartai_chat/test/database/app_database_test.dart`

### chat_repository_test.dart

- Full CRUD lifecycle: createSession → saveMessage → getSessionMessages → messages match input
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Messages are ordered by timestamp ascending
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- Multiple sessions are isolated (messages from session A don't appear in session B)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- getAllSessions respects ordering (most recently updated first)
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
- deleteSession removes session and cascade-deletes its messages
  `[@test] ../smartai_chat/test/database/chat_repository_test.dart`
