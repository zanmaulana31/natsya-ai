import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isConsecutive;

  const MessageBubble({
    super.key,
    required this.message,
    this.isConsecutive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isUser = message.sender == MessageSender.user;
    final colors = theme.colors;

    final bgColor = isUser ? colors.primary : colors.muted;
    final textColor = isUser ? colors.primaryForeground : colors.foreground;
    final timeColor = isUser
        ? colors.primaryForeground.withValues(alpha: 0.7)
        : colors.mutedForeground;

    final borderRadius = BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isUser ? 18 : 4),
      bottomRight: Radius.circular(isUser ? 4 : 18),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isConsecutive ? 2 : 8,
        left: isUser ? 60 : 12,
        right: isUser ? 12 : 60,
      ),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: borderRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: timeColor,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
