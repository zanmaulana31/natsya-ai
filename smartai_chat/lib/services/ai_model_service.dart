import 'dart:async';
import 'dart:io';

import 'package:cactus/cactus.dart';

import '../models/ai_model_status.dart';

/// Model slug for the Cactus LFM 2 350M model (smaller, for compatibility).
const String _modelSlug = 'lfm2-350m';

/// Encapsulates all Cactus LM operations for the LFM 2 350M model.
class AiModelService {
  CactusLM? _lm;
  AiModelStatus _status = AiModelStatus.notDownloaded;
  String? _errorMessage;

  AiModelStatus get status => _status;
  String? get errorMessage => _errorMessage;

  AiModelService({CactusLM? lm}) : _lm = lm;

  /// Downloads the LFM 2 350M model.
  ///
  /// Retries once on transient network errors.
  Future<void> downloadModel({void Function(double progress)? onProgress}) async {
    _status = AiModelStatus.downloading;
    _errorMessage = null;

    Future<void> doDownload() async {
      final lm = _lm ?? CactusLM();
      _lm = lm;
      await lm.downloadModel(
        model: _modelSlug,
        downloadProcessCallback: (progress, status, isError) {
          if (progress != null) {
            onProgress?.call(progress);
          }
        },
      );
    }

    try {
      await doDownload();
      _status = AiModelStatus.downloaded;
    } on SocketException catch (_) {
      try {
        await doDownload();
        _status = AiModelStatus.downloaded;
      } catch (e) {
        _status = AiModelStatus.error;
        _errorMessage = 'Model download failed: $e';
      }
    } on TimeoutException catch (_) {
      try {
        await doDownload();
        _status = AiModelStatus.downloaded;
      } catch (e) {
        _status = AiModelStatus.error;
        _errorMessage = 'Model download failed: $e';
      }
    } catch (e) {
      _status = AiModelStatus.error;
      _errorMessage = 'Model download failed: $e';
    }
  }

  /// Initializes the downloaded model for inference.
  Future<void> initializeModel() async {
    if (_status != AiModelStatus.downloaded) {
      throw StateError('Model must be downloaded before initialization');
    }

    _status = AiModelStatus.initializing;
    _errorMessage = null;

    try {
      await _lm!.initializeModel(
        params: CactusInitParams(
          model: _modelSlug,
          contextSize: 2048,
        ),
      );
      _status = AiModelStatus.ready;
    } catch (e) {
      _status = AiModelStatus.error;
      _errorMessage = 'Model initialization failed: $e';
    }
  }

  /// Generates a text completion using the loaded model.
  Future<CactusCompletionResult> generateCompletion(
    List<ChatMessage> messages, {
    CactusCompletionParams? params,
  }) async {
    if (_status != AiModelStatus.ready) {
      throw StateError('Model is not ready');
    }
    return await _lm!.generateCompletion(
      messages: messages,
      params: params,
    );
  }

  /// Generates a streaming text completion using the loaded model.
  Future<CactusStreamedCompletionResult> generateCompletionStream(
    List<ChatMessage> messages, {
    CactusCompletionParams? params,
  }) async {
    if (_status != AiModelStatus.ready) {
      throw StateError('Model is not ready');
    }
    return await _lm!.generateCompletionStream(
      messages: messages,
      params: params,
    );
  }

  /// Fetches metadata for the LFM 2 350M model.
  Future<CactusModel?> getModelInfo() async {
    final lm = _lm ?? CactusLM();
    _lm ??= lm;
    final models = await lm.getModels();
    for (final model in models) {
      if (model.slug == _modelSlug) return model;
    }
    return null;
  }

  /// Returns whether the model is already downloaded locally.
  Future<bool> isDownloaded() async {
    try {
      final info = await getModelInfo();
      return info?.isDownloaded ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Unloads the model from memory and resets status.
  void unload() {
    _lm?.unload();
    _status = AiModelStatus.notDownloaded;
    _errorMessage = null;
  }

  /// Disposes the service for Riverpod compatibility.
  void dispose() {
    unload();
  }
}
