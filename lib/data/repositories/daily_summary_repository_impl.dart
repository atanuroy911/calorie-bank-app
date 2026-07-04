import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/daily_summary.dart';
import '../../domain/entities/nutrition.dart';
import '../../domain/repositories/daily_summary_repository.dart';
import '../datasources/local/isar_service.dart';

String _dateKey(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

class DailySummaryRepositoryImpl implements DailySummaryRepository {
  final _uuid = const Uuid();

  @override
  Future<DailySummary?> getSummaryForDate(
      String userId, DateTime date) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'daily_summaries',
      where: 'user_id = ? AND date_key = ?',
      whereArgs: [userId, _dateKey(date)],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> saveSummary(DailySummary summary) async {
    final db = await DatabaseService.instance;
    await db.insert(
      'daily_summaries',
      _toRow(summary),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateSummary(DailySummary summary) async {
    final db = await DatabaseService.instance;
    final key = _dateKey(summary.date);
    final existing = await db.query(
      'daily_summaries',
      where: 'user_id = ? AND date_key = ?',
      whereArgs: [summary.userId, key],
    );
    if (existing.isEmpty) {
      await saveSummary(summary);
    } else {
      await db.update(
        'daily_summaries',
        {
          'consumed': summary.consumed,
          'exercise_bonus': summary.exerciseBonus,
          'bank_bonus': summary.bankBonus,
          'macros_json': jsonEncode(summary.macros.toJson()),
          'micros_json': jsonEncode(summary.micros.toJson()),
          'end_of_day_processed': summary.endOfDayProcessed ? 1 : 0,
        },
        where: 'user_id = ? AND date_key = ?',
        whereArgs: [summary.userId, key],
      );
    }
  }

  @override
  Stream<DailySummary?> watchSummaryForDate(
      String userId, DateTime date) async* {
    while (true) {
      yield await getSummaryForDate(userId, date);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  Map<String, dynamic> _toRow(DailySummary s) => {
        'id': _uuid.v4(),
        'user_id': s.userId,
        'date_key': _dateKey(s.date),
        'date': s.date.toIso8601String(),
        'budget': s.budget,
        'consumed': s.consumed,
        'exercise_bonus': s.exerciseBonus,
        'bank_bonus': s.bankBonus,
        'macros_json': jsonEncode(s.macros.toJson()),
        'micros_json': jsonEncode(s.micros.toJson()),
        'end_of_day_processed': s.endOfDayProcessed ? 1 : 0,
      };

  DailySummary _fromRow(Map<String, dynamic> row) {
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
    } catch (_) {}

    return DailySummary(
      userId: row['user_id'] as String,
      date: DateTime.parse(row['date'] as String),
      budget: row['budget'] as int,
      consumed: row['consumed'] as int,
      exerciseBonus: row['exercise_bonus'] as int,
      bankBonus: row['bank_bonus'] as int,
      macros: macros,
      micros: micros,
      endOfDayProcessed: row['end_of_day_processed'] == 1,
    );
  }
}
