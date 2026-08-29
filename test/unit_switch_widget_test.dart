import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/app.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/state/app_controller.dart';

void main() {
  testWidgets(
    'unit switch refreshes active load without changing its meaning',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 900));
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final repository = DriftWorkoutRepository(database);
      await repository.initialize();
      final location = (await repository.loadLocations()).single;
      final exercise = (await repository.loadCatalog()).exercises.firstWhere(
        (item) => item.name == 'Bench press',
      );
      final session = await repository.startWorkout(location.id);
      await repository.addExercise(session.id, exercise);
      final set =
          (await repository.loadActiveWorkout())!.exercises.single.sets.single;
      await repository.updateSet(setId: set.id, reps: 8, loadKg: 50);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [databaseProvider.overrideWithValue(database)],
          child: const WorkoutTrackerApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(_fieldValues(tester), containsAll(['8', '50']));
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pounds (lb)'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Workout'));
      await tester.pumpAndSettle();
      expect(_fieldValues(tester), containsAll(['8', '110.2']));

      await tester.pumpWidget(const SizedBox.shrink());
      await database.close();
    },
  );
}

List<String> _fieldValues(WidgetTester tester) => tester
    .widgetList<TextField>(find.byType(TextField))
    .map((field) => field.controller?.text ?? '')
    .toList();
