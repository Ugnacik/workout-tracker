import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/domain/models.dart';

void main() {
  test('weight conversion round trips between kg and lb', () {
    const kilograms = 42.5;
    final pounds = WeightUnit.pounds.fromKilograms(kilograms);
    expect(pounds, closeTo(93.696, 0.001));
    expect(WeightUnit.pounds.toKilograms(pounds), closeTo(kilograms, 0.0001));
  });

  test('taxonomy filtering combines muscle, pattern, and equipment', () {
    const pullUp = ExerciseChoice(
      id: 'pull-up',
      name: 'Neutral-grip pull-up',
      muscleGroupId: 'back',
      muscleGroupName: 'Back',
      movementPatternId: 'vertical',
      movementPatternName: 'Vertical pulling',
      equipmentType: EquipmentType.bodyweight,
    );
    const row = ExerciseChoice(
      id: 'row',
      name: 'Barbell row',
      muscleGroupId: 'back',
      muscleGroupName: 'Back',
      movementPatternId: 'horizontal',
      movementPatternName: 'Horizontal pulling',
      equipmentType: EquipmentType.barbell,
    );
    const catalog = CatalogSnapshot(
      muscles: [],
      patterns: [],
      exercises: [pullUp, row],
      machines: [],
    );
    final result = filterExercises(
      catalog,
      const ExerciseFilter(
        muscleGroupId: 'back',
        movementPatternId: 'vertical',
        equipmentType: EquipmentType.bodyweight,
      ),
    );
    expect(result, [pullUp]);
  });

  test('bodyweight adjustment distinguishes assistance from added load', () {
    const assisted = WorkoutSetModel(
      id: 'set',
      position: 0,
      reps: 8,
      bodyweightAdjustmentKg: 15,
      adjustment: BodyweightAdjustment.assisted,
    );
    const added = WorkoutSetModel(
      id: 'set-2',
      position: 1,
      reps: 5,
      bodyweightAdjustmentKg: 10,
      adjustment: BodyweightAdjustment.added,
    );
    expect(assisted.adjustment, BodyweightAdjustment.assisted);
    expect(added.adjustment, BodyweightAdjustment.added);
    expect(
      assisted.bodyweightAdjustmentKg,
      isNot(added.bodyweightAdjustmentKg),
    );
  });
}
