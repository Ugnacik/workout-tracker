# Workout Tracker

An offline-first Flutter workout logger organized around muscles, movement patterns, exercise variations, equipment, and machine models.

The current daily-driver flow supports explicit set completion, previous-set placeholders, reusable workout routines, configurable rest timers with background notifications, workout history, custom exercises, gym locations, and kg/lb display.

## Run locally

```sh
flutter pub get
dart run build_runner build
flutter run
```

Android, iOS, and Linux platform projects are included. To run the app as a
native application on a Linux computer, use:

```sh
flutter run -d linux
```

To create a standalone local Linux build, use `flutter build linux --release`.
The executable and its required libraries will be written to
`build/linux/x64/release/bundle/`.

Android is the primary mobile target; building iOS requires macOS and Xcode.

## Verify

```sh
flutter analyze
flutter test
flutter test integration_test
```

The Drift database is schema-versioned in `lib/data/app_database.dart`. Generated `*.g.dart` files are checked in so the app can be analyzed immediately after cloning.

Schema migration tests verify that existing version 1 workout history is retained when upgrading to the current schema.
