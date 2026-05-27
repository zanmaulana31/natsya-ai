---
name: Model Loading Screen with Background Download & Notification
description: Blocking launch screen that downloads the Cactus AI model in the background, shows branded progress UI, and sends a local push notification when the model is ready — even if the app is in the background
targets:
  - ../smartai_chat/lib/main.dart
  - ../smartai_chat/lib/screens/model_loading_screen.dart
  - ../smartai_chat/lib/services/notification_service.dart
  - ../smartai_chat/lib/providers/ai_model_provider.dart
  - ../smartai_chat/android/app/src/main/AndroidManifest.xml
  - ../smartai_chat/pubspec.yaml
---

# Model Loading Screen with Background Download & Notification

## Overview

A **blocking** screen shown on first app launch when the AI model is not yet downloaded. The model download runs in the background so the UI remains responsive. When download completes, a **local push notification** is shown with the message **"Natsya AI can you try right now!"**, even if the user has minimized or backgrounded the app.

If the user **force-closes** the app during download, the download stops (OS limitation). On the next launch, the app checks if the model is already downloaded and skips the blocking screen if so.

---

## Dependencies

- Add `flutter_local_notifications: ^17.2.1` to `pubspec.yaml` dependencies
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- Run `flutter pub get` succeeds without errors
  `[@test] ../smartai_chat/test/pubspec_test.dart`

---

## Android Configuration

### AndroidManifest.xml Permissions

- Add `<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />` for Android 13+ (API 33)
  `[@test] ../smartai_chat/test/android_manifest_test.dart`
- Keep existing permissions: `INTERNET`, `ACCESS_NETWORK_STATE`, `RECORD_AUDIO`
  `[@test] ../smartai_chat/test/android_manifest_test.dart`

---

## Notification Service

### NotificationService

- `lib/services/notification_service.dart` exports a `NotificationService` class
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- `NotificationService` is a singleton accessible via `NotificationService.instance`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- `initialize()` sets up `FlutterLocalNotificationsPlugin` with Android and iOS settings
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Android channel ID: `"natsya_ai_model"`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Android channel name: `"Natsya AI Model"`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Android channel description: `"Notifications for AI model readiness"`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Android importance: `Importance.high`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- iOS presentation options: `alert`, `badge`, `sound`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`

### Show Notification

- `showModelReadyNotification()` displays a local notification with:
  - Title: `"Natsya AI"`
  - Body: `"Natsya AI can you try right now!"`
  - Payload: `"model_ready"`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Notification ID is `1` (fixed)
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`
- Does not throw if called before `initialize()` (no-op)
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`

---

## Routing Logic (main.dart)

- `SmartAiApp.build()` watches `aiModelProvider` to determine the initial route
  `[@test] ../smartai_chat/test/main_test.dart`
- If `aiModelProvider.status` is `AiModelStatus.ready`, `home` is `ChatScreen`
  `[@test] ../smartai_chat/test/main_test.dart`
- For any other status (`notDownloaded`, `downloading`, `downloaded`, `initializing`, `error`), `home` is `ModelLoadingScreen`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` imports `../screens/model_loading_screen.dart` and `../services/notification_service.dart`
  `[@test] ../smartai_chat/test/main_test.dart`
- In `main()`, before `runApp()`, call `NotificationService.instance.initialize()`
  `[@test] ../smartai_chat/test/main_test.dart`
- `main.dart` calls `WidgetsFlutterBinding.ensureInitialized()` before all initialization
  `[@test] ../smartai_chat/test/main_test.dart`

---

## Auto-Trigger Download

- `ModelLoadingScreen` is a `ConsumerStatefulWidget`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- In `initState()`, after first frame, calls `ref.read(aiModelProvider.notifier).downloadAndInit()` if status is `notDownloaded` or `error`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- The screen does **not** trigger download again if status is already `downloading`, `downloaded`, or `initializing`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Download runs asynchronously in the background — the UI thread remains responsive and the progress bar updates smoothly
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Screen Layout

### Structure

- Root widget is `Scaffold` with `backgroundColor` matching the active Forui theme's `background` color
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Body is `Center` containing a vertical `Column` (mainAxisSize: `MainAxisSize.min`)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Brand Logo

- Displays the Natsya AI brand logo (N-logo) as an `Image.asset`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Logo is **centered** above the progress bar
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Logo size is fixed at 120 × 120 px with `BoxFit.contain`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Asset path: `assets/images/n_logo.png` (must be declared in `pubspec.yaml` under `assets:`)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Title Text

- Below the logo: a title text `"Preparing Natsya AI"`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Text style uses `context.theme.typography.lg` with `fontWeight: FontWeight.w600`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Text color uses `context.theme.colors.foreground`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Progress Bar

- Below the title: a `LinearProgressIndicator` (determinate)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- When `aiModelProvider.status` is `downloading`, `value` is set to `aiModelProvider.downloadProgress` (0.0 – 1.0)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- When status is `initializing` or `downloaded`, `value` is `null` (indeterminate) to show ongoing work
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Progress bar width is constrained to 280 px, height 6 px, border radius 3 px
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Progress bar `backgroundColor` uses `context.theme.colors.muted` with alpha 0.3
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Progress bar `valueColor` uses `context.theme.colors.primary`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Status Text

- Below the progress bar: a status message text
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- When `downloading`: `"Downloading AI model... ${(progress * 100).toInt()}%"`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- When `downloaded` or `initializing`: `"Initializing AI model..."`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- When `error`: `"Something went wrong"`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Text style uses `context.theme.typography.sm` with `context.theme.colors.mutedForeground`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

### Error State

- When `aiModelProvider.status` is `error`:
  - Status text shows `aiModelProvider.errorMessage` (truncated to 2 lines)
    `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
  - A **Retry** button (`FButton`) appears below the status text
    `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
  - Retry button label: `"Try Again"`
    `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
  - Tapping Retry calls `ref.read(aiModelProvider.notifier).downloadAndInit()`
    `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Progress bar is hidden when in error state
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Navigation

- `ref.listen(aiModelProvider, ...)` inside `build()` watches for status changes
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- When status transitions to `ready`, calls `Navigator.of(context).pushReplacement()` with `MaterialPageRoute(builder: (_) => const ChatScreen())`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Navigation happens only once; subsequent rebuilds do not trigger duplicate navigation (guarded by a `_didNavigate` boolean)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Push Notification on Ready

- When `AiModelNotifier` state transitions to `ready`, it calls `NotificationService.instance.showModelReadyNotification()`
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Notification is shown **only once** per successful download (guarded by `_hasNotified` flag)
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Notification is shown even if the app is in the **background** or **minimized**
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- If the app is in the foreground when download completes, the notification is still shown (standard local notification behavior)
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`
- Tapping the notification brings the app to the foreground on the `ChatScreen`
  `[@test] ../smartai_chat/test/services/notification_service_test.dart`

---

## App Kill / Force-Close Handling

- If the user **force-closes** the app during download, the download stops (OS limitation — background execution is killed)
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- On the next app launch, `AiModelService.isDownloaded()` checks whether the model files exist on disk
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- If the model is **partially downloaded** (incomplete files), `isDownloaded()` returns `false` and the blocking screen reappears
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- If the model is **fully downloaded** (complete files), `isDownloaded()` returns `true` and the app skips directly to `ChatScreen`
  `[@test] ../smartai_chat/test/services/ai_model_service_test.dart`
- The `AiModelNotifier` constructor or `build()` method calls `isDownloaded()` to set the initial status to `ready` if the model is already present
  `[@test] ../smartai_chat/test/providers/ai_model_provider_test.dart`

---

## Blocking Behavior

- User **cannot dismiss** or skip this screen
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- No AppBar, no back button, no drawer, no gesture to exit
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- The screen is the only widget in the navigation stack until model is ready
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Asset Requirement

- `pubspec.yaml` must declare the logo asset:
  ```yaml
  flutter:
    assets:
      - assets/images/n_logo.png
  ```
  `[@test] ../smartai_chat/test/pubspec_test.dart`
- The asset file `assets/images/n_logo.png` must exist (same N-logo from Android branding spec, copied as Flutter asset)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## const Optimization (Flutter Expert)

- `ModelLoadingScreen` constructor is `const`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- All static spacing widgets (`SizedBox`, `EdgeInsets`, `Duration`) use `const` constructors
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Static text widgets that do not depend on state are `const` where possible
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- No widget class is instantiated inside the `build()` method — all reusable parts are extracted to private widget classes or helper methods
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Keys for Testability (Flutter Expert)

- Progress bar section uses `const Key('model_loading_progress')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Retry button uses `const Key('model_loading_retry')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- Error message text uses `const Key('model_loading_error')`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`

---

## Theming

- Screen respects the current Forui theme (light/dark violet)
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
- All colors come from `context.theme.colors`
  `[@test] ../smartai_chat/test/screens/model_loading_screen_test.dart`
