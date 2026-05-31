import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/core/llm_service.dart';

void main() {
  group('LlmService', () {
    test('is a singleton', () {
      final a = LlmService();
      final b = LlmService();
      expect(identical(a, b), isTrue);
    });

    test('initial state is not initialized', () {
      expect(LlmService().isInitialized, isFalse);
    });
  });
}
