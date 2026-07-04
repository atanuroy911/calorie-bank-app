import 'package:equatable/equatable.dart';

class ExerciseEntry extends Equatable {
  final String id;
  final DateTime timestamp;
  final String exerciseName;
  final int durationMinutes;
  final int caloriesBurned;
  final String? notes;
  final String userId;

  const ExerciseEntry({
    required this.id,
    required this.timestamp,
    required this.exerciseName,
    required this.durationMinutes,
    required this.caloriesBurned,
    this.notes,
    required this.userId,
  });

  @override
  List<Object?> get props => [id, timestamp, exerciseName, caloriesBurned];
}
