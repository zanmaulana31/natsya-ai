import '../models/session.dart';

class MockSessions {
  static List<ChatSession> get sessions => [
    const ChatSession(id: 's1', title: 'Flutter Development Help', isActive: true),
    const ChatSession(id: 's2', title: 'Project Planning Discussion'),
    const ChatSession(id: 's3', title: 'Bug Fixing Session'),
    const ChatSession(id: 's4', title: 'Code Review'),
    const ChatSession(id: 's5', title: 'UI Design Ideas'),
  ];
}
