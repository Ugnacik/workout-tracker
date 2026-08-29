import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/app.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/state/app_controller.dart';

void main() {
  testWidgets('user can start, log, finish, and review a workout', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(430, 900));
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ready when you are'), findsOneWidget);
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start empty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add exercise'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Neutral-grip pull-up'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to workout'));
    await tester.pumpAndSettle();

    expect(find.text('Neutral-grip pull-up'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, '8');
    await tester.pump();
    await tester.tap(find.byIcon(Icons.radio_button_unchecked));
    await tester.pumpAndSettle();
    expect(find.textContaining('Rest 1:'), findsOneWidget);
    await tester.tap(find.text('Finish'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Finish'));
    await tester.pumpAndSettle();

    expect(find.textContaining('1 exercises'), findsOneWidget);
    await tester.tap(find.textContaining('1 exercises'));
    await tester.pumpAndSettle();
    expect(find.textContaining('8 reps'), findsOneWidget);
    await tester.tap(find.text('Save as routine'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pull day');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    expect(find.text('Pull day'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await database.close();
  });
}
