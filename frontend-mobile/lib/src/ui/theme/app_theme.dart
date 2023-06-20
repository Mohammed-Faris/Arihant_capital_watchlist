import '../../constants/app_constants.dart';
import 'dark_theme.dart';
import 'light_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData themeManager(String themeType) {
    switch (themeType) {
      case AppConstants.darkMode:
        return darkTheme();
      case AppConstants.lightMode:
        return lightTheme();
      default:
        return lightTheme();
    }
  }
}
