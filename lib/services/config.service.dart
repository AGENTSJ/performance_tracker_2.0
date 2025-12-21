import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:performance_tracker/constants.ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConfigService {
  static const _keyDarkMode = 'isDarkMode';
  final ValueNotifier<bool> darkThemeNotifier = ValueNotifier(false);

  Future<void> setDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, isDark);
    applyTheme(isDarkMode: isDark);
  }

  Future<bool> isDarkmode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false; // default = light
  }
  setUpTheme()async
  {
    var isDark = await this.isDarkmode();
    print(isDark);
    applyTheme(isDarkMode: isDark);
  }
  void applyTheme({required bool isDarkMode}) {
    darkThemeNotifier.value = isDarkMode;
    if (isDarkMode) {
      PRIMARY = const Color(0xff2C5C53);
      BACKGROUND = const Color(0xFF181A1B);
      SURFACE = const Color(0xFF232726);
      SURFACE2 = const Color.fromARGB(255, 44, 49, 48);
      CONT_BACKGROUND = const Color(0xFF222524);
      TEXT_PRIMARY = const Color(0xFFF3F3F3);
      TEXT_SECONDARY = const Color.fromARGB(255, 184, 206, 206);
      TEXT_TERTIARY = const Color.fromARGB(255, 108, 108, 108);
      BORDER_PRIMARY = const Color.fromARGB(255, 88, 88, 88);
      BORDER_SECONDARY = const Color.fromARGB(255, 60, 60, 60);
    } else {
      PRIMARY = const Color(0xff3E8E7E);
      BACKGROUND = const Color.fromARGB(255, 243, 243, 243);
      SURFACE = const Color(0xFFF5FAF6);
      SURFACE2 = const Color.fromARGB(255, 255, 255, 255);
      CONT_BACKGROUND = Colors.white;
      TEXT_PRIMARY = const Color(0xff1E1E1E);
      TEXT_SECONDARY = const Color(0xff6E7C7C);
      TEXT_TERTIARY = const Color.fromARGB(255, 108, 108, 108);
      BORDER_PRIMARY = Colors.grey.shade300;
      BORDER_SECONDARY = Colors.grey.shade100;
    }
  }
}
