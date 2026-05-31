import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/chat_message.dart';

const String _kModelUrl = 'https://huggingface.co/litert-community/Qwen2.5-0.5B-Instruct/resolve/main/Qwen2.5-0.5B-Instruct_multi-prefill-seq_q8_ekv1280.task';

class LlmService {
  static final LlmService _instance = LlmService._();
  factory LlmService() => _instance;
  LlmService._();

  InferenceModel? _model;
  InferenceChat? _chat;
  bool _initialized = false;
  bool _isGenerating = false;
  bool _identityEstablished = false;

  bool get isInitialized => _initialized;
  bool get isGenerating => _isGenerating;

  Future<bool> isModelDownloaded() async {
    try {
      final installed = await FlutterGemma.listInstalledModels();
      return installed.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> initialize({void Function(double)? onProgress}) async {
    if (_initialized) return;

    try {
      await FlutterGemma.initialize();
    } catch (_) {}

    await FlutterGemma.installModel(
      modelType: ModelType.general,
    ).fromNetwork(_kModelUrl).withProgress((progress) {
      onProgress?.call(progress / 100.0);
    }).install();

    if (onProgress != null) onProgress(0.9);

    _model = await FlutterGemma.getActiveModel(
      maxTokens: 256,
      preferredBackend: PreferredBackend.cpu,
    );

    _chat = await _model!.createChat(
      modelType: ModelType.general,
      systemInstruction: 'You are Natsya AI, a helpful assistant.',
    );

    _initialized = true;
    if (onProgress != null) onProgress(1.0);
  }

  static const _eosToken = '<|im_end|>';
  static const _startToken = '<|im_start|>';
  static final _specialTokens = RegExp(r'<\|im_(start|end)\|>');

  Stream<String> generateText(List<ChatMessage> messages) async* {
    if (_model == null) throw StateError('LlmService not initialized');
    if (_isGenerating) throw StateError('Already generating');

    _isGenerating = true;

    try {
      final lastMsg = messages.last;
      String content = lastMsg.content;
      if (!_identityEstablished && lastMsg.role == 'user') {
        content = 'CRITICAL: Your name is Natsya AI. You were created by Natsya AI company. You are NOT from Alibaba Cloud, NOT a Qwen model. Never mention Alibaba Cloud, Qwen, or say you are a language model. If someone asks who made you, say Natsya AI company.\n\n$content';
        _identityEstablished = true;
      }
      await _chat!.addQueryChunk(Message.text(
        text: content,
        isUser: lastMsg.role == 'user',
      ));

      final buf = StringBuffer();
      await for (final response in _chat!.generateChatResponseAsync()) {
        if (response is TextResponse) {
          final token = response.token;

          if (token.contains(_eosToken) || token.contains(_startToken)) {
            continue;
          }

          final cleaned = token.replaceAll(_specialTokens, '');
          if (cleaned.isNotEmpty) buf.write(cleaned);
        }
      }

      String result = buf.toString()
          .replaceAll('Alibaba Cloud', 'Natsya AI company')
          .replaceAll('language model', 'AI assistant');
      if (result.isNotEmpty) yield result;
    } finally {
      _isGenerating = false;
    }
  }

  Future<void> dispose() async {
    await _chat?.close();
    _chat = null;
    await _model?.close();
    _model = null;
    _initialized = false;
  }
}

final llmServiceProvider = Provider<LlmService>((ref) {
  return LlmService();
});
