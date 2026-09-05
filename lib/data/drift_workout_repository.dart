import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/models.dart';
import '../domain/workout_repository.dart';
import 'app_database.dart';

class DriftWorkoutRepository implements WorkoutRepository {
  DriftWorkoutRepository(this.db, {Uuid? uuid}) : _uuid = uuid ?? const Uuid();

  final AppDatabase db;
  final Uuid _uuid;

  @override
  Future<void> initialize() async {
    await db.transaction(() async {
      await db.batch((batch) {
        batch.insertAll(db.muscleGroups, [
          MuscleGroupsCompanion.insert(
            id: 'muscle-back',
            name: 'Back',
            origin: 'seeded',
          ),
          MuscleGroupsCompanion.insert(
            id: 'muscle-chest',
            name: 'Chest',
            origin: 'seeded',
          ),
          MuscleGroupsCompanion.insert(
            id: 'muscle-shoulders',
            name: 'Shoulders',
            origin: 'seeded',
          ),
          MuscleGroupsCompanion.insert(
            id: 'muscle-legs',
            name: 'Legs',
            origin: 'seeded',
          ),
          MuscleGroupsCompanion.insert(
            id: 'muscle-arms',
            name: 'Arms',
            origin: 'seeded',
          ),
          MuscleGroupsCompanion.insert(
            id: 'muscle-core',
            name: 'Core',
            origin: 'seeded',
          ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(db.movementPatterns, [
          MovementPatternsCompanion.insert(
            id: 'pattern-vertical-pull',
            muscleGroupId: 'muscle-back',
            name: 'Vertical pulling',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-horizontal-pull',
            muscleGroupId: 'muscle-back',
            name: 'Horizontal pulling',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-elevation',
            muscleGroupId: 'muscle-back',
            name: 'Scapular elevation',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-rear-fly',
            muscleGroupId: 'muscle-back',
            name: 'Horizontal abduction',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-horizontal-push',
            muscleGroupId: 'muscle-chest',
            name: 'Horizontal pushing',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-vertical-push',
            muscleGroupId: 'muscle-shoulders',
            name: 'Vertical pushing',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-knee-dominant',
            muscleGroupId: 'muscle-legs',
            name: 'Knee dominant',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-hip-hinge',
            muscleGroupId: 'muscle-legs',
            name: 'Hip hinge',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-elbow-flexion',
            muscleGroupId: 'muscle-arms',
            name: 'Elbow flexion',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-elbow-extension',
            muscleGroupId: 'muscle-arms',
            name: 'Elbow extension',
            origin: 'seeded',
          ),
          MovementPatternsCompanion.insert(
            id: 'pattern-trunk-flexion',
            muscleGroupId: 'muscle-core',
            name: 'Trunk flexion',
            origin: 'seeded',
          ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(db.exerciseVariations, [
          ExerciseVariationsCompanion.insert(
            id: 'exercise-pull-up',
            movementPatternId: 'pattern-vertical-pull',
            name: 'Pull-up',
            equipmentType: 'bodyweight',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-chin-up',
            movementPatternId: 'pattern-vertical-pull',
            name: 'Chin-up',
            equipmentType: 'bodyweight',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-neutral-pull-up',
            movementPatternId: 'pattern-vertical-pull',
            name: 'Neutral-grip pull-up',
            equipmentType: 'bodyweight',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-lat-pulldown',
            movementPatternId: 'pattern-vertical-pull',
            name: 'Lat pulldown',
            equipmentType: 'machine',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-barbell-row',
            movementPatternId: 'pattern-horizontal-pull',
            name: 'Barbell row',
            equipmentType: 'barbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-cable-row',
            movementPatternId: 'pattern-horizontal-pull',
            name: 'Seated cable row',
            equipmentType: 'machine',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-shrug',
            movementPatternId: 'pattern-elevation',
            name: 'Dumbbell shrug',
            equipmentType: 'dumbbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-reverse-fly',
            movementPatternId: 'pattern-rear-fly',
            name: 'Reverse fly',
            equipmentType: 'dumbbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-bench-press',
            movementPatternId: 'pattern-horizontal-push',
            name: 'Bench press',
            equipmentType: 'barbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-overhead-press',
            movementPatternId: 'pattern-vertical-push',
            name: 'Overhead press',
            equipmentType: 'barbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-squat',
            movementPatternId: 'pattern-knee-dominant',
            name: 'Back squat',
            equipmentType: 'barbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-leg-press',
            movementPatternId: 'pattern-knee-dominant',
            name: 'Leg press',
            equipmentType: 'machine',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-rdl',
            movementPatternId: 'pattern-hip-hinge',
            name: 'Romanian deadlift',
            equipmentType: 'barbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-db-curl',
            movementPatternId: 'pattern-elbow-flexion',
            name: 'Dumbbell curl',
            equipmentType: 'dumbbell',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-triceps-pushdown',
            movementPatternId: 'pattern-elbow-extension',
            name: 'Triceps pushdown',
            equipmentType: 'machine',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-crunch',
            movementPatternId: 'pattern-trunk-flexion',
            name: 'Crunch',
            equipmentType: 'bodyweight',
            origin: 'seeded',
          ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(db.manufacturers, [
          ManufacturersCompanion.insert(
            id: 'manufacturer-technogym',
            name: 'Technogym',
            origin: 'seeded',
          ),
          ManufacturersCompanion.insert(
            id: 'manufacturer-hammer-strength',
            name: 'Hammer Strength',
            origin: 'seeded',
          ),
          ManufacturersCompanion.insert(
            id: 'manufacturer-life-fitness',
            name: 'Life Fitness',
            origin: 'seeded',
          ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(db.machineModels, [
          MachineModelsCompanion.insert(
            id: 'machine-technogym-selection-pulldown',
            manufacturerId: 'manufacturer-technogym',
            name: 'Selection Lat Pulldown',
            origin: 'seeded',
          ),
          MachineModelsCompanion.insert(
            id: 'machine-hammer-iso-row',
            manufacturerId: 'manufacturer-hammer-strength',
            name: 'Iso-Lateral Row',
            origin: 'seeded',
          ),
          MachineModelsCompanion.insert(
            id: 'machine-life-signature-press',
            manufacturerId: 'manufacturer-life-fitness',
            name: 'Signature Chest Press',
            origin: 'seeded',
          ),
        ], mode: InsertMode.insertOrIgnore);
      });
      await db.batch((batch) {
        batch.insertAll(db.exerciseVariations, [
          ExerciseVariationsCompanion.insert(
            id: 'exercise-machine-chest-press',
            movementPatternId: 'pattern-horizontal-push',
            name: 'Machine chest press',
            equipmentType: 'machine',
            origin: 'seeded',
          ),
          ExerciseVariationsCompanion.insert(
            id: 'exercise-machine-row',
            movementPatternId: 'pattern-horizontal-pull',
            name: 'Machine row',
            equipmentType: 'machine',
            origin: 'seeded',
          ),
        ], mode: InsertMode.insertOrIgnore);
        batch.insertAll(db.exerciseMachineCompatibility, [
          ExerciseMachineCompatibilityCompanion.insert(
            exerciseVariationId: 'exercise-lat-pulldown',
            machineModelId: 'machine-technogym-selection-pulldown',
          ),
          ExerciseMachineCompatibilityCompanion.insert(
            exerciseVariationId: 'exercise-machine-row',
            machineModelId: 'machine-hammer-iso-row',
          ),
          ExerciseMachineCompatibilityCompanion.insert(
            exerciseVariationId: 'exercise-machine-chest-press',
            machineModelId: 'machine-life-signature-press',
          ),
        ], mode: InsertMode.insertOrIgnore);
      });
      final metadataApplied = await (db.select(
        db.appSettings,
      )..where((t) => t.key.equals('catalogMetadataV4'))).getSingleOrNull();
      if (metadataApplied == null) {
        // Explicit catalog audit, never infer equipment/execution from display names.
        await (db.update(db.exerciseVariations)..where(
              (t) =>
                  t.origin.equals('seeded') &
                  t.id.isIn([
                    'exercise-pull-up',
                    'exercise-chin-up',
                    'exercise-neutral-pull-up',
                    'exercise-barbell-row',
                    'exercise-bench-press',
                    'exercise-overhead-press',
                    'exercise-squat',
                    'exercise-rdl',
                    'exercise-crunch',
                  ]),
            ))
            .write(
              const ExerciseVariationsCompanion(execution: Value('bilateral')),
            );
        await (db.update(db.exerciseVariations)..where(
              (t) =>
                  t.origin.equals('seeded') &
                  t.id.isIn([
                    'exercise-cable-row',
                    'exercise-triceps-pushdown',
                  ]),
            ))
            .write(
              const ExerciseVariationsCompanion(equipmentType: Value('cable')),
            );
        await (db.update(db.machineModels)..where(
              (t) =>
                  t.id.equals('machine-hammer-iso-row') &
                  t.origin.equals('seeded'),
            ))
            .write(const MachineModelsCompanion(independentLimbs: Value(true)));
        await db
            .into(db.appSettings)
            .insert(
              AppSettingsCompanion.insert(key: 'catalogMetadataV4', value: '1'),
            );
      }
      final locationCount = await db.gymLocations.count().getSingle();
      if (locationCount == 0) {
        await db
            .into(db.gymLocations)
            .insert(
              GymLocationsCompanion.insert(
                id: 'location-my-gym',
                name: 'My Gym',
                isDefault: Value(true),
              ),
            );
      }
      await db
          .into(db.appSettings)
          .insert(
            AppSettingsCompanion.insert(key: 'weightUnit', value: 'kilograms'),
            mode: InsertMode.insertOrIgnore,
          );
      await db
          .into(db.appSettings)
          .insert(
            AppSettingsCompanion.insert(key: 'themePreference', value: 'dark'),
            mode: InsertMode.insertOrIgnore,
          );
    });
  }

  @override
  Future<CatalogSnapshot> loadCatalog() => _loadCatalog();

  Future<CatalogSnapshot> _loadCatalog({bool includeArchived = false}) async {
    final muscles =
        await (db.select(db.muscleGroups)..where(
              (t) => t.archived.equals(false) | Constant(includeArchived),
            ))
            .get();
    final patterns =
        await (db.select(db.movementPatterns)..where(
              (t) => t.archived.equals(false) | Constant(includeArchived),
            ))
            .get();
    final variations =
        await (db.select(db.exerciseVariations)..where(
              (t) => t.archived.equals(false) | Constant(includeArchived),
            ))
            .get();
    final manufacturers =
        await (db.select(db.manufacturers)..where(
              (t) => t.archived.equals(false) | Constant(includeArchived),
            ))
            .get();
    final machineRows =
        await (db.select(db.machineModels)..where(
              (t) => t.archived.equals(false) | Constant(includeArchived),
            ))
            .get();
    final compatibility = await db
        .select(db.exerciseMachineCompatibility)
        .get();
    final muscleById = {for (final item in muscles) item.id: item};
    final patternById = {for (final item in patterns) item.id: item};
    final manufacturerById = {for (final item in manufacturers) item.id: item};
    final machines = machineRows.map((machine) {
      final maker = manufacturerById[machine.manufacturerId]!;
      return MachineModelInfo(
        id: machine.id,
        name: machine.name,
        manufacturerId: maker.id,
        manufacturerName: maker.name,
        independentLimbs: machine.independentLimbs,
        compatibleExerciseIds: compatibility
            .where((link) => link.machineModelId == machine.id)
            .map((link) => link.exerciseVariationId)
            .toList(),
      );
    }).toList()..sort((a, b) => a.displayName.compareTo(b.displayName));
    final exercises = variations.map((variation) {
      final pattern = patternById[variation.movementPatternId]!;
      final muscle = muscleById[pattern.muscleGroupId]!;
      return ExerciseChoice(
        id: variation.id,
        name: variation.name,
        muscleGroupId: muscle.id,
        muscleGroupName: muscle.name,
        movementPatternId: pattern.id,
        movementPatternName: pattern.name,
        equipmentType: EquipmentType.values.byName(variation.equipmentType),
        execution: variation.execution == null
            ? null
            : ExerciseExecution.values.byName(variation.execution!),
        independentLimbs: variation.independentLimbs,
      );
    }).toList()..sort((a, b) => a.name.compareTo(b.name));
    return CatalogSnapshot(
      muscles: muscles
          .map((e) => MuscleGroupModel(id: e.id, name: e.name))
          .toList(),
      patterns: patterns
          .map(
            (e) => MovementPatternModel(
              id: e.id,
              name: e.name,
              muscleGroupId: e.muscleGroupId,
            ),
          )
          .toList(),
      exercises: exercises,
      machines: machines,
      manufacturers:
          manufacturers
              .map((m) => ManufacturerInfo(id: m.id, name: m.name))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name)),
    );
  }

  @override
  Future<List<GymLocationModel>> loadLocations() async {
    final rows =
        await (db.select(db.gymLocations)
              ..where((t) => t.archived.equals(false))
              ..orderBy([
                (t) => OrderingTerm.desc(t.isDefault),
                (t) => OrderingTerm.asc(t.name),
              ]))
            .get();
    return rows
        .map(
          (e) =>
              GymLocationModel(id: e.id, name: e.name, isDefault: e.isDefault),
        )
        .toList();
  }

  @override
  Future<WeightUnit> loadWeightUnit() async {
    final row = await (db.select(
      db.appSettings,
    )..where((t) => t.key.equals('weightUnit'))).getSingleOrNull();
    return WeightUnit.values.byName(row?.value ?? 'kilograms');
  }

  @override
  Future<void> setWeightUnit(WeightUnit unit) => db
      .into(db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: 'weightUnit', value: unit.name),
      );

  @override
  Future<AppThemePreference> loadThemePreference() async {
    final row = await (db.select(
      db.appSettings,
    )..where((t) => t.key.equals('themePreference'))).getSingleOrNull();
    return AppThemePreference.values.byName(row?.value ?? 'dark');
  }

  @override
  Future<void> setThemePreference(AppThemePreference preference) => db
      .into(db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(
          key: 'themePreference',
          value: preference.name,
        ),
      );

  @override
  Future<int> loadRestTimerSeconds() async {
    final row = await (db.select(
      db.appSettings,
    )..where((t) => t.key.equals('restTimerSeconds'))).getSingleOrNull();
    return int.tryParse(row?.value ?? '') ?? 90;
  }

  @override
  Future<void> setRestTimerSeconds(int seconds) => db
      .into(db.appSettings)
      .insertOnConflictUpdate(
        AppSettingsCompanion.insert(key: 'restTimerSeconds', value: '$seconds'),
      );

  @override
  Future<DateTime?> loadRestTimerDeadline() async {
    final row = await (db.select(
      db.appSettings,
    )..where((t) => t.key.equals('restTimerDeadline'))).getSingleOrNull();
    return row == null ? null : DateTime.tryParse(row.value);
  }

  @override
  Future<void> setRestTimerDeadline(DateTime? deadline) async {
    if (deadline == null) {
      await (db.delete(
        db.appSettings,
      )..where((t) => t.key.equals('restTimerDeadline'))).go();
      return;
    }
    await db
        .into(db.appSettings)
        .insertOnConflictUpdate(
          AppSettingsCompanion.insert(
            key: 'restTimerDeadline',
            value: deadline.toUtc().toIso8601String(),
          ),
        );
  }

  @override
  Future<void> setDefaultLocation(String locationId) =>
      db.transaction(() async {
        await db
            .update(db.gymLocations)
            .write(GymLocationsCompanion(isDefault: Value(false)));
        await (db.update(db.gymLocations)
              ..where((t) => t.id.equals(locationId)))
            .write(GymLocationsCompanion(isDefault: Value(true)));
      });

  @override
  Future<GymLocationModel> addLocation(String name) async {
    final id = _uuid.v4();
    final hasLocations = await db.gymLocations.count().getSingle() > 0;
    await db
        .into(db.gymLocations)
        .insert(
          GymLocationsCompanion.insert(
            id: id,
            name: name.trim(),
            isDefault: Value(!hasLocations),
          ),
        );
    return GymLocationModel(
      id: id,
      name: name.trim(),
      isDefault: !hasLocations,
    );
  }

  @override
  Future<void> archiveLocation(String id) async {
    final location = await (db.select(
      db.gymLocations,
    )..where((t) => t.id.equals(id))).getSingle();
    if (location.isDefault) {
      throw StateError('Choose another default location first.');
    }
    await (db.update(db.gymLocations)..where((t) => t.id.equals(id))).write(
      GymLocationsCompanion(archived: Value(true)),
    );
  }

  @override
  Future<ExerciseChoice> addCustomExercise({
    required String name,
    required String muscleGroupId,
    required String movementPatternId,
    required EquipmentType equipmentType,
    ExerciseExecution? execution,
    bool independentLimbs = false,
  }) async {
    final pattern =
        await (db.select(db.movementPatterns)..where(
              (p) =>
                  p.id.equals(movementPatternId) &
                  p.muscleGroupId.equals(muscleGroupId),
            ))
            .getSingleOrNull();
    if (pattern == null) {
      throw ArgumentError(
        'Movement pattern must belong to the selected muscle.',
      );
    }
    final id = _uuid.v4();
    await db
        .into(db.exerciseVariations)
        .insert(
          ExerciseVariationsCompanion.insert(
            id: id,
            movementPatternId: movementPatternId,
            name: name.trim(),
            equipmentType: equipmentType.name,
            origin: 'user',
            execution: Value(execution?.name),
            independentLimbs: Value(independentLimbs),
          ),
        );
    return (await loadCatalog()).exercises.firstWhere((e) => e.id == id);
  }

  @override
  Future<MovementPatternModel> addMovementPattern({
    required String name,
    required String muscleGroupId,
  }) async {
    final id = _uuid.v4();
    await db
        .into(db.movementPatterns)
        .insert(
          MovementPatternsCompanion.insert(
            id: id,
            muscleGroupId: muscleGroupId,
            name: name.trim(),
            origin: 'user',
          ),
        );
    return MovementPatternModel(
      id: id,
      name: name.trim(),
      muscleGroupId: muscleGroupId,
    );
  }

  @override
  Future<MachineModelInfo> addMachineModel({
    required String manufacturerName,
    required String modelName,
    String? exerciseId,
    bool independentLimbs = false,
  }) async {
    if (manufacturerName.trim().isEmpty || modelName.trim().isEmpty) {
      throw ArgumentError('Manufacturer and model names cannot be empty.');
    }
    if (exerciseId != null) {
      final exercise = (await loadCatalog()).exercises.firstWhere(
        (e) => e.id == exerciseId,
      );
      if (!exercise.supportsMachineSelection) {
        throw ArgumentError('This exercise does not use a machine.');
      }
    }
    final existing = await db.select(db.manufacturers).get();
    var manufacturer = existing
        .where(
          (e) => e.name.toLowerCase() == manufacturerName.trim().toLowerCase(),
        )
        .firstOrNull;
    if (manufacturer == null) {
      final id = _uuid.v4();
      await db
          .into(db.manufacturers)
          .insert(
            ManufacturersCompanion.insert(
              id: id,
              name: manufacturerName.trim(),
              origin: 'user',
            ),
          );
      manufacturer = await (db.select(
        db.manufacturers,
      )..where((t) => t.id.equals(id))).getSingle();
    }
    final machineId = _uuid.v4();
    await db
        .into(db.machineModels)
        .insert(
          MachineModelsCompanion.insert(
            id: machineId,
            manufacturerId: manufacturer.id,
            name: modelName.trim(),
            independentLimbs: Value(independentLimbs),
            origin: 'user',
          ),
        );
    if (exerciseId != null) {
      await db
          .into(db.exerciseMachineCompatibility)
          .insert(
            ExerciseMachineCompatibilityCompanion.insert(
              exerciseVariationId: exerciseId,
              machineModelId: machineId,
            ),
          );
    }
    return MachineModelInfo(
      compatibleExerciseIds: [?exerciseId],
      independentLimbs: independentLimbs,
      id: machineId,
      name: modelName.trim(),
      manufacturerId: manufacturer.id,
      manufacturerName: manufacturer.name,
    );
  }

  @override
  Future<WorkoutSessionModel?> loadActiveWorkout() async {
    final row =
        await (db.select(db.workoutSessions)
              ..where((t) => t.finishedAt.isNull())
              ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
            .getSingleOrNull();
    return row == null ? null : _hydrateSession(row);
  }

  @override
  Future<List<WorkoutSessionModel>> loadHistory() async {
    final rows =
        await (db.select(db.workoutSessions)
              ..where((t) => t.finishedAt.isNotNull())
              ..orderBy([(t) => OrderingTerm.desc(t.finishedAt)]))
            .get();
    return Future.wait(rows.map(_hydrateSession));
  }

  @override
  Future<List<WorkoutRoutineModel>> loadRoutines() async {
    final rows = await (db.select(
      db.workoutRoutines,
    )..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).get();
    return Future.wait(rows.map(_hydrateRoutine));
  }

  @override
  Future<WorkoutSessionModel> startWorkout(String gymLocationId) async {
    final current = await loadActiveWorkout();
    if (current != null) return current;
    final id = _uuid.v4();
    final row = WorkoutSessionsCompanion.insert(
      id: id,
      gymLocationId: gymLocationId,
      startedAt: DateTime.now(),
    );
    await db.into(db.workoutSessions).insert(row);
    return (await loadActiveWorkout())!;
  }

  @override
  Future<WorkoutSessionModel> startWorkoutFromRoutine(
    String gymLocationId,
    String routineId,
  ) async {
    final current = await loadActiveWorkout();
    if (current != null) return current;
    final routine = await _hydrateRoutine(
      await (db.select(
        db.workoutRoutines,
      )..where((t) => t.id.equals(routineId))).getSingle(),
    );
    final sessionId = _uuid.v4();
    await db.transaction(() async {
      await db
          .into(db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: sessionId,
              gymLocationId: gymLocationId,
              startedAt: DateTime.now(),
            ),
          );
      for (final routineExercise in routine.exercises) {
        final entryId = _uuid.v4();
        await db
            .into(db.workoutEntries)
            .insert(
              WorkoutEntriesCompanion.insert(
                id: entryId,
                sessionId: sessionId,
                exerciseVariationId: routineExercise.exercise.id,
                machineModelId: Value(
                  routineExercise.exercise.machineModel?.id,
                ),
                manufacturerId: Value(routineExercise.exercise.manufacturerId),
                position: routineExercise.position,
              ),
            );
        for (
          var position = 0;
          position < routineExercise.setCount;
          position++
        ) {
          await db
              .into(db.loggedSets)
              .insert(
                LoggedSetsCompanion.insert(
                  id: _uuid.v4(),
                  workoutEntryId: entryId,
                  position: position,
                ),
              );
        }
      }
    });
    return (await loadActiveWorkout())!;
  }

  @override
  Future<WorkoutRoutineModel> saveWorkoutAsRoutine({
    required WorkoutSessionModel workout,
    required String name,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await db.transaction(() async {
      await db
          .into(db.workoutRoutines)
          .insert(
            WorkoutRoutinesCompanion.insert(
              id: id,
              name: name.trim(),
              createdAt: now,
              updatedAt: now,
            ),
          );
      for (final entry in workout.exercises) {
        await db
            .into(db.routineExercises)
            .insert(
              RoutineExercisesCompanion.insert(
                id: _uuid.v4(),
                routineId: id,
                exerciseVariationId: entry.exercise.id,
                machineModelId: Value(entry.exercise.machineModel?.id),
                manufacturerId: Value(entry.exercise.manufacturerId),
                position: entry.position,
                setCount: Value(entry.sets.isEmpty ? 1 : entry.sets.length),
              ),
            );
      }
    });
    return _hydrateRoutine(
      await (db.select(
        db.workoutRoutines,
      )..where((t) => t.id.equals(id))).getSingle(),
    );
  }

  @override
  Future<void> renameRoutine(String routineId, String name) =>
      (db.update(
        db.workoutRoutines,
      )..where((t) => t.id.equals(routineId))).write(
        WorkoutRoutinesCompanion(
          name: Value(name.trim()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  @override
  Future<void> deleteRoutine(String routineId) => (db.delete(
    db.workoutRoutines,
  )..where((t) => t.id.equals(routineId))).go();

  @override
  Future<void> changeWorkoutLocation(String sessionId, String locationId) =>
      (db.update(db.workoutSessions)..where((t) => t.id.equals(sessionId)))
          .write(WorkoutSessionsCompanion(gymLocationId: Value(locationId)));

  @override
  Future<void> addExercise(String sessionId, ExerciseChoice exercise) async {
    final rows = await (db.select(
      db.workoutEntries,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    final entryId = _uuid.v4();
    await db
        .into(db.workoutEntries)
        .insert(
          WorkoutEntriesCompanion.insert(
            id: entryId,
            sessionId: sessionId,
            exerciseVariationId: exercise.id,
            machineModelId: Value(exercise.machineModel?.id),
            manufacturerId: Value(exercise.manufacturerId),
            position: rows.length,
          ),
        );
    await addSet(entryId);
  }

  @override
  Future<void> setExerciseMachine(
    String entryId, {
    String? manufacturerId,
    String? machineModelId,
  }) async {
    final entry = await (db.select(
      db.workoutEntries,
    )..where((t) => t.id.equals(entryId))).getSingle();
    final catalog = await _loadCatalog(includeArchived: true);
    final exercise = catalog.exercises.firstWhere(
      (e) => e.id == entry.exerciseVariationId,
    );
    if (manufacturerId != null) {
      if (!exercise.supportsMachineSelection ||
          !catalog.manufacturers.any((m) => m.id == manufacturerId)) {
        throw ArgumentError('Select a valid manufacturer for this exercise.');
      }
    }
    if (machineModelId != null &&
        !catalog
            .compatibleModels(exercise, manufacturerId)
            .any((m) => m.id == machineModelId)) {
      // Legacy mismatches remain readable and can be cleared, but cannot be newly assigned.
      if (entry.machineModelId != machineModelId ||
          entry.manufacturerId != manufacturerId) {
        throw ArgumentError(
          'The model is not compatible with this exercise and manufacturer.',
        );
      }
    }
    await (db.update(
      db.workoutEntries,
    )..where((t) => t.id.equals(entryId))).write(
      WorkoutEntriesCompanion(
        manufacturerId: Value(manufacturerId),
        machineModelId: Value(machineModelId),
      ),
    );
  }

  @override
  Future<void> removeExercise(String exerciseEntryId) async {
    final entry = await (db.select(
      db.workoutEntries,
    )..where((t) => t.id.equals(exerciseEntryId))).getSingle();
    await db.transaction(() async {
      await (db.delete(
        db.loggedSets,
      )..where((t) => t.workoutEntryId.equals(exerciseEntryId))).go();
      await (db.delete(
        db.workoutEntries,
      )..where((t) => t.id.equals(exerciseEntryId))).go();
      await _normalizeExercises(entry.sessionId);
    });
  }

  @override
  Future<void> moveExercise(String exerciseEntryId, int direction) async {
    final item = await (db.select(
      db.workoutEntries,
    )..where((t) => t.id.equals(exerciseEntryId))).getSingle();
    final rows =
        await (db.select(db.workoutEntries)
              ..where((t) => t.sessionId.equals(item.sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final index = rows.indexWhere((e) => e.id == exerciseEntryId);
    final target = index + direction;
    if (target < 0 || target >= rows.length) return;
    await db.transaction(() async {
      await (db.update(db.workoutEntries)
            ..where((t) => t.id.equals(rows[index].id)))
          .write(WorkoutEntriesCompanion(position: Value(target)));
      await (db.update(db.workoutEntries)
            ..where((t) => t.id.equals(rows[target].id)))
          .write(WorkoutEntriesCompanion(position: Value(index)));
    });
  }

  @override
  Future<void> addSet(String exerciseEntryId) async {
    final rows = await (db.select(
      db.loggedSets,
    )..where((t) => t.workoutEntryId.equals(exerciseEntryId))).get();
    await db
        .into(db.loggedSets)
        .insert(
          LoggedSetsCompanion.insert(
            id: _uuid.v4(),
            workoutEntryId: exerciseEntryId,
            position: rows.length,
          ),
        );
  }

  @override
  Future<void> updateSet({
    required String setId,
    required int reps,
    double? loadKg,
    double? bodyweightAdjustmentKg,
    BodyweightAdjustment adjustment = BodyweightAdjustment.none,
  }) => (db.update(db.loggedSets)..where((t) => t.id.equals(setId))).write(
    LoggedSetsCompanion(
      reps: Value(reps),
      loadKg: Value(loadKg),
      bodyweightAdjustmentKg: Value(bodyweightAdjustmentKg),
      adjustment: Value(adjustment.name),
    ),
  );

  @override
  Future<void> completeSet({
    required String setId,
    required int reps,
    double? loadKg,
    double? bodyweightAdjustmentKg,
    BodyweightAdjustment adjustment = BodyweightAdjustment.none,
  }) => (db.update(db.loggedSets)..where((t) => t.id.equals(setId))).write(
    LoggedSetsCompanion(
      reps: Value(reps),
      loadKg: Value(loadKg),
      bodyweightAdjustmentKg: Value(bodyweightAdjustmentKg),
      adjustment: Value(adjustment.name),
      isCompleted: const Value(true),
      completedAt: Value(DateTime.now()),
    ),
  );

  @override
  Future<void> reopenSet(String setId) =>
      (db.update(db.loggedSets)..where((t) => t.id.equals(setId))).write(
        const LoggedSetsCompanion(
          isCompleted: Value(false),
          completedAt: Value(null),
        ),
      );

  @override
  Future<void> duplicateSet(String setId) async {
    final source = await (db.select(
      db.loggedSets,
    )..where((t) => t.id.equals(setId))).getSingle();
    final siblings = await (db.select(
      db.loggedSets,
    )..where((t) => t.workoutEntryId.equals(source.workoutEntryId))).get();
    await db
        .into(db.loggedSets)
        .insert(
          LoggedSetsCompanion.insert(
            id: _uuid.v4(),
            workoutEntryId: source.workoutEntryId,
            position: siblings.length,
            reps: Value(source.reps),
            loadKg: Value(source.loadKg),
            bodyweightAdjustmentKg: Value(source.bodyweightAdjustmentKg),
            adjustment: Value(source.adjustment),
          ),
        );
  }

  @override
  Future<void> removeSet(String setId) async {
    final item = await (db.select(
      db.loggedSets,
    )..where((t) => t.id.equals(setId))).getSingle();
    await (db.delete(db.loggedSets)..where((t) => t.id.equals(setId))).go();
    await _normalizeSets(item.workoutEntryId);
  }

  @override
  Future<void> moveSet(String setId, int direction) async {
    final item = await (db.select(
      db.loggedSets,
    )..where((t) => t.id.equals(setId))).getSingle();
    final rows =
        await (db.select(db.loggedSets)
              ..where((t) => t.workoutEntryId.equals(item.workoutEntryId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final index = rows.indexWhere((e) => e.id == setId);
    final target = index + direction;
    if (target < 0 || target >= rows.length) return;
    await db.transaction(() async {
      await (db.update(db.loggedSets)
            ..where((t) => t.id.equals(rows[index].id)))
          .write(LoggedSetsCompanion(position: Value(target)));
      await (db.update(db.loggedSets)
            ..where((t) => t.id.equals(rows[target].id)))
          .write(LoggedSetsCompanion(position: Value(index)));
    });
  }

  @override
  Future<FinishWorkoutResult> finishWorkout(
    String sessionId, {
    String? name,
  }) async {
    final normalizedName = name?.trim();
    final entries = await (db.select(
      db.workoutEntries,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    var omitted = 0;
    await db.transaction(() async {
      for (final entry in entries) {
        final incomplete =
            await (db.select(db.loggedSets)..where(
                  (t) =>
                      t.workoutEntryId.equals(entry.id) &
                      t.isCompleted.equals(false),
                ))
                .get();
        omitted += incomplete.length;
        await (db.delete(db.loggedSets)..where(
              (t) =>
                  t.workoutEntryId.equals(entry.id) &
                  t.isCompleted.equals(false),
            ))
            .go();
        await _normalizeSets(entry.id);
        final remaining = await (db.select(
          db.loggedSets,
        )..where((t) => t.workoutEntryId.equals(entry.id))).get();
        if (remaining.isEmpty) {
          await (db.delete(
            db.workoutEntries,
          )..where((t) => t.id.equals(entry.id))).go();
        }
      }
      await _normalizeExercises(sessionId);
      await (db.update(
        db.workoutSessions,
      )..where((t) => t.id.equals(sessionId))).write(
        WorkoutSessionsCompanion(
          name: Value(
            normalizedName == null || normalizedName.isEmpty
                ? null
                : normalizedName,
          ),
          finishedAt: Value(DateTime.now()),
        ),
      );
    });
    return FinishWorkoutResult(omittedSetCount: omitted);
  }

  @override
  Future<void> discardWorkout(String sessionId) async {
    final entries = await (db.select(
      db.workoutEntries,
    )..where((t) => t.sessionId.equals(sessionId))).get();
    await db.transaction(() async {
      for (final entry in entries) {
        await (db.delete(
          db.loggedSets,
        )..where((t) => t.workoutEntryId.equals(entry.id))).go();
      }
      await (db.delete(
        db.workoutEntries,
      )..where((t) => t.sessionId.equals(sessionId))).go();
      await (db.delete(
        db.workoutSessions,
      )..where((t) => t.id.equals(sessionId))).go();
    });
  }

  @override
  Future<List<PreviousSetSnapshot>> previousSets(
    ExerciseChoice exercise, {
    required String gymLocationId,
  }) async {
    final history = await loadHistory();
    for (final session in history) {
      if (session.gymLocationId != gymLocationId) continue;
      for (final entry in session.exercises) {
        if (entry.exercise.id == exercise.id &&
            entry.exercise.machineModel?.id == exercise.machineModel?.id &&
            entry.exercise.manufacturerId == exercise.manufacturerId &&
            entry.sets.any((set) => set.isCompleted)) {
          final performedAt = session.finishedAt ?? session.startedAt;
          return entry.sets
              .where((set) => set.isCompleted)
              .map(
                (set) => PreviousSetSnapshot(
                  position: set.position,
                  reps: set.reps,
                  performedAt: performedAt,
                  loadKg: set.loadKg,
                  bodyweightAdjustmentKg: set.bodyweightAdjustmentKg,
                  adjustment: set.adjustment,
                ),
              )
              .toList();
        }
      }
    }
    return const [];
  }

  Future<WorkoutSessionModel> _hydrateSession(WorkoutSession row) async {
    final catalog = await _loadCatalog(includeArchived: true);
    final locations = await loadLocations();
    final location =
        locations.where((e) => e.id == row.gymLocationId).firstOrNull ??
        GymLocationModel(
          id: row.gymLocationId,
          name: 'Archived location',
          isDefault: false,
        );
    final entryRows =
        await (db.select(db.workoutEntries)
              ..where((t) => t.sessionId.equals(row.id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final entries = <WorkoutExerciseModel>[];
    for (final entry in entryRows) {
      var exercise = catalog.exercises.firstWhere(
        (e) => e.id == entry.exerciseVariationId,
      );
      if (entry.machineModelId != null) {
        exercise = exercise.withMachine(
          catalog.machines
              .where((e) => e.id == entry.machineModelId)
              .firstOrNull,
        );
      }
      if (entry.manufacturerId != null) {
        exercise = exercise.withEquipmentSelection(
          catalog.manufacturers
              .where((m) => m.id == entry.manufacturerId)
              .firstOrNull,
          exercise.machineModel,
        );
      }
      final setRows =
          await (db.select(db.loggedSets)
                ..where((t) => t.workoutEntryId.equals(entry.id))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();
      entries.add(
        WorkoutExerciseModel(
          id: entry.id,
          position: entry.position,
          exercise: exercise,
          sets: setRows
              .map(
                (set) => WorkoutSetModel(
                  id: set.id,
                  position: set.position,
                  reps: set.reps,
                  loadKg: set.loadKg,
                  bodyweightAdjustmentKg: set.bodyweightAdjustmentKg,
                  adjustment: BodyweightAdjustment.values.byName(
                    set.adjustment,
                  ),
                  isCompleted: set.isCompleted,
                  completedAt: set.completedAt,
                ),
              )
              .toList(),
        ),
      );
    }
    return WorkoutSessionModel(
      id: row.id,
      name: row.name,
      gymLocationId: row.gymLocationId,
      gymLocationName: location.name,
      startedAt: row.startedAt,
      finishedAt: row.finishedAt,
      exercises: entries,
    );
  }

  Future<WorkoutRoutineModel> _hydrateRoutine(WorkoutRoutine row) async {
    final catalog = await _loadCatalog(includeArchived: true);
    final entries =
        await (db.select(db.routineExercises)
              ..where((t) => t.routineId.equals(row.id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    return WorkoutRoutineModel(
      id: row.id,
      name: row.name,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      exercises: entries.map((entry) {
        var exercise = catalog.exercises.firstWhere(
          (candidate) => candidate.id == entry.exerciseVariationId,
        );
        if (entry.machineModelId != null) {
          exercise = exercise.withMachine(
            catalog.machines
                .where((machine) => machine.id == entry.machineModelId)
                .firstOrNull,
          );
        }
        if (entry.manufacturerId != null) {
          exercise = exercise.withEquipmentSelection(
            catalog.manufacturers
                .where((m) => m.id == entry.manufacturerId)
                .firstOrNull,
            exercise.machineModel,
          );
        }
        return RoutineExerciseModel(
          id: entry.id,
          position: entry.position,
          exercise: exercise,
          setCount: entry.setCount,
        );
      }).toList(),
    );
  }

  Future<void> _normalizeExercises(String sessionId) async {
    final rows =
        await (db.select(db.workoutEntries)
              ..where((t) => t.sessionId.equals(sessionId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    for (var index = 0; index < rows.length; index++) {
      await (db.update(db.workoutEntries)
            ..where((t) => t.id.equals(rows[index].id)))
          .write(WorkoutEntriesCompanion(position: Value(index)));
    }
  }

  Future<void> _normalizeSets(String entryId) async {
    final rows =
        await (db.select(db.loggedSets)
              ..where((t) => t.workoutEntryId.equals(entryId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    for (var index = 0; index < rows.length; index++) {
      await (db.update(db.loggedSets)
            ..where((t) => t.id.equals(rows[index].id)))
          .write(LoggedSetsCompanion(position: Value(index)));
    }
  }

  @override
  Future<void> close() => db.close();
}
