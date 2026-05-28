---
name: Login Model
description: Immutable data models for Google OAuth authentication, representing authenticated user identity and session tokens.
targets:
  - ../smartai_chat/lib/models/auth/auth_user.dart
  - ../smartai_chat/lib/models/auth/auth_session.dart
---

# Login Model — Natsya

## AuthUser

```dart
@immutable
class AuthUser {
  final String id;              // UUID dari Supabase / Google sub
  final String email;           // Wajib, valid email format
  final bool isActive;          // Default true saat registrasi
  final String provider;        // Runtime only, e.g., 'google'
  final String? displayName;    // Runtime only, dari Google
  final String? photoUrl;       // Runtime only, dari Google
}
```

- `AuthUser.id` adalah UUID unik yang diambil dari hasil autentikasi Supabase/Google.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- `AuthUser.email` wajib non-empty dan harus berformat email valid.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- `AuthUser.isActive` default `true`, menandakan akun aktif setelah login sukses.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- `AuthUser.provider`, `displayName`, `photoUrl` hanya tersedia saat runtime (tidak dipersisten ke tabel Supabase).
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- Menyediakan `const` constructor dengan `id`, `email` sebagai `required`, dan `isActive` default `true`.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- Menyediakan `copyWith(...)` untuk pembuatan salinan immutable dengan field yang diubah.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- Override `operator ==` dan `hashCode` berdasarkan `id` dan `email`.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- Menyediakan `toJson()` yang hanya menserialisasi field yang dipersisten ke Supabase: `id`, `email`, `is_active`.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`
- Menyediakan `fromJson(Map<String, dynamic>)` untuk deserialisasi dari response Supabase, mengisi `id`, `email`, `isActive`. Field runtime (`provider`, `displayName`, `photoUrl`) akan null saat deserialisasi dari JSON Supabase.
  `[@test] ../smartai_chat/test/models/auth_user_test.dart`

## AuthSession

```dart
@immutable
class AuthSession {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;
}
```

- `AuthSession.accessToken` adalah Supabase JWT access token.
  `[@test] ../smartai_chat/test/models/auth_session_test.dart`
- `AuthSession.refreshToken` digunakan untuk silent refresh session.
  `[@test] ../smartai_chat/test/models/auth_session_test.dart`
- `AuthSession.expiresAt` adalah `DateTime` yang menunjukkan kapan access token kadaluarsa.
  `[@test] ../smartai_chat/test/models/auth_session_test.dart`
- Menyediakan `const` constructor dengan semua field sebagai `required`.
  `[@test] ../smartai_chat/test/models/auth_session_test.dart`
- Menyediakan `copyWith(...)` untuk update immutable.
  `[@test] ../smartai_chat/test/models/auth_session_test.dart`
- Override `operator ==` dan `hashCode` berdasarkan `accessToken`.
  `[@test] ../smartai_chat/test/models/auth_session_test.dart`

## Rules & Constraints

- Tidak ada field `password` karena autentikasi eksklusif menggunakan **Google OAuth**.
- `AuthUser` dipersisten ke tabel Supabase dengan kolom minimal: `id` (uuid, primary key), `email` (text, unique), `is_active` (boolean).
- Field `provider`, `displayName`, dan `photoUrl` tidak disimpan ke database.
- `AuthSession` bersifat sementara (runtime) dan tidak dipersisten ke tabel database.
