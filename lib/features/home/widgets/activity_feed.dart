import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/meal.dart';
import 'package:myapp/models/workout_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  State<ActivityFeed> createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  late Future<List<dynamic>> _activityFuture;

  @override
  void initState() {
    super.initState();
    _activityFuture = _fetchActivities();
  }

  Future<List<dynamic>> _fetchActivities() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }

    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);

    try {
      final mealResponse = await supabase
          .from('meals')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', startOfToday.toIso8601String());

      final workoutResponse = await supabase
          .from('workout_logs')
          .select()
          .eq('user_id', user.id)
          .gte('created_at', startOfToday.toIso8601String());

      final List<Meal> meals = (mealResponse as List).map((e) => Meal.fromJson(e)).toList();
      final List<WorkoutLog> workouts = (workoutResponse as List).map((e) => WorkoutLog.fromJson(e)).toList();

      final List<dynamic> activities = [...meals, ...workouts];
      activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return activities;
    } catch (e) {
      // Handle error
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _activityFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No activities logged today.')),
            ),
          );
        }

        final activities = snapshot.data!;

        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text("Today's Activity", style: Theme.of(context).textTheme.titleLarge),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final item = activities[index];
                  if (item is Meal) {
                    return ListTile(
                      leading: const Icon(Icons.fastfood_rounded),
                      title: Text(item.foodItem),
                      subtitle: Text('${item.calories} kcal - ${item.mealType}'),
                      trailing: Text(DateFormat.jm().format(item.createdAt.toLocal())),
                    );
                  }
                  if (item is WorkoutLog) {
                    return ListTile(
                      leading: const Icon(Icons.fitness_center_rounded),
                      title: Text(item.exerciseName),
                      subtitle: Text('${item.durationMinutes} mins - ${item.caloriesBurned} kcal'),
                      trailing: Text(DateFormat.jm().format(item.createdAt.toLocal())),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
