import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser, AuthException;

import '../../models/auth/auth_session.dart';
import '../../models/auth/auth_user.dart';
import 'auth_exceptions.dart';

class LoginService {
  final SupabaseClient _client;
  late final GoogleSignIn _googleSignIn;

  LoginService(this._client) {
    final webClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID']?.trim();
    final dartDefineClientId =
        const String.fromEnvironment('GOOGLE_WEB_CLIENT_ID').trim();
    final effectiveClientId = (webClientId?.isNotEmpty ?? false)
        ? webClientId
        : (dartDefineClientId.isNotEmpty ? dartDefineClientId : null);

    _googleSignIn = GoogleSignIn(
      scopes: [
        'email',
        'openid',
        'profile',
      ],
      serverClientId: effectiveClientId,
    );
  }

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
        throw AuthException(
          'Google ID Token tidak ditemukan. '
          'Pastikan GOOGLE_WEB_CLIENT_ID sudah diatur di .env atau --dart-define. '
          'Lihat SETUP_GOOGLE_OAuth.md untuk panduan mendapatkan Web Client ID.',
        );
      }

      final authResponse = await _client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final user = authResponse.user ?? _client.auth.currentUser;
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
    } on OAuthCancelledException catch (e) {
      debugPrint('[LoginService] OAuth cancelled: $e');
      rethrow;
    } on AuthException catch (e) {
      debugPrint('[LoginService] AuthException: ${e.message}');
      rethrow;
    } on PlatformException catch (e) {
      debugPrint('[LoginService] PlatformException: ${e.code} - ${e.message}');
      if (e.code == 'sign_in_failed' && e.message?.contains('10:') == true) {
        throw AuthException(
          'Google Sign-In gagal (Error 10 / DEVELOPER_ERROR). '
          'Pastikan: 1) SHA-1 di Google Cloud Console cocok dengan signingReport, '
          '2) Package name benar (com.smartai.smartai_chat), '
          '3) OAuth Client ID Android sudah dibuat.',
        );
      }
      throw AuthException('${e.code}: ${e.message}');
    } catch (e, st) {
      debugPrint('[LoginService] Unexpected error: $e');
      debugPrint(st.toString());
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
