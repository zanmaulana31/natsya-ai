import 'dart:async';

import 'package:cactus/cactus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_model_status.dart';
import '../models/message.dart';
import '../mock/mock_data.dart';
import '../services/ai_model_service.dart';
import '../services/cloud_ai_service.dart';
import 'ai_model_provider.dart';
import 'cloud_ai_provider.dart';

enum AiResponseMode { stream, complete }

class ChatState {
  final List<Message> messages;
  final bool isGenerating;
  final String? lastFailedMessage;

  const ChatState({
    required this.messages,
    this.isGenerating = false,
    this.lastFailedMessage,
  });
}

class ChatNotifier extends Notifier<ChatState> {
  StreamSubscription<String>? _streamSubscription;

  @override
  ChatState build() {
    ref.onDispose(() {
      _streamSubscription?.cancel();
    });
    return ChatState(messages: MockData.messages);
  }

  Future<void> sendMessage(String text, {AiResponseMode mode = AiResponseMode.complete}) async {
    if (text.trim().isEmpty) return;
    if (state.isGenerating) return;

    final userMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      sender: MessageSender.user,
    );

    state = ChatState(
      messages: [...state.messages, userMessage],
      isGenerating: true,
      lastFailedMessage: null,
    );

    final cloudConfig = ref.read(cloudAiConfigProvider);
    if (cloudConfig.enabled) {
      try {
        if (mode == AiResponseMode.stream) {
          await _generateStreamCloud(text.trim());
        } else {
          await _generateCompleteCloud(text.trim());
        }
      } catch (e) {
        _appendError('Cloud AI failed: $e', text.trim());
      }
      return;
    }

    final modelState = ref.read(aiModelProvider);
    if (modelState.status != AiModelStatus.ready) {
      _appendError('Model is not ready yet. Please wait for initialization to complete.', text.trim());
      return;
    }

    final service = ref.read(aiModelServiceProvider);

    try {
      if (mode == AiResponseMode.stream) {
        await _generateStream(service, text.trim());
      } else {
        await _generateComplete(service, text.trim());
      }
    } catch (e) {
      _appendError('Failed to generate response: $e', text.trim());
    }
  }

  Future<void> _generateStream(AiModelService service, String originalText) async {
    final placeholder = Message(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: '',
      timestamp: DateTime.now(),
      sender: MessageSender.ai,
    );

    state = ChatState(
      messages: [...state.messages, placeholder],
      isGenerating: true,
      lastFailedMessage: null,
    );

    try {
      final result = await service.generateCompletionStream(_buildContext());
      _streamSubscription = result.stream.listen(
        (token) {
          final updatedMessages = [...state.messages];
          final lastIdx = updatedMessages.length - 1;
          final existing = updatedMessages[lastIdx];
          updatedMessages[lastIdx] = Message(
            id: existing.id,
            text: existing.text + token,
            timestamp: existing.timestamp,
            sender: MessageSender.ai,
          );
          state = ChatState(
            messages: updatedMessages,
            isGenerating: true,
            lastFailedMessage: null,
          );
        },
        onDone: () {
          _streamSubscription = null;
          final msgs = [...state.messages];
          if (msgs.isNotEmpty && msgs.last.text.isEmpty && msgs.last.sender == MessageSender.ai) {
            msgs.removeLast();
          }
          state = ChatState(
            messages: msgs,
            isGenerating: false,
            lastFailedMessage: null,
          );
        },
        onError: (error) {
          _streamSubscription = null;
          _appendError('Failed to generate response: $error', originalText);
        },
      );
    } catch (e) {
      final msgs = [...state.messages];
      if (msgs.isNotEmpty && msgs.last.text.isEmpty && msgs.last.sender == MessageSender.ai) {
        msgs.removeLast();
      }
      state = ChatState(messages: msgs, isGenerating: false);
      _appendError('Failed to generate response: $e', originalText);
    }
  }

  Future<void> _generateComplete(AiModelService service, String originalText) async {
    try {
      final result = await service.generateCompletion(_buildContext());
      final aiMessage = Message(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: result.response,
        timestamp: DateTime.now(),
        sender: MessageSender.ai,
      );
      state = ChatState(
        messages: [...state.messages, aiMessage],
        isGenerating: false,
        lastFailedMessage: null,
      );
    } catch (e) {
      _appendError('Failed to generate response: $e', originalText);
    }
  }

  Future<void> _generateCompleteCloud(String originalText) async {
    final service = ref.read(cloudAiServiceProvider);
    final cloudMessages = _buildCloudContext();
    try {
      final result = await service.generateCompletion(cloudMessages);
      final aiMessage = Message(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        text: result,
        timestamp: DateTime.now(),
        sender: MessageSender.ai,
      );
      state = ChatState(
        messages: [...state.messages, aiMessage],
        isGenerating: false,
        lastFailedMessage: null,
      );
    } catch (e) {
      _appendError('Cloud AI failed: $e', originalText);
    }
  }

  Future<void> _generateStreamCloud(String originalText) async {
    final service = ref.read(cloudAiServiceProvider);
    final cloudMessages = _buildCloudContext();
    final placeholder = Message(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      text: '',
      timestamp: DateTime.now(),
      sender: MessageSender.ai,
    );

    state = ChatState(
      messages: [...state.messages, placeholder],
      isGenerating: true,
      lastFailedMessage: null,
    );

    try {
      final stream = service.generateCompletionStream(cloudMessages);
      _streamSubscription = stream.listen(
        (token) {
          final updatedMessages = [...state.messages];
          final lastIdx = updatedMessages.length - 1;
          final existing = updatedMessages[lastIdx];
          updatedMessages[lastIdx] = Message(
            id: existing.id,
            text: existing.text + token,
            timestamp: existing.timestamp,
            sender: MessageSender.ai,
          );
          state = ChatState(
            messages: updatedMessages,
            isGenerating: true,
            lastFailedMessage: null,
          );
        },
        onDone: () {
          _streamSubscription = null;
          final msgs = [...state.messages];
          if (msgs.isNotEmpty && msgs.last.text.isEmpty && msgs.last.sender == MessageSender.ai) {
            msgs.removeLast();
          }
          state = ChatState(
            messages: msgs,
            isGenerating: false,
            lastFailedMessage: null,
          );
        },
        onError: (error) {
          _streamSubscription = null;
          _appendError('Cloud AI failed: $error', originalText);
        },
      );
    } catch (e) {
      final msgs = [...state.messages];
      if (msgs.isNotEmpty && msgs.last.text.isEmpty && msgs.last.sender == MessageSender.ai) {
        msgs.removeLast();
      }
      state = ChatState(messages: msgs, isGenerating: false);
      _appendError('Cloud AI failed: $e', originalText);
    }
  }

  void cancelGeneration() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    state = ChatState(
      messages: state.messages,
      isGenerating: false,
      lastFailedMessage: state.lastFailedMessage,
    );
  }

  void retry() {
    final lastFailed = state.lastFailedMessage;
    if (lastFailed == null) return;

    final msgs = [...state.messages];
    if (msgs.isNotEmpty && msgs.last.isError) {
      msgs.removeLast();
    }

    state = ChatState(
      messages: msgs,
      isGenerating: false,
      lastFailedMessage: null,
    );

    sendMessage(lastFailed);
  }

  void _appendError(String errorText, String originalText) {
    final errorMsg = Message(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      text: errorText,
      timestamp: DateTime.now(),
      sender: MessageSender.ai,
      isError: true,
    );
    state = ChatState(
      messages: [...state.messages, errorMsg],
      isGenerating: false,
      lastFailedMessage: originalText,
    );
  }

  List<ChatMessage> _buildContext() {
    final msgs = state.messages.where((m) => !m.isError).toList();
    const maxChars = 8000;
    int totalChars = 0;
    final result = <ChatMessage>[];

    for (final m in msgs.reversed) {
      final role = m.sender == MessageSender.user ? 'user' : 'assistant';
      final chars = m.text.length + role.length + 4;
      if (totalChars + chars > maxChars && result.isNotEmpty) break;
      totalChars += chars;
      result.insert(0, ChatMessage(content: m.text, role: role));
    }

    return result;
  }

  List<CloudMessage> _buildCloudContext() {
    final msgs = state.messages.where((m) => !m.isError).toList();
    const maxChars = 32000;
    int totalChars = 0;
    final result = <CloudMessage>[];

    for (final m in msgs.reversed) {
      final role = m.sender == MessageSender.user ? 'user' : 'assistant';
      final chars = m.text.length + role.length + 4;
      if (totalChars + chars > maxChars && result.isNotEmpty) break;
      totalChars += chars;
      result.insert(0, CloudMessage(role: role, content: m.text));
    }

    return result;
  }
}

final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);
