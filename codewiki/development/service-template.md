# Template Service

Service adalah layer yang menangani operasi I/O: API call, database, file system, download, notifikasi, dll. Service dipanggil oleh provider melalui dependency injection (lihat [Pola D - Provider Template](/development/provider-template#pola-d-provider-dengan-service-real-data--api)).

Konvensi proyek:
- 1 file per service di `lib/services/`
- Service class tidak extend Riverpod apapun — pure Dart class
- Service di-inject ke provider lewat `Provider<ServiceClass>` (DI)

> **Prasyarat**: model sudah jadi. Kalau belum, baca [Template Model](/development/model-template) dulu.

---

## Pola A: Service Sederhana (Stateless / Config-based)

Untuk service yang tidak punya state internal, hanya menerima config lalu memproses: API client, HTTP wrapper, dll.

Contoh di proyek: `CloudAiService`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/services/namamu_service.dart           // ⬅️ GANTI: nama file
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/namamu_config.dart';         // ⬅️ GANTI: import model config (jika perlu)

// ⬇️ Custom exception class (opsional — hapus jika tidak perlu)
class NamaException implements Exception {     // ⬅️ GANTI: nama exception class
  final String message;
  final int? statusCode;

  const NamaException(this.message, {this.statusCode});
  //    ⬅️ GANTI: nama constructor

  @override
  String toString() => 'NamaException: $message';
  //                      ⬅️ GANTI: nama exception
}

class NamaService {                            // ⬅️ GANTI: nama service class
  NamaConfig _config;                          // ⬅️ GANTI: config model (atau hapus)

  NamaService([NamaConfig? config])
  // ⬅️ GANTI: constructor + param
      : _config = config ?? const NamaConfig();
      //              ⬅️ GANTI: config default

  NamaConfig get config => _config;
  // ⬅️ GANTI: getter config

  void updateConfig(NamaConfig config) {       // ⬅️ GANTI: method update config
    _config = config;
  }

  void resetConfig() {                         // ⬅️ GANTI: method reset config
    _config = const NamaConfig();
    //            ⬅️ GANTI: config default
  }

  /// ⬇️ Method utama: async operasi
  Future<ReturnType> operasiUtama(             // ⬅️ GANTI: nama method + return type
    ParameterType param, {                     // ⬅️ GANTI: parameter
    NamaConfig? config,                        // ⬅️ GANTI: config override (opsional)
  }) async {
    final cfg = config ?? _config;

    try {
      // ... panggil API / proses data ...
      return hasil;                            // ⬅️ GANTI: return value
    } on SocketException catch (e) {
      throw NamaException('Network error: ${e.message}');
      //       ⬅️ GANTI: exception class
    } on NamaException {
      rethrow;                                 // ⬅️ GANTI: exception class
    } catch (e) {
      throw NamaException('Unexpected error: $e');
      //       ⬅️ GANTI: exception class
    }
  }

  /// ⬇️ Method stream (opsional — hapus jika tidak perlu)
  Stream<String> operasiStream(                // ⬅️ GANTI: nama method
    ParameterType param, {                     // ⬅️ GANTI: parameter
    NamaConfig? config,                        // ⬅️ GANTI: config override
  }) {
    // ... return stream ...
  }

  /// ⬇️ Method private helper
  Map<String, dynamic> _buildBody(             // ⬅️ GANTI: nama helper method
    ParameterType param,
    NamaConfig cfg,
  ) {
    return {
      // ... build request body ...
    };
  }
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_service.dart` | `cloud_ai_service.dart` |
| Exception class | `NamaException` | `CloudAiException` |
| Service class | `NamaService` | `CloudAiService` |
| Config model | `NamaConfig` | `CloudAiConfig` |
| Method utama | `operasiUtama()` | `generateCompletion()` |
| Method stream | `operasiStream()` | `generateCompletionStream()` |

---

## Pola B: Service dengan State Internal

Untuk service yang punya state internal (status, error, initialized flag) dan lifecycle management: download model, database connection, file manager, dll.

Contoh di proyek: `AiModelService`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/services/namamu_service.dart           // ⬅️ GANTI: nama file
import 'dart:async';
import 'dart:io';

import '../models/namamu_status.dart';         // ⬅️ GANTI: import status enum (jika perlu)

class NamaService {                            // ⬅️ GANTI: nama service class
  // ⬇️ State internal
  TipeStatus _status = StatusDefault;          // ⬅️ GANTI: status enum + default
  String? _errorMessage;                       // ⬅️ GANTI: error tracking

  TipeStatus get status => _status;            // ⬅️ GANTI: getter status
  String? get errorMessage => _errorMessage;   // ⬅️ GANTI: getter error

  NamaService({Dependency? dep}) : _dep = dep; // ⬅️ GANTI: constructor + DI param

  /// ⬇️ Inisialisasi / koneksi
  Future<void> inisialisasi() async {          // ⬅️ GANTI: nama method
    _status = StatusLoading;                   // ⬅️ GANTI: status loading
    _errorMessage = null;

    try {
      // ... inisialisasi / connect ...
      _status = StatusSiap;                    // ⬅️ GANTI: status sukses
    } catch (e) {
      _status = StatusError;                   // ⬅️ GANTI: status error
      _errorMessage = 'Init failed: $e';
    }
  }

  /// ⬇️ Operasi utama
  Future<ReturnType> operasiUtama(             // ⬅️ GANTI: nama method + return type
    ParameterType param,
  ) async {
    if (_status != StatusSiap) {               // ⬅️ GANTI: guard clause
      throw StateError('Service not ready');
    }

    try {
      // ... operasi ...
      return hasil;
    } catch (e) {
      _status = StatusError;                   // ⬅️ GANTI: set error state
      _errorMessage = 'Operasi gagal: $e';
      rethrow;
    }
  }

  /// ⬇️ Reset / cleanup
  void reset() {                               // ⬅️ GANTI: nama method reset
    _status = StatusDefault;                   // ⬅️ GANTI: reset ke default
    _errorMessage = null;
  }

  /// ⬇️ Dispose untuk Riverpod onDispose
  void dispose() {                             // ⬅️ GANTI: nama method dispose
    reset();
    // ... cleanup resources ...
  }
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_service.dart` | `ai_model_service.dart` |
| Service class | `NamaService` | `AiModelService` |
| Status enum | `TipeStatus` | `AiModelStatus` |
| Status default | `StatusDefault` | `AiModelStatus.notDownloaded` |
| Status siap | `StatusSiap` | `AiModelStatus.ready` |
| Method init | `inisialisasi()` | `downloadModel()` / `initializeModel()` |
| Method utama | `operasiUtama()` | `generateCompletion()` |
| Method reset | `reset()` | `unload()` |
| Method dispose | `dispose()` | `dispose()` |

---

## Pola C: Service Singleton

Untuk service yang hanya butuh 1 instance global: notification, analytics, logging, shared preferences, dll.

Contoh di proyek: `NotificationService`

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/services/namamu_service.dart           // ⬅️ GANTI: nama file
import 'package:some_package/some_package.dart'; // ⬅️ GANTI: import dependency

class NamaService {                            // ⬅️ GANTI: nama service class
  // ⬇️ Singleton instance
  static final NamaService instance = NamaService._internal();
  //               ⬅️ GANTI: nama class

  NamaService._internal();                    // ⬅️ GANTI: private constructor

  // ⬇️ Dependencies internal
  final SomePlugin _plugin = SomePlugin();     // ⬅️ GANTI: plugin/dependency

  bool _initialized = false;

  /// ⬇️ Inisialisasi (guard agar tidak double-init)
  Future<void> initialize() async {           // ⬅️ GANTI: nama method init
    if (_initialized) return;

    // ... setup plugin, permission, config ...
    _initialized = true;
  }

  /// ⬇️ Operasi (dengan guard init)
  Future<void> operasi() async {              // ⬅️ GANTI: nama method
    if (!_initialized) return;

    // ... eksekusi operasi ...
  }
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_service.dart` | `notification_service.dart` |
| Service class | `NamaService` | `NotificationService` |
| Dependency | `SomePlugin` | `FlutterLocalNotificationsPlugin` |
| Method init | `initialize()` | `initialize()` |
| Method operasi | `operasi()` | `showModelReadyNotification()` |

---

## Pola D: Service dengan Exception Kustom + Model Data

Untuk service yang perlu exception class sendiri dan model data internal: API dengan response model, parsing JSON, dll.

Contoh di proyek: `CloudAiService` (punya `CloudMessage` + `CloudAiException`)

**Kode — copy paste, lalu ganti yang ditandai `⬅️ GANTI`:**

```dart
// lib/services/namamu_service.dart           // ⬅️ GANTI: nama file
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/namamu_config.dart';         // ⬅️ GANTI: import config (jika perlu)

// ⬇️ Model data internal service (opsional — jika perlu type khusus)
class NamaMessage {                           // ⬅️ GANTI: nama model class
  final String role;
  final String content;

  const NamaMessage({required this.role, required this.content});
  //    ⬅️ GANTI: constructor

  Map<String, dynamic> toJson() => {           // ⬅️ GANTI: serialisasi (jika perlu)
    'role': role,
    'content': content,
  };
}

// ⬇️ Exception custom
class NamaException implements Exception {     // ⬅️ GANTI: nama exception class
  final String message;
  final int? statusCode;
  final String? body;

  const NamaException(                         // ⬅️ GANTI: constructor
    this.message, {
    this.statusCode,
    this.body,
  });

  @override
  String toString() => 'NamaException: $message';
  //                      ⬅️ GANTI: nama exception
}

class NamaService {                            // ⬅️ GANTI: nama service class
  NamaConfig _config;                          // ⬅️ GANTI: config

  NamaService([NamaConfig? config])
  // ⬅️ GANTI: constructor
      : _config = config ?? const NamaConfig();

  // ⬇️ Method utama (complete response)
  Future<String> operasiUtama(                 // ⬅️ GANTI: nama method + return type
    List<NamaMessage> messages, {             // ⬅️ GANTI: param (model)
    NamaConfig? config,
  }) async {
    final cfg = config ?? _config;
    final body = _buildBody(messages, cfg);

    try {
      final request = await _postRequest(cfg, body);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw NamaException(                   // ⬅️ GANTI: exception class
          _parseError(responseBody, response.statusCode),
          statusCode: response.statusCode,
          body: responseBody,
        );
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      return _parseResponse(json);             // ⬅️ GANTI: parse response
    } on SocketException catch (e) {
      throw NamaException('Network error: ${e.message}');
      //       ⬅️ GANTI: exception class
    } on NamaException {
      rethrow;                                 // ⬅️ GANTI: exception class
    } catch (e) {
      throw NamaException('Unexpected error: $e');
      //       ⬅️ GANTI: exception class
    }
  }

  // ⬇️ Method stream (opsional)
  Stream<String> operasiStream(                // ⬅️ GANTI: nama method
    List<NamaMessage> messages, {             // ⬅️ GANTI: param
    NamaConfig? config,
  }) {
    // ... return stream ...
  }

  // ⬇️ Private helpers
  Map<String, dynamic> _buildBody(             // ⬅️ GANTI: nama helper
    List<NamaMessage> messages,               // ⬅️ GANTI: tipe model
    NamaConfig cfg, {                         // ⬅️ GANTI: tipe config
    bool stream = false,
  }) {
    return {
      // ... build body ...
    };
  }

  Future<HttpClientRequest> _postRequest(      // ⬅️ GANTI: nama helper
    NamaConfig cfg,                           // ⬅️ GANTI: tipe config
    Map<String, dynamic> body,
  ) async {
    // ... build + return request ...
  }

  String _parseError(String body, int statusCode) {  // ⬅️ GANTI: nama helper
    // ... parse error response ...
  }

  String _parseResponse(Map<String, dynamic> json) { // ⬅️ GANTI: nama helper
    // ... parse success response ...
  }
}
```

| Bagian yang diganti | Contoh sebelum | Contoh sesudah |
|---|---|---|
| Nama file | `namamu_service.dart` | `cloud_ai_service.dart` |
| Model internal | `NamaMessage` | `CloudMessage` |
| Exception class | `NamaException` | `CloudAiException` |
| Service class | `NamaService` | `CloudAiService` |
| Config model | `NamaConfig` | `CloudAiConfig` |
| Method utama | `operasiUtama()` | `generateCompletion()` |
| Method stream | `operasiStream()` | `generateCompletionStream()` |
| Private helper | `_postRequest()` | `_postRequest()` |
| Parse response | `_parseResponse()` | (inline di `generateCompletion`) |
| Parse error | `_parseError()` | `_parseError()` |

---

## Ringkasan

| Pola | State | Kapan Dipakai | Contoh di Proyek |
|---|---|---|---|
| **A** | Stateless (config-based) | API client, HTTP wrapper | `CloudAiService` |
| **B** | State internal (status, error) | Download, DB connection, lifecycle panjang | `AiModelService` |
| **C** | Singleton | Notifikasi, analytics, shared prefs | `NotificationService` |
| **D** | Exception + model internal | API parsing kompleks, banyak error type | `CloudAiService` |

> **Catatan**: Pola bisa dikombinasikan. Misalnya `CloudAiService` adalah kombinasi A + D (config-based + exception custom + model internal).

## Alur Development

```
Model                          Service                         Provider
─────                          ───────                         ────────
lib/models/namamu_config.dart  lib/services/namamu_service.dart  lib/providers/namamu_provider.dart
    │                                │                                │
    └─── Config di-inject ──────────┘                                │
                                     │                                │
                                     └─── Service di-inject ─────────┘
                                     via Provider<ServiceClass>       via ref.read(serviceProvider)
```

> Setelah service jadi, lanjut ke [Template Provider - Pola D](/development/provider-template#pola-d-provider-dengan-service-real-data--api) untuk menghubungkan service ke provider, lalu ke [Template Test Provider - Pola D](/development/provider-test-template#test-untuk-pola-d-service--real-data--dengan-mocktail) untuk testing dengan `mocktail`.
