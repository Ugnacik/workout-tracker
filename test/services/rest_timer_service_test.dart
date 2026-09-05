import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/services/rest_timer_service.dart';

class FakeRestTimerNotifications implements RestTimerNotifications {
  bool permission = true;
  DateTime? scheduled;
  var cancelCount = 0;
  Completer<bool>? permissionWait;
  Completer<void>? scheduleWait;
  bool failSchedule = false;
  int scheduleCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async =>
      permissionWait == null ? permission : await permissionWait!.future;

  @override
  Future<void> schedule(DateTime deadline) async {
    scheduleCount++;
    if (scheduleWait != null) await scheduleWait!.future;
    if (failSchedule) throw StateError('scheduling failed');
    scheduled = deadline;
  }

  @override
  Future<void> cancel() async {
    cancelCount++;
    scheduled = null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('timer persists, extends, and clears its deadline', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftWorkoutRepository(database);
    await repository.initialize();
    final notifications = FakeRestTimerNotifications();
    final timer = RestTimerService(repository, notifications);
    await timer.initialize();
    await timer.setDuration(60);
    await timer.start();
    final original = timer.deadline!;
    expect(timer.isRunning, isTrue);
    expect(notifications.scheduled, original);
    expect(await repository.loadRestTimerDeadline(), original.toUtc());
    await timer.addThirtySeconds();
    expect(timer.deadline, original.add(const Duration(seconds: 30)));
    await timer.skip();
    expect(timer.isRunning, isFalse);
    expect(await repository.loadRestTimerDeadline(), isNull);
    expect(notifications.cancelCount, 4);
    timer.dispose();
    await repository.close();
  });

  test('denied notifications keep the in-app timer running', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final repository = DriftWorkoutRepository(database);
    await repository.initialize();
    final notifications = FakeRestTimerNotifications()..permission = false;
    final timer = RestTimerService(repository, notifications);
    await timer.initialize();
    await timer.start();
    expect(timer.permissionDenied, isTrue);
    expect(timer.isRunning, isTrue);
    expect(notifications.scheduled, isNull);
    await timer.skip();
    timer.dispose();
    await repository.close();
  });
  test(
    'skip during permission prompt cannot resurrect a cancelled timer',
    () async {
      final repository = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );
      await repository.initialize();
      final notifications = FakeRestTimerNotifications()
        ..permissionWait = Completer<bool>();
      final timer = RestTimerService(repository, notifications);
      await timer.initialize();
      final start = timer.start();
      await Future<void>.delayed(const Duration(milliseconds: 20));
      final skip = timer.skip();
      notifications.permissionWait!.complete(true);
      await Future.wait([start, skip]);
      expect(timer.deadline, isNull);
      expect(notifications.scheduled, isNull);
      expect(notifications.scheduleCount, 0);
      expect(await repository.loadRestTimerDeadline(), isNull);
      timer.dispose();
      await repository.close();
    },
  );

  test(
    'replacement and skip serialize behind an in-flight native schedule',
    () async {
      final repository = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );
      await repository.initialize();
      final notifications = FakeRestTimerNotifications()
        ..scheduleWait = Completer<void>();
      final timer = RestTimerService(repository, notifications);
      await timer.initialize();
      final first = timer.start();
      while (notifications.scheduleCount == 0) {
        await Future<void>.delayed(const Duration(milliseconds: 1));
      }
      final replacement = timer.start();
      final skip = timer.skip();
      notifications.scheduleWait!.complete();
      await Future.wait([first, replacement, skip]);
      expect(notifications.scheduled, isNull);
      expect(await repository.loadRestTimerDeadline(), isNull);
      timer.dispose();
      await repository.close();
    },
  );

  test(
    'extend failure is recoverable and cancellation is still attempted',
    () async {
      final repository = DriftWorkoutRepository(
        AppDatabase.forTesting(NativeDatabase.memory()),
      );
      await repository.initialize();
      final notifications = FakeRestTimerNotifications();
      final timer = RestTimerService(repository, notifications);
      await timer.initialize();
      await timer.start();
      notifications.failSchedule = true;
      await timer.addThirtySeconds();
      expect(timer.isRunning, isTrue);
      expect(timer.permissionDenied, isTrue);
      expect(notifications.scheduled, isNull);
      await timer.skip();
      notifications.failSchedule = false;
      await timer.start();
      expect(timer.permissionDenied, isFalse);
      expect(notifications.scheduled, timer.deadline);
      await timer.skip();
      timer.dispose();
      await repository.close();
    },
  );

  test('future deadline is restored and expired deadline is cleared', () async {
    final repository = DriftWorkoutRepository(
      AppDatabase.forTesting(NativeDatabase.memory()),
    );
    await repository.initialize();
    final deadline = DateTime.now().add(const Duration(minutes: 1));
    await repository.setRestTimerDeadline(deadline);
    final notifications = FakeRestTimerNotifications();
    var timer = RestTimerService(repository, notifications);
    await timer.initialize();
    expect(timer.deadline, deadline.toUtc());
    expect(notifications.scheduled, deadline.toUtc());
    timer.dispose();
    await repository.setRestTimerDeadline(
      DateTime.now().subtract(const Duration(minutes: 1)),
    );
    timer = RestTimerService(repository, notifications);
    await timer.initialize();
    expect(timer.deadline, isNull);
    expect(notifications.scheduled, isNull);
    timer.dispose();
    await repository.close();
  });
}
