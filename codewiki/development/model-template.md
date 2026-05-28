# Template Model

Model adalah cetakan/struktur data. Semua mock, provider, dan UI bergantung ke model — jadi definisikan model **dulu** sebelum bikin apa pun.

Konvensi proyek:
- 1 file per model di `lib/models/`
- Gunakan `@immutable` agar Dart menjamin objek tidak bisa diubah

---

## Pola A: Model Sederhana

Untuk entity data: `Message`, `ChatSession`, `User`, `Product`, dll.

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/models/namamu.dart                // ⬅️ GANTI: nama file
import 'package:flutter/foundation.dart';

enum StatusPilihan { nilai1, nilai2 }    // ⬅️ GANTI: hapus jika tidak perlu enum

@immutable
class NamaModel {                          // ⬅️ GANTI: nama class
  final String id;                         // ⬅️ GANTI: field wajib
  final String judul;                      // ⬅️ GANTI: field wajib
  final DateTime waktu;                    // ⬅️ GANTI: field wajib
  final StatusPilihan status;              // ⬅️ GANTI: field wajib (hapus enum jika tidak pakai)
  final bool isActive;                     // ⬅️ GANTI: field opsional dengan default value

  const NamaModel({                        // ⬅️ GANTI: nama constructor
    required this.id,
    required this.judul,
    required this.waktu,
    required this.status,
    this.isActive = false,                 // ⬅️ GANTI: default value
  });
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu.dart` | `message.dart` |
| Nama class | `NamaModel` | `Message` |
| Enum + value | `StatusPilihan { nilai1, nilai2 }` | `MessageSender { user, ai }` |
| Field wajib | `final String judul;` | `final String text;` |
| Field opsional + default | `this.isActive = false` | `this.isError = false` |

---

## Pola B: Model + copyWith

Untuk config/settings/state object yang butuh update tanpa mutasi: `CloudAiConfig`, `ChatState`, `UserSettings`, dll.

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/models/namamu_config.dart           // ⬅️ GANTI: nama file
import 'package:flutter/foundation.dart';

@immutable
class NamaConfig {                          // ⬅️ GANTI: nama class
  final String url;                         // ⬅️ GANTI: field (bisa diganti/tambah/hapus)
  final String kunci;                       // ⬅️ GANTI: field
  final double suhu;                        // ⬅️ GANTI: field
  final bool aktif;                         // ⬅️ GANTI: field

  const NamaConfig({                        // ⬅️ GANTI: nama constructor
    this.url = 'https://default.com',       // ⬅️ GANTI: default value per field
    this.kunci = '',
    this.suhu = 0.7,
    this.aktif = false,
  });

  // ⬇️ copyWith: bikin salinan dengan beberapa field berubah
  NamaConfig copyWith({                     // ⬅️ GANTI: nama class return
    String? url,                            // ⬅️ GANTI: parameter (harus nullable type)
    String? kunci,                          // ⬅️ GANTI: parameter
    double? suhu,                           // ⬅️ GANTI: parameter
    bool? aktif,                            // ⬅️ GANTI: parameter
  }) {
    return NamaConfig(                      // ⬅️ GANTI: nama constructor
      url: url ?? this.url,
      kunci: kunci ?? this.kunci,
      suhu: suhu ?? this.suhu,
      aktif: aktif ?? this.aktif,
    );
  }

  // ⬇️ == dan hashCode: agar dua objek dengan nilai sama dianggap sama
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamaConfig &&                // ⬅️ GANTI: nama class
          url == other.url &&               // ⬅️ GANTI: field yang dibandingkan
          kunci == other.kunci &&           // ⬅️ GANTI: field
          suhu == other.suhu &&             // ⬅️ GANTI: field
          aktif == other.aktif;             // ⬅️ GANTI: field

  @override
  int get hashCode =>
      url.hashCode ^                        // ⬅️ GANTI: field
      kunci.hashCode ^                      // ⬅️ GANTI: field
      suhu.hashCode ^                       // ⬅️ GANTI: field
      aktif.hashCode;                       // ⬅️ GANTI: field
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_config.dart` | `cloud_ai_config.dart` |
| Nama class | `NamaConfig` | `CloudAiConfig` |
| Field + tipe | `final double suhu;` | `final double temperature;` |
| Default value | `this.suhu = 0.7` | `this.temperature = 0.7` |
| Parameter copyWith | `double? suhu` | `double? temperature` |
| Operator == field | `suhu == other.suhu` | `temperature == other.temperature` |
| hashCode field | `suhu.hashCode ^` | `temperature.hashCode ^` |

---

## Ringkasan

| Pola | Kapan Dipakai | Contoh di Proyek | Ada enum? | Ada copyWith? |
|---|---|---|---|---|
| **A** | Data entity (message, user, product, session) | `Message`, `ChatSession`, `AiModelStatus` | opsional | tidak perlu |
| **B** | Config, settings, state immutable | `CloudAiConfig`, `ChatState` | jarang | wajib |

> Setelah model jadi, lanjut ke [Template Mock Data](/development/mock-data-template) untuk bikin data palsu, lalu ke [Template Provider](/development/provider-template) untuk state management + testing.
