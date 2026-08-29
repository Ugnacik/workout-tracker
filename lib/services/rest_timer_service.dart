import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../domain/workout_repository.dart';

abstract interface class RestTimerNotifications {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> schedule(DateTime deadline);
  Future<void> cancel();
}

class LocalRestTimerNotifications implements RestTimerNotifications {
  LocalRestTimerNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
    );
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, sound: true) ??
        true;
  }

  @override
  Future<void> schedule(DateTime deadline) => _plugin.zonedSchedule(
    1,
    'Rest complete',
    'Time for your next set.',
    tz.TZDateTime.from(deadline, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'rest_timer',
        'Rest timer',
        channelDescription: 'Alerts when a workout rest period ends.',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  );

  @override
  Future<void> cancel() => _plugin.cancel(1);
}

class RestTimerService extends ChangeNotifier {
  RestTimerService(this._repository, this._notifications);

  final WorkoutRepository _repository;
  final RestTimerNotifications _notifications;
  Timer? _ticker;
  DateTime? _deadline;
  int _durationSeconds = 90;
  bool _permissionDenied = false;
  bool _notificationsReady = true;

  int get durationSeconds => _durationSeconds;
  DateTime? get deadline => _deadline;
  bool get isRunning => remainingSeconds > 0;
  bool get permissionDenied => _permissionDenied;
  int get remainingSeconds {
    final deadline = _deadline;
    if (deadline == null) return 0;
    final remaining = deadline.difference(DateTime.now()).inSeconds;
    return remaining < 0 ? 0 : remaining;
  }

  Future<void> initialize() async {
    try {
      await _notifications.initialize();
    } catch (_) {
      _notificationsReady = false;
    }
    _durationSeconds = await _repository.loadRestTimerSeconds();
    _deadline = await _repository.loadRestTimerDeadline();
    if (_deadline != null && _deadline!.isAfter(DateTime.now())) {
      _startTicker();
    } else {
      _deadline = null;
      await _repository.setRestTimerDeadline(null);
    }
    notifyListeners();
  }

  Future<void> setDuration(int seconds) async {
    _durationSeconds = seconds;
    await _repository.setRestTimerSeconds(seconds);
    notifyListeners();
  }

  Future<void> start() async {
    final deadline = DateTime.now().add(Duration(seconds: _durationSeconds));
    _deadline = deadline;
    await _repository.setRestTimerDeadline(deadline);
    var allowed = false;
    if (_notificationsReady) {
      try {
        allowed = await _notifications.requestPermission();
      } catch (_) {
        _notificationsReady = false;
      }
    }
    _permissionDenied = !allowed;
    if (allowed) {
      try {
        await _notifications.schedule(deadline);
      } catch (_) {
        _notificationsReady = false;
        _permissionDenied = true;
      }
    }
    _startTicker();
    notifyListeners();
  }

  Future<void> addThirtySeconds() async {
    if (!isRunning) return;
    _deadline = _deadline!.add(const Duration(seconds: 30));
    await _repository.setRestTimerDeadline(_deadline);
    if (!_permissionDenied && _notificationsReady) {
      await _notifications.schedule(_deadline!);
    }
    notifyListeners();
  }

  Future<void> skip() async {
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;
    await _repository.setRestTimerDeadline(null);
    if (_notificationsReady) await _notifications.cancel();
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!isRunning) {
        _ticker?.cancel();
        _ticker = null;
        _deadline = null;
        await _repository.setRestTimerDeadline(null);
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }
}
