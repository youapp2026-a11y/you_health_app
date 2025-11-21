import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/app/app_theme.dart';
import 'package:myapp/constants.dart';
import 'package:myapp/features/auth/screens/auth_screen.dart';
import 'package:myapp/features/exercise_tracking/screens/add_workout_screen.dart';
import 'package:myapp/features/exercise_tracking/screens/workout_log_screen.dart';
import 'package:myapp/features/home/screens/home_screen.dart';
import 'package:myapp/features/meal_tracking/screens/add_meal_screen.dart';
import 'package:myapp/features/meal_tracking/screens/meal_log_screen.dart';
import 'package:myapp/features/onboarding/screens/onboarding_screen.dart';
import 'package:myapp/features/profile/screens/edit_profile_screen.dart';
import 'package:myapp/features/profile/screens/profile_screen.dart';
import 'package:myapp/features/profile/screens/profile_setup_screen.dart';
import 'package:myapp/providers/theme_provider.dart'; 
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const AuthGate(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/profile-setup',
      builder: (context, state) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),
    GoRoute(
      path: '/add-meal',
      builder: (context, state) => const AddMealScreen(),
    ),
    GoRoute(
      path: '/meal-log',
      builder: (context, state) => const MealLogScreen(),
    ),
    GoRoute(
      path: '/add-workout',
      builder: (context, state) => const AddWorkoutScreen(),
    ),
    GoRoute(
      path: '/workout-log',
      builder: (context, state) => const WorkoutLogScreen(),
    ),
  ],
);

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final session = snapshot.data?.session;
          if (session != null) {
            return const HomeScreen();
          }
        }
        return const AuthScreen();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          routerConfig: _router,
          title: 'YOU - Smart Health App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
        );
      },
    );
  }
}
