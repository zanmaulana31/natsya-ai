import 'package:cactus/cactus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ai_model_status.dart';
import '../services/ai_model_service.dart';
import '../services/notification_service.dart';

/// Immutable state for the AI model lifecycle.
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

/// Provider for the AI model service (dependency injection).
final aiModelServiceProvider = Provider<AiModelService>((ref) {
  return AiModelService();
});

/// Notifier that orchestrates model download, initialization, and inference.
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
        // If the check fails, remain in notDownloaded state
      }
    });
    return const AiModelState(status: AiModelStatus.notDownloaded);
  }

  /// Downloads and initializes the model, updating state at each step.
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

    // Show local notification once when model is ready
    if (!_hasNotified) {
      _hasNotified = true;
      await NotificationService.instance.showModelReadyNotification();
    }
  }

  /// Unloads the model and resets state.
  void unloadModel() {
    _serviceInstance.unload();
    state = const AiModelState(status: AiModelStatus.notDownloaded);
  }

  /// Generates a completion for a single user message.
  Future<CactusCompletionResult> generate(String userMessage) async {
    return await _serviceInstance.generateCompletion([
      ChatMessage(content: userMessage, role: 'user'),
    ]);
  }
}

/// Riverpod provider for the AI model state.
final aiModelProvider = NotifierProvider<AiModelNotifier, AiModelState>(
  AiModelNotifier.new,
);
