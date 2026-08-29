import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class MuscleGroups extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get origin => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MovementPatterns extends Table {
  TextColumn get id => text()();
  TextColumn get muscleGroupId => text()();
  TextColumn get name => text()();
  TextColumn get origin => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class ExerciseVariations extends Table {
  TextColumn get id => text()();
  TextColumn get movementPatternId => text()();
  TextColumn get name => text()();
  TextColumn get equipmentType => text()();
  TextColumn get origin => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class Manufacturers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get origin => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class MachineModels extends Table {
  TextColumn get id => text()();
  TextColumn get manufacturerId => text()();
  TextColumn get name => text()();
  TextColumn get origin => text()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class GymLocations extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get gymLocationId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get finishedAt => dateTime().nullable()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class WorkoutEntries extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get exerciseVariationId => text()();
  TextColumn get machineModelId => text().nullable()();
  IntColumn get position => integer()();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LoggedSets extends Table {
  TextColumn get id => text()();
  TextColumn get workoutEntryId => text()();
  IntColumn get position => integer()();
  IntColumn get reps => integer().withDefault(const Constant(0))();
  RealColumn get loadKg => real().nullable()();
  RealColumn get bodyweightAdjustmentKg => real().nullable()();
  TextColumn get adjustment => text().withDefault(const Constant('none'))();
  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DriftDatabase(
  tables: [
    MuscleGroups,
    MovementPatterns,
    ExerciseVariations,
    Manufacturers,
    MachineModels,
    GymLocations,
    WorkoutSessions,
    WorkoutEntries,
    LoggedSets,
    AppSettings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      // Schema changes are added here as versioned migrations.
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}

LazyDatabase _openConnection() => LazyDatabase(() async {
  final directory = await getApplicationDocumentsDirectory();
  return NativeDatabase.createInBackground(
    File(p.join(directory.path, 'workout_tracker.sqlite')),
  );
});
