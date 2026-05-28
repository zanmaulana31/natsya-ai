import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser, AuthException;

import '../../models/auth/auth_user.dart';
import '../../services/auth/auth_exceptions.dart';
import '../../services/auth/login_service.dart';

final loginServiceProvider = Provider<LoginService>((ref) {
  return LoginService(Supabase.instance.client);
});

class AuthNotifier extends AsyncNotifier<AuthUser?> {
  late final LoginService _loginService;
  StreamSubscription<AuthUser?>? _sub;

  @override
  Future<AuthUser?> build() async {
    _loginService = ref.watch(loginServiceProvider);

    _sub?.cancel();
    _sub = _loginService.authStateChanges.listen(
      (user) => state = AsyncValue.data(user),
      onError: (err, st) => state = AsyncValue.error(err, st),
    );

    ref.onDispose(() => _sub?.cancel());

    return _loginService.getCurrentUser();
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final user = await _loginService.signInWithGoogle();
      state = AsyncValue.data(user);
    } on OAuthCancelledException catch (_) {
      state = AsyncValue.error(
        OAuthCancelledException('Masuk dengan Google dibatalkan.'),
        StackTrace.current,
      );
    } on AuthException catch (_) {
      state = AsyncValue.error(
        AuthException('Gagal masuk. Silakan coba lagi nanti.'),
        StackTrace.current,
      );
    } catch (e, st) {
      state = AsyncValue.error(
        AuthException('Koneksi internet bermasalah. Periksa jaringan Anda.'),
        st,
      );
    }
  }

  void clearError() {
    state = AsyncValue.data(_loginService.getCurrentUser());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthUser?>(
  AuthNotifier.new,
);
