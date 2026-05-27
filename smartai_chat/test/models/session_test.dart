import 'package:flutter_test/flutter_test.dart';
import 'package:smartai_chat/models/session.dart';

void main() {
  group('ChatSession', () {
    test('creates a session with all fields', () {
      final session = const ChatSession(
        id: 's1',
        title: 'Test Session',
        isActive: true,
      );

      expect(session.id, 's1');
      expect(session.title, 'Test Session');
      expect(session.isActive, isTrue);
    });

    test('defaults isActive to false', () {
      final session = const ChatSession(
        id: 's2',
        title: 'Inactive Session',
      );

      expect(session.isActive, isFalse);
    });

    test('id is a unique string identifier', () {
      final s1 = const ChatSession(id: 'unique-id', title: 'First');
      final s2 = const ChatSession(id: 'another-id', title: 'Second');

      expect(s1.id, isNot(equals(s2.id)));
    });
  });
}
