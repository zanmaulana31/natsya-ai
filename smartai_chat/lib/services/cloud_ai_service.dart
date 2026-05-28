import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../models/cloud_ai_config.dart';

class CloudMessage {
  final String role;
  final String content;

  const CloudMessage({required this.role, required this.content});

  Map<String, dynamic> toJson() => {'role': role, 'content': content};
}

class CloudAiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  const CloudAiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => 'CloudAiException: $message';
}

class CloudAiService {
  CloudAiConfig _config;

  CloudAiService([CloudAiConfig? config]) : _config = config ?? const CloudAiConfig();

  CloudAiConfig get config => _config;

  void updateConfig(CloudAiConfig config) {
    _config = config;
  }

  void resetConfig() {
    _config = const CloudAiConfig();
  }

  Future<String> generateCompletion(
    List<CloudMessage> messages, {
    CloudAiConfig? config,
  }) async {
    final cfg = config ?? _config;
    final body = _buildBody(messages, cfg);

    try {
      final request = await _postRequest(cfg, body);
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      if (response.statusCode != 200) {
        throw CloudAiException(
          _parseError(responseBody, response.statusCode),
          statusCode: response.statusCode,
          body: responseBody,
        );
      }

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final choices = json['choices'] as List<dynamic>;
      if (choices.isEmpty) {
        throw const CloudAiException('Empty response from API');
      }
      final choice = choices[0] as Map<String, dynamic>;
      final message = choice['message'] as Map<String, dynamic>;
      return message['content'] as String? ?? '';
    } on SocketException catch (e) {
      throw CloudAiException('Network error: ${e.message}');
    } on HttpException catch (e) {
      throw CloudAiException('HTTP error: ${e.message}');
    } on CloudAiException {
      rethrow;
    } catch (e) {
      throw CloudAiException('Unexpected error: $e');
    }
  }

  Stream<String> generateCompletionStream(
    List<CloudMessage> messages, {
    CloudAiConfig? config,
  }) {
    final cfg = config ?? _config;
    final body = _buildBody(messages, cfg, stream: true);

    late HttpClientRequest request;
    late StreamController<String> controller;

    controller = StreamController<String>(
      onCancel: () {
        try {
          request.close();
        } catch (_) {}
      },
    );

    _postRequest(cfg, body).then((req) {
      request = req;
      req.close().then((response) {
        if (response.statusCode != 200) {
          response.transform(utf8.decoder).join().then((responseBody) {
            controller.addError(CloudAiException(
              _parseError(responseBody, response.statusCode),
              statusCode: response.statusCode,
              body: responseBody,
            ));
          });
          return;
        }

        var buffer = '';
        response.transform(utf8.decoder).listen(
          (chunk) {
            buffer += chunk;
            final lines = buffer.split('\n');
            buffer = lines.removeLast();

            for (final line in lines) {
              final trimmed = line.trim();
              if (trimmed.isEmpty || !trimmed.startsWith('data: ')) continue;
              final data = trimmed.substring(6);
              if (data == '[DONE]') {
                controller.close();
                return;
              }
              try {
                final json = jsonDecode(data) as Map<String, dynamic>;
                final choices = json['choices'] as List<dynamic>?;
                if (choices == null || choices.isEmpty) continue;
                final delta = choices[0]['delta'] as Map<String, dynamic>?;
                final content = delta?['content'] as String?;
                if (content != null && content.isNotEmpty) {
                  controller.add(content);
                }
              } catch (_) {}
            }
          },
          onDone: () {
            if (!controller.isClosed) controller.close();
          },
          onError: (error) {
            if (!controller.isClosed) {
              controller.addError(CloudAiException('Stream error: $error'));
            }
          },
        );
      }).catchError((error) {
        if (!controller.isClosed) {
          controller.addError(CloudAiException('Stream error: $error'));
        }
      });
    }).catchError((error) {
      if (!controller.isClosed) {
        controller.addError(CloudAiException('Connection failed: $error'));
      }
    });

    return controller.stream;
  }

  Map<String, dynamic> _buildBody(
    List<CloudMessage> messages,
    CloudAiConfig cfg, {
    bool stream = false,
  }) {
    return {
      'model': cfg.model,
      'messages': [
        {'role': 'system', 'content': 'You are Natsya AI, a helpful assistant.'},
        ...messages.map((m) => m.toJson()),
      ],
      'temperature': cfg.temperature,
      'max_tokens': cfg.maxTokens,
      if (stream) 'stream': true,
    };
  }

  Future<HttpClientRequest> _postRequest(CloudAiConfig cfg, Map<String, dynamic> body) async {
    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 30);

    final uri = Uri.parse('${cfg.baseUrl}/chat/completions');
    final request = await client.postUrl(uri);

    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Authorization', 'Bearer ${cfg.apiKey}');
    request.headers.set('User-Agent', 'NatsyaAI/1.0');

    request.add(utf8.encode(jsonEncode(body)));
    return request;
  }

  String _parseError(String body, int statusCode) {
    if (statusCode == 429) return 'Rate limit reached. Please wait.';
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return error?['message'] as String? ?? 'API error ($statusCode)';
    } catch (_) {
      return 'API error ($statusCode)';
    }
  }
}
