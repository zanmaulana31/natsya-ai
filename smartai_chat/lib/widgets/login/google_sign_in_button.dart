import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import '../../providers/auth/login_provider.dart';
import '../../services/auth/auth_exceptions.dart';

class GoogleSignInButton extends ConsumerWidget {
  const GoogleSignInButton({super.key});

  String? _extractErrorMessage(Object? error) {
    if (error is AuthException) return error.message;
    if (error is OAuthCancelledException) return error.message;
    return error?.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;
    final errorMessage = authState.hasError
        ? _extractErrorMessage(authState.error)
        : null;

    final typography = context.theme.typography;
    final colors = context.theme.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FButton(
          onPress: isLoading
              ? null
              : () => ref.read(authProvider.notifier).signInWithGoogle(),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.login,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Sign in with Google',
                      style: typography.sm,
                    ),
                  ],
                ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: errorMessage != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Text(
                    errorMessage,
                    style: typography.sm.copyWith(
                      color: colors.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
