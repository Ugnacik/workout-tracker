# Workout Tracker UI/UX audit and implementation record

## Scope inspected

- `lib/app.dart`, `lib/main.dart`: app shell, routes, theme, orientation.
- `lib/ui/screens/dashboard_screen.dart`: Workout, History, Settings, rest timer, dialogs, sheets, and shared screen widgets.
- `lib/ui/screens/exercise_picker_screen.dart`: search, filtering, creation, machine selection, and previous performance.
- `lib/state/app_controller.dart`, `lib/domain/*`, `lib/data/*`: state transitions, persistence, workout completion, preferences, and local-first behavior.
- `test/`, `integration_test/`: protected flows and current copy-based test contracts.
- Android and iOS runners: notification-settings recovery route.

Baseline screenshots are in `audit/baseline/`. The rendered app confirmed the reported problems: cramped set rows, clipped bodyweight/compact labels, weak separation of previous and current values, an over-prominent gym selector, permanently expanded picker filters, and generic History/Settings states.

## Implemented hierarchy and interaction contracts

1. Workout status: progress and completed-set count first, then location and start time. Location remains editable without dominating the screen.
2. Exercise: exercise identity, movement context, then the next set. The next set receives an outlined focus surface and explicit `Next` state.
3. Set: previous performance is read-only reference; current Reps and Load/Added/Assistance fields are labelled inputs; completion is a full-width one-handed action. Completed sets collapse to a concise icon + text + color state with an explicit Edit action.
4. Workout-level actions: Finish remains visible but secondary in the app bar. Save routine and destructive Discard live in a separate actions sheet; discard requires confirmation.
5. Finish: the dialog summarizes saved and omitted sets, keeps the optional name, exposes a saving state, and stays open with recovery copy after failure. Typed data and the active workout are retained.
6. Picker: search stays fixed at the top, muscle shortcuts remain horizontally scrollable, secondary filters move to a bottom sheet, active filters become removable chips, and result count/reset are always explicit. Create exercise has one app-bar location plus a recovery action in no-results.
7. History: cards expose name/date/location/exercise count/set count and exercise summary. The detail sheet is near-full-height, independently scrollable, and groups sets by exercise.
8. Settings: Appearance, Measurements, Rest timer, Gym locations, and Privacy are grouped and described. Notification denial explains the consequence and opens the native app notification settings when available.

## State model

- Initial/loading: honest local-data preparation state.
- Empty: specific next action for Workout, History, picker results, and previous performance.
- Active/partial/completed: progress count and bar, explicit next set, non-color completion state, editable completed sets.
- Saving/failure: disabled saving controls with progress; inline retry while preserving active workout and typed name.
- Offline/local-only: persistent privacy explanation; no cloud or account implication.
- Permission denied: timer remains usable in-app and provides an actionable system-settings route.
- Restored workout: active session, drafts, location, previous performance, and completion status load from Drift as before.

## Responsive and accessibility contract

- Content max-width is 720 dp; screens use a navigation rail at 840 dp and above.
- Set inputs reflow vertically below 300 dp of inner card width or at 150%+ text scaling. No fixed-width text-entry columns are used.
- Verified widths: 320 dp at 200% text, 360 dp, 411 dp, 430 dp, and 480 dp; also short-height landscape and keyboard-visible picker state.
- Interactive controls use Material minimum 48 dp targets. Icon-only controls have tooltips/semantic labels; decorative icons are excluded.
- Progress and completion communicate through text/state/icon in addition to color. Set semantics preserve explicit child order so labelled inputs and actions remain independently reachable.
- Dialogs and sheets scroll, respect safe areas/insets, and restore the calling route on dismissal. Motion stays restrained and uses the platform's reduced-motion preference.

## Semantic token plan

- Color: Material 3 light/dark schemes plus semantic success, subtle, and warning surfaces. Green is reserved for primary actions, progress, selection, and success.
- Type: theme text roles only; no screen-local font families or arbitrary text colors.
- Spacing: 4/8/12/16/24/32 dp scale.
- Radius: 12 dp inputs, 16 dp cards, 28 dp sheets, full pill for status controls.
- Size: 48 dp minimum targets and named icon sizes.
- Elevation/motion: restrained zero/low elevation surfaces; no gradients or decorative motion.

## Material decisions approved before implementation

- Dark is the persisted default; Light and System remain available.
- Portrait lock was removed so short-height landscape is supported.
- Completed sets collapse and can be reopened with Edit.
- Secondary exercise filters use a bottom sheet.
- Destructive workout actions moved out of the primary path.
- Notification denial can deep-link to native app notification settings.

After screenshots and additional QA captures are in `audit/after/`.

## Verification result

- `dart format lib test integration_test`: clean.
- `flutter analyze`: no issues.
- `flutter test`: 24 tests passed, including theme persistence, 320 dp/200% text reflow, all compact width bands, semantic input labels, loading/error recovery, and failed-finish data preservation.
- `flutter test integration_test -d emulator-5554`: Android acceptance flow passed.
- Android native notification-settings channel compiled and was exercised from the denial state. iOS channel code was checked against the installed Flutter engine headers; an iOS device build remains platform-specific manual QA.
