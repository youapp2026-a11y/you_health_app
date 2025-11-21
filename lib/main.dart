
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_theme.dart';
import 'constants.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/screens/auth_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/profile/screens/profile_setup_screen.dart';
import 'features/meal_tracking/screens/add_meal_screen.dart';
import 'features/meal_tracking/screens/meal_log_screen.dart';
import 'features/exercise_tracking/screens/add_workout_screen.dart';
import 'features/exercise_tracking/screens/workout_log_screen.dart';
import 'features/profile/screens/profile_screen.dart';
import 'features/profile/screens/edit_profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnnonKey,
  );

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter _router = GoRouter(
      routes: <RouteBase>[
        GoRoute(
          path: '/',
          builder: (BuildContext context, GoRouterState state) {
            return const OnboardingScreen();
          },
        ),
        GoRoute(
          path: '/auth',
          builder: (BuildContext acontext, GoRouterState state) {
            return const AuthScreen();
          },
        ),
        GoRoute(
          path: '/home',
          builder: (BuildContext context, GoRouterState state) {
            return const HomeScreen();
          },
        ),
        GoRoute(
          path: '/profile-setup',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileSetupScreen();
          },
        ),
        GoRoute(
          path: '/add-meal',
          builder: (BuildContext context, GoRouterState state) {
            return const AddMealScreen();
          },
        ),
        GoRoute(
          path: '/meal-log',
          builder: (BuildContext context, GoRouterState state) {
            return const MealLogScreen();
          },
        ),
        GoRoute(
          path: '/add-workout',
          builder: (BuildContext context, GoRouterState state) {
            return const AddWorkoutScreen();
          },
        ),
        GoRoute(
          path: '/workout-log',
          builder: (BuildContext context, GoRouterState state) {
            return const WorkoutLogScreen();
          },
        ),
        GoRoute(
          path: '/profile',
          builder: (BuildContext context, GoRouterState state) {
            return const ProfileScreen();
          },
        ),
        GoRoute(
          path: '/edit-profile',
          builder: (BuildContext context, GoRouterState state) {
            return const EditProfileScreen();
          },
        ),
      ],
    );

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
