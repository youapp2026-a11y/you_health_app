import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:myapp/constants.dart';

class HealthSummary extends StatefulWidget {
  const HealthSummary({super.key});

  @override
  State<HealthSummary> createState() => _HealthSummaryState();
}

class _HealthSummaryState extends State<HealthSummary> {
  Map<String, dynamic>? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      try {
        final response = await supabase.from('users').select().eq('id', user.id).single();
        setState(() {
          _userProfile = response;
          _isLoading = false;
        });
      } catch (e) {
        // Handle error
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_userProfile == null) {
      return const Center(child: Text('No profile data.'));
    }

    final name = _userProfile!['name'] ?? 'User';
    // You can calculate BMI or other metrics here

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome back, $name!', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Add more health summary widgets here
            Text('Here is a summary of your health today...'),
          ],
        ),
      ),
    );
  }
}
