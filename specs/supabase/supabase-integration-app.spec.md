---
name: Supabase Integration — App Entry
description: Inisialisasi Supabase SDK di main.dart sebelum runApp, konfigurasi environment variable SUPABASE_ANON_KEY, dan setup Google OAuth provider.
targets:
  - ../smartai_chat/lib/main.dart
  - ../smartai_chat/lib/models/supabase_config.dart
---

# Supabase Integration — App Entry

## main.dart

- Sebelum `runApp()`, `main()` harus memanggil `WidgetsFlutterBinding.ensureInitialized()` (sudah ada).
- Setelah notifikasi diinisialisasi, panggil `Supabase.initialize()` secara **asinkron** menggunakan nilai dari `SupabaseConfig`.
  `[@test] ../smartai_chat/test/main_test.dart`
- `Supabase.initialize()` memerlukan parameter `url` (Supabase project URL) dan `anonKey` (public anon key).
  `[@test] ../smartai_chat/test/main_test.dart`
- URL dan anon key diambil dari instance `const SupabaseConfig()` yang membaca environment variable `SUPABASE_ANON_KEY`.
  `[@test] ../smartai_chat/test/main_test.dart`
- Jika `SUPABASE_ANON_KEY` tidak di-set (empty string), app tetap berjalan namun autentikasi Supabase akan gagal.
  `[@test] ../smartai_chat/test/main_test.dart`

## SupabaseConfig

```dart
class SupabaseConfig {
  final String url;
  final String kunci;
}
```

- `SupabaseConfig.url` default ke `https://nzqcnenzbxwwxaaogvdn.supabase.co`.
  `[@test] ../smartai_chat/test/models/supabase_config_test.dart`
- `SupabaseConfig.kunci` diambil dari environment variable `SUPABASE_ANON_KEY` via `const String.fromEnvironment('SUPABASE_ANON_KEY')`.
  `[@test] ../smartai_chat/test/models/supabase_config_test.dart`
- Field `kunci` di-rename menjadi `anonKey` agar lebih eksplisit dan sesuai dengan terminologi Supabase.
  `[@test] ../smartai_chat/test/models/supabase_config_test.dart`

## Environment Variable

- `SUPABASE_ANON_KEY` wajib di-pass saat run atau build via `--dart-define`:
  ```bash
  flutter run --dart-define=SUPABASE_ANON_KEY=eyJhbG...
  ```
  `[@test] ../smartai_chat/test/main_test.dart`
- Untuk build release:
  ```bash
  flutter build apk --dart-define=SUPABASE_ANON_KEY=eyJhbG...
  ```
  `[@test] ../smartai_chat/test/main_test.dart`

## Supabase Dashboard Configuration

- Google OAuth provider harus di-enable di Supabase Dashboard → Authentication → Providers → Google.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Masukkan **Client ID** dan **Client Secret** dari Google Cloud Console.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Tambahkan authorized redirect URI yang sesuai platform:
  - Android: `io.supabase.flutterquickstart://login-callback/`
  - iOS: sesuai bundle identifier
  - Web: `http://localhost:3000`
  `[@test] ../smartai_chat/test/services/login_service_test.dart`

## Rules & Constraints

- `Supabase.initialize()` harus dipanggil sekali saja dan sebelum `runApp()`.
- Jangan menyimpan Service Role Key di client-side; gunakan hanya **anon key**.
- `SUPABASE_ANON_KEY` tidak boleh di-commit ke repository; selalu pass via environment variable.
