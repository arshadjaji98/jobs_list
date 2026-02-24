import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  ThemeService._();

  static const _prefKey = 'isDarkMode';
  static final ValueNotifier<ThemeMode> modeNotifier =
      ValueNotifier(ThemeMode.light);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefKey) ?? false;
    modeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static bool get isDark => modeNotifier.value == ThemeMode.dark;

  static Future<void> setDark(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, isDark);
    modeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static Future<void> toggle() async => setDark(!isDark);
}
