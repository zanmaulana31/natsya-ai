---
name: Android App Branding - Natsya Ai
description: Change Android app name to "Natsya Ai" and replace launcher icon with the provided N-logo
targets:
  - ../smartai_chat/android/app/src/main/AndroidManifest.xml
  - ../smartai_chat/android/app/src/main/res/mipmap-mdpi/ic_launcher.png
  - ../smartai_chat/android/app/src/main/res/mipmap-hdpi/ic_launcher.png
  - ../smartai_chat/android/app/src/main/res/mipmap-xhdpi/ic_launcher.png
  - ../smartai_chat/android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png
  - ../smartai_chat/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png
---

## Overview

Update the Android app's display name and launcher icon to reflect the "Natsya Ai" brand identity. The source logo (`N-logo.png`) is a purple gradient rounded-square with a white "N" lettermark.

---

## 1. App Name

- The `android:label` in `AndroidManifest.xml` must be changed from `"smartai_chat"` to `"Natsya Ai"`
  `[@test] ../smartai_chat/test/branding/app_name_test.dart`

---

## 2. Launcher Icon

The source image (`N-logo.png`) must be resized and placed as `ic_launcher.png` in each mipmap density folder:

| Density folder     | Required size |
|--------------------|---------------|
| `mipmap-mdpi`      | 48 × 48 px    |
| `mipmap-hdpi`      | 72 × 72 px    |
| `mipmap-xhdpi`     | 96 × 96 px    |
| `mipmap-xxhdpi`    | 144 × 144 px  |
| `mipmap-xxxhdpi`   | 192 × 192 px  |

- Each file must be named `ic_launcher.png` and replace the existing placeholder
  `[@test] ../smartai_chat/test/branding/launcher_icon_test.dart`

- The `android:icon` attribute in `AndroidManifest.xml` must remain `"@mipmap/ic_launcher"`
  `[@test] ../smartai_chat/test/branding/launcher_icon_test.dart`

---

## 3. Out of Scope

- iOS app name / icon changes (separate spec)
- Adaptive icon (`ic_launcher_foreground` / `ic_launcher_background`) — not required unless targeting API 26+ adaptive icon behavior explicitly
- Play Store assets (feature graphic, store listing icon)
