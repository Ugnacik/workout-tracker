import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';

void main() {
  for (final version in [1, 2, 3]) {
    test(
      'v$version migration preserves workouts, custom metadata and machine associations',
      () async {
        final directory = await Directory.systemTemp.createTemp(
          'workout_v${version}_',
        );
        final file = File('${directory.path}/legacy.sqlite');
        final sqlite = sqlite3.open(file.path);
        sqlite.execute(await File('test/data/legacy_v1.sql').readAsString());
        if (version >= 2) {
          sqlite.execute('''
          ALTER TABLE logged_sets ADD COLUMN is_completed INTEGER NOT NULL DEFAULT 0;
          ALTER TABLE logged_sets ADD COLUMN completed_at INTEGER;
          CREATE TABLE workout_routines (
            id TEXT NOT NULL PRIMARY KEY, name TEXT NOT NULL,
            created_at INTEGER NOT NULL, updated_at INTEGER NOT NULL);
          CREATE TABLE routine_exercises (
            id TEXT NOT NULL PRIMARY KEY, routine_id TEXT NOT NULL REFERENCES workout_routines(id) ON DELETE CASCADE,
            exercise_variation_id TEXT NOT NULL, machine_model_id TEXT,
            position INTEGER NOT NULL, set_count INTEGER NOT NULL DEFAULT 1);
        ''');
        }
        if (version >= 3) {
          sqlite.execute('ALTER TABLE workout_sessions ADD COLUMN name TEXT');
        }
        sqlite.execute('''
        INSERT INTO muscle_groups VALUES ('muscle-back', 'Back', 'seeded', 0);
        INSERT INTO movement_patterns VALUES ('pattern-vertical-pull', 'muscle-back', 'Vertical pulling', 'seeded', 0);
        INSERT INTO exercise_variations VALUES ('exercise-lat-pulldown', 'pattern-vertical-pull', 'Lat pulldown', 'machine', 'seeded', 0);
        INSERT INTO exercise_variations VALUES ('custom', 'pattern-vertical-pull', 'My custom pull', 'machine', 'user', 0);
        INSERT INTO manufacturers VALUES ('manufacturer-life-fitness', 'Life Fitness', 'seeded', 0);
        INSERT INTO machine_models VALUES ('machine-life-signature-press', 'manufacturer-life-fitness', 'Signature Chest Press', 'seeded', 0);
        INSERT INTO machine_models VALUES ('custom-model', 'manufacturer-life-fitness', 'My pull machine', 'user', 0);
        INSERT INTO gym_locations VALUES ('gym', 'Gym', 1, 0);
        INSERT INTO workout_sessions (id, gym_location_id, started_at, finished_at) VALUES ('session', 'gym', 1785585600, 1785589200);
        INSERT INTO workout_entries VALUES ('legacy-mismatch', 'session', 'exercise-lat-pulldown', 'machine-life-signature-press', 0);
        INSERT INTO workout_entries VALUES ('custom-entry', 'session', 'custom', 'custom-model', 1);
        INSERT INTO logged_sets (id, workout_entry_id, position, reps, load_kg) VALUES ('set', 'legacy-mismatch', 0, 8, 50);
        INSERT INTO logged_sets (id, workout_entry_id, position, reps, load_kg) VALUES ('custom-set', 'custom-entry', 0, 10, 30);
        INSERT INTO app_settings VALUES ('weightUnit', 'pounds');
      ''');
        if (version >= 2) {
          sqlite.execute(
            "UPDATE logged_sets SET is_completed = 1, completed_at = 1785589200",
          );
          sqlite.execute(
            "INSERT INTO workout_routines VALUES ('routine', 'Saved routine', 1785585600, 1785589200)",
          );
          sqlite.execute(
            "INSERT INTO routine_exercises VALUES ('routine-entry', 'routine', 'custom', 'custom-model', 0, 2)",
          );
        }
        if (version >= 3) {
          sqlite.execute("UPDATE workout_sessions SET name = 'Saved name'");
        }
        sqlite.execute('PRAGMA user_version = $version');
        sqlite.close();

        final database = AppDatabase.forTesting(NativeDatabase(file));
        final repository = DriftWorkoutRepository(database);
        await repository.initialize();
        final history = (await repository.loadHistory()).single;
        expect(database.schemaVersion, 4);
        expect(history.name, version >= 3 ? 'Saved name' : null);
        expect(history.muscleLabels, ['Back']);
        expect(history.exercises, hasLength(2));
        expect(history.exercises.first.sets.single.reps, 8);
        expect(history.exercises.first.sets.single.loadKg, 50);
        expect(history.exercises.first.sets.single.isCompleted, isTrue);
        expect(
          history.exercises.first.exercise.machineModel!.id,
          'machine-life-signature-press',
        );
        expect(
          history.exercises.first.exercise.manufacturer!.name,
          'Life Fitness',
        );
        expect(history.exercises.last.exercise.execution, isNull);
        expect(history.exercises.last.exercise.independentLimbs, isFalse);
        final catalog = await repository.loadCatalog();
        expect(
          catalog.compatibleModels(
            history.exercises.first.exercise,
            'manufacturer-life-fitness',
          ),
          isEmpty,
        );
        expect(
          catalog
              .compatibleModels(
                history.exercises.last.exercise,
                'manufacturer-life-fitness',
              )
              .single
              .id,
          'custom-model',
        );
        if (version >= 2) {
          final routine = (await repository.loadRoutines()).single;
          expect(
            routine.exercises.single.exercise.manufacturer!.name,
            'Life Fitness',
          );
          expect(
            routine.exercises.single.exercise.machineModel!.id,
            'custom-model',
          );
        }
        await repository.close();
        // Verify migration is persisted and a second open is idempotent.
        final reopened = DriftWorkoutRepository(
          AppDatabase.forTesting(NativeDatabase(file)),
        );
        await reopened.initialize();
        expect(
          (await reopened.loadHistory())
              .single
              .exercises
              .first
              .sets
              .single
              .loadKg,
          50,
        );
        await reopened.close();
        await directory.delete(recursive: true);
      },
    );
  }
}
