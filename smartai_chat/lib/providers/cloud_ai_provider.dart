import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cloud_ai_config.dart';
import '../services/cloud_ai_service.dart';

final cloudAiConfigProvider = NotifierProvider<CloudAiConfigNotifier, CloudAiConfig>(
  CloudAiConfigNotifier.new,
);

final cloudAiServiceProvider = Provider<CloudAiService>((ref) {
  final config = ref.watch(cloudAiConfigProvider);
  final service = CloudAiService(config);
  ref.onDispose(() {});
  return service;
});

class CloudAiConfigNotifier extends Notifier<CloudAiConfig> {
  @override
  CloudAiConfig build() => CloudAiConfig.fromEnv();

  void setApiKey(String key) {
    state = state.copyWith(apiKey: key, enabled: key.isNotEmpty);
  }

  void setProvider(String baseUrl, String model, String apiKey) {
    state = state.copyWith(
      baseUrl: baseUrl,
      model: model,
      apiKey: apiKey,
      enabled: apiKey.isNotEmpty,
    );
  }

  void disable() {
    state = state.copyWith(enabled: false);
  }
}
