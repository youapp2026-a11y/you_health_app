
class WorkoutLog {
  final String id;
  final String userId;
  final String exerciseName;
  final int durationMinutes;
  final int caloriesBurned;
  final DateTime createdAt;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.exerciseName,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.createdAt,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String,
      exerciseName: json['exercise_name'] as String,
      durationMinutes: json['duration_minutes'] as int,
      caloriesBurned: json['calories_burned'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'exercise_name': exerciseName,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

