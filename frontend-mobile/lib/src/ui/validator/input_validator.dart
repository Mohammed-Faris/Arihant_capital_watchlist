import 'double_value_validator.dart';
import 'password_validator.dart';
import 'watchlist_name_text_formatter.dart';
import 'package:flutter/services.dart';
import 'dob_validator.dart';

class InputValidator {
  static List<TextInputFormatter> username = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp('[a-zA-Za-z0-9.,@!#\$%^&*()_+]')),
    // FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),

    LengthLimitingTextInputFormatter(50),
  ];

  static List<TextInputFormatter> loginPassword = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(16),
    FilteringTextInputFormatter.allow(
        RegExp('[a-zA-Z0-9.!@#\$%^&*()^_+;.?":{}|<>]')),
    PasswordValidator()
  ];
  static List<TextInputFormatter> dob = <TextInputFormatter>[
    LengthLimitingTextInputFormatter(10),
    FilteringTextInputFormatter.allow(RegExp("[0-9/]")),
    DateFormatter()
  ];
  static RegExp dateRegPatten = RegExp('([0-9]{2})/([0-9]{2})/([0-9]{4})');

  static List<TextInputFormatter> qtyRegEx = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    FilteringTextInputFormatter.allow(RegExp('^[1-9].*')),
    LengthLimitingTextInputFormatter(10),
    // DateFormatter()
  ];
  static List<TextInputFormatter> dateRegEx = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(8),
    // DateFormatter()
  ];
  static List<TextInputFormatter> mobileNumberRegEx = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
    // DateFormatter()
  ];
  static List<TextInputFormatter> qtyValidator = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(10),
  ];

  static List<TextInputFormatter> priceValidator = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(9),
    FilteringTextInputFormatter.allow(RegExp('^[1-9].*')),
  ];

  static List<TextInputFormatter> watchlistName = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
    WatchlistNameTextFormatter()
  ];

  static List<TextInputFormatter> doubleValidator(decimalPoint) {
    return <TextInputFormatter>[
      // FilteringTextInputFormatter.allow(RegExp(r'^\d{0,10}(\.\d{0,2})?')),
      FilteringTextInputFormatter.allow(RegExp(r'^\d{0,10}(\.\d*)?')),
      DoubleValueValidator(decimalPoint: decimalPoint)
    ];
  }

  static List<TextInputFormatter> intValidator() {
    return <TextInputFormatter>[
      // FilteringTextInputFormatter.allow(RegExp(r'^\d{0,10}(\.\d{0,2})?')),
      FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
    ];
  }

  static List<TextInputFormatter> signedDoubleValidator(decimalPoint) {
    return <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'^[-,0-9].*')),
      FilteringTextInputFormatter.deny(RegExp(r',')),
      DoubleValueValidator(decimalPoint: decimalPoint)
    ];
  }

  static List<TextInputFormatter> doubleFormatter(int decimalDigits,
      {int maxLength = -1}) {
    return [
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      if (!maxLength.isNegative) LengthLimitingTextInputFormatter(maxLength),
    ];
  }

  static List<TextInputFormatter> alertName = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp('[A-Za-z]')),
    TextLengthFormatter(10)
  ];

  static List<TextInputFormatter> ipoUPIRestrict = <TextInputFormatter>[
    // FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
    FilteringTextInputFormatter.deny(RegExp(r'\s')),
  ];

  static List<TextInputFormatter> numberRegEx = <TextInputFormatter>[
    FilteringTextInputFormatter.digitsOnly
  ];

  // DateFormatter()
  static List<TextInputFormatter> searchSymbol = <TextInputFormatter>[
    FilteringTextInputFormatter.allow(RegExp('[a-zA-Z&.0-9 ]')),
  ];
}

class TextLengthFormatter extends TextInputFormatter {
  final int maxLength;
  TextLengthFormatter(this.maxLength);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String value = newValue.text;
    bool isValid = value.length <= maxLength;
    if (!isValid) {
      value = oldValue.text;
    }

    return TextEditingValue(
        text: value,
        selection: isValid ? newValue.selection : oldValue.selection);
  }
}
