# Export and install Workout Tracker on a Pixel phone

## Ready-to-install APK

The app has already been exported as:

`exports/workout-tracker-1.0.0-pixel.apk`

Build details:

- App name: Workout Tracker
- Version: 1.0.0 (build 1)
- Android package: `com.example.workout_tracker`
- Minimum Android version: Android 7.0 / API 24
- Target Android SDK: API 36
- APK type: universal release APK, compatible with physical Pixel phones
- File size: 60,547,718 bytes (about 60.5 MB)
- SHA-256: `f5315c0415f920437df680a6222d7a34e822827b911acc43158eb4c5acb7c406`

The APK is release-optimized, but the current Android project signs release builds with the local Android debug certificate. It is suitable for personal installation and testing. Do not upload this build to Google Play or distribute it as a production-signed release.

## Option 1: install with a USB cable and ADB

This is the most reliable installation method.

### 1. Enable developer options on the Pixel

1. Open **Settings → About phone**.
2. Tap **Build number** seven times.
3. Enter the phone PIN when prompted.
4. Open **Settings → System → Developer options**.
5. Enable **USB debugging**.

### 2. Connect and authorize the phone

Connect the Pixel to the computer with a data-capable USB cable. Accept the **Allow USB debugging?** prompt on the phone.

From this project directory, verify that the device is visible:

```bash
adb devices
```

The device should appear with the status `device`, not `unauthorized`.

### 3. Install the exported APK

Run:

```bash
adb install -r exports/workout-tracker-1.0.0-pixel.apk
```

The `-r` flag updates an existing compatible installation while preserving its app data. After `Success` appears, open **Workout Tracker** from the Pixel app launcher.

If `adb` is not on the shell path on this computer, use the installed Android SDK copy:

```bash
/home/gejpes/Android/Sdk/platform-tools/adb install -r exports/workout-tracker-1.0.0-pixel.apk
```

## Option 2: copy the APK to the phone

1. Copy `exports/workout-tracker-1.0.0-pixel.apk` to the Pixel's **Downloads** folder using USB file transfer or another trusted transfer method.
2. On the Pixel, open **Files → Downloads** and tap the APK.
3. If Android blocks installation, follow the prompt to allow **Install unknown apps** for the Files app.
4. Return to the APK and tap **Install**.
5. For better security, disable the Files app's **Install unknown apps** permission again afterward.

Android may show a Play Protect warning because this is a locally built app that was not downloaded from Google Play. Confirm only if the filename and checksum match this guide.

## Verify the downloaded or copied file

On Linux:

```bash
sha256sum exports/workout-tracker-1.0.0-pixel.apk
```

On macOS:

```bash
shasum -a 256 exports/workout-tracker-1.0.0-pixel.apk
```

The result must match:

```text
f5315c0415f920437df680a6222d7a34e822827b911acc43158eb4c5acb7c406
```

## Export a newer build later

From `build-x20/`, run:

```bash
flutter pub get
flutter analyze
flutter test
flutter build apk --release
```

Flutter writes the result to:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Copy it to a clearly versioned export name:

```bash
cp build/app/outputs/flutter-apk/app-release.apk exports/workout-tracker-1.0.0-pixel.apk
```

Increment `version:` in `pubspec.yaml` before distributing a newer build. For example, `1.0.1+2` means user-visible version 1.0.1 and Android build number 2.

## Protect existing workout data

Workout Tracker stores its data locally inside the app's Android sandbox.

- Installing a compatible update with `adb install -r` preserves that data.
- Uninstalling the app normally deletes its workout database and settings.
- Android will refuse an update if the new APK was signed by a different certificate.

If installation reports `INSTALL_FAILED_UPDATE_INCOMPATIBLE`, do not immediately uninstall the existing app if it contains workout history you care about. That error means the installed app and new APK use different signing keys. Rebuild with the original key or first arrange a data backup.

## Production or Google Play distribution

Before publishing beyond personal testing:

1. Replace the placeholder `com.example.workout_tracker` application ID with a unique package ID you control.
2. Create and securely store a private release/upload keystore.
3. Configure the release signing block in `android/app/build.gradle.kts` instead of using `signingConfigs.getByName("debug")`.
4. Keep passwords and `key.properties` out of source control.
5. Build an Android App Bundle with `flutter build appbundle --release` for Google Play.

Changing the application ID creates a separate Android app and will not automatically inherit data from the currently installed package.

## Troubleshooting

- **Device is unauthorized:** unlock the Pixel, accept the USB debugging prompt, then run `adb devices` again.
- **No device is shown:** choose USB mode **File transfer / Android Auto**, try a different cable or port, and confirm USB debugging remains enabled.
- **Install blocked:** allow installs from the specific Files/browser app used to open the APK, or install through ADB.
- **Signature mismatch:** use an APK signed by the same key as the installed version. Uninstalling fixes the mismatch but deletes local app data.
- **Notifications do not appear:** open Workout Tracker's Settings and use **Open notification settings** after denying notification permission.
- **App cannot be installed on an old device:** this build requires Android 7.0 or newer.
