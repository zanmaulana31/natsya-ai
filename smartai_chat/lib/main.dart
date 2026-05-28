import 'package:cactus/cactus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/ai_model_status.dart';
import 'models/supabase_config.dart';
import 'providers/ai_model_provider.dart';
import 'providers/auth/login_provider.dart';
import 'providers/cloud_ai_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/login_screen.dart';
import 'screens/model_loading_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cactus SDK configuration
  CactusConfig.isTelemetryEnabled = false;

  // Initialize local notifications
  await NotificationService.instance.initialize();

  // Initialize Supabase
  const supabaseConfig = SupabaseConfig();
  await Supabase.initialize(
    url: supabaseConfig.url,
    anonKey: supabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: SmartAiApp()));
}

class SmartAiApp extends ConsumerWidget {
  const SmartAiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final theme = themeMode == ThemeMode.light
        ? FThemes.violet.light.touch
        : FThemes.violet.dark.touch;

    final authState = ref.watch(authProvider);

    final Widget home;
    if (authState is AsyncLoading) {
      home = const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authState is AsyncData && authState.value != null) {
      final cloudConfig = ref.watch(cloudAiConfigProvider);
      final modelState = ref.watch(aiModelProvider);
      if (cloudConfig.enabled || modelState.status == AiModelStatus.ready) {
        home = const ChatScreen();
      } else {
        home = const ModelLoadingScreen();
      }
    } else {
      home = const LoginScreen();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme.toApproximateMaterialTheme(),
      darkTheme: FThemes.violet.dark.touch.toApproximateMaterialTheme(),
      themeMode: themeMode,
      builder: (_, child) => FTheme(
        data: theme,
        child: FToaster(child: FTooltipGroup(child: child!)),
      ),
      home: home,
    );
  }
}
