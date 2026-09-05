
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/services/rest_timer_service.dart';

// Run with tool/verify_android_notifications.py. The host grants permissions on
// the test emulator and changes lifecycle/screen state at the printed markers.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'real Android foreground, background, lock-screen and cancellation delivery',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Rest notification delivery check')),
          ),
        ),
      );
      final repository = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );
      await repository.initialize();
      final plugin = FlutterLocalNotificationsPlugin();
      final notifications = LocalRestTimerNotifications(plugin: plugin);
      final timer = RestTimerService(repository, notifications);
      await timer.initialize();
      debugPrint('REST_QA:denied-initial');
      await Future<void>.delayed(const Duration(seconds: 4));
      await timer.start();
      expect(timer.permissionDenied, isTrue);
      expect(timer.isRunning, isTrue);
      expect(await plugin.pendingNotificationRequests(), isEmpty);
      await timer.skip();
      debugPrint('REST_QA:permissions');
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(await notifications.requestPermission(), isTrue);

      for (final state in ['foreground', 'background', 'locked']) {
        await timer.skip();
        await timer.setDuration(4);
        await timer.start();
        expect(timer.timingMayBeDelayed, isFalse);
        expect(await plugin.pendingNotificationRequests(), hasLength(1));
        debugPrint('REST_QA:$state');
        await Future<void>.delayed(const Duration(seconds: 11));
        final active = await plugin.getActiveNotifications();
        expect(active.where((n) => n.id == 1), hasLength(1), reason: state);
        expect(active.single.title, 'Rest complete');
        expect(await plugin.pendingNotificationRequests(), isEmpty);
        debugPrint('REST_QA:passed-$state');
      }

      await timer.skip();
      await timer.setDuration(3);
      await timer.start();
      await timer.skip();
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(await plugin.pendingNotificationRequests(), isEmpty);
      expect(await plugin.getActiveNotifications(), isEmpty);

      await timer.setDuration(2);
      await timer.start();
      await timer.setDuration(7);
      await timer.start();
      expect(await plugin.pendingNotificationRequests(), hasLength(1));
      await Future<void>.delayed(const Duration(seconds: 4));
      expect(
        await plugin.getActiveNotifications(),
        isEmpty,
        reason: 'replaced deadline must not alert',
      );
      await Future<void>.delayed(const Duration(seconds: 5));
      expect(await plugin.getActiveNotifications(), hasLength(1));
      await timer.skip();

      debugPrint('REST_QA:done');
      timer.dispose();
      await repository.close();
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
