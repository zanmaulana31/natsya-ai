import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../providers/chat_provider.dart';

class MessageInput extends ConsumerStatefulWidget {
  final bool isGenerating;
  final VoidCallback? onCancel;

  const MessageInput({
    super.key,
    this.isGenerating = false,
    this.onCancel,
  });

  @override
  ConsumerState<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends ConsumerState<MessageInput> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() => _hasText = value.trim().isNotEmpty);
  }

  void _onSend() {
    final text = _controller.text;
    if (text.trim().isEmpty) return;

    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    setState(() => _hasText = false);
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          top: BorderSide(
            color: colors.muted.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
        top: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: FTextField(
              hint: 'Message',
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              enabled: !widget.isGenerating,
              control: FTextFieldControl.managed(
                controller: _controller,
                onChange: (value) => _onChanged(value.text),
              ),
              onSubmit: widget.isGenerating ? null : (_) => _onSend(),
            ),
          ),
          const SizedBox(width: 8),
          if (widget.isGenerating)
            _StopButton(onTap: widget.onCancel, colors: colors)
          else
            _SendButton(
              active: _hasText,
              onTap: _hasText ? _onSend : null,
              colors: colors,
            ),
        ],
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool active;
  final VoidCallback? onTap;
  final FColors colors;

  const _SendButton({
    required this.active,
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: active ? colors.primary : colors.muted,
        ),
        child: Center(
          child: Icon(
            Icons.arrow_upward,
            color: active ? colors.primaryForeground : colors.mutedForeground,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _StopButton extends StatelessWidget {
  final VoidCallback? onTap;
  final FColors colors;

  const _StopButton({
    required this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.destructive,
        ),
        child: const Center(
          child: Icon(
            Icons.stop_rounded,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}
