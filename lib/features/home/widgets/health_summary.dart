
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../main.dart';
import '../../profile/models/user_profile.dart';

class HealthSummary extends StatefulWidget {
  const HealthSummary({super.key});

  @override
  _HealthSummaryState createState() => _HealthSummaryState();
}

class _HealthSummaryState extends State<HealthSummary> {
  late Future<UserProfile?> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _fetchUserProfile();
  }

  Future<UserProfile?> _fetchUserProfile() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      return null;
    }
    final response = await supabase.from('users').select().eq('id', user.id).single();
    return UserProfile.fromMap(response);
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('Could not load profile data.'),
            ),
          );
        }

        final profile = snapshot.data!;
        final bmi = profile.bmi;
        final bmiCategory = _getBmiCategory(bmi);
        final bmiColor = _getBmiColor(bmi);

        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text('Health Overview', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildHealthMetric('Calories', '2,200', 'kcal', context),
                    _buildHealthMetric('Workouts', '3', 'times', context),
                    _buildHealthMetric('Water', '8', 'glasses', context),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 16),
                _buildBmiSection(bmi, bmiCategory, bmiColor, context),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthMetric(String label, String value, String unit, BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(unit, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildBmiSection(double bmi, String category, Color color, BuildContext context) {
    return Column(
      children: [
        Text('Your Body Mass Index (BMI)', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          bmi.toStringAsFixed(1),
          style: Theme.of(context).textTheme.displaySmall?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(category, style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: color)),
      ],
    );
  }
}
