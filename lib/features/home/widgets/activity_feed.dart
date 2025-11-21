
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../../meal_tracking/models/meal.dart';
import '../../exercise_tracking/models/workout_log.dart';

class ActivityFeed extends StatefulWidget {
  const ActivityFeed({super.key});

  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {
  late Future<List<dynamic>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _fetchActivityFeed();
  }

  Future<List<dynamic>> _fetchActivityFeed() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final today = DateTime.now();
    final beginningOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = beginningOfDay.add(const Duration(days: 1));

    final mealResponse = await supabase
        .from('meals')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', beginningOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String());

    final workoutResponse = await supabase
        .from('workout_logs')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', beginningOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String());

    final meals = (mealResponse as List).map((json) => Meal.fromJson(json)).toList();
    final workouts = (workoutResponse as List).map((json) => WorkoutLog.fromJson(json)).toList();

    final combinedFeed = [...meals, ...workouts];
    combinedFeed.sort((a, b) {
      DateTime aDate, bDate;
      if (a is Meal) {
        aDate = a.createdAt;
      } else if (a is WorkoutLog) {
        aDate = a.createdAt;
      } else {
        return 0;
      }

      if (b is Meal) {
        bDate = b.createdAt;
      } else if (b is WorkoutLog) {
        bDate = b.createdAt;
      } else {
        return 0;
      }
      
      return bDate.compareTo(aDate);
    });

    return combinedFeed;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Activity',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<dynamic>>(
          future: _feedFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No activity logged for today.'));
            }

            final feedItems = snapshot.data!;

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: feedItems.length,
              itemBuilder: (context, index) {
                final item = feedItems[index];
                if (item is Meal) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.fastfood, color: Colors.orange),
                      title: Text(item.name),
                      subtitle: Text('${item.calories} kcal - ${item.mealType}'),
                      trailing: Text(DateFormat.jm().format(item.createdAt.toLocal())),
                    ),
                  );
                } else if (item is WorkoutLog) {
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.fitness_center, color: Colors.blue),
                      title: Text(item.workoutName),
                      subtitle: Text('${item.durationMinutes} mins - ${item.caloriesBurned ?? 0} kcal'),
                      trailing: Text(DateFormat.jm().format(item.createdAt.toLocal())),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ],
    );
  }
}
