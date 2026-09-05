import 'package:flutter/services.dart';

abstract final class SystemSettingsService {
  static const _channel = MethodChannel('workout_tracker/system_settings');

  static Future<bool> openNotificationSettings() async =>
      await _channel.invokeMethod<bool>('openNotificationSettings') ?? false;
}
