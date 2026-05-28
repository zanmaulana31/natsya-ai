# Template Provider

Provider adalah state management layer yang menghubungkan model/mock/service ke UI. Proyek menggunakan Riverpod dengan pola `Notifier` + `NotifierProvider`.

Konvensi proyek:
- 1 file per provider di `lib/providers/`
- Gunakan `Notifier<T>` untuk state sederhana, `Notifier<StateClass>` untuk state kompleks
- Service di-inject lewat `Provider<T>` terpisah, dibaca via `ref.read()`

> **Prasyarat**: model dan mock sudah jadi. Kalau belum, baca [Template Model](/development/model-template) dan [Template Mock Data](/development/mock-data-template) dulu.

---

## Pola A: Provider Sederhana (Primitive State)

Untuk state boolean, enum, atau tipe primitif: sidebar toggle, theme mode, tab index, dll.

Contoh di proyek: `SidebarNotifier`, `ThemeNotifier`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/providers/namamu_provider.dart       // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NamaNotifier extends Notifier<TipeState> {  // ⬅️ GANTI: nama notifier, tipe state
  @override
  TipeState build() => NilaiDefault;              // ⬅️ GANTI: tipe + nilai default

  void aksiPertama() {                            // ⬅️ GANTI: nama method
    state = NilaiBaru;                            // ⬅️ GANTI: logika state
  }

  void aksiKedua() {                              // ⬅️ GANTI: nama method (atau hapus)
    state = NilaiLain;                            // ⬅️ GANTI: logika state
  }
}

final namaProvider = NotifierProvider<NamaNotifier, TipeState>(NamaNotifier.new);
//                  ⬅️ GANTI: nama notifier, tipe state
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_provider.dart` | `sidebar_provider.dart` |
| Nama notifier | `NamaNotifier` | `SidebarNotifier` |
| Tipe state | `TipeState` | `bool` |
| Nilai default | `NilaiDefault` | `false` |
| Nama method | `aksiPertama()` | `toggle()` |
| Nama provider | `namaProvider` | `sidebarProvider` |

---

## Pola B: Provider dengan State Class + copyWith

Untuk state kompleks yang punya beberapa field: loading progress, form state, multi-field config, dll.

State class didefinisikan di file provider (karena erat dengan logika provider), bukan di file model terpisah.

Contoh di proyek: `AiModelNotifier` + `AiModelState`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/providers/namamu_provider.dart       // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ⬇️ State class (di file yang sama dengan provider)
class NamaState {                              // ⬅️ GANTI: nama state class
  final TipeField fieldPertama;                // ⬅️ GANTI: field + tipe
  final TipeField fieldKedua;                  // ⬅️ GANTI: field + tipe
  final TipeField fieldKetiga;                 // ⬅️ GANTI: field + tipe (bisa tambah/hapus)

  const NamaState({                            // ⬅️ GANTI: nama constructor
    this.fieldPertama = NilaiDefault,          // ⬅️ GANTI: default value
    this.fieldKedua = NilaiDefault,            // ⬅️ GANTI: default value
    this.fieldKetiga,                          // ⬅️ GANTI: nullable field (boleh null)
  });

  // ⬇️ copyWith: bikin salinan dengan beberapa field berubah
  NamaState copyWith({                         // ⬅️ GANTI: nama class return
    TipeField? fieldPertama,                   // ⬅️ GANTI: parameter nullable
    TipeField? fieldKedua,                     // ⬅️ GANTI: parameter nullable
    TipeField? fieldKetiga,                    // ⬅️ GANTI: parameter nullable
  }) {
    return NamaState(                          // ⬅️ GANTI: nama constructor
      fieldPertama: fieldPertama ?? this.fieldPertama,
      fieldKedua: fieldKedua ?? this.fieldKedua,
      fieldKetiga: fieldKetiga ?? this.fieldKetiga,
    );
  }

  // ⬇️ == dan hashCode: agar dua objek dengan nilai sama dianggap sama
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamaState &&                    // ⬅️ GANTI: nama class
          fieldPertama == other.fieldPertama &&// ⬅️ GANTI: field
          fieldKedua == other.fieldKedua &&    // ⬅️ GANTI: field
          fieldKetiga == other.fieldKetiga;    // ⬅️ GANTI: field

  @override
  int get hashCode =>
      fieldPertama.hashCode ^                  // ⬅️ GANTI: field
      fieldKedua.hashCode ^                    // ⬅️ GANTI: field
      fieldKetiga.hashCode;                    // ⬅️ GANTI: field
}

// ⬇️ Notifier class
class NamaNotifier extends Notifier<NamaState> { // ⬅️ GANTI: nama notifier + state
  @override
  NamaState build() => const NamaState();        // ⬅️ GANTI: nama state

  void aksiPertama(ParamTipe param) {            // ⬅️ GANTI: method + parameter
    state = state.copyWith(
      fieldPertama: NilaiBaru,                   // ⬅️ GANTI: field yang diupdate
    );
  }

  Future<void> aksiAsync() async {               // ⬅️ GANTI: method async (jika perlu)
    state = state.copyWith(fieldKedua: NilaiLoading);
    try {
      // ... operasi async ...
      state = state.copyWith(fieldKedua: NilaiSukses);
    } catch (e) {
      state = state.copyWith(fieldKetiga: e.toString());
    }
  }
}

final namaProvider = NotifierProvider<NamaNotifier, NamaState>(NamaNotifier.new);
//                  ⬅️ GANTI: nama notifier, nama state
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_provider.dart` | `ai_model_provider.dart` |
| State class | `NamaState` | `AiModelState` |
| Notifier class | `NamaNotifier` | `AiModelNotifier` |
| Field state | `fieldPertama` | `status` |
| Default value | `NilaiDefault` | `AiModelStatus.notDownloaded` |
| Provider name | `namaProvider` | `aiModelProvider` |

---

## Pola C: Provider dengan Mock Data (List State)

Untuk state berbasis list yang membaca mock data sebagai initial state: chat messages, product list, todo items, dll.

State class didefinisikan di file provider, dan list diisi dari class mock di `lib/mock/`.

Contoh di proyek: `ChatNotifier` + `ChatState`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/providers/namamu_provider.dart       // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/namamu.dart';             // ⬅️ GANTI: import model
import '../mock/mock_namamu.dart';          // ⬅️ GANTI: import mock

class NamaState {                           // ⬅️ GANTI: nama state class
  final List<NamaModel> items;              // ⬅️ GANTI: list field (nama model)
  final bool isGenerating;                  // ⬅️ GANTI: field opsional loading state
  final String? lastFailedItem;             // ⬅️ GANTI: field opsional error tracking

  const NamaState({                         // ⬅️ GANTI: nama constructor
    required this.items,
    this.isGenerating = false,
    this.lastFailedItem,
  });
}

class NamaNotifier extends Notifier<NamaState> { // ⬅️ GANTI: nama notifier + state
  @override
  NamaState build() {                       // ⬅️ GANTI: nama state
    return NamaState(items: MockNamamu.items);  // ⬅️ GANTI: MockNamamu → mock class
  }

  void tambahItem(NamaModel item) {         // ⬅️ GANTI: nama method, param model
    state = NamaState(                      // ⬅️ GANTI: nama state
      items: [...state.items, item],
      isGenerating: state.isGenerating,
    );
  }

  void hapusItem(String id) {               // ⬅️ GANTI: nama method, param ID
    state = NamaState(                      // ⬅️ GANTI: nama state
      items: state.items.where((e) => e.id != id).toList(),  // ⬅️ GANTI: field ID
      isGenerating: state.isGenerating,
    );
  }

  void updateItem(String id, NamaModel updated) {  // ⬅️ GANTI: nama method
    state = NamaState(                              // ⬅️ GANTI: nama state
      items: state.items.map((e) => e.id == id ? updated : e).toList(), // ⬅️ GANTI: field ID
      isGenerating: state.isGenerating,
    );
  }
}

final namaProvider = NotifierProvider<NamaNotifier, NamaState>(NamaNotifier.new);
//                  ⬅️ GANTI: nama notifier, nama state
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_provider.dart` | `chat_provider.dart` |
| Import model | `../models/namamu.dart` | `../models/message.dart` |
| Import mock | `../mock/mock_namamu.dart` | `../mock/mock_data.dart` |
| State class | `NamaState` | `ChatState` |
| Model class | `NamaModel` | `Message` |
| List field | `items` | `messages` |
| Mock class | `MockNamamu.items` | `MockData.messages` |
| Notifier class | `NamaNotifier` | `ChatNotifier` |
| Provider name | `namaProvider` | `chatProvider` |

---

## Pola D: Provider dengan Service (Real Data / API)

Untuk provider yang mengambil data dari service/API eksternal: download model, cloud AI, HTTP client, database, dll.

**Struktur file:**
- `lib/services/namamu_service.dart` — service class (logic API/IO)
- `lib/providers/namamu_provider.dart` — provider + state class

**Pola dependency injection:**
1. Buat `Provider<ServiceClass>` sebagai DI container
2. Notifier akses service lewat `ref.read(serviceProvider)`
3. Service di-mock saat testing dengan `overrideWith`

Contoh di proyek: `AiModelNotifier` + `aiModelServiceProvider`, `CloudAiConfigNotifier` + `cloudAiServiceProvider`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

### Step 1: Service class

```dart
// lib/services/namamu_service.dart          // ⬅️ GANTI: nama file
class NamaService {                          // ⬅️ GANTI: nama service class
  bool isSiap = false;                       // ⬅️ GANTI: field internal
  String? pesanError;                        // ⬅️ GANTI: field internal

  Future<bool> cekKoneksi() async {          // ⬅️ GANTI: nama method
    await Future.delayed(const Duration(milliseconds: 500));
    isSiap = true;                           // ⬅️ GANTI: logika
    return true;
  }

  Future<String> ambilData(String param) async {  // ⬅️ GANTI: nama method + param
    // ... panggil API / database ...
    return 'hasil';                          // ⬅️ GANTI: return type
  }

  void reset() {                             // ⬅️ GANTI: nama method
    isSiap = false;
    pesanError = null;
  }
}
```

### Step 2: Provider file

```dart
// lib/providers/namamu_provider.dart       // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/namamu_service.dart';    // ⬅️ GANTI: import service

// ⬇️ State class
class NamaState {                            // ⬅️ GANTI: nama state class
  final TipeStatus status;                   // ⬅️ GANTI: field status
  final String? data;                        // ⬅️ GANTI: field data (nullable)
  final String? errorMessage;                // ⬅️ GANTI: field error

  const NamaState({                          // ⬅️ GANTI: nama constructor
    this.status = NilaiDefault,              // ⬅️ GANTI: default status
    this.data,
    this.errorMessage,
  });

  NamaState copyWith({                       // ⬅️ GANTI: nama class return
    TipeStatus? status,                      // ⬅️ GANTI: parameter nullable
    String? data,
    String? errorMessage,
  }) {
    return NamaState(                        // ⬅️ GANTI: nama constructor
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NamaState &&                  // ⬅️ GANTI: nama class
          status == other.status &&
          data == other.data &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode =>
      status.hashCode ^
      data.hashCode ^
      errorMessage.hashCode;
}

// ⬇️ Service provider (dependency injection)
final namaServiceProvider = Provider<NamaService>((ref) {
  //                                   ⬅️ GANTI: nama service
  return NamaService();                 // ⬅️ GANTI: nama service
});

// ⬇️ Notifier class
class NamaNotifier extends Notifier<NamaState> {  // ⬅️ GANTI: nama notifier + state
  late final NamaService _service = ref.read(namaServiceProvider);
  //              ⬅️ GANTI: nama service                ⬅️ GANTI: service provider

  @override
  NamaState build() => const NamaState();         // ⬅️ GANTI: nama state

  Future<void> ambilData(String param) async {    // ⬅️ GANTI: method + parameter
    state = state.copyWith(errorMessage: null);
    try {
      final hasil = await _service.ambilData(param); // ⬅️ GANTI: method service
      state = state.copyWith(status: NilaiSukses, data: hasil);
      //                         ⬅️ GANTI: field yang diupdate
    } catch (e) {
      state = state.copyWith(
        status: NilaiError,                       // ⬅️ GANTI: status error
        errorMessage: e.toString(),
      );
    }
  }

  void reset() {                                  // ⬅️ GANTI: nama method
    _service.reset();                             // ⬅️ GANTI: method service
    state = const NamaState();                    // ⬅️ GANTI: nama state
  }
}

final namaProvider = NotifierProvider<NamaNotifier, NamaState>(NamaNotifier.new);
//                  ⬅️ GANTI: nama notifier, nama state
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file service | `namamu_service.dart` | `cloud_ai_service.dart` |
| Nama service class | `NamaService` | `CloudAiService` |
| Nama file provider | `namamu_provider.dart` | `cloud_ai_provider.dart` |
| State class | `NamaState` | `CloudAiConfig` |
| Service provider | `namaServiceProvider` | `cloudAiServiceProvider` |
| Notifier class | `NamaNotifier` | `CloudAiConfigNotifier` |
| Provider name | `namaProvider` | `cloudAiConfigProvider` |

---

## Ringkasan

| Pola | State Tipe | Sumber Data | Kapan Dipakai | Contoh di Proyek |
|---|---|---|---|---|
| **A** | Primitif (`bool`, `enum`, dll) | Internal | Toggle, theme, tab index | `SidebarNotifier`, `ThemeNotifier` |
| **B** | State class + copyWith | Internal | Progress, multi-field state | `AiModelNotifier` + `AiModelState` |
| **C** | State class + list | Mock (`lib/mock/`) | Prototyping CRUD list | `ChatNotifier` + `ChatState` |
| **D** | State class + service provider | Service (`lib/services/`) | API, database, real IO | `AiModelNotifier` + `aiModelServiceProvider` |

## Alur Development

```
Model                     Mock Data                Provider                  Service
─────                     ─────────                ────────                  ───────
lib/models/namamu.dart    lib/mock/mock_namamu.dart  lib/providers/...         lib/services/...
    │                          │                        │                         │
    └────────────┬──────────────┘                        │                         │
                 │          Pola C (mock list) ──────────┤                         │
                 │          Pola B (state class) ────────┤                         │
                 │          Pola A (primitive) ──────────┤                         │
                 │                                       │                         │
                 └──────────────────── Pola D (service) ─┴─────────────────────────┘
```

> Setelah provider jadi, lanjut ke [Template Test Provider](/development/provider-test-template) untuk unit testing semua pola (A/B/C/D) termasuk mock service dengan `mocktail`.
