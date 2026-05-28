// lib/models/supabase_config.dart
import 'package:flutter/foundation.dart';

@immutable
class SupabaseConfig {
  final String url;
  final String anonKey;

  const SupabaseConfig({
    this.url = 'https://nzqcnenzbxwwxaaogvdn.supabase.co',
    this.anonKey = const String.fromEnvironment('SUPABASE_ANON_KEY'),
  });

  SupabaseConfig copyWith({
    String? url,
    String? anonKey,
  }) {
    return SupabaseConfig(
      url: url ?? this.url,
      anonKey: anonKey ?? this.anonKey,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupabaseConfig &&
          url == other.url &&
          anonKey == other.anonKey;

  @override
  int get hashCode => url.hashCode ^ anonKey.hashCode;
}
