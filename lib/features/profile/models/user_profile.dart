
import 'dart:convert';

class UserProfile {
  final String id;
  final String name;
  final int age;
  final String gender;
  final double height;
  final double weight;
  final String activityLevel;
  final String fitnessGoal;

  UserProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.height,
    required this.weight,
    required this.activityLevel,
    required this.fitnessGoal,
  });

  double get bmi {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      gender: map['gender'] ?? '',
      height: map['height']?.toDouble() ?? 0.0,
      weight: map['weight']?.toDouble() ?? 0.0,
      activityLevel: map['activity_level'] ?? '',
      fitnessGoal: map['fitness_goal'] ?? '',
    );
  }

    factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
