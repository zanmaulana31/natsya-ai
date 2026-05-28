import 'package:flutter/foundation.dart';

String _envApiKey() => const String.fromEnvironment('CLOUD_API_KEY');

@immutable
class CloudAiConfig {
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int maxTokens;
  final bool enabled;

  const CloudAiConfig({
    this.baseUrl = 'https://api.publicai.co/v1',
    this.apiKey = '',
    this.model = 'swiss-ai/apertus-8b-instruct',
    this.temperature = 0.7,
    this.maxTokens = 2048,
    this.enabled = false,
  });

  CloudAiConfig copyWith({
    String? baseUrl,
    String? apiKey,
    String? model,
    double? temperature,
    int? maxTokens,
    bool? enabled,
  }) {
    return CloudAiConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
      model: model ?? this.model,
      temperature: temperature ?? this.temperature,
      maxTokens: maxTokens ?? this.maxTokens,
      enabled: enabled ?? this.enabled,
    );
  }

  /// Creates a config with the API key from --dart-define=CLOUD_API_KEY.
  /// Returns a disabled config if the env var is empty.
  factory CloudAiConfig.fromEnv() {
    final key = _envApiKey();
    return CloudAiConfig(
      apiKey: key,
      enabled: key.isNotEmpty,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudAiConfig &&
          runtimeType == other.runtimeType &&
          baseUrl == other.baseUrl &&
          apiKey == other.apiKey &&
          model == other.model &&
          temperature == other.temperature &&
          maxTokens == other.maxTokens &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      baseUrl.hashCode ^
      apiKey.hashCode ^
      model.hashCode ^
      temperature.hashCode ^
      maxTokens.hashCode ^
      enabled.hashCode;
}
