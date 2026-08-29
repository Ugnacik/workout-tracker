import 'models.dart';

abstract interface class WorkoutRepository {
  Future<void> initialize();
  Future<CatalogSnapshot> loadCatalog();
  Future<List<GymLocationModel>> loadLocations();
  Future<WeightUnit> loadWeightUnit();
  Future<void> setWeightUnit(WeightUnit unit);
  Future<int> loadRestTimerSeconds();
  Future<void> setRestTimerSeconds(int seconds);
  Future<DateTime?> loadRestTimerDeadline();
  Future<void> setRestTimerDeadline(DateTime? deadline);
  Future<void> setDefaultLocation(String locationId);
  Future<GymLocationModel> addLocation(String name);
  Future<void> archiveLocation(String id);
  Future<ExerciseChoice> addCustomExercise({
    required String name,
    required String muscleGroupId,
    required String movementPatternId,
    required EquipmentType equipmentType,
  });
  Future<MovementPatternModel> addMovementPattern({
    required String name,
    required String muscleGroupId,
  });
  Future<MachineModelInfo> addMachineModel({
    required String manufacturerName,
    required String modelName,
  });
  Future<WorkoutSessionModel?> loadActiveWorkout();
  Future<List<WorkoutSessionModel>> loadHistory();
  Future<List<WorkoutRoutineModel>> loadRoutines();
  Future<WorkoutSessionModel> startWorkout(String gymLocationId);
  Future<WorkoutSessionModel> startWorkoutFromRoutine(
    String gymLocationId,
    String routineId,
  );
  Future<WorkoutRoutineModel> saveWorkoutAsRoutine({
    required WorkoutSessionModel workout,
    required String name,
  });
  Future<void> renameRoutine(String routineId, String name);
  Future<void> deleteRoutine(String routineId);
  Future<void> changeWorkoutLocation(String sessionId, String locationId);
  Future<void> addExercise(String sessionId, ExerciseChoice exercise);
  Future<void> removeExercise(String exerciseEntryId);
  Future<void> moveExercise(String exerciseEntryId, int direction);
  Future<void> addSet(String exerciseEntryId);
  Future<void> updateSet({
    required String setId,
    required int reps,
    double? loadKg,
    double? bodyweightAdjustmentKg,
    BodyweightAdjustment adjustment = BodyweightAdjustment.none,
  });
  Future<void> completeSet({
    required String setId,
    required int reps,
    double? loadKg,
    double? bodyweightAdjustmentKg,
    BodyweightAdjustment adjustment = BodyweightAdjustment.none,
  });
  Future<void> reopenSet(String setId);
  Future<void> duplicateSet(String setId);
  Future<void> removeSet(String setId);
  Future<void> moveSet(String setId, int direction);
  Future<FinishWorkoutResult> finishWorkout(String sessionId);
  Future<void> discardWorkout(String sessionId);
  Future<List<PreviousSetSnapshot>> previousSets(
    ExerciseChoice exercise, {
    required String gymLocationId,
  });
  Future<void> close();
}
