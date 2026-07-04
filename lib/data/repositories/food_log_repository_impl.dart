import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import '../../domain/entities/food_entry.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/food_log_repository.dart';
import '../datasources/local/isar_service.dart';

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class FoodLogRepositoryImpl implements FoodLogRepository {
  @override
  Future<void> addFoodEntry(FoodEntry entry) async {
    final db = await DatabaseService.instance;
    await db.insert(
      'food_entries',
      {
        'id': entry.id,
        'user_id': entry.userId,
        'timestamp': entry.timestamp.toIso8601String(),
        'date_key': _dateKey(entry.timestamp),
        'meal_type': entry.mealType,
        'foods_json': jsonEncode(entry.foods.map((f) => f.toJson()).toList()),
        'total_calories': entry.totalCalories,
        'macros_json': jsonEncode(entry.totalMacros.toJson()),
        'micros_json': jsonEncode(entry.totalMicros.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteFoodEntry(String entryId) async {
    final db = await DatabaseService.instance;
    await db.delete('food_entries', where: 'id = ?', whereArgs: [entryId]);
  }

  @override
  Future<List<FoodEntry>> getEntriesForDate(
      String userId, DateTime date) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'food_entries',
      where: 'user_id = ? AND date_key = ?',
      whereArgs: [userId, _dateKey(date)],
      orderBy: 'timestamp ASC',
    );
    return rows.map(_fromRow).toList();
  }

  @override
  Stream<List<FoodEntry>> watchEntriesForDate(
      String userId, DateTime date) async* {
    while (true) {
      yield await getEntriesForDate(userId, date);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  FoodEntry _fromRow(Map<String, dynamic> row) {
    final foodsRaw = jsonDecode(row['foods_json'] as String) as List<dynamic>;
    final foods = foodsRaw
        .map((f) => FoodItem.fromJson(f as Map<String, dynamic>))
        .toList();

    Macros macros = const Macros();
    Micros micros = const Micros();
    try {
      final mj = row['macros_json'] as String?;
      final uj = row['micros_json'] as String?;
      if (mj != null && mj.isNotEmpty && mj != '{}') {
        macros = Macros.fromJson(jsonDecode(mj) as Map<String, dynamic>);
      }
      if (uj != null && uj.isNotEmpty && uj != '{}') {
        micros = Micros.fromJson(jsonDecode(uj) as Map<String, dynamic>);
      }
    } catch (_) {
      // Legacy rows without JSON columns — recompute from foods
      macros = foods.fold(const Macros(), (acc, f) => acc + f.macros);
      micros = foods.fold(const Micros(), (acc, f) => acc + f.micros);
    }

    return FoodEntry(
      id: row['id'] as String,
      timestamp: DateTime.parse(row['timestamp'] as String),
      mealType: row['meal_type'] as String,
      foods: foods,
      totalCalories: row['total_calories'] as int,
      totalMacros: macros,
      totalMicros: micros,
      aiSessionId: null,
      userId: row['user_id'] as String,
    );
  }
}
