import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/domain/models.dart';

void main() {
  late DriftWorkoutRepository repository;
  late AppDatabase db;
  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repository = DriftWorkoutRepository(db);
    await repository.initialize();
  });
  tearDown(() => repository.close());

  test('muscle-dependent patterns and combined filters exclude incompatible exercises', () async {
    final catalog = await repository.loadCatalog();
    expect(catalog.patternsForMuscle(null), isEmpty);
    expect(
      catalog.patternsForMuscle('muscle-back').map((p) => p.name),
      containsAll(['Vertical pulling', 'Horizontal pulling']),
    );
    expect(
      catalog.patternsForMuscle('muscle-legs').map((p) => p.name),
      isNot(contains('Vertical pulling')),
    );
    expect(
      filterExercises(
        catalog,
        const ExerciseFilter(
          muscleGroupId: 'muscle-legs',
          movementPatternId: 'pattern-vertical-pull',
        ),
      ),
      isEmpty,
    );
    final results = filterExercises(
      catalog,
      const ExerciseFilter(
        muscleGroupId: 'muscle-back',
        movementPatternId: 'pattern-vertical-pull',
      ),
    );
    expect(results, isNotEmpty);
    expect(
      results.every(
        (e) =>
            e.muscleGroupId == 'muscle-back' &&
            e.movementPatternId == 'pattern-vertical-pull',
      ),
      isTrue,
    );
  });

  test(
    'brand names and model compatibility are separate and enforced on writes',
    () async {
      final catalog = await repository.loadCatalog();
      expect(catalog.manufacturers.map((m) => m.name), [
        'Hammer Strength',
        'Life Fitness',
        'Technogym',
      ]);
      final pull = catalog.exercises.singleWhere(
        (e) => e.id == 'exercise-lat-pulldown',
      );
      expect(
        catalog.compatibleModels(pull, 'manufacturer-life-fitness'),
        isEmpty,
      );
      expect(
        catalog.compatibleModels(pull, 'manufacturer-technogym').single.name,
        'Selection Lat Pulldown',
      );
      final workout = await repository.startWorkout('location-my-gym');
      await repository.addExercise(workout.id, pull);
      var entry = (await repository.loadActiveWorkout())!.exercises.single;
      expect(entry.exercise.manufacturer, isNull);
      await expectLater(
        repository.setExerciseMachine(
          entry.id,
          manufacturerId: 'manufacturer-life-fitness',
          machineModelId: 'machine-life-signature-press',
        ),
        throwsArgumentError,
      );
      await repository.setExerciseMachine(
        entry.id,
        manufacturerId: 'manufacturer-technogym',
        machineModelId: 'machine-technogym-selection-pulldown',
      );
      entry = (await repository.loadActiveWorkout())!.exercises.single;
      expect(entry.exercise.machineModel!.name, 'Selection Lat Pulldown');
      await repository.setExerciseMachine(
        entry.id,
        manufacturerId: 'manufacturer-life-fitness',
      );
      entry = (await repository.loadActiveWorkout())!.exercises.single;
      expect(entry.exercise.machineModel, isNull);
      expect(entry.exercise.manufacturer!.name, 'Life Fitness');
      await repository.setExerciseMachine(entry.id);
      expect(
        (await repository.loadActiveWorkout())!
            .exercises
            .single
            .exercise
            .manufacturerId,
        isNull,
      );
    },
  );

  test(
    'history labels use completed sets, deduplicate, sort and follow edits',
    () async {
      final catalog = await repository.loadCatalog();
      final workout = await repository.startWorkout('location-my-gym');
      for (final id in [
        'exercise-squat',
        'exercise-bench-press',
        'exercise-overhead-press',
        'exercise-leg-press',
      ]) {
        await repository.addExercise(
          workout.id,
          catalog.exercises.singleWhere((e) => e.id == id),
        );
      }
      final active = (await repository.loadActiveWorkout())!;
      for (final i in [0, 1, 3]) {
        await repository.completeSet(
          setId: active.exercises[i].sets.single.id,
          reps: 8,
          loadKg: 40,
        );
      }
      await repository.finishWorkout(workout.id);
      var history = (await repository.loadHistory()).single;
      expect(history.muscleLabels, ['Chest', 'Legs']);
      expect(history.exercises, hasLength(3));
      // Editing a completed workout changes labels on the next read.
      await repository.reopenSet(history.exercises[1].sets.single.id);
      expect((await repository.loadHistory()).single.muscleLabels, ['Legs']);
      await repository.completeSet(
        setId: history.exercises[1].sets.single.id,
        reps: 10,
        loadKg: 40,
      );
      await repository.removeExercise(history.exercises.first.id);
      history = (await repository.loadHistory()).single;
      expect(history.muscleLabels, ['Chest', 'Legs']);
      await repository.removeExercise(history.exercises.last.id);
      expect((await repository.loadHistory()).single.muscleLabels, ['Chest']);
    },
  );

  test(
    'execution and independent limbs overlap only with explicit metadata',
    () async {
      var catalog = await repository.loadCatalog();
      final squat = catalog.exercises.singleWhere(
        (e) => e.id == 'exercise-squat',
      );
      expect(squat.labels, [
        'Legs',
        'Knee dominant',
        'Barbell',
        'Both sides together',
      ]);
      expect(
        catalog.exercises
            .singleWhere((e) => e.id == 'exercise-cable-row')
            .equipmentType,
        EquipmentType.cable,
      );
      final unspecified = await repository.addCustomExercise(
        name: 'Barbell in name only',
        muscleGroupId: 'muscle-back',
        movementPatternId: 'pattern-horizontal-pull',
        equipmentType: EquipmentType.other,
      );
      expect(unspecified.labels, ['Back', 'Horizontal pulling']);
      final custom = await repository.addCustomExercise(
        name: 'My independent row',
        muscleGroupId: 'muscle-back',
        movementPatternId: 'pattern-horizontal-pull',
        equipmentType: EquipmentType.machine,
        execution: ExerciseExecution.unilateral,
      );
      final model = await repository.addMachineModel(
        manufacturerName: 'My brand',
        modelName: 'Row 1',
        exerciseId: custom.id,
        independentLimbs: true,
      );
      expect(
        custom.withMachine(model).labels,
        containsAll(['One side at a time', 'Independent arms/legs']),
      );
      await repository.initialize();
      catalog = await repository.loadCatalog();
      expect(
        catalog.exercises.singleWhere((e) => e.id == custom.id).execution,
        ExerciseExecution.unilateral,
      );
      expect(
        catalog.machines.singleWhere((m) => m.id == model.id).supports(squat),
        isFalse,
      );
      await expectLater(
        repository.addCustomExercise(
          name: 'Bad pairing',
          muscleGroupId: 'muscle-legs',
          movementPatternId: 'pattern-horizontal-pull',
          equipmentType: EquipmentType.barbell,
        ),
        throwsArgumentError,
      );
    },
  );

  test('archived exercises and models remain readable in history', () async {
    final custom = await repository.addCustomExercise(
      name: 'Old pull',
      muscleGroupId: 'muscle-back',
      movementPatternId: 'pattern-vertical-pull',
      equipmentType: EquipmentType.machine,
    );
    final model = await repository.addMachineModel(
      manufacturerName: 'Old maker',
      modelName: 'Old model',
      exerciseId: custom.id,
    );
    final session = await repository.startWorkout('location-my-gym');
    await repository.addExercise(session.id, custom.withMachine(model));
    final entry = (await repository.loadActiveWorkout())!.exercises.single;
    await repository.completeSet(setId: entry.sets.single.id, reps: 7);
    await repository.finishWorkout(session.id);
    await (db.update(db.exerciseVariations)
          ..where((t) => t.id.equals(custom.id)))
        .write(const ExerciseVariationsCompanion(archived: Value(true)));
    await (db.update(db.machineModels)..where((t) => t.id.equals(model.id)))
        .write(const MachineModelsCompanion(archived: Value(true)));
    expect(
      (await repository.loadHistory())
          .single
          .exercises
          .single
          .exercise
          .machineModel!
          .name,
      'Old model',
    );
    expect((await repository.loadHistory()).single.muscleLabels, ['Back']);
  });

  test(
    'optional selection survives disk reopen and routine round-trip',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'workout_optional_',
      );
      final file = File('${directory.path}/data.sqlite');
      var disk = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase(file)),
      );
      await disk.initialize();
      final pull = (await disk.loadCatalog()).exercises.singleWhere(
        (e) => e.id == 'exercise-lat-pulldown',
      );
      final session = await disk.startWorkout('location-my-gym');
      await disk.addExercise(session.id, pull);
      var entry = (await disk.loadActiveWorkout())!.exercises.single;
      await disk.close();
      disk = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase(file)),
      );
      await disk.initialize();
      expect(
        (await disk.loadActiveWorkout())!
            .exercises
            .single
            .exercise
            .manufacturerId,
        isNull,
      );
      await disk.setExerciseMachine(
        entry.id,
        manufacturerId: 'manufacturer-life-fitness',
      );
      await disk.completeSet(setId: entry.sets.single.id, reps: 10, loadKg: 30);
      await disk.finishWorkout(session.id);
      await disk.close();
      disk = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase(file)),
      );
      await disk.initialize();
      var history = (await disk.loadHistory()).single;
      expect(
        history.exercises.single.exercise.manufacturer!.name,
        'Life Fitness',
      );
      expect(history.exercises.single.exercise.machineModel, isNull);
      final routine = await disk.saveWorkoutAsRoutine(
        workout: history,
        name: 'Pull routine',
      );
      final fromRoutine = await disk.startWorkoutFromRoutine(
        'location-my-gym',
        routine.id,
      );
      expect(
        fromRoutine.exercises.single.exercise.manufacturer!.name,
        'Life Fitness',
      );
      await disk.setExerciseMachine(history.exercises.single.id);
      history = (await disk.loadHistory()).single;
      expect(history.exercises.single.exercise.manufacturerId, isNull);
      expect(history.muscleLabels, ['Back']);
      await disk.close();
      await directory.delete(recursive: true);
    },
  );
}
