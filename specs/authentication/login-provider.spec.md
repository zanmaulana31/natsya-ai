---
name: Login Provider
description: Riverpod provider for Google OAuth authentication state, auto-subscribing to auth changes and exposing user-friendly error messages.
targets:
  - ../smartai_chat/lib/providers/auth/login_provider.dart
---

# Login Provider — Natsya

## AuthNotifier

```dart
class AuthNotifier extends AsyncNotifier<AuthUser?> {
  late final LoginService _loginService;

  @override
  Future<AuthUser?> build() async {
    // Auto-subscribe ke authStateChanges dari LoginService
    // Return user saat ini (null jika belum login)
  }

  Future<void> signInWithGoogle();
  void clearError();
}
```

- `AuthNotifier` extends `AsyncNotifier<AuthUser?>` untuk state management yang idiomatic Riverpod 3.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `build()` menginisialisasi state dengan `AuthUser` saat ini (via `LoginService.getCurrentUser()`).
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `build()` secara otomatis subscribe ke `LoginService.authStateChanges` dan update state ketika status autentikasi berubah.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `signInWithGoogle()` memanggil `LoginService.signInWithGoogle()`.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `signInWithGoogle()` menangkap `AuthException` dan mengubahnya menjadi error message user-friendly di `AsyncValue.error`.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `signInWithGoogle()` menangkap `OAuthCancelledException` dan mengubahnya menjadi error message khusus (contoh: "Sign-in dibatalkan") di `AsyncValue.error`.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- Saat proses login berjalan, state berubah ke `AsyncValue.loading`.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- Setelah login sukses, state menjadi `AsyncValue.data(user)` dengan `AuthUser` hasil login.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `clearError()` mereset state dari `AsyncValue.error` ke `AsyncValue.data(null)` atau kondisi terakhir yang valid.
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`

## authProvider

```dart
final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(() => AuthNotifier());
```

- `authProvider` adalah `AsyncNotifierProvider` yang expose `AsyncValue<AuthUser?>` ke UI layer.
  `[@test] ../smartai_chat/test/providers/auth_provider_test.dart`
- Consumer dapat mengecek `.when(data:, loading:, error:)` untuk render UI sesuai state.
  `[@test] ../smartai_chat/test/providers/auth_provider_test.dart`

## Error Messages

- `AuthException` → "Gagal masuk. Silakan coba lagi nanti." (atau message user-friendly serupa).
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- `OAuthCancelledException` → "Masuk dengan Google dibatalkan.".
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`
- Network error → "Koneksi internet bermasalah. Periksa jaringan Anda.".
  `[@test] ../smartai_chat/test/providers/auth_notifier_test.dart`

## Rules & Constraints

- State menggunakan `AsyncValue<AuthUser?>` bawaan Riverpod 3 (loading/error/data built-in).
- Auto-subscribe ke `authStateChanges` dari `LoginService` untuk sinkronisasi real-time.
- Semua error dari service ditangkap dan diubah menjadi pesan user-friendly sebelum masuk ke state.
- `signOut` tidak termasuk di spec ini (akan ditangani di spec terpisah).
