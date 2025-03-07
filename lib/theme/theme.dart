import "package:cold_river_express_app/theme/buttons_style.dart";
import "package:flutter/material.dart";

class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff00696f),
      surfaceTint: Color(0xff00696f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff9cf0f7),
      onPrimaryContainer: Color(0xff004f54),
      secondary: Color(0xff4a6365),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffcce8ea),
      onSecondaryContainer: Color(0xff324b4d),
      tertiary: Color(0xff4f5f7d),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xffd6e3ff),
      onTertiaryContainer: Color(0xff374764),
      error: Color(0xffba1a1a),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffffdad6),
      onErrorContainer: Color(0xff93000a),
      surface: Color(0xfff4fafb),
      onSurface: Color(0xff161d1d),
      onSurfaceVariant: Color(0xff3f4849),
      outline: Color(0xff6f797a),
      outlineVariant: Color(0xffbec8c9),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3232),
      inversePrimary: Color(0xff80d4db),
      primaryFixed: Color(0xff9cf0f7),
      onPrimaryFixed: Color(0xff002022),
      primaryFixedDim: Color(0xff80d4db),
      onPrimaryFixedVariant: Color(0xff004f54),
      secondaryFixed: Color(0xffcce8ea),
      onSecondaryFixed: Color(0xff051f21),
      secondaryFixedDim: Color(0xffb1cbce),
      onSecondaryFixedVariant: Color(0xff324b4d),
      tertiaryFixed: Color(0xffd6e3ff),
      onTertiaryFixed: Color(0xff091b36),
      tertiaryFixedDim: Color(0xffb6c7ea),
      onTertiaryFixedVariant: Color(0xff374764),
      surfaceDim: Color(0xffd5dbdb),
      surfaceBright: Color(0xfff4fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f5),
      surfaceContainer: Color(0xffe9efef),
      surfaceContainerHigh: Color(0xffe3e9e9),
      surfaceContainerHighest: Color(0xffdde4e4),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003d41),
      surfaceTint: Color(0xff00696f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff16797f),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff213a3c),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff587274),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff263652),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff5d6d8c),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff740006),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffcf2c27),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fafb),
      onSurface: Color(0xff0c1213),
      onSurfaceVariant: Color(0xff2e3839),
      outline: Color(0xff4b5455),
      outlineVariant: Color(0xff656f70),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3232),
      inversePrimary: Color(0xff80d4db),
      primaryFixed: Color(0xff16797f),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff005e64),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff587274),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff40595b),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff5d6d8c),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff455573),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc1c8c8),
      surfaceBright: Color(0xfff4fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffeff5f5),
      surfaceContainer: Color(0xffe3e9e9),
      surfaceContainerHigh: Color(0xffd8dede),
      surfaceContainerHighest: Color(0xffcdd3d3),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff003235),
      surfaceTint: Color(0xff00696f),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff005256),
      onPrimaryContainer: Color(0xffffffff),
      secondary: Color(0xff173032),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff354d4f),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff1c2c48),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff3a4966),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff600004),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff98000a),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfff4fafb),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff242e2f),
      outlineVariant: Color(0xff414b4c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff2b3232),
      inversePrimary: Color(0xff80d4db),
      primaryFixed: Color(0xff005256),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff00393d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff354d4f),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff1e3739),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff3a4966),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff23334f),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffb4baba),
      surfaceBright: Color(0xfff4fafb),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xffecf2f2),
      surfaceContainer: Color(0xffdde4e4),
      surfaceContainerHigh: Color(0xffcfd6d6),
      surfaceContainerHighest: Color(0xffc1c8c8),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff80d4db),
      surfaceTint: Color(0xff80d4db),
      onPrimary: Color(0xff00363a),
      primaryContainer: Color(0xff004f54),
      onPrimaryContainer: Color(0xff9cf0f7),
      secondary: Color(0xffb1cbce),
      onSecondary: Color(0xff1b3436),
      secondaryContainer: Color(0xff324b4d),
      onSecondaryContainer: Color(0xffcce8ea),
      tertiary: Color(0xffb6c7ea),
      onTertiary: Color(0xff20304c),
      tertiaryContainer: Color(0xff374764),
      onTertiaryContainer: Color(0xffd6e3ff),
      error: Color(0xffffb4ab),
      onError: Color(0xff690005),
      errorContainer: Color(0xff93000a),
      onErrorContainer: Color(0xffffdad6),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffdde4e4),
      onSurfaceVariant: Color(0xffbec8c9),
      outline: Color(0xff899393),
      outlineVariant: Color(0xff3f4849),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e4),
      inversePrimary: Color(0xff00696f),
      primaryFixed: Color(0xff9cf0f7),
      onPrimaryFixed: Color(0xff002022),
      primaryFixedDim: Color(0xff80d4db),
      onPrimaryFixedVariant: Color(0xff004f54),
      secondaryFixed: Color(0xffcce8ea),
      onSecondaryFixed: Color(0xff051f21),
      secondaryFixedDim: Color(0xffb1cbce),
      onSecondaryFixedVariant: Color(0xff324b4d),
      tertiaryFixed: Color(0xffd6e3ff),
      onTertiaryFixed: Color(0xff091b36),
      tertiaryFixedDim: Color(0xffb6c7ea),
      onTertiaryFixedVariant: Color(0xff374764),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff343a3b),
      surfaceContainerLowest: Color(0xff090f10),
      surfaceContainerLow: Color(0xff161d1d),
      surfaceContainer: Color(0xff1a2121),
      surfaceContainerHigh: Color(0xff252b2c),
      surfaceContainerHighest: Color(0xff303636),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xff96eaf1),
      surfaceTint: Color(0xff80d4db),
      onPrimary: Color(0xff002b2e),
      primaryContainer: Color(0xff479da4),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xffc6e1e4),
      onSecondary: Color(0xff10292b),
      secondaryContainer: Color(0xff7b9598),
      onSecondaryContainer: Color(0xff000000),
      tertiary: Color(0xffcdddff),
      onTertiary: Color(0xff152641),
      tertiaryContainer: Color(0xff8191b2),
      onTertiaryContainer: Color(0xff000000),
      error: Color(0xffffd2cc),
      onError: Color(0xff540003),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffd4dedf),
      outline: Color(0xffaab4b4),
      outlineVariant: Color(0xff889293),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e4),
      inversePrimary: Color(0xff005055),
      primaryFixed: Color(0xff9cf0f7),
      onPrimaryFixed: Color(0xff001416),
      primaryFixedDim: Color(0xff80d4db),
      onPrimaryFixedVariant: Color(0xff003d41),
      secondaryFixed: Color(0xffcce8ea),
      onSecondaryFixed: Color(0xff001416),
      secondaryFixedDim: Color(0xffb1cbce),
      onSecondaryFixedVariant: Color(0xff213a3c),
      tertiaryFixed: Color(0xffd6e3ff),
      onTertiaryFixed: Color(0xff00112b),
      tertiaryFixedDim: Color(0xffb6c7ea),
      onTertiaryFixedVariant: Color(0xff263652),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff3f4646),
      surfaceContainerLowest: Color(0xff040809),
      surfaceContainerLow: Color(0xff181f1f),
      surfaceContainer: Color(0xff232929),
      surfaceContainerHigh: Color(0xff2d3434),
      surfaceContainerHighest: Color(0xff383f3f),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffc0faff),
      surfaceTint: Color(0xff80d4db),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xff7cd0d7),
      onPrimaryContainer: Color(0xff000e0f),
      secondary: Color(0xffdaf5f7),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffadc8ca),
      onSecondaryContainer: Color(0xff000e0f),
      tertiary: Color(0xffebf0ff),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xffb3c3e6),
      onTertiaryContainer: Color(0xff000b20),
      error: Color(0xffffece9),
      onError: Color(0xff000000),
      errorContainer: Color(0xffff5449),
      onErrorContainer: Color(0xff220001),
      surface: Color(0xff0e1415),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xffe8f2f2),
      outlineVariant: Color(0xffbac4c5),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffdde4e4),
      inversePrimary: Color(0xff005055),
      primaryFixed: Color(0xff9cf0f7),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xff80d4db),
      onPrimaryFixedVariant: Color(0xff001416),
      secondaryFixed: Color(0xffcce8ea),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffb1cbce),
      onSecondaryFixedVariant: Color(0xff001416),
      tertiaryFixed: Color(0xffd6e3ff),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xffb6c7ea),
      onTertiaryFixedVariant: Color(0xff00112b),
      surfaceDim: Color(0xff0e1415),
      surfaceBright: Color(0xff4b5152),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff1a2121),
      surfaceContainer: Color(0xff2b3232),
      surfaceContainerHigh: Color(0xff363d3d),
      surfaceContainerHighest: Color(0xff414848),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyles.primary(colorScheme),
    ),
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
