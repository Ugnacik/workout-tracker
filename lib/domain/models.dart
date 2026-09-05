enum CatalogOrigin { seeded, user }

enum EquipmentType { bodyweight, dumbbell, barbell, machine, cable, other }

extension EquipmentTypeLabel on EquipmentType {
  String get label => switch (this) {
    EquipmentType.bodyweight => 'Bodyweight',
    EquipmentType.dumbbell => 'Dumbbell',
    EquipmentType.barbell => 'Barbell',
    EquipmentType.machine => 'Machine',
    EquipmentType.cable => 'Cable',
    EquipmentType.other => 'Other',
  };
}

enum ExerciseExecution { unilateral, bilateral }

extension ExerciseExecutionLabel on ExerciseExecution {
  String get label => switch (this) {
    ExerciseExecution.unilateral => 'One side at a time',
    ExerciseExecution.bilateral => 'Both sides together',
  };
}

class ManufacturerInfo {
  const ManufacturerInfo({required this.id, required this.name});
  final String id;
  final String name;
}

enum WeightUnit { kilograms, pounds }

enum AppThemePreference { dark, light, system }

extension WeightUnitLabel on WeightUnit {
  String get shortLabel => this == WeightUnit.kilograms ? 'kg' : 'lb';

  double fromKilograms(double kilograms) =>
      this == WeightUnit.kilograms ? kilograms : kilograms * 2.2046226218;

  double toKilograms(double value) =>
      this == WeightUnit.kilograms ? value : value / 2.2046226218;
}

enum BodyweightAdjustment { none, added, assisted }

class MuscleGroupModel {
  const MuscleGroupModel({required this.id, required this.name});
  final String id;
  final String name;
}

class MovementPatternModel {
  const MovementPatternModel({
    required this.id,
    required this.name,
    required this.muscleGroupId,
  });
  final String id;
  final String name;
  final String muscleGroupId;
}

class MachineModelInfo {
  const MachineModelInfo({
    required this.id,
    required this.name,
    required this.manufacturerId,
    required this.manufacturerName,
    this.compatibleExerciseIds = const [],
    this.independentLimbs = false,
  });
  final String id;
  final String name;
  final String manufacturerId;
  final String manufacturerName;
  final List<String> compatibleExerciseIds;
  final bool independentLimbs;

  bool supports(ExerciseChoice exercise) =>
      compatibleExerciseIds.contains(exercise.id);

  String get displayName => '$manufacturerName · $name';
}

class ExerciseChoice {
  const ExerciseChoice({
    required this.id,
    required this.name,
    required this.muscleGroupId,
    required this.muscleGroupName,
    required this.movementPatternId,
    required this.movementPatternName,
    required this.equipmentType,
    this.machineModel,
    this.manufacturer,
    this.execution,
    this.independentLimbs = false,
  });

  final String id;
  final String name;
  final String muscleGroupId;
  final String muscleGroupName;
  final String movementPatternId;
  final String movementPatternName;
  final EquipmentType equipmentType;
  final MachineModelInfo? machineModel;
  final ManufacturerInfo? manufacturer;
  final ExerciseExecution? execution;
  final bool independentLimbs;

  String? get manufacturerId =>
      manufacturer?.id ?? machineModel?.manufacturerId;
  String? get machineDescription =>
      machineModel?.displayName ?? manufacturer?.name;
  bool get supportsMachineSelection =>
      equipmentType == EquipmentType.machine ||
      equipmentType == EquipmentType.cable;

  List<String> get labels => [
    muscleGroupName,
    movementPatternName,
    if (equipmentType != EquipmentType.other) equipmentType.label,
    if (execution != null) execution!.label,
    if (independentLimbs || (machineModel?.independentLimbs ?? false))
      'Independent arms/legs',
  ];

  ExerciseChoice withMachine(MachineModelInfo? machine) =>
      withEquipmentSelection(
        machine == null
            ? null
            : ManufacturerInfo(
                id: machine.manufacturerId,
                name: machine.manufacturerName,
              ),
        machine,
      );

  ExerciseChoice withEquipmentSelection(
    ManufacturerInfo? maker,
    MachineModelInfo? machine,
  ) => ExerciseChoice(
    id: id,
    name: name,
    muscleGroupId: muscleGroupId,
    muscleGroupName: muscleGroupName,
    movementPatternId: movementPatternId,
    movementPatternName: movementPatternName,
    equipmentType: equipmentType,
    machineModel: machine,
    manufacturer: maker,
    execution: execution,
    independentLimbs: independentLimbs,
  );
}

class WorkoutSetModel {
  const WorkoutSetModel({
    required this.id,
    required this.position,
    required this.reps,
    this.loadKg,
    this.bodyweightAdjustmentKg,
    this.adjustment = BodyweightAdjustment.none,
    this.isCompleted = false,
    this.completedAt,
  });

  final String id;
  final int position;
  final int reps;
  final double? loadKg;
  final double? bodyweightAdjustmentKg;
  final BodyweightAdjustment adjustment;
  final bool isCompleted;
  final DateTime? completedAt;
}

class PreviousSetSnapshot {
  const PreviousSetSnapshot({
    required this.position,
    required this.reps,
    required this.performedAt,
    this.loadKg,
    this.bodyweightAdjustmentKg,
    this.adjustment = BodyweightAdjustment.none,
  });

  final int position;
  final int reps;
  final DateTime performedAt;
  final double? loadKg;
  final double? bodyweightAdjustmentKg;
  final BodyweightAdjustment adjustment;
}

class WorkoutExerciseModel {
  const WorkoutExerciseModel({
    required this.id,
    required this.position,
    required this.exercise,
    required this.sets,
  });
  final String id;
  final int position;
  final ExerciseChoice exercise;
  final List<WorkoutSetModel> sets;
}

class WorkoutSessionModel {
  const WorkoutSessionModel({
    required this.id,
    required this.gymLocationId,
    required this.gymLocationName,
    required this.startedAt,
    required this.exercises,
    this.name,
    this.finishedAt,
  });
  final String id;
  final String? name;
  final String gymLocationId;
  final String gymLocationName;
  final DateTime startedAt;
  final DateTime? finishedAt;
  final List<WorkoutExerciseModel> exercises;

  // Derived on every hydration, so historical edits cannot leave stale labels.
  List<String> get muscleLabels {
    final names = <String, String>{};
    for (final entry in exercises) {
      if (entry.sets.any((set) => set.isCompleted)) {
        names[entry.exercise.muscleGroupId] = entry.exercise.muscleGroupName;
      }
    }
    return names.values.toSet().toList()..sort();
  }
}

class RoutineExerciseModel {
  const RoutineExerciseModel({
    required this.id,
    required this.position,
    required this.exercise,
    required this.setCount,
  });

  final String id;
  final int position;
  final ExerciseChoice exercise;
  final int setCount;
}

class WorkoutRoutineModel {
  const WorkoutRoutineModel({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.exercises,
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<RoutineExerciseModel> exercises;
}

class FinishWorkoutResult {
  const FinishWorkoutResult({required this.omittedSetCount});
  final int omittedSetCount;
}

class GymLocationModel {
  const GymLocationModel({
    required this.id,
    required this.name,
    required this.isDefault,
  });
  final String id;
  final String name;
  final bool isDefault;
}

class CatalogSnapshot {
  const CatalogSnapshot({
    required this.muscles,
    required this.patterns,
    required this.exercises,
    required this.machines,
    this.manufacturers = const [],
  });
  final List<MuscleGroupModel> muscles;
  final List<MovementPatternModel> patterns;
  final List<ExerciseChoice> exercises;
  final List<MachineModelInfo> machines;
  final List<ManufacturerInfo> manufacturers;

  List<MovementPatternModel> patternsForMuscle(String? muscleId) =>
      muscleId == null
      ? []
      : patterns.where((p) => p.muscleGroupId == muscleId).toList();

  List<MachineModelInfo> compatibleModels(
    ExerciseChoice exercise,
    String? manufacturerId,
  ) => manufacturerId == null
      ? []
      : machines
            .where(
              (m) => m.manufacturerId == manufacturerId && m.supports(exercise),
            )
            .toList();
}

class ExerciseFilter {
  const ExerciseFilter({
    this.query = '',
    this.muscleGroupId,
    this.movementPatternId,
    this.equipmentType,
    this.manufacturerId,
  });

  final String query;
  final String? muscleGroupId;
  final String? movementPatternId;
  final EquipmentType? equipmentType;
  final String? manufacturerId;
}

List<ExerciseChoice> filterExercises(
  CatalogSnapshot catalog,
  ExerciseFilter filter,
) {
  final query = filter.query.trim().toLowerCase();
  return catalog.exercises.where((exercise) {
    if (filter.muscleGroupId != null &&
        exercise.muscleGroupId != filter.muscleGroupId) {
      return false;
    }
    if (filter.movementPatternId != null &&
        exercise.movementPatternId != filter.movementPatternId) {
      return false;
    }
    if (filter.equipmentType != null &&
        exercise.equipmentType != filter.equipmentType) {
      return false;
    }
    if (filter.manufacturerId != null &&
        !catalog.machines.any(
          (model) =>
              model.manufacturerId == filter.manufacturerId &&
              model.supports(exercise),
        )) {
      return false;
    }
    if (query.isEmpty) return true;
    return exercise.name.toLowerCase().contains(query) ||
        exercise.movementPatternName.toLowerCase().contains(query) ||
        exercise.muscleGroupName.toLowerCase().contains(query);
  }).toList();
}
