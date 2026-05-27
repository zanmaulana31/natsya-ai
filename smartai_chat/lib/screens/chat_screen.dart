import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../providers/chat_provider.dart';
import '../providers/sidebar_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input.dart';
import '../widgets/sidebar.dart';
import '../widgets/sidebar_toggle_button.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _scrollController = ScrollController();
  bool _isNearBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final nearBottom = (maxScroll - currentScroll) < 100;
    if (nearBottom != _isNearBottom) {
      setState(() => _isNearBottom = nearBottom);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);
    final themeMode = ref.watch(themeProvider);
    final isSidebarOpen = ref.watch(sidebarProvider);

    ref.listen(chatProvider, (prev, next) {
      if (_isNearBottom && prev != null && next.length > prev.length) {
        _scrollToBottom();
      }
    });

    return Stack(
      children: [
        FScaffold(
          header: FHeader(
            title: const Text('Chat with Natsya'),
            suffixes: [
              FHeaderAction(
                icon: Icon(
                  themeMode == ThemeMode.light
                      ? Icons.dark_mode_outlined
                      : Icons.light_mode_outlined,
                ),
                onPress: () => ref.read(themeProvider.notifier).toggle(),
              ),
            ],
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isConsecutive = index > 0 &&
                        messages[index - 1].sender == message.sender;

                    return MessageBubble(
                      message: message,
                      isConsecutive: isConsecutive,
                    );
                  },
                ),
              ),
              const MessageInput(),
            ],
          ),
        ),
        AnimatedPositioned(
          left: isSidebarOpen ? 0 : -260,
          top: 0,
          bottom: 0,
          width: 260,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: const Sidebar(),
        ),
        Positioned(
          left: isSidebarOpen ? 260 : 0,
          top: 0,
          bottom: 0,
          child: Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => ref.read(sidebarProvider.notifier).toggle(),
              child: const SidebarToggleButton(),
            ),
          ),
        ),
      ],
    );
  }
}
