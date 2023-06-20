import 'package:flutter/material.dart';

import '../../constants/app_constants.dart';
import '../../data/store/app_store.dart';
import '../../data/store/app_utils.dart';
import '../styles/app_widget_size.dart';
import 'custom_text_widget.dart';

Widget buildErrorWidget(
  bool isError,
  String errorMessage,
  bool isSuccessMessage,
  BuildContext context,
) {
  final double textHeight = errorMessage == ''
      ? 5
      : errorMessage.textHeight(Theme.of(context).primaryTextTheme.titleLarge!,
          MediaQuery.of(context).size.width - AppWidgetSize.dimen_100);
  return Visibility(
    visible: isError || isSuccessMessage,
    child: Center(
      child: Container(
        padding: EdgeInsets.only(
          top: AppWidgetSize.dimen_7,
          left: 15.w,
          right: AppWidgetSize.dimen_15,
          bottom: AppWidgetSize.dimen_7,
        ),
        height: textHeight + AppWidgetSize.dimen_15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.w),
          color: isSuccessMessage
              ? Theme.of(context).snackBarTheme.backgroundColor
              : Theme.of(context).colorScheme.error,
        ),
        child: CustomTextWidget(
          errorMessage,
          Theme.of(context).primaryTextTheme.titleLarge!.copyWith(
                color: AppStore().getThemeData() == AppConstants.darkMode
                    ? !isSuccessMessage
                        ? const Color(0xFFFBF2F4)
                        : const Color(0xFFE1F4E5)
                    : !isSuccessMessage
                        ? const Color(0xFFB00020)
                        : const Color(0xFF00C802),
              ),
        ),
      ),
    ),
  );
}
