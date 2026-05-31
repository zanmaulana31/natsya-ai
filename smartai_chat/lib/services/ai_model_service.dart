import '../models/ai_model_status.dart';
import '../models/chat_message.dart';
import '../models/completion_result.dart';
import '../core/llm_service.dart';

class AiModelService {
  final LlmService _llm;
  AiModelStatus _status = AiModelStatus.notDownloaded;
  String? _errorMessage;

  AiModelService({LlmService? llm}) : _llm = llm ?? LlmService();

  AiModelStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<void> downloadModel({void Function(double progress)? onProgress}) async {
    _status = AiModelStatus.downloading;
    _errorMessage = null;

    try {
      await _llm.initialize(onProgress: onProgress);
      _status = AiModelStatus.downloaded;
    } catch (e) {
      _status = AiModelStatus.error;
      _errorMessage = 'Model download failed: $e';
    }
  }

  Future<void> initializeModel() async {
    if (_status != AiModelStatus.downloaded) {
      throw StateError('Model must be downloaded before initialization');
    }
    _status = AiModelStatus.ready;
  }

  Future<CompletionResult> generateCompletion(
    List<ChatMessage> messages, {
    Object? params,
  }) async {
    if (_status != AiModelStatus.ready) {
      throw StateError('Model is not ready');
    }
    final buffer = StringBuffer();
    await for (final chunk in _llm.generateText(messages)) {
      buffer.write(chunk);
    }
    return CompletionResult(response: buffer.toString());
  }

  Future<StreamedCompletionResult> generateCompletionStream(
    List<ChatMessage> messages, {
    Object? params,
  }) async {
    if (_status != AiModelStatus.ready) {
      throw StateError('Model is not ready');
    }
    final stream = _llm.generateText(messages);
    return StreamedCompletionResult(stream: stream);
  }

  Future<bool> isDownloaded() async {
    try {
      return await _llm.isModelDownloaded();
    } catch (_) {
      return false;
    }
  }

  void unload() {
    _llm.dispose();
    _status = AiModelStatus.notDownloaded;
    _errorMessage = null;
  }

  void dispose() {
    unload();
  }
}
