import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../models/ai_model_status.dart';
import '../providers/ai_model_provider.dart';
import '../providers/cloud_ai_provider.dart';
import '../screens/chat_screen.dart';

class ModelLoadingScreen extends ConsumerStatefulWidget {
  const ModelLoadingScreen({super.key});

  @override
  ConsumerState<ModelLoadingScreen> createState() =>
      _ModelLoadingScreenState();
}

class _ModelLoadingScreenState extends ConsumerState<ModelLoadingScreen> {
  bool _didNavigate = false;
  bool _userChoseLocal = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cloudConfig = ref.read(cloudAiConfigProvider);
      if (cloudConfig.enabled && !_userChoseLocal) {
        _navigateToChat();
      }
    });
  }

  void _navigateToChat() {
    if (_didNavigate) return;
    _didNavigate = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  void _useCloud() {
    _navigateToChat();
  }

  void _downloadLocal() {
    _userChoseLocal = true;
    ref.read(aiModelProvider.notifier).downloadAndInit();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    ref.listen(aiModelProvider, (_, next) {
      if (next.status == AiModelStatus.ready && _userChoseLocal) {
        _navigateToChat();
      }
    });

    final modelState = ref.watch(aiModelProvider);
    final showChoice =
        modelState.status == AiModelStatus.notDownloaded && !_userChoseLocal;

    return Scaffold(
      backgroundColor: colors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/n_logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 24),
            Text(
              'Preparing Natsya AI',
              style: typography.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.foreground,
              ),
            ),
            const SizedBox(height: 32),
            if (showChoice)
              _ChoiceSection(
                onUseCloud: _useCloud,
                onDownloadLocal: _downloadLocal,
              ),
            if (!showChoice && modelState.status != AiModelStatus.error)
              _ProgressSection(state: modelState),
            if (modelState.status == AiModelStatus.error)
              _ErrorSection(
                errorMessage: modelState.errorMessage,
                onRetry: () {
                  _userChoseLocal = true;
                  ref.read(aiModelProvider.notifier).downloadAndInit();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceSection extends StatelessWidget {
  final VoidCallback onUseCloud;
  final VoidCallback onDownloadLocal;

  const _ChoiceSection({
    required this.onUseCloud,
    required this.onDownloadLocal,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose how to use Natsya AI',
          style: typography.sm.copyWith(color: colors.mutedForeground),
        ),
        const SizedBox(height: 24),
        FButton(
          key: const Key('model_choice_cloud'),
          onPress: onUseCloud,
          child: const Text('Use Cloud AI'),
        ),
        const SizedBox(height: 12),
        FButton(
          key: const Key('model_choice_local'),
          onPress: onDownloadLocal,
          child: const Text('Download Local Model'),
        ),
      ],
    );
  }
}

class _ProgressSection extends StatelessWidget {
  final AiModelState state;

  const _ProgressSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    final isDeterminate = state.status == AiModelStatus.downloading &&
        state.downloadProgress != null;

    String statusText;
    if (state.status == AiModelStatus.downloading &&
        state.downloadProgress != null) {
      statusText =
          'Downloading AI model... ${(state.downloadProgress! * 100).toInt()}%';
    } else if (state.status == AiModelStatus.initializing ||
        state.status == AiModelStatus.downloaded) {
      statusText = 'Initializing AI model...';
    } else {
      statusText = 'Preparing...';
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 280,
          height: 6,
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(3)),
            child: LinearProgressIndicator(
              key: const Key('model_loading_progress'),
              value: isDeterminate ? state.downloadProgress : null,
              backgroundColor: colors.muted.withValues(alpha: 0.3),
              valueColor: AlwaysStoppedAnimation(colors.primary),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          statusText,
          style: typography.sm.copyWith(color: colors.mutedForeground),
        ),
      ],
    );
  }
}

class _ErrorSection extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _ErrorSection({
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;
    final typography = context.theme.typography;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Something went wrong',
          style: typography.sm.copyWith(
            color: colors.errorForeground,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        if (errorMessage != null)
          Text(
            errorMessage!,
            key: const Key('model_loading_error'),
            style: typography.sm.copyWith(color: colors.mutedForeground),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        const SizedBox(height: 24),
        FButton(
          key: const Key('model_loading_retry'),
          onPress: onRetry,
          child: const Text('Try Again'),
        ),
      ],
    );
  }
}
