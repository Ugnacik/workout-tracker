import 'dart:io';

import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:workout_tracker/data/app_database.dart';

void main() {
  test('v1 migration preserves history and marks its sets completed', () async {
    final directory = await Directory.systemTemp.createTemp(
      'workout_tracker_migration_',
    );
    final file = File('${directory.path}/v1.sqlite');
    final sqlite = sqlite3.open(file.path);
    sqlite.execute('''
      CREATE TABLE muscle_groups (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        origin TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE movement_patterns (
        id TEXT NOT NULL PRIMARY KEY,
        muscle_group_id TEXT NOT NULL,
        name TEXT NOT NULL,
        origin TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE exercise_variations (
        id TEXT NOT NULL PRIMARY KEY,
        movement_pattern_id TEXT NOT NULL,
        name TEXT NOT NULL,
        equipment_type TEXT NOT NULL,
        origin TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE manufacturers (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        origin TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE machine_models (
        id TEXT NOT NULL PRIMARY KEY,
        manufacturer_id TEXT NOT NULL,
        name TEXT NOT NULL,
        origin TEXT NOT NULL,
        archived INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE gym_locations (
        id TEXT NOT NULL PRIMARY KEY,
        name TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        archived INTEGER NOT NULL DEFAULT 0
      );
      CREATE TABLE workout_sessions (
        id TEXT NOT NULL PRIMARY KEY,
        gym_location_id TEXT NOT NULL,
        started_at INTEGER NOT NULL,
        finished_at INTEGER
      );
      CREATE TABLE workout_entries (
        id TEXT NOT NULL PRIMARY KEY,
        session_id TEXT NOT NULL,
        exercise_variation_id TEXT NOT NULL,
        machine_model_id TEXT,
        position INTEGER NOT NULL
      );
      CREATE TABLE logged_sets (
        id TEXT NOT NULL PRIMARY KEY,
        workout_entry_id TEXT NOT NULL,
        position INTEGER NOT NULL,
        reps INTEGER NOT NULL DEFAULT 0,
        load_kg REAL,
        bodyweight_adjustment_kg REAL,
        adjustment TEXT NOT NULL DEFAULT 'none'
      );
      CREATE TABLE app_settings (
        key TEXT NOT NULL PRIMARY KEY,
        value TEXT NOT NULL
      );
    ''');
    final finishedAt = DateTime(2026, 8, 1, 12).millisecondsSinceEpoch ~/ 1000;
    sqlite.execute("INSERT INTO gym_locations VALUES ('gym', 'Gym', 1, 0)");
    sqlite.execute(
      "INSERT INTO workout_sessions VALUES ('session', 'gym', $finishedAt, $finishedAt)",
    );
    sqlite.execute(
      "INSERT INTO workout_entries VALUES ('entry', 'session', 'exercise', NULL, 0)",
    );
    sqlite.execute(
      "INSERT INTO logged_sets VALUES ('set', 'entry', 0, 8, 50, NULL, 'none')",
    );
    sqlite.execute('PRAGMA user_version = 1');
    sqlite.close();

    final database = AppDatabase.forTesting(NativeDatabase(file));
    final migrated = await database
        .customSelect(
          'SELECT is_completed, completed_at FROM logged_sets WHERE id = ?',
          variables: [const Variable<String>('set')],
        )
        .getSingle();
    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 2);
    expect(migrated.read<int>('is_completed'), 1);
    expect(migrated.read<int?>('completed_at'), isNotNull);
    expect(
      await database.customSelect('SELECT * FROM workout_routines').get(),
      isEmpty,
    );
    await database.close();
    await directory.delete(recursive: true);
  });
}
