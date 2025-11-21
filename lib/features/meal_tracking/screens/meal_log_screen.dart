import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/meal.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class MealLogScreen extends StatefulWidget {
  const MealLogScreen({super.key});

  @override
  State<MealLogScreen> createState() => _MealLogScreenState();
}

class _MealLogScreenState extends State<MealLogScreen> {
  late Future<List<Meal>> _mealLogsFuture;

  @override
  void initState() {
    super.initState();
    _mealLogsFuture = _fetchMealLogs();
  }

  Future<List<Meal>> _fetchMealLogs() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('meals')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return (response as List).map((e) => Meal.fromJson(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching meals: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Meals (${DateFormat.yMd().format(DateTime.now())})'),
      ),
      body: FutureBuilder<List<Meal>>(
        future: _mealLogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final meals = snapshot.data ?? [];
          if (meals.isEmpty) {
            return const Center(child: Text('No meals logged yet.'));
          }
          return ListView.builder(
            itemCount: meals.length,
            itemBuilder: (context, index) {
              final meal = meals[index];
              return ListTile(
                title: Text(meal.foodItem),
                subtitle: Text('${meal.calories} kcal - ${meal.mealType}'),
                trailing: Text(DateFormat.jm().format(meal.createdAt.toLocal())),
              );
            },
          );
        },
      ),
    );
  }
}
