import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/mock/mock_sessions.dart';

void main() {
  group('MockSessions', () {
    test('provides at least 5 sessions', () {
      expect(MockSessions.sessions.length, greaterThanOrEqualTo(5));
    });

    test('has exactly one active session', () {
      final active = MockSessions.sessions.where((s) => s.isActive);
      expect(active.length, 1);
    });

    test('all sessions have non-empty titles', () {
      for (final session in MockSessions.sessions) {
        expect(session.title, isNotEmpty);
      }
    });

    test('all sessions have unique ids', () {
      final ids = MockSessions.sessions.map((s) => s.id).toSet();
      expect(ids.length, MockSessions.sessions.length);
    });

    test('first session is the active one', () {
      expect(MockSessions.sessions.first.isActive, isTrue);
    });
  });
}
