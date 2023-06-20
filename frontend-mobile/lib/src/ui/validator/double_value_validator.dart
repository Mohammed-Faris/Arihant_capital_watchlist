import 'package:flutter/services.dart';

class DoubleValueValidator extends TextInputFormatter {
  int decimalPoint;
  DoubleValueValidator({this.decimalPoint = 2});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    final double getDoubleValue =
        (value != '' && (value.indexOf('0') == 0)) ? double.parse(value) : 0;
    int selectionIndexFromTheRight = value.length - newValue.selection.end;
    if (value.split('.').length > 2 || (getDoubleValue > 9999999999.99)) {
      value = oldValue.text;
      selectionIndexFromTheRight = value.length - oldValue.selection.end;
    }

    final bool checkFloat =
        value.contains('.') && (value.split('.')[1]).isNotEmpty;
    if (checkFloat) {
      final String split1 = value.split('.')[0];
      final String split2 = value.split('.')[1];

      value =
          '$split1.${split2.length > decimalPoint ? split2.substring(0, decimalPoint) : split2}';

      if (getDoubleValue > 9999999999.99) {
        value = oldValue.text;
        selectionIndexFromTheRight = value.length - oldValue.selection.end;
      }
    }
    return TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(
        offset: value.length - selectionIndexFromTheRight,
      ),
    );
  }
}
