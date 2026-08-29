enum CatalogOrigin { seeded, user }

enum EquipmentType { bodyweight, dumbbell, barbell, machine, other }

extension EquipmentTypeLabel on EquipmentType {
  String get label => switch (this) {
    EquipmentType.bodyweight => 'Bodyweight',
    EquipmentType.dumbbell => 'Dumbbell',
    EquipmentType.barbell => 'Barbell',
    EquipmentType.machine => 'Machine',
    EquipmentType.other => 'Other',
  };
}

enum WeightUnit { kilograms, pounds }

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
  });
  final String id;
  final String name;
  final String manufacturerId;
  final String manufacturerName;

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
  });

  final String id;
  final String name;
  final String muscleGroupId;
  final String muscleGroupName;
  final String movementPatternId;
  final String movementPatternName;
  final EquipmentType equipmentType;
  final MachineModelInfo? machineModel;

  ExerciseChoice withMachine(MachineModelInfo? machine) => ExerciseChoice(
    id: id,
    name: name,
    muscleGroupId: muscleGroupId,
    muscleGroupName: muscleGroupName,
    movementPatternId: movementPatternId,
    movementPatternName: movementPatternName,
    equipmentType: equipmentType,
    machineModel: machine,
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
  });
  final List<MuscleGroupModel> muscles;
  final List<MovementPatternModel> patterns;
  final List<ExerciseChoice> exercises;
  final List<MachineModelInfo> machines;
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
        exercise.machineModel?.manufacturerId != filter.manufacturerId) {
      // Machine models are chosen after the exercise, so machine exercises
      // remain visible when filtering by manufacturer.
      if (exercise.equipmentType != EquipmentType.machine) return false;
    }
    if (query.isEmpty) return true;
    return exercise.name.toLowerCase().contains(query) ||
        exercise.movementPatternName.toLowerCase().contains(query) ||
        exercise.muscleGroupName.toLowerCase().contains(query);
  }).toList();
}
