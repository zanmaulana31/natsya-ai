# Template Mock Data

Mock data adalah data palsu yang dipakai sebelum backend/API siap — buat prototyping UI dan unit testing.

Konvensi proyek:
- File di `lib/mock/`
- Gunakan class dengan `static get` (bukan `static final`) agar setiap akses dapat list baru, aman dari mutasi
- Provider membaca mock sebagai initial state

> **Prasyarat**: model sudah jadi. Kalau belum, baca [Template Model](/development/model-template) dulu.

---

## 1. Mock Data

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/mock/mock_namamu.dart               // ⬅️ GANTI: nama file
import '../models/namamu.dart';             // ⬅️ GANTI: import model yang dipakai

class MockNamamu {                          // ⬅️ GANTI: nama class mock (awali "Mock")
  static List<NamaModel> get items => [     // ⬅️ GANTI: NamaModel → class model kamu
    NamaModel(                              // ⬅️ GANTI: constructor model
      id: '1',                              // ⬅️ GANTI: ID unik (string/angka)
      judul: 'Isi data pertama',            // ⬅️ GANTI: isi field sesuai model
      waktu: DateTime(2026, 5, 23, 9, 0),   // ⬅️ GANTI: timestamp
      status: StatusPilihan.nilai1,         // ⬅️ GANTI: enum value (hapus jika tidak ada)
      isActive: true,                       // ⬅️ GANTI: field opsional
    ),
    // ⬇️ Tambah item (minimal 5 untuk test yang valid)
    NamaModel(                              // ⬅️ GANTI
      id: '2',                              // ⬅️ GANTI: ID unik
      judul: 'Isi data kedua',              // ⬅️ GANTI
      waktu: DateTime(2026, 5, 23, 10, 0),  // ⬅️ GANTI
      status: StatusPilihan.nilai2,         // ⬅️ GANTI
    ),
    NamaModel(                              // ⬅️ GANTI
      id: '3',                              // ⬅️ GANTI
      judul: 'Isi data ketiga',             // ⬅️ GANTI
      waktu: DateTime(2026, 5, 23, 11, 0),  // ⬅️ GANTI
      status: StatusPilihan.nilai1,         // ⬅️ GANTI
    ),
    // ... tambah sampai minimal 5 item
  ];
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `mock_namamu.dart` | `mock_product.dart` |
| Import model | `import '../models/namamu.dart';` | `import '../models/product.dart';` |
| Nama class mock | `MockNamamu` | `MockProduct` |
| Model di return type | `List<NamaModel>` | `List<Product>` |
| Nama getter | `get items` | `get products` |
| Constructor model | `NamaModel(` | `Product(` |
| Isi field | `judul: '...'` | `name: 'Kopi Susu'` |

### Aturan Khusus Mock Data Chat (Conversation)

Kalau mock untuk chat/percakapan, ikuti aturan ini:

1. **Mulai dengan AI/system** — pesan pertama harus greeting dari AI
2. **Alternating sender** — AI → User → AI → User → ...
3. **Timestamp multi-jam** — jarak antar pesan 2 menit sampai 60 menit
4. **Pesan natural** — konten terasa seperti percakapan nyata, bukan lorem ipsum

```dart
// lib/mock/mock_chat.dart
import '../models/message.dart';

class MockChat {
  static List<Message> get messages {
    final now = DateTime.now();
    return [
      // 1. AI greeting (selalu pertama)
      Message(
        id: '1',
        text: 'Halo! Ada yang bisa saya bantu?',      // ⬅️ GANTI: teks natural
        timestamp: now.subtract(const Duration(hours: 5)),
        sender: MessageSender.ai,
      ),
      // 2. User menjawab
      Message(
        id: '2',
        text: 'Saya mau tanya tentang...',             // ⬅️ GANTI: teks natural
        timestamp: now.subtract(const Duration(hours: 4, minutes: 58)),
        sender: MessageSender.user,
      ),
      // 3. AI merespon — jeda 28 menit (waktu "berpikir")
      Message(
        id: '3',
        text: 'Tentu, ini penjelasannya...',           // ⬅️ GANTI: teks natural
        timestamp: now.subtract(const Duration(hours: 4, minutes: 30)),
        sender: MessageSender.ai,
      ),
      // ... lanjut alternating sampai minimal 10 pesan
    ];
  }
}
```

---

## 2. Sambungkan ke Provider

Provider membaca mock sebagai initial state di method `build()`.

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/providers/namamu_provider.dart       // ⬅️ GANTI: nama file
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/namamu.dart';             // ⬅️ GANTI: import model
import '../mock/mock_namamu.dart';          // ⬅️ GANTI: import mock

class NamaState {                           // ⬅️ GANTI: nama state class
  final List<NamaModel> items;              // ⬅️ GANTI: field sesuai model

  const NamaState({required this.items});   // ⬅️ GANTI: constructor
}

class NamaNotifier extends Notifier<NamaState> { // ⬅️ GANTI: nama notifier + state
  @override
  NamaState build() {                       // ⬅️ GANTI: nama state
    return NamaState(items: MockNamamu.items); // ⬅️ GANTI: MockNamamu → mock class kamu
  }
}

final namaProvider = NotifierProvider<NamaNotifier, NamaState>(NamaNotifier.new);
//                  ⬅️ GANTI: nama notifier, nama state
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_provider.dart` | `product_provider.dart` |
| Import model | `../models/namamu.dart` | `../models/product.dart` |
| Import mock | `../mock/mock_namamu.dart` | `../mock/mock_product.dart` |
| State class | `NamaState` | `ProductState` |
| Field state | `List<NamaModel> items` | `List<Product> products` |
| Notifier class | `NamaNotifier` | `ProductNotifier` |
| Mock class | `MockNamamu.items` | `MockProduct.products` |
| Provider name | `namaProvider` | `productProvider` |

---

## 3. Testing

Unit test verifikasi mock data valid sebelum dipakai di widget test. Jalankan dengan `flutter test test/mock/`.

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// test/mock/mock_namamu_test.dart          // ⬅️ GANTI: nama file
import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/mock/mock_namamu.dart'; // ⬅️ GANTI: import mock
import 'package:smartai_chat/models/namamu.dart';     // ⬅️ GANTI: import model (jika perlu)

void main() {
  group('MockNamamu', () {                  // ⬅️ GANTI: nama mock class
    test('menyediakan minimal 5 item', () {
      expect(MockNamamu.items.length, greaterThanOrEqualTo(5));
      //              ⬅️ GANTI: mock class
    });

    test('semua item punya ID unik', () {
      final ids = MockNamamu.items.map((e) => e.id).toSet();
      //               ⬅️ GANTI: mock class               ⬅️ GANTI: field ID
      expect(ids.length, MockNamamu.items.length);
      //                        ⬅️ GANTI: mock class
    });

    test('semua item punya field wajib tidak kosong', () {
      for (final item in MockNamamu.items) {
        //                    ⬅️ GANTI: mock class
        expect(item.judul, isNotEmpty);         // ⬅️ GANTI: field yang wajib diisi
      }
    });

    test('item pertama adalah item yang diharapkan', () {
      final first = MockNamamu.items.first;
      //                 ⬅️ GANTI: mock class
      expect(first.judul, contains('data pertama')); // ⬅️ GANTI: isi field pertama
    });

    test('urutan item sesuai timestamp (ascending)', () {
      final items = MockNamamu.items;
      //                ⬅️ GANTI: mock class
      for (int i = 1; i < items.length; i++) {
        expect(
          items[i].waktu.isAfter(items[i - 1].waktu), // ⬅️ GANTI: field timestamp
          isTrue,
        );
      }
    });
  });
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file test | `mock_namamu_test.dart` | `mock_product_test.dart` |
| Import mock | `mock_namamu.dart` | `mock_product.dart` |
| Import model | `namamu.dart` | `product.dart` |
| Nama mock class | `MockNamamu` | `MockProduct` |
| Field ID di `.map()` | `e.id` | `e.productId` |
| Field wajib dicek | `item.judul` | `item.name` |
| Field pertama dicek | `contains('data pertama')` | `contains('Kopi')` |
| Field timestamp di loop | `items[i].waktu` | `items[i].createdAt` |

### Jalankan Test

```bash
flutter test test/mock/mock_namamu_test.dart   # ⬅️ GANTI: path file test
```

---

## Ringkasan Flow

```
Model                   Mock Data               Provider               Testing
─────                   ─────────               ────────               ───────
lib/models/namamu.dart  lib/mock/mock_namamu.dart  lib/providers/...   test/mock/...
    ↓                        ↓                        ↓                    ↓
Template Model          Template Mock Data        Template Provider     Template Test
(Sebelum halaman ini)   (Section 1)               (provider-template.md)(Section 3)
```
