import 'dart:math';
import 'dart:ui';

import '../../../data/store/app_utils.dart';
import 'package:flutter/material.dart';

class TechnicalsPivotStrategyHelper {
  double multipler = 7.5;
  static late Map<String, String> keysmap;
  dynamic listData;
  late String valueToBeHighlighted;

  TechnicalsPivotStrategyHelper();

  void setListValues(dynamic list, String value) {
    listData = list;
    valueToBeHighlighted = value;
  }

  double _calculateneedlepositiontobehighlighted(
      Map<String, dynamic> listvalue) {
    return _getValueToBePlottedinchartInSameRange(listvalue);
  }

  double _getValueToBePlottedinchartInSameRange(
      Map<String, dynamic> listvalue) {
    final double pivot =
        AppUtils().doubleValue(listvalue['Pivot'].replaceAll(',', ''));
    final double minValue = listvalue.values
        .map((value) => AppUtils().doubleValue(value.replaceAll(',', '')))
        .toList()
        .reduce(min);
    final double maxValue = listvalue.values
        .map((value) => AppUtils().doubleValue(value.replaceAll(',', '')))
        .toList()
        .reduce(max);

    final double highlighted =
        AppUtils().doubleValue(valueToBeHighlighted.replaceAll(',', ''));

    if (highlighted < pivot) {
      return max(((highlighted - minValue) / (pivot - minValue) * 22) + 8, 8);
    } else if (highlighted > pivot) {
      return min(((highlighted - pivot) / (maxValue - pivot) * 22) + 30, 52);
    } else {
      return 30;
    }
  }

  String generateDivisorNumber(int lenghtvalue) {
    return 1.toString().padRight(lenghtvalue, '0');
  }

//Other helper methods
  String removedUnwantedChar(String value) {
    return value.replaceAll(RegExp(r'([^.0-9])'), '');
  }

  double getvalueaftertrimcharacters(String value) {
    value = removedUnwantedChar(value);
    if (value.isEmpty) {
      value = '0';
    }

    return AppUtils().doubleValue(value);
  }

  List<String> _getKeysFromResponse() {
    final List<String> listvalue = <String>[];

    if (listData is Map) {
      final Map<dynamic, dynamic> mapObject = listData;
      if (mapObject.keys.isNotEmpty) {
        if (mapObject.keys.length >= 2) {
          for (final dynamic item in mapObject.keys) {
            listvalue.add(item);
          }
        }
      }
    }
    return listvalue;
  }

  double getValueToBePointed() {
    final List<String> templst = _getKeysFromResponse();

    if (templst.isEmpty || listData[templst[1]] == null) {
      return 30.0;
    }
    keysmap = _generateMapForIndicator(templst);
    return _calculateneedlepositiontobehighlighted(listData);
  }

  Map<String, String> _generateMapForIndicator(List<dynamic> valuelst) {
    int start = 45, mid = 0, end = 5;
    final Map<String, String> internamap = <String, String>{};

    for (final String item in valuelst) {
      if (item.startsWith('S')) {
        internamap.addAll(<String, String>{'$start': item});
        start = start + 5;
      } else if (item.startsWith('P')) {
        internamap.addAll(<String, String>{'$mid': item});
        mid = mid + 5;
      } else if (item.startsWith('R')) {
        internamap.addAll(<String, String>{'$end': item});
        end = end + 5;
      }
    }

    return internamap;
  }

  static Map<String, String> getKeysListForIndicator() {
    return keysmap;
  }

  static double getAngel() {
    return 2 * pi / 60;
  }

  static Offset centerOffet(Size size) {
    return Offset(getWidthForRadius(size), size.height / 2);
  }

  static double centerRadius(Size size) {
    return min(getWidthForRadius(size), size.height);
  }

  static double getWidthForRadius(Size size) {
    return size.width / 2;
  }

  static double getheightForRadius(Size size) {
    return size.height / 2;
  }
}
