import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/models/workout_log.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  String _exerciseName = '';
  int _duration = 0;
  int _caloriesBurned = 0;

  Future<void> _submitWorkout() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final user = supabase.auth.currentUser;
      if (user != null) {
        final workoutLog = WorkoutLog(
          id: ' ',
          userId: user.id,
          exerciseName: _exerciseName,
          durationMinutes: _duration,
          caloriesBurned: _caloriesBurned,
          createdAt: DateTime.now(),
        );
        try {
          await supabase.from('workout_logs').insert(workoutLog.toJson());
          if (mounted) {
            context.pop();
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving workout: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Workout')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Exercise Name'),
                onSaved: (value) => _exerciseName = value!,
                validator: (value) => value!.isEmpty ? 'Please enter an exercise name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Duration (minutes)'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _duration = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter a duration' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Calories Burned'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _caloriesBurned = int.parse(value!),
                validator: (value) => value!.isEmpty ? 'Please enter calories burned' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitWorkout,
                child: const Text('Add Workout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
