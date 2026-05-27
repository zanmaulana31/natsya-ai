import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/message.dart';
import '../mock/mock_data.dart';

class ChatNotifier extends Notifier<List<Message>> {
  @override
  List<Message> build() => MockData.messages;

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final message = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      timestamp: DateTime.now(),
      sender: MessageSender.user,
    );

    state = [...state, message];
  }
}

final chatProvider = NotifierProvider<ChatNotifier, List<Message>>(ChatNotifier.new);
