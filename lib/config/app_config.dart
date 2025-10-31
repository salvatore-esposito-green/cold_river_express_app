import 'package:cold_river_express_app/theme/theme.dart';
import 'package:cold_river_express_app/theme/util.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {
  // App name
  static String appName = "Cold River Express";

  // Logo
  static String logoPath = "assets/icons/icon-appbar.png";
  static const String _defaultLogoPath = "assets/icons/icon-appbar.png";

  // Localization
  static String dateLocal = "it_IT";

  //Colors
  static Color primaryColor = Colors.blue;
  static Color? secondaryColor;

  // Text
  static late TextTheme textTheme;
  static void initializeTextTheme(BuildContext context) {
    textTheme = createTextTheme(context, "Cousine", "Cousine");
  }

  // Dark mode
  static bool isDarkMode = false;

  static final ValueNotifier<ThemeData> currentTheme = ValueNotifier(
    MaterialTheme(
      textTheme: textTheme,
      primarySeed: primaryColor,
      secondarySeed: secondaryColor,
    ).light(),
  );

  static void updateTheme(Color newPrimary) {
    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    primaryColor = newPrimary;

    if (isDarkMode || brightness == Brightness.dark) {
      currentTheme.value = MaterialTheme(
        textTheme: textTheme,
        primarySeed: newPrimary,
        secondarySeed: secondaryColor,
      ).dark();
    } else {
      currentTheme.value = MaterialTheme(
        textTheme: textTheme,
        primarySeed: newPrimary,
        secondarySeed: secondaryColor,
      ).light();
    }
  }

  static void toggleDarkMode(bool darkMode) {
    isDarkMode = darkMode;

    updateTheme(primaryColor);
  }

  static Future<void> loadLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    logoPath = prefs.getString('logo_path') ?? _defaultLogoPath;
  }

  static Future<void> saveLogoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logo_path', path);
    logoPath = path;
  }

  static Future<void> resetLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logo_path');
    logoPath = _defaultLogoPath;
  }
}
