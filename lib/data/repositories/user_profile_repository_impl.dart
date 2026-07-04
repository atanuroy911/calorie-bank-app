import 'package:sqflite/sqflite.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/local/isar_service.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  @override
  Future<UserProfile?> getProfile(String userId) async {
    final db = await DatabaseService.instance;
    final rows = await db.query(
      'user_profiles',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (rows.isEmpty) return null;
    return _fromRow(rows.first);
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final db = await DatabaseService.instance;
    await db.insert(
      'user_profiles',
      _toRow(profile),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> updateProfile(UserProfile profile) async {
    await saveProfile(profile);
  }

  @override
  Stream<UserProfile?> watchProfile(String userId) async* {
    // Polling-based stream for simplicity (replace with sqflite_common or firestore later)
    while (true) {
      yield await getProfile(userId);
      await Future.delayed(const Duration(seconds: 5));
    }
  }

  Map<String, dynamic> _toRow(UserProfile p) => {
        'id': p.id,
        'email': p.email,
        'display_name': p.displayName,
        'age': p.age,
        'gender': p.gender,
        'height_cm': p.heightCm,
        'current_weight_kg': p.currentWeightKg,
        'goal_weight_kg': p.goalWeightKg,
        'activity_level': p.activityLevel,
        'goal': p.goal,
        'daily_calorie_budget': p.dailyCalorieBudget,
        'daily_protein_goal_g': p.dailyProteinGoalG,
        'daily_carbs_goal_g': p.dailyCarbsGoalG,
        'daily_fat_goal_g': p.dailyFatGoalG,
        'daily_fiber_goal_g': p.dailyFiberGoalG,
        'daily_sugar_goal_g': p.dailySugarGoalG,
        'is_premium': p.isPremium ? 1 : 0,
        'created_at': p.createdAt.toIso8601String(),
        'updated_at': p.updatedAt.toIso8601String(),
      };

  UserProfile _fromRow(Map<String, dynamic> row) => UserProfile(
        id: row['id'] as String,
        email: row['email'] as String,
        displayName: row['display_name'] as String,
        age: row['age'] as int,
        gender: row['gender'] as String,
        heightCm: (row['height_cm'] as num).toDouble(),
        currentWeightKg: (row['current_weight_kg'] as num).toDouble(),
        goalWeightKg: (row['goal_weight_kg'] as num).toDouble(),
        activityLevel: row['activity_level'] as String,
        goal: row['goal'] as String,
        dailyCalorieBudget: row['daily_calorie_budget'] as int,
        dailyProteinGoalG: (row['daily_protein_goal_g'] as num).toDouble(),
        dailyCarbsGoalG: (row['daily_carbs_goal_g'] as num).toDouble(),
        dailyFatGoalG: (row['daily_fat_goal_g'] as num).toDouble(),
        dailyFiberGoalG: (row['daily_fiber_goal_g'] as num?)?.toDouble() ?? 28,
        dailySugarGoalG: (row['daily_sugar_goal_g'] as num?)?.toDouble() ?? 50,
        isPremium: row['is_premium'] == 1,
        createdAt: DateTime.parse(row['created_at'] as String),
        updatedAt: DateTime.parse(row['updated_at'] as String),
      );
}
