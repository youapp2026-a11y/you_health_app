
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../widgets/health_summary.dart';
import '../widgets/quick_actions.dart';
import '../widgets/activity_feed.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              context.push('/profile');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          HealthSummary(),
          SizedBox(height: 24),
          QuickActions(),
          SizedBox(height: 24),
          ActivityFeed(),
        ],
      ),
    );
  }
}
