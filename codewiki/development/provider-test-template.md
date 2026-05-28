# Template Test Provider

Unit test provider menggunakan `ProviderContainer` — cepat, terisolasi, tidak butuh widget tree.

Konvensi proyek:
- File test di `test/providers/`
- Nama file test: `<nama>_provider_test.dart`
- Gunakan `ProviderContainer` + `addTearDown(container.dispose)`
- Service di-mock dengan `mocktail` (`overrideWith`)

> **Prasyarat**: provider sudah jadi. Kalau belum, baca [Template Provider](/development/provider-template) dulu.

Jalankan test:

```bash
flutter test test/providers/namamu_provider_test.dart   # ⬅️ GANTI: path
flutter test test/providers/                              # semua test provider
```

---

## Test untuk Pola A (Primitive State)

Contoh di proyek: `sidebar_provider_test.dart`, `theme_provider_test.dart`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// test/providers/namamu_provider_test.dart  // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/providers/namamu_provider.dart'; // ⬅️ GANTI: import

void main() {
  group('NamaNotifier', () {                   // ⬅️ GANTI: nama notifier
    test('initial state adalah nilai default', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(namaProvider), NilaiDefault);
      //                     ⬅️ GANTI: provider name + expected value
    });

    test('aksiPertama mengubah state', () {    // ⬅️ GANTI: nama method
      final container = ProviderContainer();
      addTearDown(container.dispose);

      container.read(namaProvider.notifier).aksiPertama();
      //                 ⬅️ GANTI: provider name + method name
      expect(container.read(namaProvider), NilaiBaru);
      //              ⬅️ GANTI: provider name + expected value
    });

    test('state bolak-balik toggle', () {      // ⬅️ GANTI: jika ada toggle
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(namaProvider.notifier);
      //                                ⬅️ GANTI: provider name

      notifier.aksiToggler();                  // ⬅️ GANTI: method toggle
      expect(container.read(namaProvider), NilaiSetelahToggle);
      //              ⬅️ GANTI: provider + expected value

      notifier.aksiToggler();                  // ⬅️ GANTI: method toggle
      expect(container.read(namaProvider), NilaiDefault);
      //              ⬅️ GANTI: kembali ke default
    });
  });
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file test | `namamu_provider_test.dart` | `sidebar_provider_test.dart` |
| Import provider | `namamu_provider.dart` | `sidebar_provider.dart` |
| Nama notifier | `NamaNotifier` | `SidebarNotifier` |
| Provider name | `namaProvider` | `sidebarProvider` |
| Nilai default | `NilaiDefault` | `false` |
| Method toggle | `aksiToggler()` | `toggle()` |

---

## Test untuk Pola B (State Class + copyWith)

Contoh di proyek: `ai_model_provider_test.dart`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// test/providers/namamu_provider_test.dart  // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/providers/namamu_provider.dart'; // ⬅️ GANTI: import

void main() {
  group('NamaNotifier', () {                   // ⬅️ GANTI: nama notifier
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state dengan nilai default', () {
      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.fieldPertama, NilaiDefault);
      //         ⬅️ GANTI: field + expected value
      expect(state.fieldKetiga, isNull);
      //         ⬅️ GANTI: nullable field
    });

    test('aksiPertama mengupdate field', () {  // ⬅️ GANTI: nama method
      container.read(namaProvider.notifier).aksiPertama(param);
      //            ⬅️ GANTI: provider name + method + param

      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.fieldPertama, NilaiBaru);
      //         ⬅️ GANTI: field + expected value
    });

    test('aksiAsync sukses update state', () async {
      await container.read(namaProvider.notifier).aksiAsync();
      //                     ⬅️ GANTI: provider name + method

      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.fieldKedua, NilaiSukses);
      //         ⬅️ GANTI: field + expected value
      expect(state.fieldKetiga, isNull);
      //         ⬅️ GANTI: error harus null saat sukses
    });

    test('state immutable (copyWith buat objek baru)', () {
      final stateBefore = container.read(namaProvider);
      //                                   ⬅️ GANTI: provider name

      container.read(namaProvider.notifier).aksiPertama(param);
      //                ⬅️ GANTI: provider + method

      final stateAfter = container.read(namaProvider);
      //                                   ⬅️ GANTI: provider name
      expect(identical(stateBefore, stateAfter), isFalse);
    });
  });
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file test | `namamu_provider_test.dart` | `ai_model_provider_test.dart` |
| Import provider | `namamu_provider.dart` | `ai_model_provider.dart` |
| Nama notifier | `NamaNotifier` | `AiModelNotifier` |
| Provider name | `namaProvider` | `aiModelProvider` |
| Field status | `fieldPertama` | `status` |
| Field error | `fieldKetiga` | `errorMessage` |

---

## Test untuk Pola C (Mock Data / List State)

Contoh di proyek: `chat_provider_test.dart`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// test/providers/namamu_provider_test.dart  // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/providers/namamu_provider.dart'; // ⬅️ GANTI: import
import 'package:smartai_chat/models/namamu.dart';             // ⬅️ GANTI: import model

void main() {
  group('NamaNotifier', () {                   // ⬅️ GANTI: nama notifier
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state berisi mock data', () {
      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.items, isNotEmpty);
      //         ⬅️ GANTI: field list
      expect(state.items.length, greaterThanOrEqualTo(5));
      //         ⬅️ GANTI: minimal 5 item
      expect(state.isGenerating, isFalse);
      //         ⬅️ GANTI: loading state default
    });

    test('semua item punya ID unik', () {
      final items = container.read(namaProvider).items;
      //                                ⬅️ GANTI: provider + field list
      final ids = items.map((e) => e.id).toSet();
      //                               ⬅️ GANTI: field ID
      expect(ids.length, items.length);
    });

    test('tambahItem menambah item ke list', () {  // ⬅️ GANTI: nama method
      final notifier = container.read(namaProvider.notifier);
      //                                   ⬅️ GANTI: provider name
      final lengthBefore = container.read(namaProvider).items.length;
      //                                      ⬅️ GANTI: provider + field list

      notifier.tambahItem(NamaModel(/* ... */));
      //         ⬅️ GANTI: method + model constructor

      expect(container.read(namaProvider).items.length, lengthBefore + 1);
      //                       ⬅️ GANTI: provider + field list
    });

    test('hapusItem menghapus item dari list', () {  // ⬅️ GANTI: nama method
      final notifier = container.read(namaProvider.notifier);
      //                                   ⬅️ GANTI: provider name
      final firstId = container.read(namaProvider).items.first.id;
      //                                   ⬅️ GANTI: provider + field list + field ID

      notifier.hapusItem(firstId);              // ⬅️ GANTI: method + param
      final ids = container.read(namaProvider).items.map((e) => e.id);
      //                            ⬅️ GANTI: provider + field list + field ID
      expect(ids, isNot(contains(firstId)));
    });

    test('updateItem mengupdate item yang ada', () {  // ⬅️ GANTI: nama method
      final notifier = container.read(namaProvider.notifier);
      //                                   ⬅️ GANTI: provider name
      final firstItem = container.read(namaProvider).items.first;
      //                                      ⬅️ GANTI: provider + field list

      final updated = firstItem.copyWith(judul: 'Updated');
      //                             ⬅️ GANTI: copyWith model (jika ada)
      notifier.updateItem(firstItem.id, updated);
      //         ⬅️ GANTI: method + params

      final newFirst = container.read(namaProvider).items.first;
      //                                    ⬅️ GANTI: provider + field list
      expect(newFirst.judul, 'Updated');
      //           ⬅️ GANTI: field + expected value
    });
  });
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file test | `namamu_provider_test.dart` | `chat_provider_test.dart` |
| Import provider | `namamu_provider.dart` | `chat_provider.dart` |
| Import model | `namamu.dart` | `message.dart` |
| Nama notifier | `NamaNotifier` | `ChatNotifier` |
| Provider name | `namaProvider` | `chatProvider` |
| Field list | `state.items` | `state.messages` |
| Field ID | `e.id` | `e.id` |
| Model constructor | `NamaModel(...)` | `Message(...)` |
| Model copyWith | `firstItem.copyWith(...)` | *(jika model punya copyWith)* |

---

## Test untuk Pola D (Service / Real Data) — dengan mocktail

Provider yang bergantung ke service harus di-test dengan mock service agar test cepat dan terisolasi.

Library: `mocktail` (cek `pubspec.yaml` untuk `dev_dependencies`)

Contoh di proyek: `ai_model_provider_test.dart` (mock `AiModelService`)

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// test/providers/namamu_provider_test.dart  // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartai_chat/providers/namamu_provider.dart'; // ⬅️ GANTI: import provider
import 'package:smartai_chat/services/namamu_service.dart';    // ⬅️ GANTI: import service

// ⬇️ Mock service class
class MockNamaService extends Mock implements NamaService {}
//         ⬅️ GANTI: nama mock class      ⬅️ GANTI: nama service

void main() {
  group('NamaNotifier', () {                   // ⬅️ GANTI: nama notifier
    late MockNamaService mockService;          // ⬅️ GANTI: nama mock class
    late ProviderContainer container;

    setUp(() {
      mockService = MockNamaService();         // ⬅️ GANTI: nama mock class

      // ⬇️ Setup default mock behavior
      when(() => mockService.cekKoneksi()).thenAnswer((_) async => true);
      //              ⬅️ GANTI: method service + return mock

      container = ProviderContainer(
        overrides: [
          namaServiceProvider.overrideWith((ref) => mockService),
          // ⬅️ GANTI: service provider        ⬅️ GANTI: mock variable
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state dengan nilai default', () {
      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.status, NilaiDefault);
      //         ⬅️ GANTI: field status + expected
      expect(state.errorMessage, isNull);
    });

    test('ambilData sukses update state', () async {
      //        ⬅️ GANTI: nama method
      when(() => mockService.ambilData(any())).thenAnswer((_) async => 'hasil mock');
      //              ⬅️ GANTI: method service + param  ⬅️ GANTI: return mock

      await container.read(namaProvider.notifier).ambilData('test');
      //                      ⬅️ GANTI: provider + method notifier

      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.status, NilaiSukses);
      //         ⬅️ GANTI: field + expected sukses
      expect(state.data, 'hasil mock');
      //         ⬅️ GANTI: field data + expected

      verify(() => mockService.ambilData('test')).called(1);
      //             ⬅️ GANTI: verifikasi method service dipanggil
    });

    test('ambilData gagal set error state', () async {
      //        ⬅️ GANTI: nama method
      when(() => mockService.ambilData(any())).thenThrow(Exception('Gagal koneksi'));
      //              ⬅️ GANTI: method service            ⬅️ GANTI: error message

      await container.read(namaProvider.notifier).ambilData('test');
      //                      ⬅️ GANTI: provider + method

      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.status, NilaiError);
      //         ⬅️ GANTI: field + expected error status
      expect(state.errorMessage, contains('Gagal koneksi'));
      //         ⬅️ GANTI: field error + expected message
    });

    test('reset panggil service.reset() dan reset state', () async {
      //        ⬅️ GANTI: nama method reset

      // Setup state sukses dulu
      when(() => mockService.ambilData(any())).thenAnswer((_) async => 'data');
      //              ⬅️ GANTI: method service
      await container.read(namaProvider.notifier).ambilData('test');
      //                      ⬅️ GANTI: provider + method

      // Reset
      container.read(namaProvider.notifier).reset();
      //                ⬅️ GANTI: provider + method reset

      verify(() => mockService.reset()).called(1);
      //             ⬅️ GANTI: verifikasi service.reset() dipanggil

      final state = container.read(namaProvider);
      //                              ⬅️ GANTI: provider name
      expect(state.status, NilaiDefault);
      //         ⬅️ GANTI: field + expected default
      expect(state.data, isNull);
    });
  });

  group('namaProvider', () {                   // ⬅️ GANTI: nama provider
    test('menyediakan NamaNotifier', () {      // ⬅️ GANTI: nama notifier
      final container = ProviderContainer();
      final notifier = container.read(namaProvider.notifier);
      //                                  ⬅️ GANTI: provider name
      expect(notifier, isA<NamaNotifier>());
      //                     ⬅️ GANTI: nama notifier
      container.dispose();
    });
  });
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file test | `namamu_provider_test.dart` | `ai_model_provider_test.dart` |
| Import provider | `namamu_provider.dart` | `ai_model_provider.dart` |
| Import service | `namamu_service.dart` | `ai_model_service.dart` |
| Mock class | `MockNamaService` | `MockAiModelService` |
| Service class | `NamaService` | `AiModelService` |
| Service provider | `namaServiceProvider` | `aiModelServiceProvider` |
| Nama notifier | `NamaNotifier` | `AiModelNotifier` |
| Provider name | `namaProvider` | `aiModelProvider` |
| Method service | `ambilData()` | `downloadModel()` |
| Method notifier | `ambilData()` | `downloadAndInit()` |
| Method verifikasi | `verify(() => mockService.ambilData(...))` | `verify(() => mockService.downloadModel(...))` |

### Aturan mocktail

```dart
// Method async → .thenAnswer
when(() => mockService.methodAsync()).thenAnswer((_) async => returnValue);

// Method async dengan parameter → any() atau nilai spesifik
when(() => mockService.methodAsync(any())).thenAnswer((_) async => returnValue);
when(() => mockService.methodAsync('spesifik')).thenAnswer((_) async => returnValue);

// Method sync → .thenReturn
when(() => mockService.status).thenReturn(StatusEnum.nilai);

// Method throw error → .thenThrow
when(() => mockService.methodAsync()).thenThrow(Exception('pesan error'));

// Verifikasi method dipanggil
verify(() => mockService.methodAsync()).called(1);
verifyNever(() => mockService.methodAsync());
```

---

## Ringkasan Test per Pola

| Pola | Setup | Library Mock | Contoh Test File |
|---|---|---|---|
| **A** | `ProviderContainer()` | tidak perlu | `sidebar_provider_test.dart` |
| **B** | `ProviderContainer()` | tidak perlu | `ai_model_provider_test.dart` (bagian tanpa mock) |
| **C** | `ProviderContainer()` | tidak perlu (data dari mock class) | `chat_provider_test.dart` |
| **D** | `ProviderContainer(overrides: [...])` | `mocktail` | `ai_model_provider_test.dart` |

## Checklist Test Wajib

- [ ] Initial state sesuai default
- [ ] Setiap public method di-notifier di-test (sukses + error)
- [ ] State immutable (objek stateBefore ≠ stateAfter setelah update)
- [ ] Semua item di list punya ID unik (Pola C)
- [ ] Service method dipanggil dengan benar via `verify()` (Pola D)
- [ ] Error handling: field `errorMessage` terisi saat gagal
- [ ] Container di-dispose di `tearDown` / `addTearDown`
