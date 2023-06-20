import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

class IndianRupeeFormatter extends NumberInputFormatter {
  static final NumberFormat _formatter = NumberFormat.decimalPattern();

  final FilteringTextInputFormatter _decimalFormatter;
  final String _decimalSeparator;
  final RegExp _decimalRegex;

  final NumberFormat? formatter;
  final bool allowFraction;

  IndianRupeeFormatter({this.formatter, this.allowFraction = false})
      : _decimalSeparator = (formatter ?? _formatter).symbols.DECIMAL_SEP,
        _decimalRegex = RegExp(allowFraction
            ? '[0-9]+([${(formatter ?? _formatter).symbols.DECIMAL_SEP}])?'
            : r'\d+'),
        _decimalFormatter = FilteringTextInputFormatter.allow(RegExp(
            allowFraction
                ? '[0-9]+([${(formatter ?? _formatter).symbols.DECIMAL_SEP}])?'
                : r'\d+'));

  @override
  String _formatPattern(String? digits) {
    if (digits == null || digits.isEmpty) return '';

    num number;
    if (allowFraction) {
      String decimalDigits = digits;
      if (_decimalSeparator != '.') {
        decimalDigits = digits.replaceFirst(RegExp(_decimalSeparator), '.');
      }
      if (digits.toString().contains('.')) {
        List<String> data = digits.toString().split('.');
        if (data.length == 3) {
          digits = digits.substring(0, digits.length - 1);
          decimalDigits = decimalDigits.substring(0, decimalDigits.length - 1);
        }
      }

      number = double.tryParse(decimalDigits) ?? 0.00;
    } else {
      number = int.tryParse(digits) ?? 0;
    }

    var result = (formatter ?? _formatter).format(number);

    if (digits.toString().contains('.0')) {
      result = '$result.0';
    }

    if (allowFraction && digits.endsWith(_decimalSeparator)) {
      return '$result$_decimalSeparator';
    }

    if (digits.toString().contains('.')) {
      List<String> value = digits.toString().split('.');
      if (value.last.isNotEmpty) {
        if (value.last.length == 2) {
          if (value.last.contains('0')) {
            result = '${result.split('.').first}.${value.last}';
          }

          return result;
        } else if (value.last.length > 2) {
          result = '${result.split('.').first}.${value.last.substring(0, 2)}';
          return double.tryParse(result)?.toStringAsFixed(2) ?? result;
        }
      }
    }

    return result;
  }

  @override
  TextEditingValue _formatValue(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return _decimalFormatter.formatEditUpdate(oldValue, newValue);
  }

  @override
  bool _isUserInput(String s) {
    return s == _decimalSeparator || _decimalRegex.firstMatch(s) != null;
  }
}

abstract class NumberInputFormatter extends TextInputFormatter {
  TextEditingValue? _lastNewValue;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.split(".").length > 2) {
      return oldValue;
    }
    if (newValue.text == _lastNewValue?.text) {
      return newValue;
    }
    _lastNewValue = newValue;

    newValue = _formatValue(oldValue, newValue);

    int selectionIndex = newValue.selection.end;

    final newText = _formatPattern(newValue.text);
    int insertCount = 0;
    int inputCount = 0;
    for (int i = 0; i < newText.length && inputCount < selectionIndex; i++) {
      final character = newText[i];
      if (_isUserInput(character)) {
        inputCount++;
      } else {
        insertCount++;
      }
    }

    selectionIndex += insertCount;
    selectionIndex = math.min(selectionIndex, newText.length);

    if (selectionIndex - 1 >= 0 &&
        selectionIndex - 1 < newText.length &&
        !_isUserInput(newText[selectionIndex - 1])) {
      selectionIndex--;
    }

    return newValue.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: selectionIndex),
        composing: TextRange.empty);
  }

  bool _isUserInput(String s);

  String _formatPattern(String digits);

  TextEditingValue _formatValue(
      TextEditingValue oldValue, TextEditingValue newValue);
}
