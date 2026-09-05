import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:workout_tracker/services/rest_timer_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  bool exact = true;
  bool allowed = true;
  bool revokeDuringSchedule = false;
  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    calls.clear();
    exact = true;
    allowed = true;
    revokeDuringSchedule = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          if (call.method == 'canScheduleExactNotifications') return exact;
          if (call.method == 'requestNotificationsPermission') return allowed;
          if (call.method == 'zonedSchedule' && revokeDuringSchedule) {
            revokeDuringSchedule = false;
            throw PlatformException(code: 'exact_alarms_not_permitted');
          }
          return true;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test(
    'Android requests notification access and schedules one exact UTC alert',
    () async {
      final notifications = LocalRestTimerNotifications();
      await notifications.initialize();
      expect(await notifications.requestPermission(), isTrue);
      final deadline = DateTime.now().add(const Duration(minutes: 1));
      await notifications.schedule(deadline);
      final args =
          calls.singleWhere((c) => c.method == 'zonedSchedule').arguments
              as Map;
      expect(args['id'], LocalRestTimerNotifications.notificationId);
      expect(args['timeZoneName'], 'UTC');
      expect(
        (args['platformSpecifics'] as Map)['scheduleMode'],
        'exactAllowWhileIdle',
      );
      await notifications.cancel();
      expect(calls.last.method, 'cancel');
      expect(
        (calls.last.arguments as Map)['id'],
        LocalRestTimerNotifications.notificationId,
      );
    },
  );

  test(
    'denied exact access uses idle-capable fallback and exposes delay status',
    () async {
      exact = false;
      final notifications = LocalRestTimerNotifications();
      await notifications.initialize();
      await notifications.schedule(
        DateTime.now().add(const Duration(minutes: 1)),
      );
      expect(notifications.timingMayBeDelayed, isTrue);
      final args = calls.last.arguments as Map;
      expect(
        (args['platformSpecifics'] as Map)['scheduleMode'],
        'inexactAllowWhileIdle',
      );
      allowed = false;
      expect(await notifications.requestPermission(), isFalse);
    },
  );

  test(
    'revocation during exact scheduling falls back without duplicate IDs',
    () async {
      final notifications = LocalRestTimerNotifications();
      await notifications.initialize();
      revokeDuringSchedule = true;
      await notifications.schedule(
        DateTime.now().add(const Duration(minutes: 1)),
      );
      final schedules = calls
          .where((c) => c.method == 'zonedSchedule')
          .toList();
      expect(schedules, hasLength(2));
      expect(schedules.map((c) => (c.arguments as Map)['id']).toSet(), {1});
      expect(notifications.timingMayBeDelayed, isTrue);
    },
  );
}
