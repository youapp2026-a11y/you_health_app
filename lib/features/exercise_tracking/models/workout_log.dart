
class WorkoutLog {
  final String id;
  final String userId;
  final String workoutName;
  final int durationMinutes;
  final int? caloriesBurned;
  final String? notes;
  final DateTime createdAt;

  WorkoutLog({
    required this.id,
    required this.userId,
    required this.workoutName,
    required this.durationMinutes,
    this.caloriesBurned,
    this.notes,
    required this.createdAt,
  });

  factory WorkoutLog.fromJson(Map<String, dynamic> json) {
    return WorkoutLog(
      id: json['id'],
      userId: json['user_id'],
      workoutName: json['workout_name'],
      durationMinutes: json['duration_minutes'],
      caloriesBurned: json['calories_burned'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'workout_name': workoutName,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'notes': notes,
    };
  }
}
