import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/exercise_picker_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/exercises',
      builder: (context, state) => const ExercisePickerScreen(),
    ),
  ],
);

class WorkoutTrackerApp extends StatelessWidget {
  const WorkoutTrackerApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF16211A);
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF42D47D),
      brightness: Brightness.light,
      primary: const Color(0xFF08783D),
      surface: const Color(0xFFF6F8F4),
    );
    return MaterialApp.router(
      title: 'Workout Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: router ?? appRouter,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: scheme.surface,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: ink,
          displayColor: ink,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          titleTextStyle: TextStyle(
            color: ink,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        cardTheme: const CardThemeData(
          elevation: 0,
          color: Colors.white,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            side: BorderSide(color: Color(0xFFE4E9E2)),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFDDE4DB)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
