import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_model_status.dart';
import '../models/chat_message.dart';
import '../models/completion_result.dart';
import '../services/ai_model_service.dart';
import '../services/notification_service.dart';

class AiModelState {
  final AiModelStatus status;
  final double? downloadProgress;
  final String? errorMessage;

  const AiModelState({
    this.status = AiModelStatus.notDownloaded,
    this.downloadProgress,
    this.errorMessage,
  });

  AiModelState copyWith({
    AiModelStatus? status,
    double? downloadProgress,
    String? errorMessage,
  }) {
    return AiModelState(
      status: status ?? this.status,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AiModelState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          downloadProgress == other.downloadProgress &&
          errorMessage == other.errorMessage;

  @override
  int get hashCode => status.hashCode ^ downloadProgress.hashCode ^ errorMessage.hashCode;
}

final aiModelServiceProvider = Provider<AiModelService>((ref) {
  return AiModelService();
});

class AiModelNotifier extends Notifier<AiModelState> {
  late final AiModelService _serviceInstance = ref.read(aiModelServiceProvider);
  bool _hasNotified = false;

  @override
  AiModelState build() {
    Future.microtask(() async {
      try {
        if (await _serviceInstance.isDownloaded()) {
          state = const AiModelState(status: AiModelStatus.ready);
        }
      } catch (_) {
      }
    });
    return const AiModelState(status: AiModelStatus.notDownloaded);
  }

  Future<void> downloadAndInit() async {
    await _serviceInstance.downloadModel(
      onProgress: (progress) {
        state = state.copyWith(
          status: AiModelStatus.downloading,
          downloadProgress: progress,
        );
      },
    );

    if (_serviceInstance.status == AiModelStatus.error) {
      state = state.copyWith(
        status: AiModelStatus.error,
        errorMessage: _serviceInstance.errorMessage,
      );
      return;
    }

    state = state.copyWith(status: AiModelStatus.downloaded);

    await _serviceInstance.initializeModel();

    if (_serviceInstance.status == AiModelStatus.error) {
      state = state.copyWith(
        status: AiModelStatus.error,
        errorMessage: _serviceInstance.errorMessage,
      );
      return;
    }

    state = state.copyWith(status: AiModelStatus.ready);

    if (!_hasNotified) {
      _hasNotified = true;
      await NotificationService.instance.showModelReadyNotification();
    }
  }

  void unloadModel() {
    _serviceInstance.unload();
    state = const AiModelState(status: AiModelStatus.notDownloaded);
  }

  Future<CompletionResult> generate(String userMessage) async {
    return await _serviceInstance.generateCompletion([
      ChatMessage(content: userMessage, role: 'user'),
    ]);
  }
}

final aiModelProvider = NotifierProvider<AiModelNotifier, AiModelState>(
  AiModelNotifier.new,
);
