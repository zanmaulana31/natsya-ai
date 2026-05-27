import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../mock/mock_sessions.dart';

class Sidebar extends ConsumerWidget {
  const Sidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.theme.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.background,
        border: Border(
          right: BorderSide(
            color: colors.muted.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _BrandHeader(colors: colors),
          const SizedBox(height: 8),
          _SessionList(colors: colors),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  final FColors colors;

  const _BrandHeader({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colors.muted.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                'N',
                style: TextStyle(
                  color: colors.primaryForeground,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Natsya Ai',
            style: TextStyle(
              color: colors.foreground,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final FColors colors;

  const _SessionList({required this.colors});

  @override
  Widget build(BuildContext context) {
    final sessions = MockSessions.sessions;

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: sessions.length,
        separatorBuilder: (_, _) => const SizedBox(height: 2),
        itemBuilder: (context, index) {
          final session = sessions[index];

          return _SessionItem(
            title: session.title,
            isActive: session.isActive,
            colors: colors,
          );
        },
      ),
    );
  }
}

class _SessionItem extends StatelessWidget {
  final String title;
  final bool isActive;
  final FColors colors;

  const _SessionItem({
    required this.title,
    required this.isActive,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: isActive ? colors.primary.withValues(alpha: 0.08) : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          Text(
            title,
            style: TextStyle(
              color: isActive ? colors.primary : colors.mutedForeground,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
          if (isActive)
            Positioned(
              left: 0,
              right: 0,
              bottom: -6,
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      colors.primary.withValues(alpha: 0.0),
                      colors.primary.withValues(alpha: 0.4),
                      colors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.25),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
