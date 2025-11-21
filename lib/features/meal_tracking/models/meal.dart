
class Meal {
  final String id;
  final String userId;
  final String name;
  final int calories;
  final double? protein;
  final double? carbs;
  final double? fats;
  final String? mealType;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.userId,
    required this.name,
    required this.calories,
    this.protein,
    this.carbs,
    this.fats,
    this.mealType,
    required this.createdAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'],
      userId: json['user_id'],
      name: json['name'],
      calories: json['calories'],
      protein: json['protein']?.toDouble(),
      carbs: json['carbs']?.toDouble(),
      fats: json['fats']?.toDouble(),
      mealType: json['meal_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fats': fats,
      'meal_type': mealType,
    };
  }
}
