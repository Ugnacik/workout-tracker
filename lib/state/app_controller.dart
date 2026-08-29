import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/drift_workout_repository.dart';
import '../domain/models.dart';
import '../domain/workout_repository.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final repositoryProvider = Provider<WorkoutRepository>(
  (ref) => DriftWorkoutRepository(ref.watch(databaseProvider)),
);

final appControllerProvider = ChangeNotifierProvider<AppController>(
  (ref) => AppController(ref.watch(repositoryProvider))..initialize(),
);

class AppController extends ChangeNotifier {
  AppController(this.repository);

  final WorkoutRepository repository;
  bool isLoading = true;
  Object? error;
  CatalogSnapshot catalog = const CatalogSnapshot(
    muscles: [],
    patterns: [],
    exercises: [],
    machines: [],
  );
  List<GymLocationModel> locations = const [];
  List<WorkoutSessionModel> history = const [];
  WorkoutSessionModel? activeWorkout;
  WeightUnit weightUnit = WeightUnit.kilograms;

  GymLocationModel? get defaultLocation =>
      locations.where((location) => location.isDefault).firstOrNull ??
      locations.firstOrNull;

  Future<void> initialize() async {
    try {
      await repository.initialize();
      await refresh();
    } catch (exception) {
      error = exception;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    catalog = await repository.loadCatalog();
    locations = await repository.loadLocations();
    weightUnit = await repository.loadWeightUnit();
    activeWorkout = await repository.loadActiveWorkout();
    history = await repository.loadHistory();
    error = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> startWorkout() async {
    final location = defaultLocation;
    if (location == null) return;
    activeWorkout = await repository.startWorkout(location.id);
    notifyListeners();
  }

  Future<void> changeWorkoutLocation(String locationId) async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.changeWorkoutLocation(workout.id, locationId);
    await _refreshWorkout();
  }

  Future<String?> previousPerformance(ExerciseChoice exercise) =>
      repository.previousPerformance(exercise);

  Future<void> addExercise(ExerciseChoice exercise) async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.addExercise(workout.id, exercise);
    await _refreshWorkout();
  }

  Future<void> removeExercise(String id) async {
    await repository.removeExercise(id);
    await _refreshWorkout();
  }

  Future<void> moveExercise(String id, int direction) async {
    await repository.moveExercise(id, direction);
    await _refreshWorkout();
  }

  Future<void> addSet(String entryId) async {
    await repository.addSet(entryId);
    await _refreshWorkout();
  }

  Future<void> updateSet({
    required String setId,
    required int reps,
    double? loadKg,
    double? bodyweightAdjustmentKg,
    BodyweightAdjustment adjustment = BodyweightAdjustment.none,
  }) => repository.updateSet(
    setId: setId,
    reps: reps,
    loadKg: loadKg,
    bodyweightAdjustmentKg: bodyweightAdjustmentKg,
    adjustment: adjustment,
  );

  Future<void> duplicateSet(String id) async {
    await repository.duplicateSet(id);
    await _refreshWorkout();
  }

  Future<void> removeSet(String id) async {
    await repository.removeSet(id);
    await _refreshWorkout();
  }

  Future<void> moveSet(String id, int direction) async {
    await repository.moveSet(id, direction);
    await _refreshWorkout();
  }

  Future<void> finishWorkout() async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.finishWorkout(workout.id);
    await refresh();
  }

  Future<void> discardWorkout() async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.discardWorkout(workout.id);
    await refresh();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    await repository.setWeightUnit(unit);
    weightUnit = unit;
    notifyListeners();
  }

  Future<void> setDefaultLocation(String id) async {
    await repository.setDefaultLocation(id);
    locations = await repository.loadLocations();
    notifyListeners();
  }

  Future<void> addLocation(String name) async {
    await repository.addLocation(name);
    locations = await repository.loadLocations();
    notifyListeners();
  }

  Future<ExerciseChoice> addCustomExercise({
    required String name,
    required String muscleGroupId,
    required String movementPatternId,
    required EquipmentType equipmentType,
  }) async {
    final exercise = await repository.addCustomExercise(
      name: name,
      muscleGroupId: muscleGroupId,
      movementPatternId: movementPatternId,
      equipmentType: equipmentType,
    );
    catalog = await repository.loadCatalog();
    notifyListeners();
    return exercise;
  }

  Future<MovementPatternModel> addMovementPattern({
    required String name,
    required String muscleGroupId,
  }) async {
    final pattern = await repository.addMovementPattern(
      name: name,
      muscleGroupId: muscleGroupId,
    );
    catalog = await repository.loadCatalog();
    notifyListeners();
    return pattern;
  }

  Future<MachineModelInfo> addMachineModel({
    required String manufacturerName,
    required String modelName,
  }) async {
    final machine = await repository.addMachineModel(
      manufacturerName: manufacturerName,
      modelName: modelName,
    );
    catalog = await repository.loadCatalog();
    notifyListeners();
    return machine;
  }

  Future<void> _refreshWorkout() async {
    activeWorkout = await repository.loadActiveWorkout();
    notifyListeners();
  }
}
