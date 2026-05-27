import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartai_chat/models/ai_model_status.dart';
import 'package:smartai_chat/services/ai_model_service.dart';

class MockAiModelService extends Mock implements AiModelService {}

void main() {
  group('AiModelStatus', () {
    test('has exactly 6 enum values', () {
      expect(AiModelStatus.values.length, 6);
    });

    test('contains all expected values', () {
      expect(AiModelStatus.values, containsAllInOrder([
        AiModelStatus.notDownloaded,
        AiModelStatus.downloading,
        AiModelStatus.downloaded,
        AiModelStatus.initializing,
        AiModelStatus.ready,
        AiModelStatus.error,
      ]));
    });

    test('status can jump to error from any state', () {
      // Error is a valid enum value regardless of current state
      const error = AiModelStatus.error;
      expect(error, isA<AiModelStatus>());
    });
  });
}
