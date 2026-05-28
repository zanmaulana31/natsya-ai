# Panduan Setup Google OAuth — Natsya AI

Panduan lengkap untuk mengaktifkan login Google OAuth di aplikasi **Natsya AI** menggunakan **google_sign_in** package + **Supabase**.

---

## Prasyarat

- Project Supabase sudah dibuat ([supabase.com](https://supabase.com))
- Akses ke [Google Cloud Console](https://console.cloud.google.com/)
- Aplikasi Flutter sudah memiliki package `google_sign_in` dan `supabase_flutter`

---

## Pendekatan Arsitektur

Aplikasi menggunakan **native Google Sign-In** (via `google_sign_in` package) yang kemudian mengirimkan ID Token ke Supabase untuk autentikasi:

```
User tap "Sign in with Google"
    ↓
Google Sign-In SDK (native dialog)
    ↓
Dapatkan ID Token + Access Token
    ↓
Supabase Auth.signInWithIdToken()
    ↓
Upsert user ke tabel `users`
    ↓
Login berhasil!
```

**Keunggulan approach ini:**
- ✅ Tidak perlu Client Secret
- ✅ Tidak perlu deep link / redirect URL
- ✅ Tidak perlu konfigurasi Supabase OAuth Provider
- ✅ Lebih sederhana dan idiomatic untuk Flutter

---

## Langkah 1: Buat OAuth 2.0 Credentials di Google Cloud Console

### 1.1 Buat atau Pilih Project

1. Buka [Google Cloud Console](https://console.cloud.google.com/)
2. Klik dropdown project di bagian atas → **New Project**
3. Beri nama project (misal: `Natsya AI`) → klik **Create**

### 1.2 Aktifkan Google Identity Toolkit API

1. Masuk ke menu **APIs & Services** → **Library**
2. Cari **Google Identity Toolkit API**
3. Klik **Enable**

### 1.3 Konfigurasi Layar Persetujuan OAuth (OAuth Consent Screen)

1. Masuk ke **APIs & Services** → **OAuth consent screen**
2. Pilih **External**
3. Isi informasi aplikasi:
   - **App name**: `Natsya AI`
   - **User support email**: email Anda
   - **Developer contact information**: email Anda
4. Klik **Save and Continue** sampai selesai

### 1.4 Buat OAuth 2.0 Client ID untuk Web (WAJIB untuk ID Token)

> **Penting**: Untuk mendapatkan `idToken` dari Google Sign-In, Anda **wajib** membuat OAuth Client ID tipe **Web application** dan mengaturnya sebagai `serverClientId`.

1. Masuk ke **APIs & Services** → **Credentials**
2. Klik **Create Credentials** → **OAuth client ID**
3. Pilih **Application type**: **Web application**
4. Isi detail:
    - **Name**: `Natsya AI Web`
    - **Authorized JavaScript origins**: `http://localhost`
    - **Authorized redirect URIs**: `http://localhost`
5. Klik **Create**
6. Copy **Client ID** (contoh: `123456789-abc123.apps.googleusercontent.com`)
7. Tambahkan ke file `.env`:
    ```env
    GOOGLE_WEB_CLIENT_ID=123456789-abc123.apps.googleusercontent.com
    ```

### 1.5 Buat OAuth 2.0 Client ID untuk Android

1. Masuk ke **APIs & Services** → **Credentials**
2. Klik **Create Credentials** → **OAuth client ID**
3. Pilih **Application type**: **Android**
4. Isi detail:
    - **Name**: `Natsya AI Android`
    - **Package name**: `com.smartai.smartai_chat`
    - **SHA-1 certificate fingerprint**:
      ```bash
      cd android
      $env:JAVA_HOME = "E:\Android Studio\jbr"; .\gradlew signingReport
      ```
      Ambil nilai **SHA1** dari section `:app:signingReport` (contoh: `8A:14:EA:86:36:AB:E8:38:46:4A:D8:1A:70:7B:FA:1C:75:92:52:65`)

5. Klik **Create**

> **Catatan**: Untuk approach ini, Anda **tidak perlu** Client Secret. Google tidak menyediakan Client Secret untuk aplikasi tipe Android/iOS, dan kita juga tidak membutuhkannya karena menggunakan native Google Sign-In SDK.

### 1.5 (Opsional) Buat OAuth Client ID untuk iOS

Jika Anda juga mengembangkan untuk iOS:
1. Klik **Create Credentials** → **OAuth client ID**
2. Pilih **Application type**: **iOS**
3. Isi **Bundle ID** aplikasi Anda
4. Klik **Create**

---

## Langkah 2: Konfigurasi Supabase

### 2.1 Buat Tabel `users`

Di Supabase Dashboard → SQL Editor, jalankan:

```sql
create table if not exists users (
  id uuid primary key,
  email text unique not null,
  is_active boolean default true
);
```

> **Catatan**: Tidak perlu enable Google Provider di Supabase Authentication → Providers. Karena kita menggunakan `signInWithIdToken`, autentikasi langsung ditangani oleh Supabase Auth tanpa perlu konfigurasi provider terpisah.

---

## Langkah 3: Run Aplikasi

### 3.1 Pastikan Dependencies Terinstall

```bash
cd smartai_chat
flutter pub get
```

### 3.2 Run dengan Supabase Anon Key

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=eyJhbG...
```

Untuk multiple dart-define:
```bash
flutter run \
  --dart-define=SUPABASE_ANON_KEY=eyJhbG... \
  --dart-define=CLOUD_API_KEY=your_cloud_api_key_here
```

---

## Troubleshooting Umum

| Masalah | Penyebab | Solusi |
|---------|----------|--------|
| `PlatformException(sign_in_failed, ...)` | SHA-1 tidak cocok | Pastikan SHA-1 di Google Cloud Console sama dengan output `gradlew signingReport` |
| `AuthException: Google ID Token tidak ditemukan` | Google Sign-In gagal mendapatkan token | Periksa koneksi internet; pastikan Google Identity Toolkit API di-enable |
| `AuthException: Gagal mendapatkan user` | Supabase sign-in gagal | Periksa `SUPABASE_ANON_KEY` dan koneksi ke Supabase |
| Dialog Google tidak muncul | OAuth consent screen belum disetup | Selesaikan konfigurasi OAuth Consent Screen di Google Cloud Console |
| `developer_error` | Package name atau SHA-1 salah | Periksa kembali package name (`com.smartai.smartai_chat`) dan SHA-1 di Google Cloud Console |

---

## Perbandingan Approach

| Aspek | Supabase OAuth (redirect) | google_sign_in + signInWithIdToken (saat ini) |
|-------|--------------------------|-----------------------------------------------|
| Client Secret | ❌ Diperlukan | ✅ Tidak perlu |
| Deep Link | ❌ Wajib konfigurasi | ✅ Tidak perlu |
| Redirect URL | ❌ Wajib setup | ✅ Tidak perlu |
| Supabase Provider Config | ❌ Enable Google Provider | ✅ Tidak perlu |
| Package Tambahan | `supabase_flutter` saja | `google_sign_in` + `supabase_flutter` |
| Keamanan | 🔒 Redirect-based | 🔒 Native SDK |
| Kompleksitas Setup | Lebih kompleks | Lebih sederhana |

---

## Referensi

- [google_sign_in package](https://pub.dev/packages/google_sign_in)
- [Supabase Flutter Auth Documentation](https://supabase.com/docs/reference/dart/introduction)
- [Supabase signInWithIdToken](https://supabase.com/docs/reference/dart/auth-signinwithidtoken)
