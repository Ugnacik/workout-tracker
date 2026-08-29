import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/domain/models.dart';

void main() {
  late AppDatabase database;
  late DriftWorkoutRepository repository;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWorkoutRepository(database);
    await repository.initialize();
  });

  tearDown(() => repository.close());

  test('initial database is versioned and seeded', () async {
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    final catalog = await repository.loadCatalog();
    expect(database.schemaVersion, 2);
    expect(version.read<int>('user_version'), 2);
    expect(
      catalog.exercises.any((item) => item.name == 'Neutral-grip pull-up'),
      isTrue,
    );
    expect((await repository.loadLocations()).single.isDefault, isTrue);
  });

  test('default location changes without losing locations', () async {
    final second = await repository.addLocation('Downtown Gym');
    await repository.setDefaultLocation(second.id);
    final locations = await repository.loadLocations();
    expect(locations, hasLength(2));
    expect(
      locations.singleWhere((item) => item.isDefault).name,
      'Downtown Gym',
    );
  });

  test('initialization preserves preferences and custom taxonomy', () async {
    await repository.setWeightUnit(WeightUnit.pounds);
    final pattern = await repository.addMovementPattern(
      name: 'Shoulder adduction',
      muscleGroupId: 'muscle-back',
    );
    await repository.initialize();

    expect(await repository.loadWeightUnit(), WeightUnit.pounds);
    expect(
      (await repository.loadCatalog()).patterns.any(
        (item) => item.id == pattern.id,
      ),
      isTrue,
    );
  });

  test(
    'completed bodyweight session persists and powers previous performance',
    () async {
      final location = (await repository.loadLocations()).single;
      final exercise = (await repository.loadCatalog()).exercises.singleWhere(
        (item) => item.name == 'Neutral-grip pull-up',
      );
      final session = await repository.startWorkout(location.id);
      await repository.addExercise(session.id, exercise);
      final set =
          (await repository.loadActiveWorkout())!.exercises.single.sets.single;
      await repository.completeSet(
        setId: set.id,
        reps: 8,
        bodyweightAdjustmentKg: 12,
        adjustment: BodyweightAdjustment.assisted,
      );
      await repository.finishWorkout(session.id);
      expect(await repository.loadActiveWorkout(), isNull);
      expect(
        (await repository.loadHistory())
            .single
            .exercises
            .single
            .sets
            .single
            .reps,
        8,
      );
      expect(
        (await repository.previousSets(
          exercise,
          gymLocationId: location.id,
        )).single.adjustment,
        BodyweightAdjustment.assisted,
      );
    },
  );

  test('previous performance is scoped to gym location', () async {
    final catalog = await repository.loadCatalog();
    final curl = catalog.exercises.singleWhere(
      (item) => item.name == 'Dumbbell curl',
    );
    final firstGym = (await repository.loadLocations()).single;
    final secondGym = await repository.addLocation('Second Gym');
    final firstSession = await repository.startWorkout(firstGym.id);
    await repository.addExercise(firstSession.id, curl);
    final firstSet =
        (await repository.loadActiveWorkout())!.exercises.single.sets.single;
    await repository.completeSet(setId: firstSet.id, reps: 10, loadKg: 50);
    await repository.finishWorkout(firstSession.id);

    final secondSession = await repository.startWorkout(secondGym.id);
    await repository.addExercise(secondSession.id, curl);
    final secondSet =
        (await repository.loadActiveWorkout())!.exercises.single.sets.single;
    await repository.completeSet(setId: secondSet.id, reps: 12, loadKg: 25);
    await repository.finishWorkout(secondSession.id);

    final firstGymPrevious = await repository.previousSets(
      curl,
      gymLocationId: firstGym.id,
    );
    final secondGymPrevious = await repository.previousSets(
      curl,
      gymLocationId: secondGym.id,
    );
    expect(firstGymPrevious.single.loadKg, 50);
    expect(firstGymPrevious.single.reps, 10);
    expect(secondGymPrevious.single.loadKg, 25);
    expect(secondGymPrevious.single.reps, 12);
  });

  test('finish omits unchecked sets and empty exercises', () async {
    final location = (await repository.loadLocations()).single;
    final exercise = (await repository.loadCatalog()).exercises.first;
    final session = await repository.startWorkout(location.id);
    await repository.addExercise(session.id, exercise);
    final result = await repository.finishWorkout(session.id);
    expect(result.omittedSetCount, 1);
    expect((await repository.loadHistory()).single.exercises, isEmpty);
  });

  test('routine preserves exercise order, machine, and set count', () async {
    final catalog = await repository.loadCatalog();
    final location = (await repository.loadLocations()).single;
    final machineExercise = catalog.exercises
        .firstWhere((item) => item.equipmentType == EquipmentType.machine)
        .withMachine(catalog.machines.first);
    final session = await repository.startWorkout(location.id);
    await repository.addExercise(session.id, machineExercise);
    final active = (await repository.loadActiveWorkout())!;
    await repository.addSet(active.exercises.single.id);
    final updated = (await repository.loadActiveWorkout())!;
    final routine = await repository.saveWorkoutAsRoutine(
      workout: updated,
      name: 'Pull day',
    );
    expect(routine.exercises.single.setCount, 2);
    expect(
      routine.exercises.single.exercise.machineModel?.id,
      machineExercise.machineModel?.id,
    );
    await repository.discardWorkout(session.id);
    final fromRoutine = await repository.startWorkoutFromRoutine(
      location.id,
      routine.id,
    );
    expect(fromRoutine.exercises.single.sets, hasLength(2));
    expect(
      fromRoutine.exercises.single.exercise.machineModel?.id,
      machineExercise.machineModel?.id,
    );
  });
}
