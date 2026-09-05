import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/drift_workout_repository.dart';
import '../domain/models.dart';
import '../domain/workout_repository.dart';
import '../services/rest_timer_service.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final repositoryProvider = Provider<WorkoutRepository>(
  (ref) => DriftWorkoutRepository(ref.watch(databaseProvider)),
);

final restTimerNotificationsProvider = Provider<RestTimerNotifications>(
  (ref) => LocalRestTimerNotifications(),
);

final restTimerProvider = ChangeNotifierProvider<RestTimerService>((ref) {
  return RestTimerService(
    ref.watch(repositoryProvider),
    ref.watch(restTimerNotificationsProvider),
  );
});

final appControllerProvider = ChangeNotifierProvider<AppController>(
  (ref) =>
      AppController(ref.watch(repositoryProvider), ref.read(restTimerProvider))
        ..initialize(),
);

class AppController extends ChangeNotifier {
  AppController(this.repository, this.restTimer);

  final WorkoutRepository repository;
  final RestTimerService restTimer;
  final Map<String, Future<void>> _pendingSetWrites = {};
  bool isLoading = true;
  Object? error;
  Object? actionError;
  CatalogSnapshot catalog = const CatalogSnapshot(
    muscles: [],
    patterns: [],
    exercises: [],
    machines: [],
  );
  List<GymLocationModel> locations = const [];
  List<WorkoutSessionModel> history = const [];
  List<WorkoutRoutineModel> routines = const [];
  WorkoutSessionModel? activeWorkout;
  WeightUnit weightUnit = WeightUnit.kilograms;
  AppThemePreference themePreference = AppThemePreference.dark;

  GymLocationModel? get defaultLocation =>
      locations.where((location) => location.isDefault).firstOrNull ??
      locations.firstOrNull;

  Future<void> initialize() async {
    try {
      await repository.initialize();
      await restTimer.initialize();
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
    themePreference = await repository.loadThemePreference();
    activeWorkout = await repository.loadActiveWorkout();
    history = await repository.loadHistory();
    routines = await repository.loadRoutines();
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

  Future<void> startWorkoutFromRoutine(String routineId) async {
    final location = defaultLocation;
    if (location == null) return;
    activeWorkout = await repository.startWorkoutFromRoutine(
      location.id,
      routineId,
    );
    notifyListeners();
  }

  Future<void> changeWorkoutLocation(String locationId) async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.changeWorkoutLocation(workout.id, locationId);
    await _refreshWorkout();
  }

  Future<List<PreviousSetSnapshot>> previousSets(
    ExerciseChoice exercise,
  ) async {
    final gymLocationId = activeWorkout?.gymLocationId;
    if (gymLocationId == null) return const [];
    return repository.previousSets(exercise, gymLocationId: gymLocationId);
  }

  Future<void> addExercise(ExerciseChoice exercise) async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.addExercise(workout.id, exercise);
    await _refreshWorkout();
  }

  Future<void> setExerciseMachine(
    String entryId, {
    String? manufacturerId,
    String? machineModelId,
  }) async {
    await flushSetWrites();
    await repository.setExerciseMachine(
      entryId,
      manufacturerId: manufacturerId,
      machineModelId: machineModelId,
    );
    await refresh();
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
  }) => _enqueueSetWrite(
    setId,
    () => repository.updateSet(
      setId: setId,
      reps: reps,
      loadKg: loadKg,
      bodyweightAdjustmentKg: bodyweightAdjustmentKg,
      adjustment: adjustment,
    ),
  );

  Future<void> completeSet({
    required String setId,
    required int reps,
    double? loadKg,
    double? bodyweightAdjustmentKg,
    BodyweightAdjustment adjustment = BodyweightAdjustment.none,
  }) async {
    await flushSetWrites(setId);
    await repository.completeSet(
      setId: setId,
      reps: reps,
      loadKg: loadKg,
      bodyweightAdjustmentKg: bodyweightAdjustmentKg,
      adjustment: adjustment,
    );
    await _refreshWorkout();
    await restTimer.start();
  }

  Future<void> reopenSet(String setId) async {
    await flushSetWrites(setId);
    await repository.reopenSet(setId);
    await _refreshWorkout();
  }

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

  Future<FinishWorkoutResult?> finishWorkout({String? name}) async {
    final workout = activeWorkout;
    if (workout == null) return null;
    await flushSetWrites();
    final result = await repository.finishWorkout(workout.id, name: name);
    await restTimer.skip();
    await refresh();
    return result;
  }

  Future<void> discardWorkout() async {
    final workout = activeWorkout;
    if (workout == null) return;
    await repository.discardWorkout(workout.id);
    await restTimer.skip();
    await refresh();
  }

  Future<void> setWeightUnit(WeightUnit unit) async {
    await flushSetWrites();
    await repository.setWeightUnit(unit);
    weightUnit = unit;
    activeWorkout = await repository.loadActiveWorkout();
    notifyListeners();
  }

  Future<void> setThemePreference(AppThemePreference preference) async {
    await repository.setThemePreference(preference);
    themePreference = preference;
    notifyListeners();
  }

  void clearActionError() {
    if (actionError == null) return;
    actionError = null;
    notifyListeners();
  }

  Future<void> setRestTimerSeconds(int seconds) =>
      restTimer.setDuration(seconds);

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
    ExerciseExecution? execution,
    bool independentLimbs = false,
  }) async {
    final exercise = await repository.addCustomExercise(
      name: name,
      muscleGroupId: muscleGroupId,
      movementPatternId: movementPatternId,
      equipmentType: equipmentType,
      execution: execution,
      independentLimbs: independentLimbs,
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
    String? exerciseId,
    bool independentLimbs = false,
  }) async {
    final machine = await repository.addMachineModel(
      manufacturerName: manufacturerName,
      modelName: modelName,
      exerciseId: exerciseId,
      independentLimbs: independentLimbs,
    );
    catalog = await repository.loadCatalog();
    notifyListeners();
    return machine;
  }

  Future<void> saveWorkoutAsRoutine(
    WorkoutSessionModel workout,
    String name,
  ) async {
    await flushSetWrites();
    await repository.saveWorkoutAsRoutine(workout: workout, name: name);
    routines = await repository.loadRoutines();
    notifyListeners();
  }

  Future<void> renameRoutine(String id, String name) async {
    await repository.renameRoutine(id, name);
    routines = await repository.loadRoutines();
    notifyListeners();
  }

  Future<void> deleteRoutine(String id) async {
    await repository.deleteRoutine(id);
    routines = await repository.loadRoutines();
    notifyListeners();
  }

  Future<void> flushSetWrites([String? setId]) async {
    if (setId != null) {
      final pending = _pendingSetWrites[setId];
      if (pending != null) await pending;
      return;
    }
    await Future.wait(_pendingSetWrites.values.toList());
  }

  Future<void> _enqueueSetWrite(String setId, Future<void> Function() write) {
    final previous = _pendingSetWrites[setId] ?? Future<void>.value();
    late final Future<void> next;
    next = previous
        .catchError((Object _) {})
        .then((_) => write())
        .catchError((Object exception) {
          actionError = exception;
          notifyListeners();
          throw exception;
        })
        .whenComplete(() {
          if (identical(_pendingSetWrites[setId], next)) {
            _pendingSetWrites.remove(setId);
          }
        });
    _pendingSetWrites[setId] = next;
    return next;
  }

  Future<void> _refreshWorkout() async {
    activeWorkout = await repository.loadActiveWorkout();
    history = await repository.loadHistory();
    notifyListeners();
  }
}
