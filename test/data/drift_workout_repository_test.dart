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
        (await repository.previousSets(exercise)).single.adjustment,
        BodyweightAdjustment.assisted,
      );
    },
  );

  test('machine history is keyed by model across gym locations', () async {
    final catalog = await repository.loadCatalog();
    final pulldown = catalog.exercises
        .singleWhere((item) => item.name == 'Lat pulldown')
        .withMachine(catalog.machines.first);
    final firstGym = (await repository.loadLocations()).single;
    final secondGym = await repository.addLocation('Second Gym');
    final session = await repository.startWorkout(firstGym.id);
    await repository.addExercise(session.id, pulldown);
    final set =
        (await repository.loadActiveWorkout())!.exercises.single.sets.single;
    await repository.completeSet(setId: set.id, reps: 10, loadKg: 55);
    await repository.changeWorkoutLocation(session.id, secondGym.id);
    await repository.finishWorkout(session.id);
    expect((await repository.previousSets(pulldown)).single.loadKg, 55);
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
