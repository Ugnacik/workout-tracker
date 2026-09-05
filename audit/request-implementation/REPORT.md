# Workout Tracker implementation verification

Implemented all eight requested areas while preserving the existing theme, architecture and prior working-tree changes.

- Android scheduled-notification receivers, boot recovery, drawable icon and resource retention are configured. The service schedules exact idle-capable alerts when allowed, falls back to inexact alerts with an explanation in Settings, handles denied notification access, restores persisted deadlines, and serializes timer changes so cancellation/replacement cannot leave duplicate requests. Completing or discarding a workout cancels its timer. iOS foreground presentation is configured.
- Muscle selection precedes movement filtering. Incompatible movement filters clear when the muscle changes; empty results offer reset.
- Manufacturer and model are separate optional selections available in active workouts and history. Addition opens logging immediately. Only explicitly compatible models are offered. Unknown legacy custom model associations are retained; known invalid legacy associations remain readable and can be cleared.
- The previous-performance confirmation window was removed. Previous performance still supplies suggestions, with the same completion and kg/lb conversion rules.
- History muscle labels derive from completed sets, deduplicate by taxonomy, sort alphabetically and refresh after edits.
- Reps and weight hints are visible before focus, styled as suggestions and not written as values until the existing acceptance action.
- Equipment includes Cable. Audited execution metadata and independent limbs are separate properties; custom exercises can explicitly supply them. Unknown metadata stays unspecified.
- Drift schema 4 adds optional manufacturer/execution metadata and model compatibility. Generated Drift code is updated. Versions 1, 2 and 3 were tested with saved workouts, machine associations, routines and custom records, including reopen.

Verification:
- flutter analyze: no issues.
- flutter test: 43 tests passed, including migration, persistence, filters, labels, rendered hint opacity, unit conversion, compact layouts and timer race/platform tests.
- Android API 35 emulator: all five updated workout integration scenarios passed, including adding, logging, completing, history, optional machine editing, and compact/large-text layouts.
- Real Android notification integration passed for denied permissions, foreground/background delivery, locked-screen delivery, cancellation and replacement. Native active/pending notifications were asserted. android-notifications/locked-policy.txt confirms the keyguard was showing, and PNG captures show the notification.
- Debug Android APK built successfully.
- Layout checks cover 320, 430 and 480 dp, dark/light themes and 200% text. Screenshots are in ui/; widget-test fallback button fonts are not a device typography reference.

Remaining limits: no physical Android/OEM battery-policy testing or iOS device testing. Denying precise-alarm access allows Android to delay fallback alerts. No full-screen alarm or Do Not Disturb bypass was added.

Official references consulted:
- [flutter_local_notifications 19.4.2 setup and scheduling](https://pub.dev/packages/flutter_local_notifications/versions/19.4.2)
- [Android notification permission](https://developer.android.com/develop/ui/compose/notifications/notification-permission)
- [Flutter accessibility](https://docs.flutter.dev/ui/accessibility)

Reproduce device notification checks on the dedicated emulator with python3 tool/verify_android_notifications.py. This harness changes test-app permissions and enables the emulator swipe lock; it uses an in-memory workout database. Run the workout integration suite with flutter test integration_test/updated_workout_flow_test.dart -d emulator-5554.
