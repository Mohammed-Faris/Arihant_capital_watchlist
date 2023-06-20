import 'package:flutter/services.dart';

class PasswordValidator extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    bool isValid = value.length <= 16;
    if (!isValid) {
      value = oldValue.text;
    }

    return TextEditingValue(
        text: value,
        selection: isValid ? newValue.selection : oldValue.selection);
  }
}
