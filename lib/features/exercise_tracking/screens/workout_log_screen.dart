
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../models/workout_log.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  _WorkoutLogScreenState createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  late Future<List<WorkoutLog>> _workoutsFuture;

  @override
  void initState() {
    super.initState();
    _workoutsFuture = _fetchWorkouts();
  }

  Future<List<WorkoutLog>> _fetchWorkouts() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated');
    }

    final today = DateTime.now();
    final beginningOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = beginningOfDay.add(const Duration(days: 1));

    final response = await supabase
        .from('workout_logs')
        .select()
        .eq('user_id', user.id)
        .gte('created_at', beginningOfDay.toIso8601String())
        .lt('created_at', endOfDay.toIso8601String())
        .order('created_at', ascending: false);

    return (response as List).map((json) => WorkoutLog.fromJson(json)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Workouts (${DateFormat.yMd().format(DateTime.now())})'),
      ),
      body: FutureBuilder<List<WorkoutLog>>(
        future: _workoutsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No workouts logged for today.'));
          }

          final workouts = snapshot.data!;
          final totalDuration = workouts.fold(0, (sum, log) => sum + log.durationMinutes);
          final totalCalories = workouts.fold(0, (sum, log) => sum + (log.caloriesBurned ?? 0));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Column(
                          children: [
                            Text('Total Duration', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('$totalDuration mins', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Calories Burned', style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('$totalCalories kcal', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: workouts.length,
                  itemBuilder: (context, index) {
                    final workout = workouts[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: ListTile(
                        title: Text(workout.workoutName),
                        subtitle: Text('${workout.durationMinutes} mins - ${workout.caloriesBurned ?? 0} kcal'),
                        trailing: Text(DateFormat.jm().format(workout.createdAt.toLocal())),
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
