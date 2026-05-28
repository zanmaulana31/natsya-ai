import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser, AuthException;

import '../../models/auth/auth_session.dart';
import '../../models/auth/auth_user.dart';
import 'auth_exceptions.dart';

class LoginService {
  final SupabaseClient _client;
  final GoogleSignIn _googleSignIn;

  LoginService(this._client)
      : _googleSignIn = GoogleSignIn(
          scopes: [
            'email',
            'openid',
            'profile',
          ],
        );

  Future<AuthUser> signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw OAuthCancelledException();
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw AuthException('Google ID Token tidak ditemukan.');
      }

      await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = _client.auth.currentUser;
      if (user == null) {
        throw AuthException('Gagal mendapatkan user setelah sign-in.');
      }

      final authUser = AuthUser(
        id: user.id,
        email: user.email!,
        isActive: true,
        provider: 'google',
        displayName: user.userMetadata?['full_name'] as String?,
        photoUrl: user.userMetadata?['avatar_url'] as String?,
      );

      await _client.from('users').upsert(authUser.toJson());

      return authUser;
    } on OAuthCancelledException catch (_) {
      rethrow;
    } on AuthException catch (_) {
      rethrow;
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  AuthUser? getCurrentUser() {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    return AuthUser(
      id: user.id,
      email: user.email!,
      isActive: true,
      provider: 'google',
      displayName: user.userMetadata?['full_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
    );
  }

  AuthSession? getCurrentSession() {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    return AuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken ?? '',
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        (session.expiresAt ?? 0) * 1000,
      ),
    );
  }

  Future<AuthSession> refreshSession() async {
    try {
      final response = await _client.auth.refreshSession();
      final session = response.session;

      if (session == null) {
        throw AuthException('Failed to refresh session');
      }

      return AuthSession(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken ?? '',
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          (session.expiresAt ?? 0) * 1000,
        ),
      );
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  Stream<AuthUser?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      if (user == null) return null;

      return AuthUser(
        id: user.id,
        email: user.email!,
        isActive: true,
        provider: 'google',
        displayName: user.userMetadata?['full_name'] as String?,
        photoUrl: user.userMetadata?['avatar_url'] as String?,
      );
    });
  }
}
