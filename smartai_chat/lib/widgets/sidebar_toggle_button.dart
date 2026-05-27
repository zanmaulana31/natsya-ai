import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../providers/sidebar_provider.dart';

class SidebarToggleButton extends ConsumerWidget {
  const SidebarToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(sidebarProvider);
    final colors = context.theme.colors;

    return Container(
      width: 28,
      height: 52,
      decoration: BoxDecoration(
        color: colors.muted.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(1, 0),
          ),
        ],
      ),
      child: Center(
        child: AnimatedRotation(
          turns: isOpen ? 0.5 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: Icon(
            Icons.chevron_right,
            size: 18,
            color: colors.mutedForeground,
          ),
        ),
      ),
    );
  }
}
