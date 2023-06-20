import 'package:acml/src/data/store/app_utils.dart';
import 'package:flutter/material.dart';

class AppColors {
  Color positiveColor = AppUtils().isLightTheme()
      ? const Color(0xFF35B350)
      : const Color(0xFF00C802);
  static const Color negativeColor = Color(0xFFC25E54);
  static const Color labelColor = Color(0xFF797979);
  static const Color primaryColor = Color(0xFF35B350);

  static Map<int, Color> calendarPrimaryColorSwatch = <int, Color>{
    50: const Color.fromRGBO(204, 255, 204, .1),
    100: const Color.fromRGBO(153, 255, 153, .2),
    200: const Color.fromRGBO(102, 255, 102, .3),
    300: const Color.fromRGBO(51, 255, 51, .4),
    400: const Color.fromRGBO(0, 255, 0, .5),
    500: const Color.fromRGBO(0, 255, 0, .6),
    600: const Color.fromRGBO(0, 255, 0, .7),
    700: const Color.fromRGBO(0, 204, 0, .8),
    800: const Color.fromRGBO(0, 153, 0, .9),
    900: const Color.fromRGBO(0, 153, 0, 1),
  };

  static Map<int, Color> calendarSecondaryColorSwatch = <int, Color>{
    50: const Color.fromRGBO(255, 204, 204, .1),
    100: const Color.fromRGBO(255, 153, 153, .2),
    200: const Color.fromRGBO(255, 102, 102, .3),
    300: const Color.fromRGBO(255, 51, 51, .4),
    400: const Color.fromRGBO(255, 0, 0, .5),
    500: const Color.fromRGBO(255, 0, 0, .6),
    600: const Color.fromRGBO(255, 0, 0, .7),
    700: const Color.fromRGBO(204, 0, 0, .8),
    800: const Color.fromRGBO(153, 0, 0, .9),
    900: const Color.fromRGBO(153, 0, 0, 1),
  };
}
