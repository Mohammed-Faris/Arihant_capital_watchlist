import '../../constants/app_constants.dart';
import 'custom_text_widget.dart';
import 'package:flutter/material.dart';

Widget getRupeeSymbol(
  BuildContext context,
  TextStyle textStyle,
) {
  return CustomTextWidget(
    AppConstants.rupeeSymbol,
    textStyle,
  );
}
