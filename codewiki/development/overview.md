# Panduan Development

```text
# Related Code
- `pubspec.yaml`
- `analysis_options.yaml`
- `test/`
```

## Workflow Lokal

```bash
# Install dependencies
flutter pub get

# Jalankan di emulator/device
flutter run

# Jalankan web
flutter run -d chrome

# Build untuk production
flutter build apk          # Android
flutter build ios           # iOS
flutter build web           # Web
flutter build windows       # Windows
```

## Running Tests

```bash
# Semua test
flutter test

# Test spesifik
flutter test test/models/message_test.dart
flutter test test/providers/chat_provider_test.dart

# Coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Test Strategy

| Level | Tools | Cakupan |
|-------|-------|---------|
| **Unit Test** | `flutter_test` + `ProviderContainer` | Models, providers logic |
| **Widget Test** | `flutter_test` + `WidgetTester` | Setiap widget rendering & interaksi |
| **Integration** | Belum ada | Perlu ditambahkan |

Semua provider di-test menggunakan `ProviderContainer` langsung tanpa perlu `WidgetTester`, membuat unit test state management menjadi cepat dan terisolasi. Widget test menggunakan helper `_wrap()` yang menyediakan `ProviderScope` + `FTheme` + `MaterialApp`.

## Debugging Tips

- Gunakan `ref.listen()` (seperti di ChatScreen) untuk reaktivitas terhadap perubahan state tanpa rebuild widget
- Riverpod `ProviderContainer` sangat berguna untuk test state tanpa overhead widget tree
- Forui `context.theme` memberikan akses ke `FColors` untuk kustomisasi warna sesuai tema

## Konfigurasi .gitignore

Proyek menggunakan `.gitignore` standar Flutter yang mencakup semua platform:

### Root `.gitignore`

```text
# Flutter/Dart/Pub related
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
build/
coverage/

# Platform-specific artifacts
/android/app/debug
/android/app/profile
/android/app/release
**/ios/Pods/
**/ios/.symlinks/
**/ios/Flutter/ephemeral/
**/macos/Pods/
**/macos/Flutter/ephemeral/
**/linux/flutter/ephemeral/
**/windows/flutter/ephemeral/

# IDE
.idea/
*.iml
.vscode/launch.json

# Keystore (jangan pernah commit!)
*.keystore
*.jks
key.properties
```

### Sub-directory `.gitignore`

| Platform | File | Isi Penting |
|----------|------|-------------|
| Android | `android/.gitignore` | `local.properties`, `*.keystore`, `*.jks`, `gradle-wrapper.jar` |
| iOS | `ios/.gitignore` | `Pods/`, `.symlinks/`, `Flutter/ephemeral/`, `GeneratedPluginRegistrant.*` |

> **Catatan**: `pubspec.lock` **disertakan** dalam version control (tidak di-ignore) untuk memastikan reproducibility build.

## Melacak Request End-to-End

Untuk memahami alur kirim pesan:

1. User menekan send di `MessageInput` → `lib/widgets/message_input.dart:10628`
2. `ChatNotifier.sendMessage()` dipanggil → `lib/providers/chat_provider.dart:10318`
3. State berubah, `ChatScreen` mendeteksi via `ref.listen()` → `lib/screens/chat_screen.dart:10437`
4. `ListView.builder` me-render ulang dengan pesan baru
5. Auto-scroll ke bawah jika user sedang di bagian bawah
