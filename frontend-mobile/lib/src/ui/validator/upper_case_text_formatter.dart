import 'package:flutter/services.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final String value = newValue.text;

    return TextEditingValue(
      text: value.toUpperCase(),
      selection: TextSelection.collapsed(
        offset: value.length,
      ),
    );
  }
}
