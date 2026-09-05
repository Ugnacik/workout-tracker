import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/app.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/domain/models.dart';
import 'package:workout_tracker/state/app_controller.dart';

void main() {
  testWidgets('set entry reflows at 320 dp and 200 percent text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 800));
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() async {
      tester.platformDispatcher.clearTextScaleFactorTestValue();
      await tester.binding.setSurfaceSize(null);
    });

    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftWorkoutRepository(database);
    await repository.initialize();
    final location = (await repository.loadLocations()).single;
    final catalog = await repository.loadCatalog();
    final weighted = catalog.exercises.singleWhere(
      (exercise) => exercise.name == 'Barbell row',
    );
    final workout = await repository.startWorkout(location.id);
    await repository.addExercise(workout.id, weighted);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reps'), findsOneWidget);
    expect(find.text('Load (kg)'), findsOneWidget);
    expect(find.text('Complete set'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Reps')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('dark is the default and appearance choice persists', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Light'));
    await tester.pumpAndSettle();
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.light,
    );

    final repository = DriftWorkoutRepository(database);
    expect(await repository.loadThemePreference(), AppThemePreference.light);
    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('active workout remains responsive across compact widths', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftWorkoutRepository(database);
    await repository.initialize();
    final location = (await repository.loadLocations()).single;
    final exercise = (await repository.loadCatalog()).exercises.singleWhere(
      (item) => item.name == 'Neutral-grip pull-up',
    );
    final workout = await repository.startWorkout(location.id);
    await repository.addExercise(workout.id, exercise);

    for (final width in <double>[360, 430, 480]) {
      await tester.binding.setSurfaceSize(Size(width, 900));
      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const WorkoutTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Neutral-grip pull-up'), findsOneWidget);
      expect(find.text('Reps'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    }

    await tester.binding.setSurfaceSize(null);
    await database.close();
  });

  testWidgets('failed finish preserves workout and entered name', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final seedRepository = DriftWorkoutRepository(database);
    await seedRepository.initialize();
    final location = (await seedRepository.loadLocations()).single;
    final exercise = (await seedRepository.loadCatalog()).exercises.singleWhere(
      (item) => item.name == 'Barbell row',
    );
    final workout = await seedRepository.startWorkout(location.id);
    await seedRepository.addExercise(workout.id, exercise);
    final set = (await seedRepository.loadActiveWorkout())!
        .exercises
        .single
        .sets
        .single;
    await seedRepository.completeSet(setId: set.id, reps: 10, loadKg: 60);
    final repository = _FailingFinishRepository(database);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(database),
          repositoryProvider.overrideWithValue(repository),
        ],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('workoutNameField')),
      'Still here',
    );
    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.text('Workout was not saved'), findsOneWidget);
    expect(find.text('Still here'), findsOneWidget);
    expect(find.text('Keep logging'), findsOneWidget);
    expect(await seedRepository.loadActiveWorkout(), isNotNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });

  testWidgets('loading and database failure states explain recovery', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final loadingDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(loadingDatabase),
          repositoryProvider.overrideWithValue(
            _PausedInitializeRepository(loadingDatabase),
          ),
        ],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pump();
    expect(find.text('Opening your workout data'), findsOneWidget);
    expect(
      find.text('Your local workout history is being prepared.'),
      findsOneWidget,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    await loadingDatabase.close();

    final failingDatabase = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(failingDatabase),
          repositoryProvider.overrideWithValue(
            _FailingInitializeRepository(failingDatabase),
          ),
        ],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Workout data could not be opened'), findsOneWidget);
    expect(
      find.text('Your data has not been changed. Try opening it again.'),
      findsOneWidget,
    );
    expect(find.text('Try again'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await failingDatabase.close();
  });
}

class _FailingFinishRepository extends DriftWorkoutRepository {
  _FailingFinishRepository(super.database);

  @override
  Future<FinishWorkoutResult> finishWorkout(String sessionId, {String? name}) =>
      throw StateError('Simulated write failure');
}

class _PausedInitializeRepository extends DriftWorkoutRepository {
  _PausedInitializeRepository(super.database);

  final _initialization = Completer<void>();

  @override
  Future<void> initialize() => _initialization.future;
}

class _FailingInitializeRepository extends DriftWorkoutRepository {
  _FailingInitializeRepository(super.database);

  @override
  Future<void> initialize() => throw StateError('Simulated open failure');
}
