import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  static Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'calorie_bank.db');

    return await openDatabase(
      path,
      version: 2,          // bumped for macro/micro columns
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE user_profiles (
        id TEXT PRIMARY KEY,
        email TEXT NOT NULL,
        display_name TEXT NOT NULL,
        age INTEGER NOT NULL,
        gender TEXT NOT NULL,
        height_cm REAL NOT NULL,
        current_weight_kg REAL NOT NULL,
        goal_weight_kg REAL NOT NULL,
        activity_level TEXT NOT NULL,
        goal TEXT NOT NULL,
        daily_calorie_budget INTEGER NOT NULL,
        daily_protein_goal_g REAL NOT NULL,
        daily_carbs_goal_g REAL NOT NULL,
        daily_fat_goal_g REAL NOT NULL,
        daily_fiber_goal_g REAL NOT NULL DEFAULT 28,
        daily_sugar_goal_g REAL NOT NULL DEFAULT 50,
        is_premium INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE food_entries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        date_key TEXT NOT NULL,
        meal_type TEXT NOT NULL,
        foods_json TEXT NOT NULL,
        total_calories INTEGER NOT NULL,
        macros_json TEXT NOT NULL DEFAULT '{}',
        micros_json TEXT NOT NULL DEFAULT '{}'
      )
    ''');

    await db.execute('''
      CREATE TABLE calorie_transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        date_key TEXT NOT NULL,
        type TEXT NOT NULL,
        calories INTEGER NOT NULL,
        label TEXT NOT NULL,
        food_entry_id TEXT,
        exercise_entry_id TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bank_accounts (
        user_id TEXT PRIMARY KEY,
        balance INTEGER NOT NULL DEFAULT 0,
        last_updated TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_summaries (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        date_key TEXT NOT NULL,
        date TEXT NOT NULL,
        budget INTEGER NOT NULL,
        consumed INTEGER NOT NULL DEFAULT 0,
        exercise_bonus INTEGER NOT NULL DEFAULT 0,
        bank_bonus INTEGER NOT NULL DEFAULT 0,
        macros_json TEXT NOT NULL DEFAULT '{}',
        micros_json TEXT NOT NULL DEFAULT '{}',
        end_of_day_processed INTEGER NOT NULL DEFAULT 0,
        UNIQUE(user_id, date_key)
      )
    ''');

    await _createIndexes(db);
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migrate food_entries: replace individual columns with JSON blobs
      await db.execute("ALTER TABLE food_entries ADD COLUMN macros_json TEXT NOT NULL DEFAULT '{}'");
      await db.execute("ALTER TABLE food_entries ADD COLUMN micros_json TEXT NOT NULL DEFAULT '{}'");

      // Migrate daily_summaries: replace individual columns with JSON blobs
      await db.execute("ALTER TABLE daily_summaries ADD COLUMN macros_json TEXT NOT NULL DEFAULT '{}'");
      await db.execute("ALTER TABLE daily_summaries ADD COLUMN micros_json TEXT NOT NULL DEFAULT '{}'");

      // Migrate user_profiles: add new goal columns
      await db.execute('ALTER TABLE user_profiles ADD COLUMN daily_fiber_goal_g REAL NOT NULL DEFAULT 28');
      await db.execute('ALTER TABLE user_profiles ADD COLUMN daily_sugar_goal_g REAL NOT NULL DEFAULT 50');
    }
  }

  static Future<void> _createIndexes(Database db) async {
    await db.execute('CREATE INDEX idx_food_user_date ON food_entries(user_id, date_key)');
    await db.execute('CREATE INDEX idx_tx_user_date ON calorie_transactions(user_id, date_key)');
    await db.execute('CREATE INDEX idx_summary_user_date ON daily_summaries(user_id, date_key)');
  }

  static Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
