import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
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

abstract interface class RestTimerPrecision {
  bool get timingMayBeDelayed;
  Future<void> requestExactTiming();
}

class LocalRestTimerNotifications
    implements RestTimerNotifications, RestTimerPrecision {
  LocalRestTimerNotifications({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  static const notificationId = 1;
  bool _timingMayBeDelayed = false;

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  @override
  bool get timingMayBeDelayed => _timingMayBeDelayed;

  @override
  Future<void> initialize() async {
    tz.initializeTimeZones();
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_rest_timer'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestSoundPermission: false,
          requestBadgePermission: false,
        ),
        linux: LinuxInitializationSettings(defaultActionName: 'Open workout'),
      ),
    );
    final android = _android;
    if (android != null) {
      _timingMayBeDelayed =
          !(await android.canScheduleExactNotifications() ?? false);
    }
  }

  @override
  Future<bool> requestPermission() async {
    final android = _android;
    if (android != null) {
      return (await android.requestNotificationsPermission() ?? false) &&
          (await android.areNotificationsEnabled() ?? false);
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin
            >()
            ?.requestPermissions(alert: true, sound: true) ??
        false;
  }

  @override
  Future<void> requestExactTiming() async {
    await _android?.requestExactAlarmsPermission();
    _timingMayBeDelayed =
        !(await _android?.canScheduleExactNotifications() ?? true);
  }

  @override
  Future<void> schedule(DateTime deadline) async {
    final android = _android;
    _timingMayBeDelayed =
        android != null &&
        !(await android.canScheduleExactNotifications() ?? false);
    try {
      await _schedule(
        deadline,
        _timingMayBeDelayed
            ? AndroidScheduleMode.inexactAllowWhileIdle
            : AndroidScheduleMode.exactAllowWhileIdle,
      );
    } on PlatformException catch (error) {
      if (error.code != 'exact_alarms_not_permitted') rethrow;
      // Access can be revoked between the capability check and scheduling.
      _timingMayBeDelayed = true;
      await _schedule(deadline, AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  Future<void> _schedule(DateTime deadline, AndroidScheduleMode mode) =>
      _plugin.zonedSchedule(
        notificationId,
        'Rest complete',
        'Time for your next set.',
        // An elapsed rest interval is an absolute instant, independent of local
        // timezone changes or daylight saving time.
        tz.TZDateTime.from(deadline, tz.UTC),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'rest_timer',
            'Rest timer',
            channelDescription: 'Alerts when a workout rest period ends.',
            importance: Importance.high,
            priority: Priority.high,
            visibility: NotificationVisibility.public,
            category: AndroidNotificationCategory.alarm,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
        androidScheduleMode: mode,
      );

  @override
  Future<void> cancel() => _plugin.cancel(notificationId);
}

class RestTimerService extends ChangeNotifier with WidgetsBindingObserver {
  RestTimerService(this._repository, this._notifications);

  final WorkoutRepository _repository;
  final RestTimerNotifications _notifications;
  Timer? _ticker;
  DateTime? _deadline;
  int _durationSeconds = 90;
  bool _permissionDenied = false;
  bool _notificationsReady = false;
  bool _disposed = false;
  int _revision = 0;
  Future<void> _operations = Future.value();

  int get durationSeconds => _durationSeconds;
  DateTime? get deadline => _deadline;
  bool get isRunning => remainingSeconds > 0;
  bool get permissionDenied => _permissionDenied;
  bool get timingMayBeDelayed =>
      _notifications is RestTimerPrecision &&
      (_notifications as RestTimerPrecision).timingMayBeDelayed;
  int get remainingSeconds {
    final milliseconds =
        _deadline?.difference(DateTime.now()).inMilliseconds ?? 0;
    return milliseconds <= 0 ? 0 : (milliseconds / 1000).ceil();
  }

  Future<void> initialize() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      await _notifications.initialize();
      _notificationsReady = true;
    } catch (error) {
      debugPrint('Rest notifications unavailable: $error');
    }
    _durationSeconds = await _repository.loadRestTimerSeconds();
    _deadline = await _repository.loadRestTimerDeadline();
    if (isRunning) {
      // Reconcile persisted timer after process recreation; a single native ID
      // replaces an existing request rather than creating a second alert.
      await _scheduleCurrent(_revision, requestPermission: false);
      _startTicker();
    } else {
      _deadline = null;
      await _repository.setRestTimerDeadline(null);
      await _cancelNotification();
    }
    _notify();
  }

  Future<void> setDuration(int seconds) async {
    if (seconds <= 0) throw ArgumentError.value(seconds, 'seconds');
    _durationSeconds = seconds;
    await _repository.setRestTimerSeconds(seconds);
    _notify();
  }

  Future<void> start() {
    _deadline = DateTime.now().add(Duration(seconds: _durationSeconds));
    final revision = ++_revision;
    _startTicker();
    _notify();
    return _enqueue(() => _scheduleCurrent(revision, requestPermission: true));
  }

  Future<void> addThirtySeconds() {
    if (!isRunning) return Future.value();
    _deadline = _deadline!.add(const Duration(seconds: 30));
    final revision = ++_revision;
    _notify();
    return _enqueue(() => _scheduleCurrent(revision, requestPermission: true));
  }

  Future<void> skip() {
    final revision = ++_revision;
    _ticker?.cancel();
    _ticker = null;
    _deadline = null;
    _notify();
    return _enqueue(() async {
      if (revision != _revision) return;
      await _repository.setRestTimerDeadline(null);
      await _cancelNotification();
    });
  }

  Future<void> enablePreciseAlerts() async {
    if (_notifications is! RestTimerPrecision) return;
    try {
      await (_notifications as RestTimerPrecision).requestExactTiming();
      if (isRunning) {
        final revision = _revision;
        await _enqueue(
          () => _scheduleCurrent(revision, requestPermission: false),
        );
      }
    } catch (error) {
      debugPrint('Could not enable precise rest alerts: $error');
    }
    _notify();
  }

  Future<void> _scheduleCurrent(
    int revision, {
    required bool requestPermission,
  }) async {
    if (revision != _revision || _disposed) return;
    final deadline = _deadline;
    await _repository.setRestTimerDeadline(deadline);
    // Always remove the previous request, including when permission was revoked.
    await _cancelNotification();
    if (revision != _revision || deadline == null || _disposed) return;
    try {
      if (!_notificationsReady) {
        await _notifications.initialize();
        _notificationsReady = true;
      }
      final allowed =
          !requestPermission || await _notifications.requestPermission();
      if (revision != _revision || _disposed) return;
      _permissionDenied = !allowed;
      if (allowed && deadline.isAfter(DateTime.now())) {
        await _notifications.schedule(deadline);
      }
    } catch (error) {
      debugPrint('Could not schedule rest notification: $error');
      _permissionDenied = true;
    }
    _notify();
  }

  Future<void> _cancelNotification() async {
    try {
      // Initialization/scheduling failure must not disable future cancellation.
      await _notifications.cancel();
    } catch (error) {
      debugPrint('Could not cancel rest notification: $error');
      _permissionDenied = true;
    }
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final result = _operations.then((_) => action());
    _operations = result.catchError((Object error) {
      debugPrint('Rest timer operation failed: $error');
    });
    return result;
  }

  void _startTicker() {
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_disposed) return;
    if (!isRunning && _deadline != null) {
      final revision = _revision;
      _ticker?.cancel();
      _ticker = null;
      _deadline = null;
      unawaited(
        _enqueue(() async {
          if (revision == _revision) {
            await _repository.setRestTimerDeadline(null);
          }
        }),
      );
      // Native scheduling delivers in foreground as well as background.
      // Do not cancel or also show here: either would race the native alarm.
    }
    _notify();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _tick();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }
}
