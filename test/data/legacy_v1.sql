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
