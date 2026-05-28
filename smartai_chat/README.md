# SmartAI Chat — Natsya

AI Chat UI built with **Flutter**, **Forui** UI library, and **Riverpod** state management.

## Features

- Chat with AI assistant **Natsya** (mock conversation data)
- Rounded message bubbles with chat tail effect
- Light / Dark mode toggle (violet accent theme via `FThemes.violet`)
- Auto-scroll to latest message
- Riverpod 3 `Notifier`-based state management

## Prerequisites

- Flutter 3.41.0+ (required by Forui 0.18.0+)
- Dart 3.11+

## Getting Started

```bash
cd smartai_chat
flutter pub get
```

## Run Application

```bash
flutter run
```

Atau spesifik ke emulator jika ada beberapa device:

Pastikan emulator sudah berjalan

```bash
flutter emulators --launch Pixel_6
```

```bash
flutter run -d emulator-5554
```

For a specific platform:

```bash
flutter run -d chrome       # Web
flutter run -d windows      # Windows desktop
flutter run -d android      # Android (emulator/device)
flutter run -d ios          # iOS (simulator/device)
```

### Supabase Anon Key (wajib untuk autentikasi)

Untuk menggunakan fitur login Google OAuth, set **Supabase anon key** saat run:

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

Anon key didapatkan dari Supabase Dashboard → Project Settings → API → `anon public` key. **Jangan** gunakan Service Role Key di client-side.

### Cloud API Key (optional)

Untuk menggunakan cloud AI sebagai fallback (saat on-device model bermasalah), set API key saat run:

```bash
flutter run --dart-define=CLOUD_API_KEY=your_api_key_here
```

Dapatkan API key gratis di [platform.publicai.co](https://platform.publicai.co) (PublicAI — nonprofit, open-source, tidak perlu kartu kredit).

Providers yang didukung: **PublicAI** (default), **Groq**, **OpenRouter**, **DeepSeek** — atau API OpenAI-compatible lainnya. Konfigurasi via `CloudAiConfig`.

### Multiple Dart Define

Anda bisa menambahkan `--dart-define` berkali-kali dalam satu command:

```bash
flutter run \
  --dart-define=SUPABASE_ANON_KEY=eyJhbG... \
  --dart-define=CLOUD_API_KEY=your_api_key_here
```

Satu baris:
```bash
flutter run --dart-define=SUPABASE_ANON_KEY=eyJhbG... --dart-define=CLOUD_API_KEY=your_api_key_here
```

Untuk build release:
```bash
flutter build apk --release \
  --dart-define=SUPABASE_ANON_KEY=eyJhbG... \
  --dart-define=CLOUD_API_KEY=your_api_key_here
```

## Run Unit Tests

```bash
flutter test
```

Run tests with coverage:

```bash
flutter test --coverage
```

Run a specific test file:

```bash
flutter test test/models/message_test.dart
flutter test test/providers/chat_provider_test.dart
flutter test test/providers/theme_provider_test.dart
flutter test test/mock/mock_data_test.dart
```

## Build Application

### Android APK / App Bundle

```bash
flutter build apk                    # Debug APK
flutter build apk --release          # Release APK
flutter build appbundle --release    # Release App Bundle (Play Store)
```

### iOS

```bash
flutter build ios --release          # Requires macOS + Xcode
```

### Web

```bash
flutter build web --release
```

### Windows

```bash
flutter build windows --release
```

### Linux

```bash
flutter build linux --release
```

### macOS

```bash
flutter build macos --release        # Requires macOS
```

## Code Analysis

```bash
flutter analyze
```

## Project Structure

```
lib/
├── main.dart                     # App entry, FTheme wiring
├── models/message.dart           # Message model + MessageSender enum
├── mock/mock_data.dart           # Mock AI conversation data
├── providers/
│   ├── chat_provider.dart        # ChatNotifier (Riverpod)
│   └── theme_provider.dart       # ThemeNotifier (light/dark toggle)
├── screens/chat_screen.dart      # Chat screen layout
└── widgets/
    ├── message_bubble.dart       # Chat bubble widget
    └── message_input.dart        # Text input + send button
test/
├── models/message_test.dart
├── mock/mock_data_test.dart
├── providers/
│   ├── chat_provider_test.dart
│   └── theme_provider_test.dart
└── widget_test.dart
specs/
└── chat-ui.spec.md               # Feature specification
```

## Tech Stack

| Library | Purpose |
|---------|---------|
| `forui` | UI components (FScaffold, FHeader, FTextField, FButton, FTheme) |
| `flutter_riverpod` | State management (Notifier / NotifierProvider) |
| `flutter` | Cross-platform framework |

## Themes

- Light: `FThemes.violet.light.touch` — white background, violet accent
- Dark: `FThemes.violet.dark.touch` — dark background, violet accent

Toggle via the sun/moon icon button in the header.
