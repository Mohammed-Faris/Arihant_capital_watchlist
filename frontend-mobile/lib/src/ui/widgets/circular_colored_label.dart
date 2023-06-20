import 'package:flutter/material.dart';

import '../styles/app_widget_size.dart';

class CircularLabelWidget extends StatelessWidget {
  final String itemName;
  final bool isError;
  const CircularLabelWidget(
      {super.key, required this.itemName, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.w),
        decoration: BoxDecoration(
            color: isError
                ? Theme.of(context).colorScheme.error.withOpacity(0.5)
                : Theme.of(context).snackBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(
              AppWidgetSize.dimen_20,
            ),
            border: Border.all(
              width: AppWidgetSize.dimen_1,
              color: isError
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).primaryColor,
            )),
        child: RichText(
            text: TextSpan(
                style:
                    Theme.of(context).primaryTextTheme.headlineMedium!.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isError
                              ? Theme.of(context).colorScheme.errorContainer
                              : Theme.of(context).primaryColor,
                          fontSize: 14.w,
                        ),
                children: [
              TextSpan(
                text: itemName.toString(),
              ),
            ])));
  }
}
