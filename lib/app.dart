import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'domain/models.dart';
import 'state/app_controller.dart';
import 'ui/screens/dashboard_screen.dart';
import 'ui/screens/exercise_picker_screen.dart';
import 'ui/theme/app_theme.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const DashboardScreen()),
    GoRoute(
      path: '/exercises',
      builder: (context, state) => const ExercisePickerScreen(),
    ),
  ],
);

class WorkoutTrackerApp extends ConsumerWidget {
  const WorkoutTrackerApp({super.key, this.router});

  final GoRouter? router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preference = ref.watch(
      appControllerProvider.select((controller) => controller.themePreference),
    );
    return MaterialApp.router(
      title: 'Workout Tracker',
      debugShowCheckedModeBanner: false,
      routerConfig: router ?? appRouter,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: switch (preference) {
        AppThemePreference.dark => ThemeMode.dark,
        AppThemePreference.light => ThemeMode.light,
        AppThemePreference.system => ThemeMode.system,
      },
    );
  }
}
