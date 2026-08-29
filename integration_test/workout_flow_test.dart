import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:workout_tracker/app.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/state/app_controller.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android acceptance smoke test', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    await tester.pumpWidget(
      ProviderScope(
        overrides: [databaseProvider.overrideWithValue(database)],
        child: const WorkoutTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Start workout'), findsOneWidget);
    await tester.tap(find.text('Start workout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Start empty'));
    await tester.pumpAndSettle();
    expect(find.text('Add exercise'), findsOneWidget);
    await database.close();
  });
}
