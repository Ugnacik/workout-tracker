import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/app.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/state/app_controller.dart';

void main() {
  testWidgets('changing gyms refreshes previous-set placeholders', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftWorkoutRepository(database);
    await repository.initialize();
    final firstGym = (await repository.loadLocations()).single;
    final secondGym = await repository.addLocation('Second Gym');
    final curl = (await repository.loadCatalog()).exercises.singleWhere(
      (item) => item.name == 'Dumbbell curl',
    );

    final firstSession = await repository.startWorkout(firstGym.id);
    await repository.addExercise(firstSession.id, curl);
    var set =
        (await repository.loadActiveWorkout())!.exercises.single.sets.single;
    await repository.completeSet(setId: set.id, reps: 10, loadKg: 50);
    await repository.finishWorkout(firstSession.id);

    final secondSession = await repository.startWorkout(secondGym.id);
    await repository.addExercise(secondSession.id, curl);
    set = (await repository.loadActiveWorkout())!.exercises.single.sets.single;
    await repository.completeSet(setId: set.id, reps: 12, loadKg: 25);
    await repository.finishWorkout(secondSession.id);

    final activeSession = await repository.startWorkout(firstGym.id);
    await repository.addExercise(activeSession.id, curl);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(_hintFor(tester, 'Reps'), '10');
    expect(_hintFor(tester, 'kg'), '50');

    final locationDropdown = find.byWidgetPredicate(
      (widget) =>
          widget is DropdownButton<String> && widget.value == firstGym.id,
    );
    await tester.tap(locationDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Second Gym').last);
    await tester.pumpAndSettle();

    expect(_hintFor(tester, 'Reps'), '12');
    expect(_hintFor(tester, 'kg'), '25');

    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
}

String? _hintFor(WidgetTester tester, String label) => tester
    .widgetList<TextField>(find.byType(TextField))
    .singleWhere((field) => field.decoration?.labelText == label)
    .decoration
    ?.hintText;
