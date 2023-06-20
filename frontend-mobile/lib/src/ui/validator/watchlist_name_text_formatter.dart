import 'package:flutter/services.dart';

class WatchlistNameTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    bool isValid = value.length <= 15;
    if (!isValid) {
      value = oldValue.text;
    }

    return TextEditingValue(
        text: value,
        selection: isValid ? newValue.selection : oldValue.selection);
  }
}
