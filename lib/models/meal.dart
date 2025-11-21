
class Meal {
  final String id;
  final String userId;
  final String foodItem;
  final int calories;
  final String mealType;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.userId,
    required this.foodItem,
    required this.calories,
    required this.mealType,
    required this.createdAt,
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    return Meal(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String,
      foodItem: json['food_item'] as String,
      calories: json['calories'] as int,
      mealType: json['meal_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'food_item': foodItem,
      'calories': calories,
      'meal_type': mealType,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
