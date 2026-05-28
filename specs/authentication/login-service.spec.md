---
name: Login Service
description: Authentication service for Google OAuth sign-in via google_sign_in package + Supabase signInWithIdToken, session management, and error handling.
targets:
  - ../smartai_chat/lib/services/auth/login_service.dart
---

# Login Service — Natsya

## LoginService

```dart
class LoginService {
  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  LoginService(this._client);

  Future<AuthUser> signInWithGoogle();
  AuthUser? getCurrentUser();
  AuthSession? getCurrentSession();
  Future<AuthSession> refreshSession();
  Stream<AuthUser?> get authStateChanges;
}
```

- `LoginService` menggunakan `google_sign_in` package untuk inisiasi Google OAuth.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- `GoogleSignIn` diinisialisasi dengan scopes `['email', 'openid', 'profile']`.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- `signInWithGoogle()` memanggil `GoogleSignIn.signIn()` untuk menampilkan dialog pilihan akun Google.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Jika user membatalkan dialog (return `null`), lempar `OAuthCancelledException`.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Setelah user dipilih, ambil `idToken` dan `accessToken` dari `GoogleSignInAuthentication`.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Jika `idToken` null, lempar `AuthException('Google ID Token tidak ditemukan.')`.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Panggil `SupabaseAuth.signInWithIdToken(provider: google, idToken: ..., accessToken: ...)` untuk autentikasi ke Supabase.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- Setelah sign-in berhasil, lakukan **upsert** ke tabel `users` dengan kolom: `id`, `email`, `is_active = true`.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- `getCurrentUser()` mengembalikan `AuthUser` aktif saat ini, atau `null` jika belum login.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- `getCurrentSession()` mengembalikan `AuthSession` aktif saat ini, atau `null` jika belum login / session expired.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- `refreshSession()` melakukan refresh token secara manual dan mengembalikan `AuthSession` baru.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`
- `authStateChanges` adalah `Stream` yang emit `AuthUser?` setiap kali status autentikasi berubah.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`

## AuthException

```dart
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
}
```

- `AuthException` digunakan untuk semua error autentikasi umum.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`

## OAuthCancelledException

```dart
class OAuthCancelledException implements Exception {
  final String message;
  OAuthCancelledException([this.message = 'OAuth sign-in was cancelled']);
}
```

- `OAuthCancelledException` digunakan khusus saat user membatalkan dialog Google Sign-In.
  `[@test] ../smartai_chat/test/services/login_service_test.dart`

## Rules & Constraints

- Autentikasi menggunakan **google_sign_in** package (Google Sign-In SDK) + **Supabase `signInWithIdToken`**.
- Tidak memerlukan Client Secret Google OAuth (karena menggunakan native Google Sign-In, bukan web OAuth).
- Tidak memerlukan deep link / redirect URL di AndroidManifest.xml.
- Upsert ke tabel `users` hanya menyimpan `id`, `email`, dan `is_active`.
- `AuthSession` di-handle secara internal oleh Supabase.
