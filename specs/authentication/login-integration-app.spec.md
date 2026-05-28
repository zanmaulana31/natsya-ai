---
name: Login Integration — App Entry
description: Integrasi LoginScreen ke main.dart sebagai entry point pertama sebelum ChatScreen atau ModelLoadingScreen.
targets:
  - ../smartai_chat/lib/main.dart
---

# Login Integration — App Entry

## SmartAiApp

```dart
class SmartAiApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authProvider terlebih dahulu
  }
}
```

- `SmartAiApp` mengecek `authProvider` sebagai prioritas pertama sebelum menentukan screen mana yang ditampilkan.
  `[@test] ../smartai_chat/test/main_test.dart`
- Jika `authProvider` state adalah `AsyncValue.loading`, tampilkan `Scaffold` kosong dengan `CircularProgressIndicator` di tengah (splash/loading state).
  `[@test] ../smartai_chat/test/main_test.dart`
- Jika `authProvider` state adalah `AsyncValue.data(null)` atau user belum login, tampilkan `LoginScreen` sebagai `home`.
  `[@test] ../smartai_chat/test/main_test.dart`
- Jika `authProvider` state adalah `AsyncValue.data(user)` dengan `user != null` (sudah login), lanjutkan ke logika existing:
  - Cek `cloudAiConfigProvider` dan `aiModelProvider`
  - Jika `cloudConfig.enabled == true` atau `modelState.status == AiModelStatus.ready`, tampilkan `ChatScreen`
  - Selain itu, tampilkan `ModelLoadingScreen`
  `[@test] ../smartai_chat/test/main_test.dart`
- Urutan prioritas screen: **LoginScreen** → **ChatScreen** / **ModelLoadingScreen**.
  `[@test] ../smartai_chat/test/main_test.dart`
- Navigation dari `LoginScreen` ke `ChatScreen` tetap di-handle oleh `LoginScreen` sendiri via `Navigator.pushReplacement` saat `authProvider` emit user login.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`

## Rules & Constraints

- `main.dart` tetap menggunakan `ProviderScope` sebagai root widget.
- `MaterialApp` tetap menggunakan `FTheme` wrapper via `builder`.
- Tidak ada perubahan pada konfigurasi theme, dark mode, atau Forui components.
- `LoginScreen` adalah gatekeeper pertama — user harus login sebelum bisa mengakses ChatScreen atau ModelLoadingScreen.
