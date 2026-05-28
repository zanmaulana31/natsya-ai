import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../providers/auth/login_provider.dart';
import '../widgets/login/google_sign_in_button.dart';
import 'chat_screen.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState is AsyncData && authState.value != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (context) => const ChatScreen(),
          ),
        );
      });
      return const SizedBox.shrink();
    }

    final typography = context.theme.typography;
    final colors = context.theme.colors;

    return FScaffold(
      header: FHeader(
        title: const Text('Welcome to Natsya AI'),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/n_logo.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 16),
              Text(
                'Natsya AI',
                style: typography.xl2,
              ),
              const SizedBox(height: 8),
              Text(
                'Your personal AI assistant',
                style: typography.sm.copyWith(
                      color: colors.mutedForeground,
                    ),
              ),
              const SizedBox(height: 32),
              const GoogleSignInButton(),
            ],
          ),
        ),
      ),
    );
  }
}
