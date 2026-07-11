# Natsya Ai - Product Overview

## Short Description

Natsya Ai adalah aplikasi chat AI Flutter dengan login Google, tema gelap/terang, dan AI lokal atau cloud.

## Description

Natsya Ai adalah aplikasi mobile chat AI berbasis Flutter yang menghadirkan asisten percakapan bernama Natsya. Aplikasi ini dirancang dengan antarmuka chat modern menggunakan Forui, state management Riverpod, autentikasi Google melalui Supabase, serta dukungan AI on-device dan cloud fallback.

Project ini dapat dijalankan secara cross-platform lewat Flutter, dengan fokus utama pada pengalaman percakapan yang sederhana, responsif, dan siap dikembangkan menjadi produk AI assistant yang lebih lengkap.

## Features

- Chat dengan asisten AI bernama Natsya.
- Integrasi model AI lokal menggunakan `flutter_gemma`.
- Cloud AI fallback melalui API OpenAI-compatible seperti PublicAI, Groq, OpenRouter, atau DeepSeek.
- Login Google OAuth menggunakan `google_sign_in` dan Supabase Auth.
- Penyimpanan user dasar melalui tabel `users` di Supabase.
- UI chat modern dengan bubble pesan user dan AI.
- Streaming response dan complete response untuk jawaban AI.
- Indikator mengetik, error bubble, retry pesan gagal, dan cancel generation.
- Sidebar sesi chat dengan daftar percakapan.
- Tema terang dan gelap memakai Forui violet theme.
- Local notification service.
- State management berbasis Riverpod 3 `Notifier`.
- Unit dan widget test untuk model, provider, mock data, dan UI dasar.
- Dukungan build Android, iOS, Web, Windows, Linux, dan macOS melalui Flutter.

## Requirements

- Flutter SDK 3.41.0 atau lebih baru.
- Dart SDK 3.11.5 atau lebih baru.
- Android Studio atau VS Code dengan Flutter extension.
- Android emulator, iOS simulator, physical device, atau browser untuk web.
- Supabase project aktif.
- Supabase anon public key.
- Google Cloud project untuk OAuth Client ID.
- Internet connection untuk login, download model AI, dan cloud AI fallback.
- Optional: Cloud AI API key jika ingin memakai provider cloud.
- Optional untuk iOS/macOS: macOS dan Xcode.

## Instructions Setup

### 1. Masuk ke Folder Project

```bash
cd smartai_chat
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Siapkan Environment

Copy file contoh environment:

```bash
cp .env.example .env
```

Jika menggunakan PowerShell:

```powershell
Copy-Item .env.example .env
```

Isi nilai berikut di file `.env`:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_supabase_anon_key_here
CLOUD_API_KEY=your_cloud_api_key_here
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

`CLOUD_API_KEY` bersifat optional. Jika kosong, aplikasi akan memakai flow AI lokal selama model sudah siap.

### 4. Setup Supabase

Buat project Supabase, lalu jalankan SQL berikut di Supabase SQL Editor:

```sql
create table if not exists users (
  id uuid primary key,
  email text unique not null,
  is_active boolean default true
);
```

Ambil `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dari Supabase Dashboard, lalu masukkan ke `.env`.

### 5. Setup Google OAuth

Buka Google Cloud Console, lalu:

- Buat atau pilih Google Cloud project.
- Aktifkan Google Identity Toolkit API.
- Konfigurasi OAuth consent screen.
- Buat OAuth Client ID tipe Web application untuk mendapatkan `GOOGLE_WEB_CLIENT_ID`.
- Buat OAuth Client ID tipe Android dengan package name `com.smartai.smartai_chat`.
- Masukkan SHA-1 debug certificate dari `gradlew signingReport`.

Panduan detail tersedia di:

```text
smartai_chat/SETUP_GOOGLE_OAuth.md
```

### 6. Jalankan Aplikasi

```bash
flutter run
```

Atau jalankan dengan `dart-define`:

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

Dengan cloud AI fallback:

```bash
flutter run --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key_here --dart-define=CLOUD_API_KEY=your_cloud_api_key_here
```

Untuk target platform tertentu:

```bash
flutter run -d android
flutter run -d chrome
flutter run -d windows
```

### 7. Jalankan Test

```bash
flutter test
```

Dengan coverage:

```bash
flutter test --coverage
```

### 8. Build Release

Android APK:

```bash
flutter build apk --release
```

Android App Bundle:

```bash
flutter build appbundle --release
```

Web:

```bash
flutter build web --release
```

Windows:

```bash
flutter build windows --release
```
