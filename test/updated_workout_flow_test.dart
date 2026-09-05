import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:workout_tracker/ui/screens/dashboard_screen.dart';
import 'package:workout_tracker/ui/screens/exercise_picker_screen.dart';
import 'package:workout_tracker/app.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/domain/models.dart';
import 'package:workout_tracker/services/rest_timer_service.dart';
import 'package:workout_tracker/state/app_controller.dart';

class _QuietNotifications implements RestTimerNotifications {
  @override
  Future<void> initialize() async {}
  @override
  Future<bool> requestPermission() async => true;
  @override
  Future<void> schedule(DateTime deadline) async {}
  @override
  Future<void> cancel() async {}
}

Future<void> _mount(WidgetTester tester, AppDatabase db) async {
  await tester.binding.setSurfaceSize(const Size(430, 1000));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final router = GoRouter(
    routes: [
      GoRoute(path: '/', builder: (_, _) => const DashboardScreen()),
      GoRoute(
        path: '/exercises',
        builder: (_, _) => const ExercisePickerScreen(),
      ),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    RepaintBoundary(
      key: const ValueKey('qa-boundary'),
      child: ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          restTimerNotificationsProvider.overrideWithValue(
            _QuietNotifications(),
          ),
        ],
        child: WorkoutTrackerApp(router: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _dropdown(String label) => find.byWidgetPredicate(
  (widget) =>
      widget is DropdownButtonFormField<String?> &&
      widget.decoration.labelText == label,
);

DropdownButton<String?> _button(WidgetTester tester, String label) =>
    tester.widget<DropdownButton<String?>>(
      find.descendant(
        of: _dropdown(label),
        matching: find.byType(DropdownButton<String?>),
      ),
    );

void _expectVisibleHint(WidgetTester tester, String text) {
  final hint = find.text(text);
  expect(hint, findsOneWidget);
  final opacity = find
      .ancestor(of: hint, matching: find.byType(AnimatedOpacity))
      .first;
  expect(tester.widget<AnimatedOpacity>(opacity).opacity, 1);
  expect(tester.widget<Text>(hint).style!.fontStyle, FontStyle.italic);
}

Future<void> _capture(WidgetTester tester, String name) async {
  if (!const bool.fromEnvironment('CAPTURE_UI')) return;
  final boundary = tester.renderObject<RenderRepaintBoundary>(
    find.byKey(const ValueKey('qa-boundary')),
  );
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final directory = Directory('audit/request-implementation/ui');
    await directory.create(recursive: true);
    await File('${directory.path}/$name.png')
        .writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

void main() {
  setUpAll(() async {
    if (!const bool.fromEnvironment('CAPTURE_UI')) return;
    const directory = String.fromEnvironment('QA_FONT_DIR');
    for (final (family, files) in [
      (
        'Roboto',
        ['Roboto-Regular.ttf', 'Roboto-Bold.ttf', 'Roboto-Italic.ttf'],
      ),
      ('Ahem', ['Roboto-Regular.ttf', 'Roboto-Bold.ttf']),
      ('MaterialIcons', ['MaterialIcons-Regular.otf']),
    ]) {
      final loader = FontLoader(family);
      for (final file in files) {
        loader.addFont(
          File('$directory/$file')
              .readAsBytes()
              .then((bytes) => ByteData.sublistView(bytes)),
        );
      }
      await loader.load();
    }
  });
  testWidgets(
    'muscle first filters reset incompatible movement and recover from empty results',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await _mount(tester, db);
      await _tap(tester, find.text('Start workout'));
      await _tap(tester, find.text('Start empty'));
      await _tap(tester, find.text('Add exercise'));
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Filters'));
      final disabled = _button(tester, 'Movement pattern');
      expect(disabled.onChanged, isNull);
      expect(disabled.items!.map((i) => i.value), [null]);
      expect(find.text('Manufacturer'), findsNothing);
      await _tap(tester, find.text('Apply filters'));
      await _tap(tester, find.widgetWithText(FilterChip, 'Back'));
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Filters (1)'));
      var pattern = _button(tester, 'Movement pattern');
      expect(
        pattern.items!.map((i) => i.value),
        isNot(contains('pattern-knee-dominant')),
      );
      await _tap(tester, _dropdown('Movement pattern'));
      await _tap(tester, find.text('Vertical pulling').last);
      await _tap(tester, find.text('Apply filters'));
      await _tap(tester, find.widgetWithText(FilterChip, 'Legs'));
      expect(find.widgetWithText(InputChip, 'Vertical pulling'), findsNothing);
      await _tap(tester, find.widgetWithText(OutlinedButton, 'Filters (1)'));
      pattern = _button(tester, 'Movement pattern');
      expect(pattern.value, isNull);
      expect(pattern.items!.map((i) => i.value), [
        null,
        'pattern-knee-dominant',
        'pattern-hip-hinge',
      ]);
      await _tap(tester, find.text('Apply filters'));
      await tester.enterText(
        find.byType(TextField),
        'No exercise matches this',
      );
      await tester.pumpAndSettle();
      expect(find.text('No matching exercises'), findsOneWidget);
      await _tap(tester, find.text('Clear search and filters'));
      expect(find.text('No matching exercises'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    },
  );

  for (final previous in [false, true]) {
    testWidgets(
      'unfocused placeholders with previous=$previous preserve acceptance and units',
      (tester) async {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final repository = DriftWorkoutRepository(db);
        await repository.initialize();
        final exercise = (await repository.loadCatalog()).exercises.singleWhere(
          (e) => e.id == 'exercise-squat',
        );
        if (previous) {
          final session = await repository.startWorkout('location-my-gym');
          await repository.addExercise(session.id, exercise);
          final set = (await repository.loadActiveWorkout())!
              .exercises
              .single
              .sets
              .single;
          await repository.completeSet(setId: set.id, reps: 8, loadKg: 50);
          await repository.finishWorkout(session.id);
          await repository.setWeightUnit(WeightUnit.pounds);
        }
        await repository.startWorkout('location-my-gym');
        await _mount(tester, db);
        await _tap(tester, find.text('Add exercise'));
        await tester.enterText(find.byType(TextField), 'Back squat');
        await tester.pumpAndSettle();
        expect(
          find.text('Legs · Knee dominant · Barbell · Both sides together'),
          findsOneWidget,
        );
        await _tap(tester, find.widgetWithText(ListTile, 'Back squat'));
        expect(find.text('No previous performance'), findsNothing);
        expect(find.text('Add to workout'), findsNothing);
        expect(
          tester
              .widgetList<EditableText>(find.byType(EditableText))
              .every(
                (field) =>
                    !field.focusNode.hasFocus && field.controller.text.isEmpty,
              ),
          isTrue,
        );
        _expectVisibleHint(tester, previous ? '8' : 'Enter reps');
        _expectVisibleHint(tester, previous ? '110.2' : 'Weight');
        var set = (await repository.loadActiveWorkout())!
            .exercises
            .single
            .sets
            .single;
        expect(set.reps, 0);
        expect(set.loadKg, isNull);
        await _tap(tester, find.text('Complete set'));
        if (!previous) {
          expect(
            find.text('Enter reps before completing the set.'),
            findsOneWidget,
          );
          final reps = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Reps',
          );
          await tester.enterText(reps, '6');
          final load = find.byWidgetPredicate(
            (w) => w is TextField && w.decoration?.labelText == 'Load (kg)',
          );
          await tester.enterText(load, '40');
          await tester.testTextInput.receiveAction(TextInputAction.done);
          await _tap(tester, find.text('Complete set'));
        }
        set = (await repository.loadActiveWorkout())!
            .exercises
            .single
            .sets
            .single;
        expect(set.isCompleted, isTrue);
        expect(set.reps, previous ? 8 : 6);
        expect(set.loadKg, closeTo(previous ? 50 : 40, .001));
        await tester.pumpWidget(const SizedBox.shrink());
        await db.close();
      },
    );
  }

  testWidgets(
    'machine addition logs immediately and optional brand/model can be edited in history',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = DriftWorkoutRepository(db);
      await repository.initialize();
      await repository.startWorkout('location-my-gym');
      await _mount(tester, db);
      await _tap(tester, find.text('Add exercise'));
      await tester.enterText(find.byType(TextField), 'Lat pulldown');
      await tester.pumpAndSettle();
      await _tap(tester, find.widgetWithText(ListTile, 'Lat pulldown'));
      expect(find.text('Choose machine model'), findsNothing);
      expect(find.text('No previous performance'), findsNothing);
      expect(
        (await repository.loadActiveWorkout())!
            .exercises
            .single
            .exercise
            .manufacturerId,
        isNull,
      );
      _expectVisibleHint(tester, 'Enter reps');
      await _tap(tester, find.byTooltip('Actions for Lat pulldown'));
      await _tap(tester, find.text('Edit machine information'));
      await _tap(tester, _dropdown('Manufacturer'));
      expect(find.text('Life Fitness'), findsWidgets);
      expect(find.textContaining('Signature Chest Press'), findsNothing);
      await _tap(tester, find.text('Life Fitness').last);
      expect(_button(tester, 'Model').items, hasLength(1));
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      expect(
        (await repository.loadActiveWorkout())!
            .exercises
            .single
            .exercise
            .manufacturer!
            .name,
        'Life Fitness',
      );
      await _tap(tester, find.byTooltip('Actions for Lat pulldown'));
      await _tap(tester, find.text('Edit machine information'));
      await _tap(tester, _dropdown('Manufacturer'));
      await _tap(tester, find.text('Technogym').last);
      await _tap(tester, _dropdown('Model'));
      await _tap(tester, find.text('Selection Lat Pulldown').last);
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      final reps = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Reps',
      );
      await tester.enterText(reps, '10');
      final load = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.labelText == 'Load (kg)',
      );
      await tester.enterText(load, '35');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _tap(tester, find.text('Complete set'));
      await _tap(tester, find.text('Finish'));
      await tester.enterText(
        find.byKey(const ValueKey('workoutNameField')),
        'Pull test',
      );
      await _tap(tester, find.widgetWithText(FilledButton, 'Finish'));
      expect(find.text('Back'), findsOneWidget);
      await _tap(tester, find.text('Pull test'));
      expect(find.text('Technogym · Selection Lat Pulldown'), findsOneWidget);
      await _tap(tester, find.text('Edit machine information'));
      await _tap(tester, find.text('Clear selection'));
      await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
      expect(find.text('Technogym · Selection Lat Pulldown'), findsNothing);
      expect(find.textContaining('10 reps'), findsOneWidget);
      final history = (await repository.loadHistory()).single;
      expect(history.exercises.single.exercise.manufacturerId, isNull);
      expect(history.muscleLabels, ['Back']);
      await tester.pumpWidget(const SizedBox.shrink());
      await db.close();
    },
  );
  testWidgets(
    'compact layouts and machine sheet remain usable in both themes and large text',
    (tester) async {
      for (final (width, scale, theme) in [
        (320.0, 1.0, AppThemePreference.dark),
        (430.0, 1.0, AppThemePreference.light),
        (480.0, 1.0, AppThemePreference.dark),
        (320.0, 2.0, AppThemePreference.dark),
      ]) {
        final db = AppDatabase.forTesting(NativeDatabase.memory());
        final repository = DriftWorkoutRepository(db);
        await repository.initialize();
        await repository.setThemePreference(theme);
        final session = await repository.startWorkout('location-my-gym');
        final squat = (await repository.loadCatalog()).exercises.singleWhere(
          (e) => e.id == 'exercise-squat',
        );
        await repository.addExercise(session.id, squat);
        await _mount(tester, db);
        await tester.binding.setSurfaceSize(Size(width, 900));
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        await tester.pumpAndSettle();
        final name = '${width.toInt()}-${scale.toInt()}-${theme.name}';
        await _capture(tester, 'workout-$name');
        await tester.ensureVisible(find.text('Complete set'));
        await tester.pumpAndSettle();
        await _capture(tester, 'placeholders-$name');
        expect(tester.takeException(), isNull);
        await _tap(tester, find.text('Add exercise'));
        await tester.enterText(find.byType(TextField), 'Lat pulldown');
        await tester.pumpAndSettle();
        await _capture(tester, 'picker-$name');
        expect(tester.takeException(), isNull);
        await _tap(tester, find.widgetWithText(ListTile, 'Lat pulldown'));
        await _tap(tester, find.byTooltip('Actions for Lat pulldown'));
        await _tap(tester, find.text('Edit machine information'));
        await _capture(tester, 'machine-$name');
        expect(tester.takeException(), isNull);
        await _tap(tester, _dropdown('Manufacturer'));
        await _tap(tester, find.text('Technogym').last);
        await _tap(tester, _dropdown('Model'));
        await _tap(tester, find.text('Selection Lat Pulldown').last);
        await _capture(tester, 'machine-selected-$name');
        await _tap(tester, find.widgetWithText(FilledButton, 'Save'));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        await db.close();
      }
    },
  );
}
