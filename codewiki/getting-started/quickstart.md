# Mulai Cepat

```text
# Related Code
- `pubspec.yaml`
- `lib/main.dart`
- `README.md`
```

## Prerequisites

- Flutter SDK >= 3.41.0
- Dart SDK >= 3.11.5
- Emulator / device (atau browser untuk web)

## Langkah 1 — Install Dependencies

```bash
cd smartai_chat
flutter pub get
```

Output yang diharapkan:

```
Resolving dependencies...
  forui 0.21.3
  flutter_riverpod 3.3.1
  cupertino_icons 1.0.8
Downloading packages...
```

## Langkah 2 — Jalankan Aplikasi

```bash
flutter run
```

Atau spesifik ke emulator:

```bash
flutter emulators --launch Pixel_6
flutter run -d emulator-5554
```

## Langkah 3 — Verifikasi

Aplikasi akan menampilkan:

- Header: **Chat with Natsya**
- Daftar pesan mock percakapan tentang Flutter development
- Input field dengan teks "Message"
- Tombol kirim berbentuk lingkaran dengan icon panah atas
- Sidebar yang bisa dibuka/tutup dengan nama sesi chat

## Struktur Direktori Utama

| Direktori | Isi |
|-----------|-----|
| `lib/` | Kode Dart utama |
| `lib/screens/` | Halaman aplikasi (ChatScreen) |
| `lib/widgets/` | Komponen UI reusable |
| `lib/providers/` | State management Riverpod |
| `lib/models/` | Model data |
| `lib/mock/` | Data mock untuk development |
| `test/` | Unit & widget tests |
