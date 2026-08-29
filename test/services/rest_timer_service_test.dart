import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:workout_tracker/data/app_database.dart';
import 'package:workout_tracker/data/drift_workout_repository.dart';
import 'package:workout_tracker/services/rest_timer_service.dart';

class FakeRestTimerNotifications implements RestTimerNotifications {
  bool permission = true;
  DateTime? scheduled;
  var cancelCount = 0;

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => permission;

  @override
  Future<void> schedule(DateTime deadline) async => scheduled = deadline;

  @override
  Future<void> cancel() async {
    cancelCount++;
    scheduled = null;
  }
}

void main() {
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
    expect(notifications.cancelCount, 1);
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
}
