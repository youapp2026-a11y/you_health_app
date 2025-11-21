
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../models/meal.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  _MealLogScreenState createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  late Future<List<Meal>> _mealsFuture;

  @override
  void initState() {
    super.initState();
    _mealsFuture = _fetchMeals();
  }

  Future<List<Meal>> _fetchMeals() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final today = DateTime.now();
    final beginningOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = beginningOfDay.add(const Duration(days: 1));

    final response = await supabase
        .from('meals')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', beginningOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);

    return (response as List).map((json) => Meal.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Meals (${DateFormat.yMd().format(DateTime.now())})'),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _mealsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No meals logged for today.'));
          }

          final meals = snapshot.data!;
          final totalCalories = meals.fold(0, (sum, meal) => sum + meal.calories);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total Calories',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalCalories kcal',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: meals.length,
                  itemBuilder: (context, index) {
                    final meal = meals[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(meal.name),
                        subtitle: Text('${meal.calories} kcal - ${meal.mealType}'),
                        trailing: Text(DateFormat.jm().format(meal.createdAt.toLocal())),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
