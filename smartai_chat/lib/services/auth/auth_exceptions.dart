class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class OAuthCancelledException implements Exception {
  final String message;
  OAuthCancelledException([this.message = 'OAuth sign-in was cancelled']);

  @override
  String toString() => 'OAuthCancelledException: $message';
}
