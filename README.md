# Workout Tracker

An offline-first Flutter workout logger organized around muscles, movement patterns, exercise variations, equipment, and machine models.

The current daily-driver flow supports explicit set completion, previous-set placeholders, reusable workout routines, configurable rest timers with background notifications, workout history, custom exercises, gym locations, and kg/lb display.

## Run locally

```sh
flutter pub get
dart run build_runner build
flutter run
```

Android and iOS platform projects are included. Android is the primary MVP target; building iOS requires macOS and Xcode.

## Verify

```sh
flutter analyze
flutter test
flutter test integration_test
```

The Drift database is schema-versioned in `lib/data/app_database.dart`. Generated `*.g.dart` files are checked in so the app can be analyzed immediately after cloning.

Schema migration tests verify that existing version 1 workout history is retained when upgrading to the current schema.
