
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to YOU',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 20),
            Text(
              'Your Smart Health Companion',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () {
                context.go('/auth');
              },
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
