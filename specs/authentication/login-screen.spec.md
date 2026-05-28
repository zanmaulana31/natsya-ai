---
name: Login Screen
description: Login screen for Google OAuth authentication with Natsya AI branding, inline error handling, and auto-redirect to ChatScreen.
targets:
  - ../smartai_chat/lib/screens/login_screen.dart
  - ../smartai_chat/lib/widgets/login/google_sign_in_button.dart
---

# Login Screen — Natsya

## LoginScreen

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch authProvider untuk handle semua state
  }
}
```

- `LoginScreen` extends `ConsumerWidget` untuk akses Riverpod `WidgetRef`.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Root layout menggunakan `FScaffold` (konsisten dengan `chat-ui.spec`).
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Top bar menggunakan `FHeader` dengan title **"Welcome to Natsya AI"**.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Body di-center secara vertical dan horizontal menggunakan `Column` + `MainAxisAlignment.center`.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Menampilkan logo aplikasi dari `assets/images/n_logo.png` dengan ukuran proporsional (misal: 120x120).
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Di bawah logo menampilkan teks besar **"Natsya AI"** dengan style `FTheme.of(context).data.textStyles.xl2` atau setara.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Di bawah nama menampilkan tagline kecil (misal: "Your personal AI assistant") dengan style muted/secondary.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Jika `authProvider` state adalah `AsyncValue.data(user)` dan `user != null`, auto-redirect ke `ChatScreen` menggunakan `Navigator.pushReplacement`.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Jika user sudah login saat screen pertama kali dibuka, redirect langsung terjadi tanpa flicker UI login.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`

## GoogleSignInButton

```dart
class GoogleSignInButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Handle loading, error, dan tap action
  }
}
```

- `GoogleSignInButton` adalah widget terpisah yang extends `ConsumerWidget`.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Menggunakan `FButton` dengan style rounded dan `FButtonStyle.primary`.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Menampilkan icon Google (SVG/PNG atau icon placeholder) di sebelah kiri teks **"Sign in with Google"**.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Saat ditekan, memanggil `ref.read(authProvider.notifier).signInWithGoogle()`.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Saat `authProvider` state adalah `AsyncValue.loading`, button menampilkan `CircularProgressIndicator` kecil dan disabled (tidak bisa ditekan).
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Saat `authProvider` state adalah `AsyncValue.error`, menampilkan inline error text berwarna merah/error di bawah button.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Error text menggunakan style `FTheme.of(context).data.textStyles.sm` dengan color `FTheme.of(context).data.colorScheme.error`.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Error text di-wrap dengan `AnimatedOpacity` atau `AnimatedSize` untuk transisi halus saat muncul/hilang.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Inline error di-clear otomatis saat user menekan button lagi (memicu loading state baru).
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`

## Error Display Rules

- Error dari `AuthException` → tampilkan message user-friendly yang sudah diproses oleh provider.
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Error dari `OAuthCancelledException` → tampilkan "Masuk dengan Google dibatalkan.".
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`
- Jika tidak ada error, inline error text tidak ditampilkan (height = 0 atau `SizedBox.shrink()`).
  `[@test] ../smartai_chat/test/widgets/google_sign_in_button_test.dart`

## Redirect Rules

- Saat `authProvider` emit `AsyncValue.data(user)` dengan `user != null`, `LoginScreen` segera navigasi ke `ChatScreen` via `Navigator.pushReplacement`.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Jika user membuka app dan sudah dalam keadaan login (session valid), `LoginScreen` tidak sempat render konten login — langsung redirect.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`
- Redirect hanya terjadi sekali; tidak ada infinite loop navigasi.
  `[@test] ../smartai_chat/test/screens/login_screen_test.dart`

## Rules & Constraints

- Tidak ada form input email/password karena autentikasi eksklusif **Google OAuth**.
- Semua state autentikasi dikelola oleh `authProvider` (`AsyncValue<AuthUser?>`); screen hanya consume dan render.
- Logo dan branding konsisten dengan asset yang sudah ada (`assets/images/n_logo.png`).
- Theme mengikuti `FThemes.violet` (light/dark) yang sudah di-set di root app.
- `LoginScreen` tidak menyimpan state lokal sendiri; semua state berasal dari provider.
- Widget `GoogleSignInButton` adalah reusable component yang bisa dipakai di tempat lain jika diperlukan.
