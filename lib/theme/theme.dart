import 'package:flutter/material.dart';
import 'package:cold_river_express_app/theme/buttons_style.dart';

class MaterialTheme {
  final TextTheme textTheme;
  final Color primarySeed;
  final Color? secondarySeed;

  const MaterialTheme({
    required this.textTheme,
    required this.primarySeed,
    this.secondarySeed,
  });

  ThemeData light() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
      secondary: secondarySeed,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyles.primary(scheme),
      ),
    );
  }

  ThemeData dark() {
    final ColorScheme scheme = ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.dark,
      secondary: secondarySeed,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: textTheme.apply(
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyles.primary(scheme),
      ),
    );
  }
}
