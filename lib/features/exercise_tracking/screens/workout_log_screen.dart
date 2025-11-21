import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/workout_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class WorkoutLogScreen extends StatefulWidget {
  const WorkoutLogScreen({super.key});

  @override
  State<WorkoutLogScreen> createState() => _WorkoutLogScreenState();
}

class _WorkoutLogScreenState extends State<WorkoutLogScreen> {
  late Future<List<WorkoutLog>> _workoutLogsFuture;

  @override
  void initState() {
    super.initState();
    _workoutLogsFuture = _fetchWorkoutLogs();
  }

  Future<List<WorkoutLog>> _fetchWorkoutLogs() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return [];
    }

    try {
      final response = await supabase
          .from('workout_logs')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return (response as List).map((e) => WorkoutLog.fromJson(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching workouts: $e')),
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Today\'s Workouts (${DateFormat.yMd().format(DateTime.now())})'),
      ),
      body: FutureBuilder<List<WorkoutLog>>(
        future: _workoutLogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final workouts = snapshot.data ?? [];
          if (workouts.isEmpty) {
            return const Center(child: Text('No workouts logged yet.'));
          }
          return ListView.builder(
            itemCount: workouts.length,
            itemBuilder: (context, index) {
              final workout = workouts[index];
              return ListTile(
                title: Text(workout.exerciseName),
                subtitle: Text(
                    '${workout.durationMinutes} mins - ${workout.caloriesBurned} kcal'),
                trailing: Text(DateFormat.jm().format(workout.createdAt.toLocal())),
              );
            },
          );
        },
      ),
    );
  }
}
