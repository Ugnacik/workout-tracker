import 'package:flutter/material.dart';

abstract final class AppSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

abstract final class AppRadii {
  static const input = 12.0;
  static const card = 16.0;
  static const sheet = 24.0;
  static const pill = 999.0;
}

abstract final class AppSizes {
  static const minTouchTarget = 48.0;
  static const iconSmall = 20.0;
  static const icon = 24.0;
  static const maxContentWidth = 720.0;
}

abstract final class AppMotion {
  static const instant = Duration(milliseconds: 100);
  static const short = Duration(milliseconds: 200);

  static Duration responsive(BuildContext context, Duration duration) =>
      MediaQuery.disableAnimationsOf(context) ? Duration.zero : duration;
}

@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.successSurface,
    required this.subtleSurface,
    required this.warningSurface,
  });

  final Color successSurface;
  final Color subtleSurface;
  final Color warningSurface;

  @override
  AppSemanticColors copyWith({
    Color? successSurface,
    Color? subtleSurface,
    Color? warningSurface,
  }) => AppSemanticColors(
    successSurface: successSurface ?? this.successSurface,
    subtleSurface: subtleSurface ?? this.subtleSurface,
    warningSurface: warningSurface ?? this.warningSurface,
  );

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      successSurface: Color.lerp(successSurface, other.successSurface, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      warningSurface: Color.lerp(warningSurface, other.warningSurface, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppSemanticColors get semanticColors =>
      Theme.of(this).extension<AppSemanticColors>()!;
}
