import 'package:cactus/cactus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:forui/forui.dart';

import 'models/ai_model_status.dart';
import 'providers/ai_model_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/chat_screen.dart';
import 'screens/model_loading_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Cactus SDK configuration
  CactusConfig.isTelemetryEnabled = false;

  // Initialize local notifications
  await NotificationService.instance.initialize();

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

    final modelState = ref.watch(aiModelProvider);
    final Widget home;
    if (modelState.status == AiModelStatus.ready) {
      home = const ChatScreen();
    } else {
      home = const ModelLoadingScreen();
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
